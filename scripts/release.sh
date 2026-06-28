#!/usr/bin/env bash
#
# release.sh — fabrique une mise à jour cliPet signée pour Sparkle.
#
# Pipeline :
#   1. Build Release + export d'un .app signé Developer ID
#   2. (notarisation — voir NOTE plus bas)
#   3. Zip → releases/cliPet-<version>.zip
#   4. generate_appcast → releases/appcast.xml (signe avec ta clé privée du Trousseau)
#   5. À toi d'uploader releases/*.zip + appcast.xml sur ton serveur, sous /clipet/
#
# Prérequis : avoir lancé une fois `generate_keys` (Task #4) → clé privée dans le Trousseau.
#
# Usage :  ./scripts/release.sh
#
set -euo pipefail

cd "$(dirname "$0")/.."
ROOT="$(pwd)"
RELEASES="$ROOT/releases"
BUILD="$ROOT/.build-release"
mkdir -p "$RELEASES"

# --- Version courante (lue depuis le build setting MARKETING_VERSION) ---
VERSION="$(xcodebuild -project cliPet.xcodeproj -showBuildSettings -configuration Release 2>/dev/null \
  | awk -F' = ' '/ MARKETING_VERSION =/{print $2; exit}')"
echo "▶︎ cliPet version $VERSION"

# --- Localise les outils Sparkle (livrés avec le package SPM) ---
SPARKLE_BIN="$(find ~/Library/Developer/Xcode/DerivedData -type d -path '*/artifacts/sparkle/Sparkle/bin' 2>/dev/null | head -1)"
if [[ -z "${SPARKLE_BIN:-}" ]]; then
  echo "✗ Outils Sparkle introuvables. Build au moins une fois dans Xcode après avoir ajouté le package." >&2
  exit 1
fi
echo "▶︎ Outils Sparkle : $SPARKLE_BIN"

# --- 1. Archive + export ---
rm -rf "$BUILD"
xcodebuild -project cliPet.xcodeproj -scheme cliPet -configuration Release \
  -archivePath "$BUILD/cliPet.xcarchive" archive

# Export Developer ID (nécessite exportOptions.plist — voir NOTE)
xcodebuild -exportArchive \
  -archivePath "$BUILD/cliPet.xcarchive" \
  -exportPath "$BUILD/export" \
  -exportOptionsPlist "$ROOT/scripts/exportOptions.plist"

APP="$BUILD/export/cliPet.app"

# --- NOTE NOTARISATION ---
# Avant de zipper pour distribution, l'app doit être notarisée par Apple :
#   xcrun notarytool submit "$APP_ZIP" --keychain-profile "AC_NOTARY" --wait
#   xcrun stapler staple "$APP"
# (configure une fois `notarytool store-credentials AC_NOTARY` avec ta clé ASC API)
# Décommente le bloc ci-dessous une fois tes credentials notarytool en place.
#
# ditto -c -k --keepParent "$APP" "$BUILD/notarize.zip"
# xcrun notarytool submit "$BUILD/notarize.zip" --keychain-profile "AC_NOTARY" --wait
# xcrun stapler staple "$APP"

# --- 3. Zip de distribution ---
ZIP="$RELEASES/cliPet-$VERSION.zip"
rm -f "$ZIP"
ditto -c -k --keepParent "$APP" "$ZIP"
echo "▶︎ Archive : $ZIP"

# --- 4. Génère/Met à jour l'appcast (signe automatiquement avec la clé du Trousseau) ---
"$SPARKLE_BIN/generate_appcast" "$RELEASES" \
  --download-url-prefix "https://clipet.sharik.fr/"
echo "✓ appcast.xml généré dans $RELEASES"

echo
echo "Prochaine étape : uploader sur ton serveur"
echo "  scp $RELEASES/cliPet-$VERSION.zip $RELEASES/appcast.xml  user@serveur:/var/www/clipet.sharik.fr/"
echo "(URL du flux dans l'Info.plist : https://clipet.sharik.fr/appcast.xml)"
