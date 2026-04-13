#!/usr/bin/env bash
# Codesign + notarize the built Kikey.app for distribution outside the App Store.
#
# Required env vars (otherwise this script no-ops with a friendly message):
#   DEVELOPER_ID         e.g. "Developer ID Application: Your Name (TEAMID)"
#   APPLE_ID             your Apple ID email
#   APPLE_TEAM_ID        10-character team ID
#   APPLE_APP_PASSWORD   app-specific password from appleid.apple.com
#
# Usage:
#   ./scripts/package.sh        # produces dist/Kikey-X.Y.Z.{zip,dmg}
#   ./scripts/notarize.sh       # signs, notarizes, staples both artifacts
set -euo pipefail
cd "$(dirname "$0")/.."

if [[ -z "${DEVELOPER_ID:-}" || -z "${APPLE_ID:-}" || -z "${APPLE_TEAM_ID:-}" || -z "${APPLE_APP_PASSWORD:-}" ]]; then
  cat <<EOF
ℹ️  Notarization skipped — missing one of:
   DEVELOPER_ID        (e.g. "Developer ID Application: Your Name (TEAMID)")
   APPLE_ID            (your Apple ID email)
   APPLE_TEAM_ID       (10-character team ID)
   APPLE_APP_PASSWORD  (app-specific password)

   Build is still installable via Gatekeeper right-click → Open.
EOF
  exit 0
fi

VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" Resources/Info.plist)
APP="build/Build/Products/Release/Kikey.app"
ZIP="dist/Kikey-$VERSION.zip"
DMG="dist/Kikey-$VERSION.dmg"

if [[ ! -d "$APP" ]]; then
  echo "==> building first"
  ./scripts/package.sh
fi

echo "==> codesign Kikey.app"
codesign --force --deep --options runtime --timestamp \
  --sign "$DEVELOPER_ID" \
  --entitlements Resources/Kikey.entitlements \
  "$APP"

echo "==> verify"
codesign --verify --deep --strict --verbose=2 "$APP"

echo "==> repackage zip with signed app"
rm -f "$ZIP"
ditto -c -k --sequesterRsrc --keepParent "$APP" "$ZIP"

echo "==> notarytool submit zip"
xcrun notarytool submit "$ZIP" \
  --apple-id "$APPLE_ID" \
  --team-id "$APPLE_TEAM_ID" \
  --password "$APPLE_APP_PASSWORD" \
  --wait

echo "==> staple .app"
xcrun stapler staple "$APP"

echo "==> rebuild dmg with stapled app"
rm -f "$DMG"
./scripts/package.sh

echo "==> notarytool submit dmg"
xcrun notarytool submit "$DMG" \
  --apple-id "$APPLE_ID" \
  --team-id "$APPLE_TEAM_ID" \
  --password "$APPLE_APP_PASSWORD" \
  --wait

echo "==> staple dmg"
xcrun stapler staple "$DMG"

echo
echo "✅ Notarized:"
ls -lh "$ZIP" "$DMG"
