#!/usr/bin/env bash
# Build Release, ad-hoc sign, package zip + dmg into ./dist
set -euo pipefail

cd "$(dirname "$0")/.."

CONFIG=Release
BUILD_DIR=build
DIST_DIR=dist
APP_NAME=Kikey
APP_PATH="$BUILD_DIR/Build/Products/$CONFIG/$APP_NAME.app"
VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" Resources/Info.plist 2>/dev/null || echo "0.1.0")

echo "==> xcodegen"
xcodegen generate

echo "==> xcodebuild ($CONFIG)"
xcodebuild \
  -project "$APP_NAME.xcodeproj" \
  -scheme "$APP_NAME" \
  -configuration "$CONFIG" \
  -derivedDataPath "$BUILD_DIR" \
  CODE_SIGN_IDENTITY="-" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  build >/dev/null

mkdir -p "$DIST_DIR"

ZIP_PATH="$DIST_DIR/$APP_NAME-$VERSION.zip"
echo "==> zip → $ZIP_PATH"
ditto -c -k --sequesterRsrc --keepParent "$APP_PATH" "$ZIP_PATH"

DMG_PATH="$DIST_DIR/$APP_NAME-$VERSION.dmg"
DMG_STAGE="$DIST_DIR/dmg-stage"
rm -rf "$DMG_STAGE" "$DMG_PATH"
mkdir -p "$DMG_STAGE"
cp -R "$APP_PATH" "$DMG_STAGE/"
ln -s /Applications "$DMG_STAGE/Applications"

echo "==> dmg → $DMG_PATH"
hdiutil create \
  -volname "$APP_NAME" \
  -srcfolder "$DMG_STAGE" \
  -ov \
  -format UDZO \
  "$DMG_PATH" >/dev/null

rm -rf "$DMG_STAGE"

echo
echo "✅ Built:"
ls -lh "$ZIP_PATH" "$DMG_PATH"
