#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ARCHIVE_PATH="$ROOT/build/Chambea.xcarchive"
EXPORT_PATH="$ROOT/build/ipa"
EXPORT_OPTIONS="$ROOT/scripts/ExportOptions.plist"

mkdir -p "$ROOT/build"

if [[ ! -f "$EXPORT_OPTIONS" ]]; then
  cat > "$EXPORT_OPTIONS" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>development</string>
    <key>compileBitcode</key>
    <false/>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>stripSwiftSymbols</key>
    <true/>
    <key>thinning</key>
    <string>&lt;none&gt;</string>
</dict>
</plist>
PLIST
fi

echo "Archivando Chambea..."
xcodebuild -project "$ROOT/Chambea.xcodeproj" \
  -scheme Chambea \
  -destination 'generic/platform=iOS' \
  -archivePath "$ARCHIVE_PATH" \
  archive

echo "Exportando IPA..."
rm -rf "$EXPORT_PATH"
xcodebuild -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportPath "$EXPORT_PATH" \
  -exportOptionsPlist "$EXPORT_OPTIONS"

echo "IPA generado en: $EXPORT_PATH"