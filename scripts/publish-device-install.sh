#!/bin/bash
# Genera IPA firmado y lo publica para instalación con un botón (OTA).
# Requisitos: Xcode, Apple Developer Program, iPhone registrado en el perfil.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="${1:-1.0.0}"
ARCHIVE="$ROOT/build/Chambea.xcarchive"
EXPORT="$ROOT/build/ipa"
IPA_NAME="Chambea.ipa"

echo "🔐 Compilando Chambea para instalación directa (v$VERSION)..."

mkdir -p "$ROOT/build"
xcodebuild -project "$ROOT/Chambea.xcodeproj" \
  -scheme Chambea \
  -destination 'generic/platform=iOS' \
  -archivePath "$ARCHIVE" \
  archive

"$ROOT/scripts/export-ipa.sh"

IPA_SRC="$(find "$EXPORT" -name '*.ipa' | head -1)"
if [[ -z "$IPA_SRC" ]]; then
  echo "❌ No se generó el IPA. Configura Signing en Xcode con tu Team."
  exit 1
fi

cp "$IPA_SRC" "$ROOT/build/$IPA_NAME"
echo "✅ IPA generado: $ROOT/build/$IPA_NAME"
echo ""
echo "📤 Sube el IPA a GitHub Releases:"
echo "   1. Ve a https://github.com/jomstudiovzla/Chambea/releases/new"
echo "   2. Tag: v$VERSION"
echo "   3. Sube: build/$IPA_NAME"
echo "   4. Publica el release"
echo ""
echo "Luego el botón 'Instalar en tu dispositivo' funcionará desde:"
echo "   https://jomstudiovzla.github.io/Chambea/install.html"