#!/usr/bin/env bash
#
# release.sh — publie une nouvelle version de cliPet en UNE commande.
#
#   ./scripts/release.sh
#
# Produit, signe (Developer ID + hardened runtime) et notarise :
#   • un DMG  → téléchargement public du site  (/download/cliPet.dmg)
#   • un ZIP  → mises à jour auto Sparkle des utilisateurs déjà installés
# puis upload + régénère l'appcast signé. Tout est notarisé → zéro alerte Gatekeeper.
#
# Pour publier : bump MARKETING_VERSION dans Xcode, puis lance ce script.
set -euo pipefail
cd "$(dirname "$0")/.."

SSH_HOST="ubuntu@51.91.125.99"
SSH_PORT="2222"
WEBROOT="/var/www/clipet.sharik.fr"
DL_PREFIX="https://clipet.sharik.fr/download/"
# HORS iCloud (le dossier projet est synchronisé iCloud → réinjecte com.apple.FinderInfo
# et casse codesign avec "detritus not allowed").
RELEASES="/tmp/clipet-releases"   # ne contient QUE le zip (pour generate_appcast)
BUILD="/tmp/clipet-build"
mkdir -p "$RELEASES"

DEVID="30F1D02E0F27DCACBC6CA17B34A9C3AA239E6C29"   # SHA-1 du cert Developer ID (noms ambigus)
NOTARY_PROFILE="AC_NOTARY"

VERSION="$(xcodebuild -project cliPet.xcodeproj -showBuildSettings -configuration Release 2>/dev/null \
  | awk -F' = ' '/ MARKETING_VERSION =/{print $2; exit}')"
echo "▶︎ cliPet $VERSION"

# --- 1. Build Release (non signé) ---
rm -rf "$BUILD"; mkdir -p "$BUILD"
xcodebuild -project cliPet.xcodeproj -scheme cliPet -configuration Release \
  -derivedDataPath "$BUILD" CODE_SIGNING_ALLOWED=NO build >/dev/null
APP="$BUILD/Build/Products/Release/cliPet.app"

if ! security find-identity -v -p codesigning 2>/dev/null | grep -q "$DEVID"; then
  echo "⚠︎ certificat Developer ID absent — signature ad-hoc + zip seul (test uniquement)."
  xattr -cr "$APP" 2>/dev/null || true
  codesign --force --deep --sign - "$APP"
  ZIP="$RELEASES/cliPet-$VERSION.zip"; rm -f "$RELEASES"/cliPet*
  ditto -c -k --keepParent "$APP" "$ZIP"
  scp -P "$SSH_PORT" "$ZIP" "$SSH_HOST:$WEBROOT/download/"
  ssh -p "$SSH_PORT" "$SSH_HOST" "cp $WEBROOT/download/cliPet-$VERSION.zip $WEBROOT/download/cliPet.zip"
  echo "✓ (test) en ligne : ${DL_PREFIX}cliPet.zip"; exit 0
fi

# --- 2. Signature Developer ID + hardened runtime (intérieur d'abord, puis l'app) ---
echo "▶︎ signature Developer ID"
xattr -cr "$APP" 2>/dev/null || true
find "$APP/Contents/Frameworks" -depth \( -name "*.xpc" -o -name "*.app" -o -name "*.framework" -o -name "Autoupdate" -o -name "*.dylib" \) -print0 2>/dev/null \
  | while IFS= read -r -d '' item; do
      codesign --force --options runtime --timestamp --sign "$DEVID" "$item" 2>/dev/null || true
    done
xattr -cr "$APP" 2>/dev/null || true
codesign --force --options runtime --timestamp --sign "$DEVID" "$APP"

