#!/bin/bash
# Genera el paquete IPA + manifest.plist para instalación con un toque en iPhone.
# Uso: ./scripts/build-ota-package.sh [--team TEAM_ID] [version]
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="1.0.0"
TEAM_ID="${CHAMBEA_TEAM_ID:-}"
ARCHIVE="$ROOT/build/Chambea.xcarchive"
EXPORT="$ROOT/build/ipa"
DIST="$ROOT/dist"
IPA_NAME="Chambea.ipa"
PROJECT="$ROOT/Chambea.xcodeproj/project.pbxproj"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --team) TEAM_ID="$2"; shift 2 ;;
    -h|--help)
      echo "Uso: $0 [--team TEAM_ID] [version]"
      echo "  CHAMBEA_TEAM_ID=XXXX $0 1.0.0"
      exit 0
      ;;
    *) VERSION="$1"; shift ;;
  esac
done

echo "📦 Creando paquete de instalación Chambea v$VERSION"
echo ""

if [[ -z "$TEAM_ID" ]]; then
  TEAM_ID="$(grep -m1 'DEVELOPMENT_TEAM = ' "$PROJECT" 2>/dev/null | sed 's/.*= \(.*\);/\1/' | tr -d ' "')" || true
fi

if [[ -z "$TEAM_ID" || "$TEAM_ID" == "" ]]; then
  echo "❌ Falta el Team ID de Apple (firma de código)."
  echo ""
  echo "Configúralo una vez en Xcode:"
  echo "  1. Abre Chambea.xcodeproj"
  echo "  2. Target Chambea → Signing & Capabilities"
  echo "  3. Automatically manage signing → elige tu Apple ID"
  echo "  4. Vuelve a ejecutar este script"
  echo ""
  echo "O pásalo directo:"
  echo "  ./scripts/build-ota-package.sh --team TU_TEAM_ID $VERSION"
  echo ""
  open "$ROOT/Chambea.xcodeproj" 2>/dev/null || true
  exit 1
fi

echo "🔐 Team ID: $TEAM_ID"
sed -i '' "s/DEVELOPMENT_TEAM = .*/DEVELOPMENT_TEAM = $TEAM_ID;/g" "$PROJECT"

DEVICE_LINE="$(xcrun xctrace list devices 2>/dev/null | awk -F'[()]' '/iPhone|iPad/ && !/Simulator/ {print $1 " (" $2 ")"}' | head -1 || true)"
if [[ -n "$DEVICE_LINE" ]]; then
  echo "📱 Dispositivo detectado: $(echo "$DEVICE_LINE" | sed 's/ (.*//')"
else
  echo "⚠️  No hay iPhone conectado. Conecta «Telefono» para registrarlo en el perfil."
fi

mkdir -p "$ROOT/build" "$DIST"

echo ""
echo "🔨 Archivando…"
xcodebuild \
  -project "$ROOT/Chambea.xcodeproj" \
  -scheme Chambea \
  -destination 'generic/platform=iOS' \
  -archivePath "$ARCHIVE" \
  -allowProvisioningUpdates \
  DEVELOPMENT_TEAM="$TEAM_ID" \
  archive 2>&1 | tail -5

export_ipa() {
  local method="$1"
  local plist="$2"
  echo ""
  echo "📤 Exportando IPA ($method)…"
  rm -rf "$EXPORT"
  xcodebuild -exportArchive \
    -archivePath "$ARCHIVE" \
    -exportPath "$EXPORT" \
    -exportOptionsPlist "$plist" \
    -allowProvisioningUpdates 2>&1 | tail -8
}

if ! export_ipa "ad-hoc" "$ROOT/scripts/ExportOptions-adhoc.plist"; then
  echo ""
  echo "⚠️  Ad-hoc falló; probando exportación development…"
  export_ipa "development" "$ROOT/scripts/ExportOptions.plist"
fi

IPA_SRC="$(find "$EXPORT" -name '*.ipa' | head -1)"
if [[ -z "$IPA_SRC" || ! -f "$IPA_SRC" ]]; then
  echo "❌ No se generó el IPA. Revisa firma en Xcode."
  exit 1
fi

cp "$IPA_SRC" "$DIST/$IPA_NAME"
cp "$IPA_SRC" "$ROOT/build/$IPA_NAME"

MANIFEST="$ROOT/docs/manifest.plist"
sed -e "s/VERSION/$VERSION/g" "$ROOT/scripts/manifest.plist.template" > "$MANIFEST"

INSTALL_CONFIG="$ROOT/docs/install-config.json"
cat > "$INSTALL_CONFIG" <<EOF
{
  "version": "$VERSION",
  "otaReady": false,
  "testFlightURL": null,
  "manifestURL": "https://jomstudiovzla.github.io/Chambea/manifest.plist",
  "ipaURL": "https://github.com/jomstudiovzla/Chambea/releases/download/v$VERSION/$IPA_NAME"
}
EOF

BYTES=$(stat -f%z "$DIST/$IPA_NAME" 2>/dev/null || stat -c%s "$DIST/$IPA_NAME")
MB=$(echo "scale=1; $BYTES / 1048576" | bc)

echo ""
echo "✅ Paquete listo:"
echo "   IPA:      $DIST/$IPA_NAME  (${MB} MB)"
echo "   Manifest: $MANIFEST"
echo ""
echo "📲 Siguiente paso — publicar para activar «Instalar con un toque»:"
echo "   ./scripts/publish-ota-release.sh $VERSION"
echo ""