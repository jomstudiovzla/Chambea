# Manual de Release iOS — DevOps y empaquetado local

**Audiencia:** desarrolladores SwiftUI que necesitan probar en iPhone físico sin publicar en App Store.  
**Entorno:** Xcode (última versión), iOS 17+, Mac con macOS Sonoma o posterior.  
**Proyecto de referencia:** Chambea (`Chambea.xcodeproj`).

---

## Mapa de decisiones: ¿qué método usar?

| Método | Cuándo usarlo | Cuenta Apple | Duración en dispositivo |
|--------|---------------|--------------|-------------------------|
| **Run desde Xcode** (Fase 2) | Desarrollo diario, debugging | Gratuita o de pago | 7 días (gratuita) / 1 año (de pago) |
| **Archive → .ipa Development/Ad Hoc** (Fase 3–4) | Instalar sin Xcode abierto, compartir con testers limitados | Gratuita (Development) / de pago (Ad Hoc) | Igual que arriba |
| **TestFlight** | Beta con muchos testers | Solo de pago ($99/año) | 90 días por build |
| **App Store** | Producción pública | Solo de pago | Permanente (con actualizaciones) |

> **Regla de oro:** para probar en tu propio iPhone durante el desarrollo, **Fase 2 (Run directo)** es el método más rápido y con menos puntos de fallo.

---

# FASE 1: Preparación del entorno y firma de código (Signing)

## 1.1 Requisitos previos

- Mac con **Xcode** instalado desde la App Store.
- iPhone con **iOS 17+** (Chambea tiene `TARGETED_DEVICE_FAMILY = 1`, solo iPhone).
- Cable USB/USB-C de datos (no solo carga).
- **Apple ID** (gratuito) o **Apple Developer Program** ($99 USD/año).

## 1.2 Añadir Apple ID a Xcode

1. Abre **Xcode**.
2. Menú **Xcode → Settings…** (o **Preferences…** en versiones anteriores).
3. Pestaña **Accounts**.
4. Pulsa **+** (abajo a la izquierda) → **Apple ID** → **Continue**.
5. Inicia sesión con tu Apple ID y contraseña.
6. Verifica que aparece tu cuenta con un **Team**:
   - **Personal Team** → cuenta gratuita (hasta 3 apps activas, firma de 7 días).
   - **Nombre de empresa / organización** → cuenta de pago.

