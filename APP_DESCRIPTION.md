# cliPet — Description Complète de l'Application

## 🎯 Vue d'ensemble

**cliPet** est une application macOS menubar résolument minimaliste et personnalisable qui apporte une **créature pixel-art animée sur le bureau** et enrichit l'expérience utilisateur avec un **gestionnaire de presse-papiers avancé**. L'application vit discrètement dans la barre de menus (status bar) et fonctionne entièrement hors de la fenêtre principale—zero clutter, zero distraction.

C'est une app **full-featured** pour les créatifs, développeurs et utilisateurs macOS qui aiment les outils de productivité avec âme.

---

## 🐾 Caractéristiques principales

### 1. Pet Pixel-Art Animé (PetEngine + PetController)

Une créature pixel-art qui vit sur votre bureau, anime entre plusieurs états comportementaux.

**Comportements :**
- **Marche** : traverse le screen de façon fluide (sprites multiples pour l'animation)
- **Saut** : rebondissement élégant avec courbe d'accélération physique
- **Repos/Idle** : pose par défaut, respiration subtile
- **Animation aléatoire** : rotations, gratouilles, petit tremblement (life-like)
- **Suiveur de souris** (optionnel) : regarde vers le curseur quand il s'approche
- **Cliquable** : tap ou clic sur le pet déclenche une réaction (saut, geste)

**Personnalisation totale :**
- **Skins multiples** : changez la créature, chaque skin a ses propres frames + palette
- **Palette de couleurs libre** : redessinez chaque couleur du pet directement depuis l'app
- **Éditeur de sprites intégré** : créez vos propres pets sans quitter l'application
- **Import image → sprite** : convertissez une image en sprite (détection de fond, quantification de couleur)
- **Persistance** : chaque skin sauvegarde sa palette + frames auto (zero-click)

**Paramètres de mouvement :**
- Vitesse de marche
- Fréquence des sauts
- Hauteur de saut
- Sensibilité au curseur
- Densité d'animations aléatoires

### 2. Gestionnaire de Presse-Papiers (ClipboardManager + ClipboardHistoryView)

Capture **intelligente et typée** de tout ce que vous copiez—texte, images, fichiers, couleurs—avec historique persistant et recherche.

**Détection automatique par priorité :**
1. **Fichiers** : drag-drop, Finder → URL du fichier (nom + chemin affichés)
2. **Images** : captures d'écran, images web → stockées sur disque (dédup par SHA-256)
3. **Texte** : tout texte ordinaire
4. **Couleurs** : détection auto de hex (`#RGB`, `#RRGGBB`, `#RRGGBBAA`) ou RGB (`rgb(r,g,b)`)

**Fonctionnalités :**
- **Historique typé** : chaque entrée garde son type + métadonnées
- **Recherche en direct** : filtrez sur texte, noms de fichiers, hex couleur
- **Clic pour re-copier** : restaurez n'importe quel ancien contenu en un clic
- **Aperçu intelligent** :
  - Texte → troncé (100 caractères max)
  - Images → miniature 64×64px
  - Fichiers → icône système + nom
  - Couleurs → swatch colorée + hex
- **Stockage hybride** : métadonnées en `UserDefaults` (rapide), images sur disque (économe en mémoire)
- **Limite configurable** : plafond d'historique (défaut 100 entrées)
- **Déduplication** : les mêmes fichiers/images ne sont sauvegardés qu'une fois

---

## 🎨 Architecture de Personnalisation

### Système de Skins

**`SkinManagerView`** affiche un catalogue complet de skins. Chaque skin est un ensemble autonome :

```
Application Support/cliPet/
  ├── edits_<skin-name>.json       ← frames du pet (grille de caractères)
  ├── palette_<skin-name>.json     ← couleurs personnalisées
  └── clipboard/
      ├── <sha-256-image-1>.jpg
      ├── <sha-256-image-2>.jpg
      └── ...
```

**Gestion de skin :**
- **Créer nouveau** : from scratch dans l'éditeur
- **Dupliquer** : copie de tous les frames + palette
- **Supprimer** : efface les fichiers associés
- **Exporter** : zips le skin complet (partage possible)

### Éditeur de Sprites Intégré (SpriteEditorView)

L'éditeur **pixel-by-pixel** directement dans l'UI, pas d'outil externe.

**Canvas interactif :**
- Grille 16×16 (configurable) affichée
- Zoom adaptatif (220–460px selon l'espace)
- Scrollable si trop grand
- Couleur active = la pastille de palette sélectionnée

**Outils :**
- **Pinceau** : clic + drag pour peindre
- **Gomme** : caractère vide `.` en tête de palette
- **Buc remplissage** (bucket) : remplir une zone connexe
- **Pipette** : sample une couleur depuis le canvas

**Pile d'undo/redo :**
- ⌘Z / ⇧⌘Z (raccourcis clavier)
- Max 50 étapes en mémoire
- Un trait de pinceau = une étape
- Undo entre frames = immédiat

**Gestion de palette :**
- **+ Ajouter une couleur** : alloue un char libre, ouvre `ColorPicker` macOS
- Supprimer couleur (sauf gomme) : pop avec confirmation
- Chaque couleur = pastille cliquable + indice hex
- Sauvegarde auto (débounce 400ms)

**Multi-frame :**
- Onglets pour chaque frame (walk_1, walk_2, idle, jump, etc.)
- Associer frames : copie la frame courante vers d'autres de même largeur
- Curseur pour animer les frames en temps réel

### Import Image → Sprite (ImageToSprite)

Convertir une photo en pixel-art automatiquement.

**Pipeline :**
1. **Sélectionner image** (Finder dialog)
2. **Détection de fond** : flood-fill depuis les bords, zones quasi-uniformes → transparent
3. **Ré-échantillonnage** : redimensionne à la taille cible (p.ex. 16×16)
4. **Quantification** : chaque pixel mappé à la couleur de palette la plus proche
5. **Tolerance slider** : 0–100 pour ajuster la similarité couleur
6. **Preview avant import** : vérifiez le rendu, confirmez ou annulez

---

## 🌍 Internationalisation (L10n)

**6 langues intégrées** : `en` (reference), `zh` (Mandarin), `hi` (Hindi), `es` (Spanish), `fr` (French), `ar` (Arabic).

Chaque string UI passe par `L10n.swift` :

```swift
struct L10n {
  static let addPetTitle = L10n.for_(.en)
  // produit la string EN, se substitue pour la langue active

  static func for_(_ language: Language) -> Self { ... }
}
```

**Détection de langue au démarrage :**
- Lire `Locale.preferredLanguages[0]`
- Tomber sur EN si pas de match
- Mémoriser le choix dans `PetSettings.language`

**Sélecteur de langue :**
- Dropdown dans Onglet Réglages
- Change persist en UserDefaults
- UI recharge au changement (labels + popups)

---

## 🛠️ Architecture Technique

### Couches principalement

| Module | Responsabilité |
|--------|---|
| **AppDelegate.swift** | Cycle de vie (mode `.accessory`, pas de fenêtre principale), status item, menu dock, popups « Lancer au démarrage » |
| **PetEngine.swift** | Boucle de simulation 60fps, machine d'états (walk, jump, idle), physics (gravity, velocity), collision écran |
| **PetController.swift** | Fenêtres flottantes : Pet window (NSPanel translucide), Clipboard history, Editor, Skin manager |
| **PetSettings.swift** | Persistance (UserDefaults JSON), configuration, extension Color ↔ hex |
| **SpriteStore.swift** | Source unique de frames, gestion palette (custom + défaut), sauvegarde auto fichiers JSON |
| **PixelCatView.swift** | Rendu SwiftUI (Canvas 2D + Text monospace), `PixelPalette` mappe caractère → `NSColor` |
| **ClipboardManager.swift** | Polling `NSPasteboard.general`, détection par type, dédup, stockage |
| **ClipboardHistoryView.swift** | List SwiftUI avec Binding reactif, search, aperçus smart, re-copy à clic |
| **SettingsView.swift** | UI tabbed (Pet / Behavior / Clipboard / About), bindings UserDefaults |
| **SpriteEditorView.swift** | Canvas pixel-edit, brush/eraser, undo/redo, palette, frame tabs |
| **SkinManagerView.swift** | Liste skins (default + custom), create/duplicate/delete/export |
| **ImageToSprite.swift** | NSImage ↔ sprite, flood-fill, quantization, tolerance slider |
| **LaunchAtLogin.swift** | SMAppService (macOS 13+) + fallback Réglages Système |
| **L10n.swift** | Enum Language + factory, 6 langues, tous les strings |

### Modèle de données — Sprite

**Sprite = grille de caractères :**

```swift
typealias Sprite = [String]
// Exemple :
["...XX....", "..XXXX..", "XXXXXXXX", ...]
// Chaque char → couleur via PixelPalette
```

**Résolution de couleur :**
1. Chercher dans `SpriteStore.shared.customColor(for: "X")` (palette utilisateur)
2. Sinon mapping par défaut (peut être recolorisé via `PetSettings.colorOverride`)

**Persistance par skin :**
- `edits_<nom-skin>.json` : array de Sprite
- `palette_<nom-skin>.json` : dict `[String: String]` (char → hex)
- Auto-chargement au changement de skin
- Auto-sauvegarde lors de l'édition (débounce 400ms)

---

## 🎮 Interactions Utilisateur

### Barre de Menus

- **Status item** (menulet) : affiche icône + label (« cliPet »)
- **Clic** : ouvre menu dock avec :
  - Montrer/Masquer le Pet
  - Ouvrir Presse-Papiers
  - Ouvrir Éditeur
  - Skins
  - Réglages
  - À propos
  - Quitter

### Pet Window (Flottante)

- **NSPanel** translucide, `level = .floating`
- **Clic sur le pet** : déclenche une animation (saut, geste)
- **Clic-drag** : repositionner le pet sur le screen
- **Clé Échap** : masquer (elle reste active en arrière-plan)
- **Coins arrondis** : 12px border radius

### Clipboard History Popover

- **Ouvre en popup** depuis le menu
- **Liste scrollable** : chaque entrée affiche aperçu + timestamp
- **Clic entrée** : re-copie le contenu dans le presse-papiers
- **Search bar** : filtre live
- **Badge de type** : 📄 fichier, 🖼️ image, 🎨 couleur, 📝 texte
- **Suppression** : swipe ou bouton ✕ (optionnel)

### Settings Panels

**Onglets :**
- **Pet** : skin, speed, jump height, cursor sensitivity
- **Behavior** : animation frequency, respiration, follow mouse toggle
- **Clipboard** : max history, auto-clear old entries, scan interval
- **About** : version, crédits, lien site

---

## 💾 Persistance & Stockage

**UserDefaults (JSON) :**
- `com.cliPet.settings` : tous les réglages (langue, speed, skin courant, etc.)
- `com.cliPet.clipboard.v2` : metadata historique (type, timestamp, hash)

**Fichiers (Application Support/cliPet/) :**
- `edits_<skin>.json` : frames
- `palette_<skin>.json` : couleurs
- `clipboard/<sha-256>.jpg|png|data` : images stockées
- Config locale can override via fichier `config.json` (dev)

**Nettoyage :**
- Orphans détectés (refs sans fichier physique) → supprimés au démarrage
- Limite d'historique respectée (ancien pruned au dépassement)

---

## 🚀 Déploiement & Signature

**Build pour l'App Store :**
```bash
xcodebuild -project cliPet.xcodeproj -scheme cliPet -configuration Release build
```

**Signature Developer ID + Notarisation Apple :**
- Clés d'enregistrement dans `Keychain` (Developer ID Application + Installer)
- `notarytool` pour la notarisation
- Workflow GitHub Actions CI/CD pour release automatique
- Téléchargement App Store Connect via `fastlane deliver`

---

## 🎯 Publics & Cas d'Usage

**Développeurs :**
- Gestionnaire de presse-papiers avec historique → trop utile pour ignorer
- Éditeur de sprites homemade → fun pour customiser leur poste

**Créatifs (designers, gamedevs, pixel artists) :**
- Outil pixel-art léger dans la barre de menu
- Skins partagés + export
- Très Instagrammable (pet pixel-art sur le desktop)

**Utilisateurs macOS amoureux d'outils cosy :**
- Esthétique indie cool
- Minimaliste (pas de fenêtre principale)
- Personnalisable sans limite

---

## 📊 État actuel (juin 2026)

- ✅ Pet moteur simulé (walk, jump, idle, animation aléatoires)
- ✅ Presse-papiers avancé (image, texte, fichiers, couleurs)
- ✅ Éditeur de sprites complet (brush, undo/redo, multi-frame)
- ✅ 6 langues (EN, ZH, HI, ES, FR, AR)
- ✅ Skins multiples + persistance
- ✅ Import image → sprite
- ✅ Lancement au démarrage (SMAppService)
- ✅ Analytics anonymes (tunnel de vente)
- 🔄 **En cours** : Signature Developer ID + notarisation pour release stable
- 📦 Prochaine étape : App Store Connect (screenshots marketing, metadata)
