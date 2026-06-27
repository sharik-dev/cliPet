# CLAUDE.md — Site vitrine cliPet

Guide de style et de structure pour la **landing page de cliPet**, un site statique HTML/CSS
hébergé dans ce dossier (`site/`). Le style et le funnel s'inspirent directement de
[vibeisland.app](https://vibeisland.app/) — un site qui convertit bien : esthétique pixel-art,
thème sombre, hiérarchie ultra-claire, CTA répétés.

> **Règle d'or** : pixel-art assumé, mais lisible. Police pixel UNIQUEMENT pour les titres et le
> logo ; le corps de texte reste en system-ui pour rester confortable à lire.

---

## L'app à présenter

**cliPet** — un *desktop pet* macOS natif (Swift / AppKit, vit dans la barre de menus).
Un chat en pixel-art se balade en bas de ton écran : il marche, court, dort, poursuit le curseur,
joue avec une pelote. Inclut aussi un **gestionnaire de presse-papier** (historique du clipboard).

- Plateforme : **macOS** (Apple Silicon + Intel), app native Swift, ultra-légère.
- Pas d'Electron, pas de cloud, 100 % local.
- Personnalisable : skins, éditeur de sprites, sons.

Ton du copy : chaleureux, joueur, un brin nostalgique (Tamagotchi / pixel des années 90),
mais qui insiste sur le côté **natif, léger, local**.

---

## Design tokens (relevés sur vibeisland.app)

Toujours déclarer ces variables dans `:root` et ne jamais hardcoder une couleur ailleurs.

```css
:root {
  /* — Fonds — */
  --bg:            #0a0a0a;   /* fond principal quasi-noir */
  --bg-soft:       #101010;   /* sections alternées */
  --card:          rgba(255, 255, 255, 0.03);  /* fond des cartes */
  --card-hover:    rgba(255, 255, 255, 0.05);
  --border:        rgba(255, 255, 255, 0.08);  /* bordures fines */

  /* — Texte — */
  --text:          #f0f0f0;   /* texte principal */
  --text-muted:    #888888;   /* descriptions, légendes */
  --text-faint:    rgba(255, 255, 255, 0.5);   /* mentions discrètes */

  /* — Accent (clay / terracotta, la couleur signature) — */
  --accent:        #d97757;   /* rgb(217,119,87) — liens actifs, highlights */
  --accent-soft:   rgba(217, 119, 87, 0.15);

  /* — Sémantique — */
  --success:       #7bb86f;   /* checks verts de la liste de pricing */

  /* — Boutons — */
  --btn-primary-bg:   #ffffff;  /* bouton plein : fond blanc, texte noir */
  --btn-primary-text: #000000;
  --btn-ghost-border: rgba(255, 255, 255, 0.15);  /* bouton secondaire transparent */

  /* — Rayons & ombres — */
  --radius:        14px;
  --radius-lg:     20px;
  --shadow:        0 20px 60px rgba(0, 0, 0, 0.5);

  /* — Layout — */
  --maxw:          1100px;   /* largeur max du contenu */
  --gap:           24px;
}
```

---

## Typographie

Trois familles, chacune avec un rôle strict :

| Rôle | Police | Usage |
|---|---|---|
| **Pixel** | `"Departure Mono"`, `"JetBrains Mono"`, monospace | H1, H2, logo, labels « techniques », prix |
| **Corps** | `-apple-system, system-ui, "SF Pro Text", "Segoe UI", sans-serif` | paragraphes, descriptions, FAQ, boutons |
| **Serif** | `"Instrument Serif", Georgia, serif` | UNIQUEMENT le logo du footer (touche élégante) |

### Charger Departure Mono

Departure Mono est une police pixel gratuite (OFL). La télécharger une fois dans `site/fonts/`
et la déclarer en `@font-face` (PAS de CDN externe — tout doit être self-contained) :

```css
@font-face {
  font-family: "Departure Mono";
  src: url("fonts/DepartureMono-Regular.woff2") format("woff2");
  font-weight: 400;
  font-display: swap;
}
```

> Fallback acceptable si la police n'est pas dispo : `"JetBrains Mono", ui-monospace, monospace`.
> Le rendu pixel parfait vient de Departure Mono — la récupérer reste préférable.

### Échelle typographique

```css
h1  { font-family: var(--pixel); font-size: clamp(40px, 7vw, 84px); line-height: 1.05; letter-spacing: -0.01em; }
h2  { font-family: var(--pixel); font-size: clamp(28px, 4vw, 44px); line-height: 1.1; }
h3  { font-family: var(--corps); font-size: 20px; font-weight: 600; }    /* titres de cartes */
p   { font-family: var(--corps); font-size: 17px; line-height: 1.6; color: var(--text-muted); }
.lead { font-size: 20px; color: var(--text); }   /* sous-titre du hero */
```

Le titre pixel doit « respirer » : grand, centré, sur 2 lignes max.

---

## Fond ASCII / grille de points

Signature visuelle du site : un motif discret de points/caractères derrière le hero.
Le reproduire en CSS pur (pas d'image) :

```css
body {
  background-color: var(--bg);
  background-image: radial-gradient(rgba(255,255,255,0.04) 1px, transparent 1px);
  background-size: 22px 22px;        /* grille de points fine */
}
```

Variante plus marquée pour le hero seul : un `::before` avec un dégradé radial qui éclaircit le
centre, pour donner de la profondeur.

---

## Composants

### Boutons

```css
.btn {
  font-family: var(--corps);
  font-weight: 600;
  font-size: 16px;
  padding: 14px 28px;
  border-radius: 10px;
  display: inline-flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  transition: transform .15s ease, opacity .15s ease;
}
.btn:hover { transform: translateY(-1px); }

.btn-primary { background: var(--btn-primary-bg); color: var(--btn-primary-text); border: none; }
.btn-ghost   { background: transparent; color: var(--text); border: 1px solid var(--btn-ghost-border); }
```

Le bouton primaire porte une icône Apple () + le label. Le secondaire est « ghost ».

### Carte de feature

```css
.feature {
  background: var(--card);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  padding: 32px 28px;
  text-align: center;
  transition: background .2s ease;
}
.feature:hover { background: var(--card-hover); }
.feature .icon { /* icône pixel 24px, couleur --text-muted, centrée */ }
```

Grille : `display: grid; grid-template-columns: repeat(3, 1fr); gap: var(--gap);`
→ passe à 2 puis 1 colonne en responsive (`@media (max-width: 860px)` / `(max-width: 560px)`).

### Checklist de pricing

Items avec un `✓` en `--success` aligné à gauche, texte clair.

---

## Structure du funnel (à reproduire dans l'ordre)

C'est la séquence qui convertit — la garder telle quelle, juste adapter le copy à cliPet.

1. **Nav** (sticky, fond translucide flouté)
   - Logo pixel `🐱 CLIPET` à gauche
   - À droite : `Fonctionnalités` · `FAQ` · bouton `Télécharger`

2. **Hero**
   - H1 pixel sur 2 lignes : ex. `Un chat pixel\nqui vit sur ton Mac`
   - Sous-titre `.lead` 2 lignes : le bénéfice émotionnel + le bénéfice pratique
     ex. « Il se balade, dort et chasse ton curseur. Léger, natif, 100 % local. »
   - 2 CTA côte à côte : `Télécharger gratuitement` (primary) + `Voir les fonctionnalités` (ghost)
   - **Démo visuelle** sous les CTA : capture / GIF du chat en bas d'un écran macOS
     (encadré arrondi avec ombre `--shadow`). C'est l'élément clé de conversion.

3. **Grille de features** (3×3, comme la source)
   Suggestions adaptées à cliPet :
   - `Vit dans la barre de menus` — zéro fenêtre, toujours là, jamais gênant
   - `Animations pixel` — marche, court, dort, saute, cligne des yeux
   - `Chasse le curseur` — il poursuit la souris et bondit sur une pelote
   - `Presse-papier` — historique du clipboard intégré, accessible d'un clic
   - `Skins personnalisables` — change la couleur et le style du chat
   - `Éditeur de sprites` — dessine tes propres animations
   - `Sons rétro` — petits bruitages 8-bit (désactivables)
   - `100 % natif` — Swift / AppKit, < 50 Mo RAM, pas d'Electron
   - `Tout en local` — aucun cloud, aucun compte, aucune télémétrie

4. **Pricing** (carte centrée)
   - Gros prix pixel. Si gratuit : afficher `Gratuit` en grand + éventuel « Pay what you want ».
   - Checklist ✓ des points forts
   - CTA blanc plein + lien discret `ou essaie d'abord →`

5. **FAQ** (H2 centré + accordéon)
   Questions types : « Compatible Intel ? », « Ça consomme quoi ? », « Mes données sont-elles
   envoyées quelque part ? » (réponse : non, tout est local), « Comment désinstaller ? ».

6. **CTA final** — H2 `Prêt à adopter ton chat ?` + un seul bouton blanc.

7. **Footer**
   - Logo en serif (`Instrument Serif`) + tagline
   - Colonnes `PRODUIT` (Télécharger, Changelog) / `LÉGAL` (Confidentialité, Mentions)
   - Icônes sociales discrètes + copyright

---

## Règles de mise en page

- Largeur de contenu max `var(--maxw)`, centrée, padding latéral 24px.
- Sections espacées verticalement : `padding: 96px 0` (desktop), `64px 0` (mobile).
- Tout centré horizontalement dans le hero, les features et les CTA.
- **Mobile-first responsive** : la grille 3 col → 1 col, le titre rétrécit via `clamp()`,
  les 2 CTA passent en pile verticale (`flex-direction: column`).

---

## Micro-interactions

Sobres, jamais clinquantes :
- Boutons : `translateY(-1px)` au survol.
- Cartes : éclaircissement du fond au survol.
- Le chat pixel du hero peut avoir une **animation CSS `steps()`** (sprite sheet) pour marcher
  en boucle — l'effet « le chat est vivant » est le meilleur argument de vente.

```css
@keyframes walk { from { background-position: 0 0; } to { background-position: -384px 0; } }
.pet-sprite { width: 64px; height: 64px; image-rendering: pixelated;
  animation: walk 0.8s steps(6) infinite; }
```

> `image-rendering: pixelated` est OBLIGATOIRE sur tout asset pixel pour éviter le flou.

---

## Contraintes techniques

- **Site statique pur** : `index.html` + `style.css` (+ `fonts/`, `img/`). Pas de build, pas de npm.
- **Self-contained** : aucune ressource externe (pas de CDN, Google Fonts en local). Hébergeable
  tel quel sur GitHub Pages.
- Accessibilité : contrastes suffisants (le texte muted #888 sur fond noir passe le AA pour du
  texte ≥ 17px), `alt` sur les images, `:focus-visible` visible sur les boutons.
- Performance : images en webp, sprite sheet légère, pas de JS lourd (un petit script vanilla
  pour l'accordéon FAQ suffit).
