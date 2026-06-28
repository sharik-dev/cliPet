#!/usr/bin/env bash
#
# release.sh — publie une nouvelle version de cliPet en UNE commande.
#
#   ./scripts/release.sh
#
# Ce que ça fait :
#   1. Build Release (nettoyage xattr + signature ad-hoc)
#   2. Zippe l'app → cliPet.zip (+ copie versionnée)
#   3. Upload sur le serveur dans /download/  → le bouton du site sert la nouvelle version
#   4. (si clé Sparkle dispo) signe + régénère appcast.xml → les utilisateurs DÉJÀ
#      installés reçoivent la mise à jour automatiquement (notif Sparkle)
#
# Pour publier une mise à jour : bump MARKETING_VERSION dans Xcode, puis lance ce script.
#
# NOTE : pour une distribution publique sans avertissement Gatekeeper, remplacer la
# signature ad-hoc par une signature Developer ID + notarisation (voir bloc plus bas).
set -euo pipefail
cd "$(dirname "$0")/.."
ROOT="$(pwd)"

SSH_HOST="ubuntu@51.91.125.99"
SSH_PORT="2222"
WEBROOT="/var/www/clipet.sharik.fr"
DL_PREFIX="https://clipet.sharik.fr/download/"
RELEASES="$ROOT/releases"
BUILD="$ROOT/.build-release"
mkdir -p "$RELEASES"

VERSION="$(xcodebuild -project cliPet.xcodeproj -showBuildSettings -configuration Release 2>/dev/null \
  | awk -F' = ' '/ MARKETING_VERSION =/{print $2; exit}')"
echo "▶︎ cliPet $VERSION"

# --- 1. Build Release (non signé) puis nettoyage + signature ad-hoc ---
rm -rf "$BUILD"
xcodebuild -project cliPet.xcodeproj -scheme cliPet -configuration Release \
  -derivedDataPath "$BUILD" CODE_SIGNING_ALLOWED=NO build >/dev/null
APP="$BUILD/Build/Products/Release/cliPet.app"
xattr -cr "$APP" 2>/dev/null || true
codesign --remove-signature "$APP" 2>/dev/null || true
codesign --force --deep --sign - "$APP"

# --- Developer ID + notarisation (à activer pour le grand public) ---
# codesign --force --deep --options runtime --sign "Developer ID Application: TON NOM (TEAMID)" "$APP"
# ditto -c -k --keepParent "$APP" "$BUILD/notarize.zip"
# xcrun notarytool submit "$BUILD/notarize.zip" --keychain-profile AC_NOTARY --wait
# xcrun stapler staple "$APP"

# --- 2. Zip versionné (seul dans releases/, sinon generate_appcast voit un doublon) ---
ZIP="$RELEASES/cliPet-$VERSION.zip"
ditto -c -k --keepParent "$APP" "$ZIP"
echo "▶︎ $(du -h "$ZIP" | cut -f1) → $ZIP"

# --- 3. Upload dans /download : version + copie 'latest' (cliPet.zip = bouton du site) ---
ssh -p "$SSH_PORT" "$SSH_HOST" "mkdir -p $WEBROOT/download"
scp -P "$SSH_PORT" "$ZIP" "$SSH_HOST:$WEBROOT/download/"
ssh -p "$SSH_PORT" "$SSH_HOST" "cp $WEBROOT/download/cliPet-$VERSION.zip $WEBROOT/download/cliPet.zip"
echo "✓ en ligne : ${DL_PREFIX}cliPet.zip"

# --- 4. Sparkle : mise à jour auto des utilisateurs déjà installés ---
SPARKLE_BIN="$(find ~/Library/Developer/Xcode/DerivedData -type d -path '*/artifacts/sparkle/Sparkle/bin' 2>/dev/null | head -1)"
if [[ -n "${SPARKLE_BIN:-}" && -x "$SPARKLE_BIN/generate_appcast" ]]; then
  "$SPARKLE_BIN/generate_appcast" "$RELEASES" --download-url-prefix "$DL_PREFIX" >/dev/null
  scp -P "$SSH_PORT" "$RELEASES/appcast.xml" "$SSH_HOST:$WEBROOT/appcast.xml"
  echo "✓ appcast.xml publié → les utilisateurs reçoivent la mise à jour (Sparkle)"
else
  echo "⚠︎ outils Sparkle introuvables — appcast non mis à jour (build au moins une fois dans Xcode)."
fi

echo "✅ cliPet $VERSION publié."
