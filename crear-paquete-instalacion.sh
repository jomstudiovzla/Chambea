#!/bin/bash
# Atajo: crea el IPA y publica para instalación con un toque en iPhone.
# Uso: ./crear-paquete-instalacion.sh [--team TEAM_ID] [version]
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
VERSION="1.0.0"

for arg in "$@"; do
  [[ "$arg" != --team && "$arg" != -* ]] && VERSION="$arg"
done

echo "══════════════════════════════════════════════"
echo "  Chambea — Paquete de instalación para iPhone"
echo "══════════════════════════════════════════════"
echo ""

"$ROOT/scripts/build-ota-package.sh" "$@"
"$ROOT/scripts/publish-ota-release.sh" "$VERSION"