#!/bin/bash
# Publica el IPA en GitHub Releases y activa la instalación con un toque.
# Uso: ./scripts/publish-ota-release.sh [version]
# Requiere: dist/Chambea.ipa (generado por build-ota-package.sh)
# Opcional: GITHUB_TOKEN en el entorno para subida automática.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="${1:-1.0.0}"
TAG="v$VERSION"
REPO="jomstudiovzla/Chambea"
IPA="$ROOT/dist/Chambea.ipa"
MANIFEST="$ROOT/docs/manifest.plist"
INSTALL_CONFIG="$ROOT/docs/install-config.json"
APP_CONFIG="$ROOT/Chambea/Core/Utilities/AppInstallConfig.swift"

if [[ ! -f "$IPA" ]]; then
  echo "❌ No existe $IPA"
  echo "   Ejecuta primero: ./scripts/build-ota-package.sh $VERSION"
  exit 1
fi

if [[ ! -f "$MANIFEST" ]]; then
  echo "❌ No existe $MANIFEST — ejecuta build-ota-package.sh"
  exit 1
fi

enable_ota_flags() {
  cat > "$INSTALL_CONFIG" <<EOF
{
  "version": "$VERSION",
  "otaReady": true,
  "testFlightURL": null,
  "manifestURL": "https://jomstudiovzla.github.io/Chambea/manifest.plist",
  "ipaURL": "https://github.com/$REPO/releases/download/$TAG/Chambea.ipa"
}
EOF

  sed -i '' "s/otaPackagePublished = false/otaPackagePublished = true/" "$APP_CONFIG" 2>/dev/null || \
    sed -i "s/otaPackagePublished = false/otaPackagePublished = true/" "$APP_CONFIG"
  sed -i '' "s|releases/download/v[^/]*/|releases/download/$TAG/|" "$APP_CONFIG" 2>/dev/null || \
    sed -i "s|releases/download/v[^/]*/|releases/download/$TAG/|" "$APP_CONFIG"
}

upload_with_api() {
  local token="$1"
  echo "📤 Subiendo release $TAG a GitHub…"

  RELEASE_JSON=$(curl -sf -X POST \
    -H "Authorization: Bearer $token" \
    -H "Accept: application/vnd.github+json" \
    "https://api.github.com/repos/$REPO/releases" \
    -d "{\"tag_name\":\"$TAG\",\"name\":\"Chambea $VERSION\",\"body\":\"Instalación con un toque para iPhone.\",\"draft\":false,\"prerelease\":false}")

  RELEASE_ID=$(echo "$RELEASE_JSON" | python3 -c "import sys,json; print(json.load(sys.stdin)['id'])" 2>/dev/null)
  if [[ -z "$RELEASE_ID" ]]; then
    echo "❌ No se pudo crear el release. ¿Ya existe $TAG?"
    RELEASE_JSON=$(curl -sf \
      -H "Authorization: Bearer $token" \
      -H "Accept: application/vnd.github+json" \
      "https://api.github.com/repos/$REPO/releases/tags/$TAG")
    RELEASE_ID=$(echo "$RELEASE_JSON" | python3 -c "import sys,json; print(json.load(sys.stdin)['id'])" 2>/dev/null)
  fi

  curl -sf -X POST \
    -H "Authorization: Bearer $token" \
    -H "Content-Type: application/octet-stream" \
    -H "Accept: application/vnd.github+json" \
    --data-binary @"$IPA" \
    "https://uploads.github.com/repos/$REPO/releases/$RELEASE_ID/assets?name=Chambea.ipa" \
    > /dev/null

  echo "✅ IPA publicado en GitHub Releases"
}

echo "🚀 Publicando Chambea $VERSION para instalación OTA"
echo ""

if [[ -n "${GITHUB_TOKEN:-}" ]]; then
  upload_with_api "$GITHUB_TOKEN"
else
  echo "ℹ️  Sin GITHUB_TOKEN — sube el IPA manualmente:"
  echo ""
  echo "   1. https://github.com/$REPO/releases/new"
  echo "   2. Tag: $TAG"
  echo "   3. Sube: $IPA"
  echo "   4. Publica el release"
  echo ""
  read -r -p "¿Ya publicaste el release en GitHub? (s/n): " answer
  if [[ "${answer,,}" != "s" && "${answer,,}" != "si" && "${answer,,}" != "y" ]]; then
    echo "Publica el release y vuelve a ejecutar este script."
    exit 0
  fi

  HTTP=$(curl -sI -o /dev/null -w "%{http_code}" "https://github.com/$REPO/releases/download/$TAG/Chambea.ipa")
  if [[ "$HTTP" != "200" && "$HTTP" != "302" ]]; then
    echo "❌ El IPA aún no está disponible (HTTP $HTTP)."
    echo "   URL esperada: https://github.com/$REPO/releases/download/$TAG/Chambea.ipa"
    exit 1
  fi
  echo "✅ IPA verificado en GitHub"
fi

enable_ota_flags

cd "$ROOT"
git add docs/manifest.plist docs/install-config.json Chambea/Core/Utilities/AppInstallConfig.swift
git add docs/install.html 2>/dev/null || true

if git diff --cached --quiet; then
  echo "ℹ️  Sin cambios git pendientes."
else
  git commit -m "Enable OTA one-tap install for Chambea $VERSION"
  git push origin main
  echo "✅ GitHub Pages actualizado"
fi

echo ""
echo "🎉 Instalación con un toque activa:"
echo "   https://jomstudiovzla.github.io/Chambea/install.html"
echo ""
echo "Abre esa URL en tu iPhone Telefono y toca «Instalar en tu dispositivo»."