**Error común:** si no aparece ningún Team, cierra sesión y vuelve a entrar, o revisa en [appleid.apple.com](https://appleid.apple.com) que la cuenta no tenga restricciones.

## 1.3 Configurar Bundle Identifier único

El **Bundle ID** identifica tu app en el ecosistema Apple. Debe ser único globalmente.

1. En Xcode, abre el proyecto (**Chambea.xcodeproj**).
2. Panel izquierdo → selecciona el proyecto **Chambea** (icono azul).
3. En **TARGETS**, selecciona **Chambea**.
4. Pestaña **General** → sección **Identity** → **Bundle Identifier**.

Para Chambea el valor por defecto es:

```
com.chambea.app
```

**Si Xcode muestra error de ID duplicado** (otro dev ya lo usa), cámbialo a algo propio:

```
com.tunombre.chambea
```

> El Bundle ID debe coincidir en: target de Xcode, perfil de aprovisionamiento y (si aplica) `manifest.plist` OTA.

## 1.4 Signing & Capabilities

1. Con el target **Chambea** seleccionado, abre **Signing & Capabilities**.
2. Marca **Automatically manage signing**.
3. En **Team**, elige tu **Personal Team** o tu equipo de pago.
4. Verifica que **Signing Certificate** muestra **Apple Development**.
5. Confirma que **Provisioning Profile** se genera automáticamente (Xcode lo descarga de Apple).

### Errores frecuentes en Signing

| Error | Causa | Solución |
|-------|-------|----------|
| *Signing requires a development team* | No hay Team seleccionado | Fase 1.2 + elegir Team en 1.4 |
| *Failed to register bundle identifier* | ID ya registrado por otro | Cambiar Bundle ID (1.3) |
| *Communication with Apple failed* | Sin internet o sesión caducada | Re-login en **Accounts** |
| *No profiles for device* | iPhone no registrado | Conectar iPhone y pulsar **Run** una vez |

### Verificación por terminal (opcional)

```bash
cd /ruta/al/proyecto
xcodebuild -project Chambea.xcodeproj -scheme Chambea \
  -destination 'generic/platform=iOS' \
  -allowProvisioningUpdates \
  -showBuildSettings | grep DEVELOPMENT_TEAM
```

Debe mostrar tu Team ID (10 caracteres alfanuméricos).

---

# FASE 2: Compilación directa al dispositivo (método recomendado)

Este método compila e instala la app directamente desde Xcode. No genera `.ipa` intermedio.

## 2.1 Conectar el iPhone

1. Conecta el iPhone al Mac con cable.
2. Desbloquea el iPhone.
3. Si aparece **¿Confiar en este ordenador?** → **Confiar** → introduce el código del iPhone.
4. En Xcode, barra superior: el dispositivo debe aparecer (ej. **Telefono**).

**Si no aparece el iPhone:**

- Prueba otro cable o puerto USB.
- En iPhone: **Ajustes → General → Transferir o restablecer → Restablecer → Restablecer ubicación y privacidad** (último recurso).
- Reinicia Xcode y el iPhone.

## 2.2 Activar Modo de Desarrollo (iOS 16+)

Obligatorio para instalar builds de desarrollo.

1. Tras el primer intento de **Run** desde Xcode, el iPhone puede mostrar un aviso.
2. En el iPhone: **Ajustes → Privacidad y seguridad → Modo de desarrollador**.
3. Activa **Modo de desarrollador**.
4. Reinicia el iPhone si lo pide.
5. Confirma la activación.

## 2.3 Seleccionar destino y compilar

1. En Xcode, barra superior central → menú de destino (**Destination Scheme**).
2. Selecciona tu **iPhone físico** (no un simulador como *iPhone 17 Simulator*).
3. Pulsa **Run** ▶ o **Product → Run** (`Cmd + R`).
4. Xcode compila, firma, instala y lanza la app.

### Script automatizado (Chambea)

Con el iPhone conectado:

```bash
./scripts/install-on-device.sh Telefono
```

## 2.4 Confiar en el certificado de desarrollador

Si al abrir la app aparece *Desarrollador no confiable*:

1. iPhone → **Ajustes → General → VPN y gestión de dispositivos**.
2. En **APPS DE DESARROLLADOR**, selecciona tu certificado (tu Apple ID).
3. Pulsa **Confiar en "[tu Apple ID]"**.
4. Confirma → abre Chambea de nuevo.

## 2.5 Depuración inalámbrica (opcional)

1. iPhone conectado por cable → **Window → Devices and Simulators**.
2. Selecciona tu iPhone → marca **Connect via network**.
3. Desconecta el cable; el iPhone seguirá disponible como destino en Xcode (misma red Wi‑Fi).

## 2.6 Limitación cuenta gratuita

Con **Personal Team**, la app instalada **expira a los 7 días**. Renueva ejecutando **Run** de nuevo desde Xcode. No es un bug: es política de Apple.

---

# FASE 3: Generación y empaquetado del archivo .ipa

## 3.1 Por qué iOS no funciona como Android (APK)

| Android | iOS |
|---------|-----|
| APK se puede copiar e instalar (con fuentes desconocidas) | Cada app debe estar **firmada criptográficamente** por Apple o un certificado de desarrollo autorizado |
| Instalación desde archivos locales relativamente abierta | **Sandbox** estricto: solo App Store, TestFlight, Xcode, o métodos de distribución registrados |
| Una sola firma del desarrollador | Cadena de confianza: certificado + perfil de aprovisionamiento + (a veces) UDID del dispositivo |

**Conclusión:** no existe un equivalente directo a “descargar APK e instalar” sin pasar por el sistema de firma de Apple.

## 3.2 Método A — Archive desde Xcode (GUI)

### Paso 1: Seleccionar destino genérico

Antes de archivar, en el **Destination Scheme** elige **Any iOS Device (arm64)** — no un simulador.

### Paso 2: Archive

**Product → Archive**

Xcode compila en modo Release y abre el **Organizer** con el archive.

### Paso 3: Distribute App

1. En **Organizer**, selecciona el archive → **Distribute App**.
2. Método según objetivo:

| Método | Uso |
|--------|-----|
| **Development** | Pruebas en dispositivos registrados en tu Team; la opción más simple con cuenta gratuita |
| **Ad Hoc** | Distribuir `.ipa` a dispositivos específicos (UDID registrados); requiere cuenta de pago |
| **App Store Connect** | Subir a TestFlight / App Store |
| **Enterprise** | Solo cuentas Enterprise ($299/año) |

3. Para prueba local: elige **Development** → **Next**.
4. **Automatically manage signing** → **Next**.
5. Revisa el contenido → **Export**.
6. Elige carpeta local (ej. `~/Desktop/Chambea-IPA/`).
7. Resultado: **`Chambea.ipa`** + archivos de aprovisionamiento.

## 3.3 Método B — Línea de comandos (Chambea)

### Solo generar IPA

```bash
./scripts/build-ota-package.sh --team TU_TEAM_ID 1.0.0
```

Salida:

- `dist/Chambea.ipa`
- `docs/manifest.plist` (para instalación OTA futura)

### Generar IPA + publicar para instalación con un toque

```bash
./crear-paquete-instalacion.sh --team TU_TEAM_ID 1.0.0
```

Requisitos adicionales para OTA (instalación desde Safari con un botón):

- IPA alojado en **HTTPS** (GitHub Releases en Chambea).
- `manifest.plist` válido.
- Cuenta de pago recomendada para **Ad Hoc** estable.

## 3.4 Verificar el IPA generado

```bash
# Tamaño y existencia
ls -lh dist/Chambea.ipa

# Inspeccionar firma (opcional)
unzip -l dist/Chambea.ipa | head -20
```

---

# FASE 4: Instalación del .ipa en el iPhone

## 4.1 Finder (macOS Catalina+) — método oficial simple

> Finder instala apps **desarrolladas desde Xcode en ese Mac**, no cualquier `.ipa` arbitrario. Funciona bien con IPAs exportados como **Development** desde tu propio archive.

1. Conecta el iPhone por USB.
2. Abre **Finder** → selecciona tu iPhone en la barra lateral.
3. Pestaña **General** (o pantalla de resumen del dispositivo).
4. Arrastra **`Chambea.ipa`** a la ventana de Finder, o usa la sección de archivos/compartir según versión de macOS.
5. Espera la sincronización/instalación.
6. En el iPhone, aplica **Fase 2.4** si pide confiar en el desarrollador.

**Nota:** en versiones recientes de macOS/iOS, la instalación de `.ipa` por Finder puede estar limitada; si falla, usa Xcode o Apple Configurator.

## 4.2 Apple Configurator (oficial, más fiable para IPA)

1. Instala **Apple Configurator** desde la Mac App Store.
2. Conecta el iPhone.
3. **File → Add Profiles / Apps** (o arrastra el `.ipa` al dispositivo en Configurator).
4. Sigue el asistente; el dispositivo debe estar registrado en tu perfil de aprovisionamiento.
5. Confía en el certificado en el iPhone si es necesario (Fase 2.4).

## 4.3 Xcode — Devices and Simulators

1. **Window → Devices and Simulators**.
2. Pestaña **Devices** → selecciona tu iPhone.
3. En **Installed Apps**, pulsa **+**.
4. Selecciona **`Chambea.ipa`**.
5. Xcode instala si la firma y el perfil son válidos para ese dispositivo.

## 4.4 Sideloading con herramientas de terceros (cuenta gratuita)

Si no tienes cuenta de pago, estas herramientas re-firman el `.ipa` con tu Apple ID:

| Herramienta | Notas |
|-------------|-------|
| **AltStore** | Requiere AltServer en Mac; refresh cada 7 días desde la misma red |
| **Sideloadly** | Interfaz simple; límite de 3 apps / 7 días con cuenta gratuita |
| **iOS App Signer + Xcode** | Flujo manual más técnico |

**Limitaciones con cuenta gratuita:**

- Máximo **3** aplicaciones sideloaded activas.
- Firma válida **7 días**; hay que reinstalar/refrescar semanalmente.
- Algunas capacidades (Push Notifications en producción, ciertos entitlements) no están disponibles.

## 4.5 Instalación OTA (un toque desde Safari)

Flujo Chambea cuando el IPA está publicado:

1. Abre en el iPhone: [install.html](https://jomstudiovzla.github.io/Chambea/install.html)
2. Toca **Instalar en tu dispositivo**.
3. iOS descarga vía `itms-services://` + `manifest.plist`.

**Requisitos técnicos OTA:**

- IPA en URL **HTTPS** pública.
- Certificado de distribución **Ad Hoc** o **Enterprise** (Development OTA suele fallar en producción).
- Dispositivo con UDID incluido en el perfil (Ad Hoc).

---

# Checklist final a prueba de errores

### Antes de compilar

- [ ] Apple ID añadido en **Xcode → Settings → Accounts**
- [ ] **Team** seleccionado en **Signing & Capabilities**
- [ ] **Bundle Identifier** único configurado
- [ ] iPhone conectado, desbloqueado y **Confiar** aceptado

### Compilación directa (recomendado)

- [ ] Destino = **iPhone físico** (no simulador)
- [ ] **Modo de desarrollador** activo en iPhone
- [ ] **Run** ▶ completado sin errores
- [ ] Certificado confiado en **VPN y gestión de dispositivos**

### Generación .ipa

- [ ] Destino = **Any iOS Device (arm64)**
- [ ] **Product → Archive** exitoso
- [ ] Export como **Development** o **Ad Hoc**
- [ ] `Chambea.ipa` presente en carpeta de exportación

### Instalación .ipa

- [ ] iPhone registrado en el perfil de aprovisionamiento
- [ ] Instalado vía **Configurator**, **Xcode Devices** o sideloading
- [ ] App abre sin error de firma

---

# Referencia rápida — comandos Chambea

```bash
# Instalar directo al iPhone conectado
./scripts/install-on-device.sh Telefono

# Generar IPA firmado
./scripts/build-ota-package.sh --team TU_TEAM_ID 1.0.0

# Publicar IPA + activar botón de instalación web
./scripts/publish-ota-release.sh 1.0.0

# Todo en uno
./crear-paquete-instalacion.sh --team TU_TEAM_ID 1.0.0
```

---

# Documentos relacionados

| Archivo | Contenido |
|---------|-----------|
| [INSTALAR-IPHONE.md](../INSTALAR-IPHONE.md) | Guía rápida del proyecto |
| [GUIA-INSTALACION-IPHONE-COMPLETA.md](./GUIA-INSTALACION-IPHONE-COMPLETA.md) | Solución de problemas extendida |
| [LEEME-PRIMERO.txt](../LEEME-PRIMERO.txt) | Inicio en 6 pasos |

---

*Última actualización: junio 2026 — Xcode 26.x, iOS 17+*