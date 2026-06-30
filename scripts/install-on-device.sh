#!/bin/bash
# Compila e instala Chambea en un iPhone conectado (p. ej. "Telefono").
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEVICE_NAME="${1:-}"
SCHEME="Chambea"
PROJECT="$ROOT/Chambea.xcodeproj"

echo "📱 Instalador Chambea → iPhone"
echo ""

pick_device() {
  local list
  list="$(xcrun xctrace list devices 2>/dev/null | awk -F'[()]' '/iPhone|iPad/ && !/Simulator/ {print $1 " (" $2 ")"}')"
  if [[ -z "$list" ]]; then
    return 1
  fi
  if [[ -n "$DEVICE_NAME" ]]; then
    echo "$list" | grep -i "$DEVICE_NAME" | head -1
  else
    echo "$list" | head -1
  fi
}

DEVICE_LINE="$(pick_device || true)"

if [[ -z "$DEVICE_LINE" ]]; then
  echo "❌ No se detectó ningún iPhone conectado."
  echo ""
  echo "Conecta tu iPhone «Telefono» y vuelve a ejecutar:"
  echo "  ./scripts/install-on-device.sh Telefono"
  echo ""
  echo "En el iPhone:"
  echo "  • Desbloquea la pantalla"
  echo "  • Toca «Confiar en este ordenador»"
  echo "  • Si hace falta: Ajustes → Privacidad → Modo desarrollador → Activar"
  echo ""
  echo "En Xcode (solo la primera vez):"
  echo "  • Xcode → Settings → Accounts → añade tu Apple ID"
  echo "  • Abre Chambea.xcodeproj → Signing & Capabilities → elige tu Team"
  exit 1
fi

DEVICE_UDID="$(echo "$DEVICE_LINE" | sed -n 's/.*(\([^)]*\)).*/\1/p')"
DEVICE_LABEL="$(echo "$DEVICE_LINE" | sed 's/ (.*//')"

echo "✅ Dispositivo: $DEVICE_LABEL"
echo "   UDID: $DEVICE_UDID"
echo ""
echo "🔨 Compilando e instalando (puede pedir firma la primera vez)…"
echo ""

cd "$ROOT"
xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -destination "id=$DEVICE_UDID" \
  -allowProvisioningUpdates \
  build 2>&1 | tail -20

echo ""
echo "🚀 Instalando en $DEVICE_LABEL…"
xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -destination "id=$DEVICE_UDID" \
  -allowProvisioningUpdates \
  install 2>&1 | tail -15 || {
    echo ""
    echo "⚠️  Si falló la firma, abre el proyecto en Xcode:"
    echo "   open \"$PROJECT\""
    echo "   → Signing & Capabilities → Team → tu Apple ID"
    echo "   → Pulsa Run ▶ con $DEVICE_LABEL seleccionado"
    exit 1
  }

echo ""
echo "✅ Chambea instalada en $DEVICE_LABEL"
echo "   Si ves «Desarrollador no confiable»: Ajustes → General → VPN y gestión de dispositivos → Confiar"