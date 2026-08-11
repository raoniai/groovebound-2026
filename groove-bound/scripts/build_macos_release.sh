#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
GAME_DIR=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
DIST_DIR="$GAME_DIR/dist"
LOVE_APP=${LOVE_APP:-/Applications/love.app}
VERSION=${VERSION:-0.7.1}
BUILD_NUMBER=${BUILD_NUMBER:-$(git -C "$GAME_DIR" rev-list --count HEAD 2>/dev/null || printf '1')}
APP_NAME="Groove Bound"
APP_PATH="$DIST_DIR/macos-build/$APP_NAME.app"
APP_RESOURCES="$APP_PATH/Contents/Resources"
PLIST="$APP_PATH/Contents/Info.plist"
ICON_SOURCE="$GAME_DIR/assets/generated/campaign/app-icon.png"
DMG_STAGE="$DIST_DIR/macos-build/dmg"
ZIP_PATH="$DIST_DIR/Groove-Bound-macOS.zip"
DMG_PATH="$DIST_DIR/Groove-Bound-macOS.dmg"

if [ ! -d "$LOVE_APP" ]; then
  printf 'LÖVE app not found at %s\n' "$LOVE_APP" >&2
  exit 1
fi
if [ ! -f "$DIST_DIR/groove-bound.love" ]; then
  printf 'Build dist/groove-bound.love first (make package).\n' >&2
  exit 1
fi
if [ ! -f "$ICON_SOURCE" ]; then
  printf 'Icon source not found at %s\n' "$ICON_SOURCE" >&2
  exit 1
fi

rm -rf "$DIST_DIR/macos-build"
rm -f "$ZIP_PATH" "$DMG_PATH"
mkdir -p "$DMG_STAGE"
sips -s format icns "$ICON_SOURCE" \
  --out "$DIST_DIR/macos-build/GrooveBound.icns" >/dev/null

ditto --rsrc --extattr "$LOVE_APP" "$APP_PATH"
cp "$DIST_DIR/groove-bound.love" "$APP_RESOURCES/Groove Bound.love"
cp "$DIST_DIR/macos-build/GrooveBound.icns" "$APP_RESOURCES/GrooveBound.icns"

/usr/libexec/PlistBuddy -c "Set :CFBundleName $APP_NAME" "$PLIST"
/usr/libexec/PlistBuddy -c "Add :CFBundleDisplayName string $APP_NAME" "$PLIST" 2>/dev/null \
  || /usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName $APP_NAME" "$PLIST"
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier ai.raoni.groove-bound" "$PLIST"
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $VERSION" "$PLIST"
/usr/libexec/PlistBuddy -c "Add :CFBundleVersion string $BUILD_NUMBER" "$PLIST" 2>/dev/null \
  || /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $BUILD_NUMBER" "$PLIST"
/usr/libexec/PlistBuddy -c "Set :CFBundleIconFile GrooveBound" "$PLIST"
/usr/libexec/PlistBuddy -c "Delete :CFBundleIconName" "$PLIST" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Delete :CFBundleDocumentTypes" "$PLIST" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Delete :UTExportedTypeDeclarations" "$PLIST" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Set :NSHumanReadableCopyright Copyright 2026 Raoni Lima" "$PLIST"

xattr -cr "$APP_PATH"
codesign --force --deep --sign - "$APP_PATH"
codesign --verify --deep --strict --verbose=2 "$APP_PATH"
plutil -lint "$PLIST"
file "$APP_PATH/Contents/MacOS/love" | grep -q 'universal binary'
test -f "$APP_RESOURCES/GrooveBound.icns"
test -f "$APP_RESOURCES/Groove Bound.love"

ditto -c -k --sequesterRsrc --keepParent "$APP_PATH" "$ZIP_PATH"
ditto "$APP_PATH" "$DMG_STAGE/$APP_NAME.app"
ln -s /Applications "$DMG_STAGE/Applications"
cp "$DIST_DIR/macos-build/GrooveBound.icns" "$DMG_STAGE/.VolumeIcon.icns"
hdiutil create -volname "$APP_NAME" -srcfolder "$DMG_STAGE" -ov -format UDZO "$DMG_PATH" >/dev/null
hdiutil verify "$DMG_PATH" >/dev/null

shasum -a 256 "$DIST_DIR/groove-bound.love" "$ZIP_PATH" "$DMG_PATH"
printf '\nBuilt universal macOS release:\n  %s\n  %s\n' "$ZIP_PATH" "$DMG_PATH"
printf 'Note: this build is ad-hoc signed and not Apple-notarized.\n'
