#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIST="$ROOT/dist"
STAGING="$DIST/Chambea-Instalar-iPhone"
ZIP_NAME="Chambea-Instalar-iPhone.zip"
ZIP_PATH="$DIST/$ZIP_NAME"

echo "📦 Empaquetando Chambea para instalación en iPhone..."

rm -rf "$STAGING" "$ZIP_PATH"
mkdir -p "$STAGING"

rsync -a \
  --exclude '.git' \
  --exclude 'build' \
  --exclude 'DerivedData' \
  --exclude 'dist' \
  --exclude 'xcuserdata' \
  --exclude '*.xcuserstate' \
  --exclude '.DS_Store' \
  --exclude '*.ipa' \
  --exclude '.env' \
  --exclude '.env.*' \
  "$ROOT/" "$STAGING/"

cp "$ROOT/LEEME-PRIMERO.txt" "$STAGING/LEEME-PRIMERO.txt"
cp "$ROOT/docs/GUIA-INSTALACION-IPHONE-COMPLETA.md" "$STAGING/GUIA-INSTALACION-IPHONE.md"

cd "$DIST"
ditto -c -k --sequesterRsrc --keepParent "$(basename "$STAGING")" "$ZIP_NAME"

BYTES=$(stat -f%z "$ZIP_PATH" 2>/dev/null || stat -c%s "$ZIP_PATH")
MB=$(echo "scale=1; $BYTES / 1048576" | bc)

echo ""
echo "✅ Paquete creado:"
echo "   $ZIP_PATH"
echo "   Tamaño: ${MB} MB"
echo ""
echo "📲 Siguiente paso en tu Mac:"
echo "   1. Descomprime el ZIP"
echo "   2. Lee LEEME-PRIMERO.txt"
echo "   3. Abre Chambea.xcodeproj en Xcode"
echo "   4. Conecta tu iPhone y pulsa Run ▶"
echo ""