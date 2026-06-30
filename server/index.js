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

// Géolocalisation par IP (base embarquée, hors-ligne, sans PII stockée :
// on ne garde que le code pays ISO, jamais l'IP). Optionnel : si le module
// n'est pas installé, on dégrade proprement (country=null).
let geoip = null;
try { geoip = require('geoip-lite'); } catch (e) { /* optionnel */ }

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
  CREATE TABLE IF NOT EXISTS events (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    name       TEXT NOT NULL,            -- ex. site_visit, app_paywall_shown
    source     TEXT NOT NULL DEFAULT 'app',  -- site | app
    anon_id    TEXT,                     -- identifiant anonyme stable (pas de PII)
    props      TEXT,                     -- JSON libre
    created_at TEXT NOT NULL
  );
  CREATE INDEX IF NOT EXISTS idx_events_name ON events(name, created_at DESC);
  CREATE INDEX IF NOT EXISTS idx_events_created ON events(created_at DESC);
`);
// Migration : colonne pays (ISO-3166-1 alpha-2) ajoutée à l'ingestion.
try { db.exec(`ALTER TABLE events ADD COLUMN country TEXT`); } catch (e) { /* déjà présente */ }

// Étapes du tunnel de vente (compte de visiteurs anonymes distincts par étape).
const SITE_FUNNEL = [
  { event: 'site_visit',          label: 'Visit' },
  { event: 'site_pricing_view',   label: 'Viewed pricing' },
  { event: 'site_download_click', label: 'Clicked download' },
  { event: 'site_download',       label: 'Downloaded' },
];
const APP_FUNNEL = [
  { event: 'app_first_launch',  label: 'First launch' },
  { event: 'app_paywall_shown', label: 'Saw paywall' },
  { event: 'app_buy_click',     label: 'Clicked buy' },
  { event: 'app_activated',     label: 'Activated licence' },
];

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

// Pays d'origine d'une requête (code ISO) — résolu à l'ingestion depuis l'IP,
// jamais l'IP elle-même. Renvoie null si indéterminé.
function countryOf(req) {
  if (!geoip) return null;
  const raw = req.headers['x-real-ip'] || req.headers['x-forwarded-for'] || req.ip || '';
  const ip = String(raw).split(',')[0].trim();
  if (!ip) return null;
  const g = geoip.lookup(ip);
  return (g && g.country) ? g.country : null;
}

// Regroupe un referrer brut en source de trafic lisible.
function classifyRef(ref) {
  if (!ref) return 'Direct';
  let h;
  try { h = new URL(ref).hostname.replace(/^www\./, '').toLowerCase(); }
  catch (e) { return 'Direct'; }
  if (/google\./.test(h))                 return 'Google';
  if (/bing\./.test(h))                   return 'Bing';
  if (/duckduckgo/.test(h))               return 'DuckDuckGo';
  if (/(^|\.)(t\.co|twitter\.com|x\.com)$/.test(h) || /twitter|x\.com/.test(h)) return 'X / Twitter';
  if (/reddit/.test(h))                   return 'Reddit';
  if (/(facebook|instagram|fb\.)/.test(h)) return 'Meta';
  if (/(youtube|youtu\.be)/.test(h))      return 'YouTube';
  if (/(linkedin|lnkd)/.test(h))          return 'LinkedIn';
  if (/(news\.ycombinator|ycombinator)/.test(h)) return 'Hacker News';
  if (/github/.test(h))                   return 'GitHub';
  if (/producthunt/.test(h))              return 'Product Hunt';
  return h;
}

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

// ===================== ANALYTICS =====================

// Ingestion publique (site + app). Accepte un event ou un lot {events:[...]}.
const insertEvent = db.prepare(
  `INSERT INTO events (name, source, anon_id, props, country, created_at) VALUES (?, ?, ?, ?, ?, ?)`
);
app.post('/api/events', (req, res) => {
  if (!rateLimit('ev:' + ipOf(req), 600, 3600_000))
    return res.status(429).json({ error: 'rate limited' });
  const now = new Date().toISOString();
  const country = countryOf(req);
  const batch = Array.isArray(req.body && req.body.events) ? req.body.events : [req.body];
  const tx = db.transaction((items) => {
    for (const e of items) {
      if (!e || typeof e.name !== 'string') continue;
      const name = e.name.slice(0, 60);
      const source = (e.source === 'site' || e.source === 'app') ? e.source : 'app';
      const anon = e.anonId ? String(e.anonId).slice(0, 64) : null;
      const props = e.props ? JSON.stringify(e.props).slice(0, 2000) : null;
      insertEvent.run(name, source, anon, props, country, now);
    }
  });
  try { tx(batch); res.json({ ok: true }); }
  catch { res.status(400).json({ error: 'bad payload' }); }
});

// Téléchargement réel du binaire : on enregistre l'event puis on redirige
// vers le fichier statique (servi par nginx). C'est le compteur fiable de
// téléchargements (≠ site_download_click qui n'est qu'un clic sur le CTA).
app.get('/api/download', (req, res) => {
  const file = (req.query.file === 'zip') ? 'cliPet.zip' : 'cliPet.dmg';
  // On redirige TOUJOURS ; le log est rate-limité pour éviter le spam.
  if (rateLimit('dl:' + ipOf(req), 60, 3600_000)) {
    const aid = req.query.aid ? String(req.query.aid).slice(0, 64) : null;
    try {
      insertEvent.run('site_download', 'site', aid, JSON.stringify({ file }), countryOf(req), new Date().toISOString());
    } catch (e) { /* ne jamais bloquer le téléchargement */ }
  }
  res.redirect(302, '/download/' + file);
});

// ----- Admin (protégé par nginx auth_request → SSO) -----

function funnelCounts(steps, since) {
  const q = db.prepare(
    `SELECT COUNT(DISTINCT COALESCE(anon_id, id)) AS c FROM events WHERE name=? AND created_at>=?`
  );
  return steps.map(s => ({ ...s, count: q.get(s.event, since).c }));
}

app.get('/api/admin/analytics/overview', (req, res) => {
  const days = Math.min(parseInt(req.query.days) || 30, 365);
  const since = new Date(Date.now() - days * 86400_000).toISOString();

  const events = db.prepare(
    `SELECT name, COUNT(*) AS count FROM events WHERE created_at>=?
       GROUP BY name ORDER BY count DESC LIMIT 50`
  ).all(since);

  // Évolution quotidienne du site : pages vues (toutes les visites) +
  // visiteurs uniques (anon_id distincts). Les jours sans donnée sont
  // remplis à 0 pour une courbe continue.
  const dailyRaw = db.prepare(
    `SELECT substr(created_at,1,10) AS date,
            SUM(CASE WHEN name='site_visit' THEN 1 ELSE 0 END) AS pageviews,
            COUNT(DISTINCT CASE WHEN name='site_visit' THEN anon_id END) AS visitors
       FROM events WHERE created_at>=? GROUP BY date`
  ).all(since);
  const dailyMap = Object.fromEntries(dailyRaw.map(r => [r.date, r]));
  const daily = [];
  for (let i = days - 1; i >= 0; i--) {
    const dt = new Date(Date.now() - i * 86400_000).toISOString().slice(0, 10);
    const r = dailyMap[dt];
    daily.push({ date: dt, pageviews: r ? r.pageviews : 0, visitors: r ? r.visitors : 0 });
  }

  const totals = db.prepare(
    `SELECT COUNT(*) AS events, COUNT(DISTINCT anon_id) AS visitors FROM events WHERE created_at>=?`
  ).get(since);

  // ---- KPIs produit (site + app) ----
  // Visiteurs distincts du site (anon_id stable, source=site).
  const siteVisitors = db.prepare(
    `SELECT COUNT(DISTINCT anon_id) AS c FROM events
       WHERE source='site' AND anon_id IS NOT NULL AND created_at>=?`
  ).get(since).c;
  // Pages vues = total des visites (pas dédupliqué).
  const pageViews = db.prepare(
    `SELECT COUNT(*) AS c FROM events WHERE name='site_visit' AND created_at>=?`
  ).get(since).c;
  // Clics sur un CTA de download (intention).
  const downloadClicks = db.prepare(
    `SELECT COUNT(DISTINCT COALESCE(anon_id, id)) AS c FROM events
       WHERE name='site_download_click' AND created_at>=?`
  ).get(since).c;
  // Téléchargements réels du .dmg (passage par /api/download).
  const downloads = db.prepare(
    `SELECT COUNT(DISTINCT COALESCE(anon_id, id)) AS c FROM events
       WHERE name='site_download' AND created_at>=?`
  ).get(since).c;
  // Installs réels = premiers lancements distincts de l'app.
  const appInstalls = db.prepare(
    `SELECT COUNT(DISTINCT COALESCE(anon_id, id)) AS c FROM events
       WHERE name='app_first_launch' AND created_at>=?`
  ).get(since).c;
  // Achats = licences activées distinctes.
  const purchases = db.prepare(
    `SELECT COUNT(DISTINCT COALESCE(anon_id, id)) AS c FROM events
       WHERE name='app_activated' AND created_at>=?`
  ).get(since).c;
  // Temps moyen passé sur le site (en secondes). Mesuré côté site via
  // l'event `site_leave` (props.dwell). On filtre les valeurs aberrantes.
  const dwellRow = db.prepare(
    `SELECT AVG(d) AS avg, COUNT(*) AS n FROM (
       SELECT CAST(json_extract(props,'$.dwell') AS REAL) AS d
         FROM events
        WHERE name='site_leave' AND created_at>=?
          AND json_extract(props,'$.dwell') IS NOT NULL
     ) WHERE d > 0 AND d < 7200`
  ).get(since);
  const avgDwellSec = (dwellRow && dwellRow.avg) ? Math.round(dwellRow.avg) : 0;
  const dwellSamples = (dwellRow && dwellRow.n) ? dwellRow.n : 0;

  const pct = (a, b) => (b > 0 ? Math.round((a / b) * 1000) / 10 : 0);
  const kpis = {
    siteVisitors,
    pageViews,
    downloadClicks,
    downloads,
    appInstalls,
    purchases,
    avgDwellSec,                                             // temps moyen sur le site (s)
    convVisitDownload: pct(downloads, siteVisitors),         // visite → téléchargement réel (site)
    convInstallPurchase: pct(purchases, appInstalls),        // install → achat (app)
  };

  // ---- Provenance des visiteurs (sources de trafic) ----
  const refRows = db.prepare(
    `SELECT json_extract(props,'$.ref') AS ref, COUNT(*) AS c
       FROM events WHERE name='site_visit' AND created_at>=? GROUP BY ref`
  ).all(since);
  const refAgg = {};
  for (const r of refRows) {
    const src = classifyRef(r.ref);
    refAgg[src] = (refAgg[src] || 0) + r.c;
  }
  const referrers = Object.entries(refAgg)
    .map(([source, count]) => ({ source, count }))
    .sort((a, b) => b.count - a.count)
    .slice(0, 12);

  // ---- Pays des visiteurs (uniques par pays) ----
  const countries = db.prepare(
    `SELECT COALESCE(NULLIF(country,''),'??') AS country, COUNT(DISTINCT anon_id) AS visitors
       FROM events
      WHERE source='site' AND anon_id IS NOT NULL AND created_at>=?
      GROUP BY country ORDER BY visitors DESC LIMIT 12`
  ).all(since);

  res.json({
    days,
    totals,
    kpis,
    dwell: { avgSec: avgDwellSec, samples: dwellSamples },
    funnels: {
      site: funnelCounts(SITE_FUNNEL, since),
      app:  funnelCounts(APP_FUNNEL, since),
    },
    events,
    daily,
    referrers,
    countries,
  });
});

app.get('/api/health', (_req, res) => res.json({ ok: true }));

app.listen(PORT, '127.0.0.1', () => console.log(`clipet-api on 127.0.0.1:${PORT}`));
