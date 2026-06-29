# Instalar Chambea en tu iPhone

## Código QR

Escanea este código desde tu iPhone para abrir la guía de instalación:

![QR Instalar Chambea en iPhone](docs/Chambea-QR-Instalar-iPhone.png)

También puedes abrir directamente: [docs/install.html](docs/install.html)

Para regenerar los QR después de cambiar URLs:

```bash
python3 scripts/generate_qr.py
```

---

iOS no permite instalar apps con un enlace como Android. Necesitas una de estas opciones:

## Opción 1 — Desde Xcode (recomendada para probar ahora)

1. Clona el repositorio en tu Mac.
2. Abre `Chambea.xcodeproj` en Xcode.
3. Ve a **Signing & Capabilities** y selecciona tu **Team** (Apple ID gratuito o cuenta Developer).
4. Conecta tu iPhone por cable (o activa depuración inalámbrica).
5. Elige tu iPhone como destino y pulsa **Run** (▶).

La app quedará instalada en tu dispositivo (7 días con Apple ID gratuito; renueva ejecutando de nuevo desde Xcode).

## Opción 2 — TestFlight (para compartir con más personas)

1. Cuenta **Apple Developer Program** (99 USD/año).
2. Archiva la app en Xcode → **Distribute App** → **App Store Connect**.
3. En App Store Connect, activa **TestFlight** y añade testers.
4. Comparte el enlace de TestFlight; desde ahí sí puedes usar un código QR.

## Opción 3 — Exportar IPA (cuando tengas firma configurada)

```bash
./scripts/export-ipa.sh
```

Sube el `.ipa` a TestFlight, Firebase App Distribution o un servicio OTA con perfil Ad Hoc (UDID del iPhone registrado).