# --- 3. DMG stylé (fond + icônes positionnées + flèche vers Applications) ---
echo "▶︎ création du DMG"
STAGE="$BUILD/dmg-stage"
rm -rf "$STAGE"; mkdir -p "$STAGE/.background"
ditto "$APP" "$STAGE/cliPet.app"
ln -s /Applications "$STAGE/Applications"
cp "$(pwd)/scripts/dmg-bg.png" "$STAGE/.background/bg.png"
hdiutil detach /Volumes/cliPet >/dev/null 2>&1 || true
RW="$BUILD/cliPet-rw.dmg"; rm -f "$RW"
hdiutil create -volname "cliPet" -srcfolder "$STAGE" -fs HFS+ -format UDRW -ov "$RW" >/dev/null
hdiutil attach "$RW" -nobrowse -noautoopen >/dev/null
# Mise en page Finder (best-effort : si ça échoue, le DMG reste valide sans layout).
osascript >/dev/null 2>&1 <<'OSA' || true
tell application "Finder"
  tell disk "cliPet"
    open
    set current view of container window to icon view
    set toolbar visible of container window to false
    set statusbar visible of container window to false
    set bounds of container window to {200, 120, 920, 580}
    set vo to icon view options of container window
    set arrangement of vo to not arranged
    set icon size of vo to 120
    set background picture of vo to file ".background:bg.png"
    set position of item "cliPet.app" of container window to {180, 205}
    set position of item "Applications" of container window to {540, 205}
    update without registering applications
    delay 1
    close
  end tell
end tell
OSA
sync
hdiutil detach /Volumes/cliPet >/dev/null 2>&1 || hdiutil detach /Volumes/cliPet -force >/dev/null 2>&1 || true
DMG="$BUILD/cliPet-$VERSION.dmg"; rm -f "$DMG"
hdiutil convert "$RW" -format UDZO -o "$DMG" >/dev/null
rm -f "$RW"
codesign --force --sign "$DEVID" "$DMG"

# --- 4. Notarisation du DMG (notarise aussi l'app à l'intérieur), staple des deux ---
echo "▶︎ notarisation (1–3 min)…"
xcrun notarytool submit "$DMG" --keychain-profile "$NOTARY_PROFILE" --wait
xcrun stapler staple "$DMG"
xcrun stapler staple "$APP"   # le cdhash de l'app est notarisé via le DMG
echo "✓ notarisé + staplé (DMG + app)"

# --- 5. ZIP (pour Sparkle) depuis l'app staplée — seul fichier dans RELEASES ---
ZIP="$RELEASES/cliPet-$VERSION.zip"
rm -f "$RELEASES"/cliPet*
ditto -c -k --keepParent "$APP" "$ZIP"

# --- 6. Upload : DMG (download public) + ZIP (Sparkle) ---
ssh -p "$SSH_PORT" "$SSH_HOST" "mkdir -p $WEBROOT/download"
scp -P "$SSH_PORT" "$DMG" "$ZIP" "$SSH_HOST:$WEBROOT/download/"
ssh -p "$SSH_PORT" "$SSH_HOST" "cp $WEBROOT/download/cliPet-$VERSION.dmg $WEBROOT/download/cliPet.dmg"
echo "✓ téléchargement : ${DL_PREFIX}cliPet.dmg"

# --- 7. Appcast Sparkle (signé) → mise à jour auto des utilisateurs ---
SPARKLE_BIN="$(find ~/Library/Developer/Xcode/DerivedData -type d -path '*/artifacts/sparkle/Sparkle/bin' 2>/dev/null | head -1)"
if [[ -n "${SPARKLE_BIN:-}" && -x "$SPARKLE_BIN/generate_appcast" ]]; then
  "$SPARKLE_BIN/generate_appcast" "$RELEASES" --download-url-prefix "$DL_PREFIX" >/dev/null
  scp -P "$SSH_PORT" "$RELEASES/appcast.xml" "$SSH_HOST:$WEBROOT/appcast.xml"
  echo "✓ appcast.xml publié → mise à jour auto (Sparkle)"
else
  echo "⚠︎ outils Sparkle introuvables — appcast non mis à jour."
fi

echo "✅ cliPet $VERSION publié (DMG notarisé + Sparkle)."
