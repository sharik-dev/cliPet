# CLAUDE.md — cliPet

Guidance pour Claude Code lorsqu'il travaille sur **cliPet**.

## Overview

cliPet est une **app macOS agent** (SwiftUI + AppKit, pas de fenêtre principale, vit dans la
barre de menus) : un **pet pixel-art** qui se balade sur le bureau + un **gestionnaire de
presse-papiers**. L'app est entièrement personnalisable (couleurs, skins, sprites dessinés à la main)
et multilingue (6 langues).

## Build / Run

```bash
xcodebuild -project cliPet.xcodeproj -scheme cliPet -configuration Debug build
open cliPet.xcodeproj          # ou ouvrir dans Xcode et ⌘R
```

> ⚠️ Le projet **n'utilise pas** de groupe synchronisé Xcode : chaque nouveau fichier `.swift`
> doit être ajouté manuellement à `cliPet.xcodeproj/project.pbxproj` (4 emplacements : `PBXBuildFile`,
> `PBXFileReference`, le groupe, et `PBXSourcesBuildPhase`). Suivre le motif des IDs `AA…/BB…00XX`.

## 🌍 i18n (règle globale — voir aussi ~/CLAUDE.md)

**Anglais d'abord, FR au minimum.** Tout texte visible par l'utilisateur passe par `L10n.swift`,
jamais codé en dur. `L10n` expose une string par champ, avec une factory `for_(Language)` couvrant
**6 langues** : `en` (référence), `zh`, `hi`, `es`, `fr`, `ar`. Ajouter une string = ajouter le champ
au struct **et** sa traduction dans les 6 cas. La langue active est dans `PetSettings.language`.

## Architecture

| Fichier | Rôle |
|---|---|
| `AppDelegate.swift` | Orchestration (mode `.accessory`), status item / menu, popup « lancer au démarrage ». |
| `PetEngine.swift` | Boucle de simulation / états du pet. |
| `PetController.swift` | Fenêtres flottantes (pet, panneau presse-papiers, éditeur, skins). |
| `PetSettings.swift` | Réglages persistés (UserDefaults, JSON unique). Extension `Color <-> hex`. |
| `SpriteStore.swift` | Source unique des frames + **palette de couleurs perso**, sauvegarde auto par skin. |
| `PixelCatView.swift` | Rendu pixel-art ; `PixelPalette` mappe char → couleur. |
| `Skin.swift` / `SkinManagerView.swift` | Catalogue de skins. |
| `ClipboardManager.swift` | Surveillance NSPasteboard + historique typé. |
| `SettingsView.swift` | UI des réglages (onglets Pet / Comportement). |
| `SpriteEditorView.swift` | Éditeur / créateur de pet. |
| `ImageToSprite.swift` | Conversion image → sprite. |
| `LaunchAtLogin.swift` | Lancement au démarrage (`SMAppService`). |
| `L10n.swift` | Internationalisation. |

### Modèle de sprite (important)

Les sprites sont des **grilles de caractères** (`[String]`), un char = une couleur via
`PixelPalette.color(for:)`. L'ordre de résolution d'une couleur :

1. `SpriteStore.shared.customColor(for:)` — **palette utilisateur** (prioritaire) ;
2. sinon le mapping par défaut (recoloré depuis `PetSettings`).

Frames et palette sont persistées par skin dans `Application Support/cliPet/`
(`edits_<skin>.json`, `palette_<skin>.json`), rechargées sans rebuild.

---

## Features

### Éditeur / créateur de pet (`SpriteEditorView`)

Feature **utilisateur** (plus un simple outil dev) : dessiner ses propres animaux.

- **Palette de couleurs libres** : pas de rôles imposés (« contour / pelage »). La sidebar affiche
  des pastilles de couleur, chacune avec son `ColorPicker`. Bouton **« + Ajouter une couleur »**
  (alloue un char libre via `SpriteStore.addColor`), suppression des couleurs ajoutées.
- **Gomme** (caractère vide `.`) en tête de palette.
- **Import image → sprite** (`ImageToSprite.convert`) : ré-échantillonne l'image à la taille de la
  frame, **détecte le fond** (flood-fill depuis les bords sur les zones quasi-uniformes + alpha →
  vide), puis quantifie chaque pixel vers la couleur de palette la plus proche. Slider de **tolérance**.
- **Undo / Redo** : boutons ↶/↷ + raccourcis ⌘Z / ⇧⌘Z ; un trait de pinceau = une étape (pile max 50).
- **Associer** : popover pour copier la frame courante vers d'autres frames de même largeur.
- **Responsive + scrollable** : canvas adaptatif (220–460 px) dans un `ScrollView`, scroll si l'onglet
  est trop petit.
- **Sauvegarde automatique** (débounce 0,4 s dans `SpriteStore`) — frames + palette. Plus de bouton
  « Sauvegarder » manuel.

### Presse-papiers (`ClipboardManager` + `ClipboardHistoryView`)

Historique typé via `ClipKind { text, image, file, color }`, capture par priorité **fichier → image →
texte/couleur** (polling `changeCount` toutes les 0,6 s, dédup, plafond `maxHistory`).

- **Texte** — capturé tel quel.
- **Images** — captures/images web ; stockées **sur disque** (`Application Support/cliPet/clipboard/`,
  nommage par hash SHA-256 → dédup naturelle), miniature dans la liste, re-copie de la vraie donnée.
- **Fichiers** — URLs fichier (`readObjects([NSURL])`) : nom + chemin affichés, re-copie en `NSURL`.
- **Couleur** — détection auto (`#RGB`, `#RRGGBB[AA]`, hex brut, `rgb(r,g,b)`) → aperçu en swatch.
- **Recherche** — filtre sur le texte et l'aperçu (noms de fichiers, hex…).
- Clé de persistance `cliPet.clipboard.v2` (métadonnées seulement ; images sur disque).

### Lancement au démarrage (`LaunchAtLogin`)

- API moderne `SMAppService.mainApp` (macOS 13+), repli vers **Réglages Système > Éléments
  d'ouverture** si l'enregistrement échoue (app non signée / hors `/Applications` / MDM).
- **Popup de guidage** au 1er lancement (`AppDelegate`, `NSAlert`, une seule fois).
- **Toggle** dans Réglages > section « Démarrage » + bouton **?** ouvrant un popover d'aide.

> `SMAppService.register()` n'est fiable que sur un build **signé lancé depuis `/Applications`** ;
> en debug Xcode il peut échouer (d'où le repli).

## Conventions

- Thème UI centralisé : `PixelTheme` (couleurs, `PixelTheme.font`), composants `PixelButtonStyle`,
  `PixelSectionHeader`, `.pixelPanel()` dans `PixelUI.swift`.
- Couleurs : utiliser `Color(hex:)` / `.hexString` (extension dans `PetSettings.swift`).
- Persistance : UserDefaults JSON pour les réglages/historique ; fichiers dans Application Support
  pour les frames, palettes et images.
