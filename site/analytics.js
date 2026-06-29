// cliPet — analytics site (tunnel de vente). Anonyme, sans PII.
// Étapes : site_visit → site_pricing_view → site_download_click.
(function () {
  "use strict";
  var API = "https://clipet.sharik.fr/api/events";

  // Identifiant anonyme stable (aucune donnée personnelle).
  var anonId;
  try {
    anonId = localStorage.getItem("clipet.aid");
    if (!anonId) {
      anonId = (crypto.randomUUID ? crypto.randomUUID()
        : String(Date.now()) + Math.random().toString(16).slice(2));
      localStorage.setItem("clipet.aid", anonId);
    }
  } catch (e) { anonId = null; }

  function track(name, props) {
    try {
      var body = JSON.stringify({ name: name, source: "site", anonId: anonId, props: props || null });
      if (navigator.sendBeacon) navigator.sendBeacon(API, new Blob([body], { type: "application/json" }));
      else fetch(API, { method: "POST", headers: { "Content-Type": "application/json" }, body: body, keepalive: true });
    } catch (e) {}
  }

  // 0) Téléchargement réel : on passe l'anonId au endpoint /api/download
  //    (qui logge puis redirige vers le .dmg) pour compter les downloads distincts.
  try {
    document.querySelectorAll('a[href*="/api/download"]').forEach(function (a) {
      var u = new URL(a.getAttribute("href"), location.origin);
      if (anonId) u.searchParams.set("aid", anonId);
      a.setAttribute("href", u.pathname + u.search);
    });
  } catch (e) {}

  // 1) Visite
  track("site_visit", { path: location.pathname, ref: document.referrer || null });

  // 2) Vue de la section pricing (une seule fois)
  var pricing = document.getElementById("pricing");
  if (pricing && "IntersectionObserver" in window) {
    var seen = false;
    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (en) {
        if (en.isIntersecting && !seen) { seen = true; track("site_pricing_view"); io.disconnect(); }
      });
    }, { threshold: 0.4 });
    io.observe(pricing);
  }

  // 3) Clic sur un CTA de téléchargement (boutons primaires + bouton de nav)
  document.addEventListener("click", function (e) {
    var el = e.target.closest && e.target.closest(".btn-primary, .btn-nav, [data-i18n='price.btn']");
    if (el) {
      var label = (el.textContent || "").trim().slice(0, 40);
      track("site_download_click", { label: label });
    }
  }, true);
})();
