// cliPet marketplace API
// ------------------------------------------------------------------
// Public endpoints (consommés par l'app macOS) :
//   GET  /api/pets            → liste des pets publiés (léger : preview)
//   GET  /api/pets/:id        → pet complet (frames + palette)
//   POST /api/pets            → publier un pet
//   POST /api/pets/:id/download → +1 téléchargement
//   POST /api/pets/:id/report   → signaler un pet
//
// Admin endpoints (dashboard, protégés par nginx auth_request → SSO Marvin) :
//   GET  /api/admin/pets?status=live|removed   → liste + nb de signalements
//   GET  /api/admin/reports                     → signalements récents
//   POST /api/admin/pets/:id/remove             → retirer (modération)
//   POST /api/admin/pets/:id/restore            → republier
//
// La sécurité admin est assurée AU NIVEAU NGINX (auth_request). Le process
// n'écoute que sur 127.0.0.1, donc /api/admin n'est joignable que via nginx.
'use strict';

const express = require('express');
const cors = require('cors');
const Database = require('better-sqlite3');
const crypto = require('crypto');
const path = require('path');

const PORT = process.env.PORT || 8090;
const DB_PATH = process.env.DB_PATH || path.join(__dirname, 'data', 'marketplace.db');

require('fs').mkdirSync(path.dirname(DB_PATH), { recursive: true });
const db = new Database(DB_PATH);
db.pragma('journal_mode = WAL');
db.exec(`
  CREATE TABLE IF NOT EXISTS pets (
    id         TEXT PRIMARY KEY,
    name       TEXT NOT NULL,
    author     TEXT NOT NULL DEFAULT 'anon',
    data       TEXT NOT NULL,            -- JSON { frames, palette }
    preview    TEXT NOT NULL,            -- JSON { frame, palette }
    downloads  INTEGER NOT NULL DEFAULT 0,
    reports    INTEGER NOT NULL DEFAULT 0,
    status     TEXT NOT NULL DEFAULT 'live',  -- live | removed
    created_at TEXT NOT NULL
  );
  CREATE TABLE IF NOT EXISTS reports (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    pet_id     TEXT NOT NULL,
    reason     TEXT,
    created_at TEXT NOT NULL
  );
  CREATE INDEX IF NOT EXISTS idx_pets_status ON pets(status, created_at DESC);
`);

const app = express();
app.use(cors());
app.use(express.json({ limit: '512kb' }));

// --- Rate limiting basique en mémoire (publications + signalements) ---
const hits = new Map();
function rateLimit(key, max, windowMs) {
  const now = Date.now();
  const rec = hits.get(key) || { n: 0, reset: now + windowMs };
  if (now > rec.reset) { rec.n = 0; rec.reset = now + windowMs; }
  rec.n++; hits.set(key, rec);
  return rec.n <= max;
}
const ipOf = (req) => req.headers['x-real-ip'] || req.ip || 'unknown';

// --- Validation d'un pet soumis ---
function validatePet(body) {
  if (!body || typeof body !== 'object') return 'invalid body';
  const name = String(body.name || '').trim();
  if (name.length < 1 || name.length > 40) return 'name must be 1–40 chars';
  const frames = body.frames;
  if (!frames || typeof frames !== 'object' || Array.isArray(frames)) return 'frames required';
  const keys = Object.keys(frames);
  if (keys.length < 1 || keys.length > 60) return 'frames count out of range';
  for (const k of keys) {
    const rows = frames[k];
    if (!Array.isArray(rows) || rows.length < 1 || rows.length > 80) return `frame ${k} invalid`;
    for (const row of rows) {
      if (typeof row !== 'string' || row.length > 80) return `frame ${k} row invalid`;
    }
  }
  const palette = body.palette || {};
  if (typeof palette !== 'object') return 'palette invalid';
  if (JSON.stringify(frames).length > 200000) return 'pet too large';
  return null;
}

function previewOf(frames, palette) {
  const frame = frames.idle1 || frames.idle || frames[Object.keys(frames)[0]] || [];
  return { frame, palette };
}

// ===================== PUBLIC =====================

