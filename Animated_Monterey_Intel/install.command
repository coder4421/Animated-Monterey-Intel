#!/bin/bash
set -e
cd "$(dirname "$0")"
APP="$HOME/Applications/Animated Monterey.app"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleExecutable</key><string>AnimatedMonterey</string>
<key>CFBundleIdentifier</key><string>local.animated.monterey</string>
<key>CFBundleName</key><string>Animated Monterey</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>LSMinimumSystemVersion</key><string>12.0</string>
<key>LSUIElement</key><true/>
<key>NSHighResolutionCapable</key><true/>
</dict></plist>
PLIST
if ! xcrun --find swiftc >/dev/null 2>&1; then
  echo "Apple Command Line Tools are required. Run: xcode-select --install"
  exit 1
fi
xcrun swiftc -O -framework Cocoa -framework AVFoundation -framework CoreGraphics main.swift -o "$APP/Contents/MacOS/AnimatedMonterey"
cp wallpaper.mp4 "$APP/Contents/Resources/wallpaper.mp4"
open "$APP"
echo "Installed! Look for the cricket icon in the menu bar."
echo "To start at login: System Preferences > Users & Groups > Login Items."