app.get('/api/pets', (req, res) => {
  const limit = Math.min(parseInt(req.query.limit) || 50, 100);
  const offset = parseInt(req.query.offset) || 0;
  const rows = db.prepare(
    `SELECT id, name, author, downloads, created_at, preview
       FROM pets WHERE status='live'
       ORDER BY created_at DESC LIMIT ? OFFSET ?`
  ).all(limit, offset);
  res.json(rows.map(r => ({
    id: r.id, name: r.name, author: r.author,
    downloads: r.downloads, createdAt: r.created_at,
    preview: JSON.parse(r.preview),
  })));
});

app.get('/api/pets/:id', (req, res) => {
  const r = db.prepare(`SELECT * FROM pets WHERE id=? AND status='live'`).get(req.params.id);
  if (!r) return res.status(404).json({ error: 'not found' });
  const data = JSON.parse(r.data);
  res.json({
    id: r.id, name: r.name, author: r.author, downloads: r.downloads,
    createdAt: r.created_at, frames: data.frames, palette: data.palette,
  });
});

app.post('/api/pets', (req, res) => {
  if (!rateLimit('pub:' + ipOf(req), 10, 3600_000))
    return res.status(429).json({ error: 'too many submissions, try later' });
  const err = validatePet(req.body);
  if (err) return res.status(400).json({ error: err });

  const id = crypto.randomUUID();
  const name = String(req.body.name).trim();
  const author = String(req.body.author || 'anon').trim().slice(0, 40) || 'anon';
  const frames = req.body.frames;
  const palette = req.body.palette || {};
  const data = JSON.stringify({ frames, palette });
  const preview = JSON.stringify(previewOf(frames, palette));
  db.prepare(
    `INSERT INTO pets (id, name, author, data, preview, created_at)
     VALUES (?, ?, ?, ?, ?, ?)`
  ).run(id, name, author, data, preview, new Date().toISOString());
  res.status(201).json({ id });
});

app.post('/api/pets/:id/download', (req, res) => {
  db.prepare(`UPDATE pets SET downloads = downloads + 1 WHERE id=? AND status='live'`)
    .run(req.params.id);
  res.json({ ok: true });
});

app.post('/api/pets/:id/report', (req, res) => {
  if (!rateLimit('rep:' + ipOf(req), 20, 3600_000))
    return res.status(429).json({ error: 'too many reports' });
  const pet = db.prepare(`SELECT id FROM pets WHERE id=?`).get(req.params.id);
  if (!pet) return res.status(404).json({ error: 'not found' });
  const reason = String((req.body && req.body.reason) || '').slice(0, 200);
  db.prepare(`INSERT INTO reports (pet_id, reason, created_at) VALUES (?, ?, ?)`)
    .run(req.params.id, reason, new Date().toISOString());
  db.prepare(`UPDATE pets SET reports = reports + 1 WHERE id=?`).run(req.params.id);
  res.json({ ok: true });
});

// ===================== ADMIN (protégé par nginx auth_request) =====================

app.get('/api/admin/pets', (req, res) => {
  const status = ['live', 'removed'].includes(req.query.status) ? req.query.status : 'live';
  const rows = db.prepare(
    `SELECT id, name, author, downloads, reports, status, created_at, preview
       FROM pets WHERE status=? ORDER BY reports DESC, created_at DESC`
  ).all(status);
  res.json(rows.map(r => ({ ...r, preview: JSON.parse(r.preview) })));
});

app.get('/api/admin/reports', (req, res) => {
  const rows = db.prepare(
    `SELECT r.id, r.pet_id, r.reason, r.created_at, p.name AS pet_name
       FROM reports r LEFT JOIN pets p ON p.id = r.pet_id
       ORDER BY r.created_at DESC LIMIT 200`
  ).all();
  res.json(rows);
});

app.post('/api/admin/pets/:id/remove', (req, res) => {
  db.prepare(`UPDATE pets SET status='removed' WHERE id=?`).run(req.params.id);
  res.json({ ok: true });
});

app.post('/api/admin/pets/:id/restore', (req, res) => {
  db.prepare(`UPDATE pets SET status='live' WHERE id=?`).run(req.params.id);
  res.json({ ok: true });
});

app.get('/api/health', (_req, res) => res.json({ ok: true }));

app.listen(PORT, '127.0.0.1', () => console.log(`clipet-api on 127.0.0.1:${PORT}`));
