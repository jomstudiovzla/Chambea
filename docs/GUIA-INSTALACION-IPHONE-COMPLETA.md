# Guía completa — Instalar Chambea en tu iPhone

Documento de instalación del paquete **Chambea** para iPhone.  
Versión del paquete: **1.0.0** · iOS mínimo: **17.0**

---

## 1. Descargar el proyecto

### Opción A — ZIP desde GitHub (recomendada)

1. Abre en tu Mac:  
   **https://github.com/jomstudiovzla/Chambea/archive/refs/heads/main.zip**
2. Se descargará `Chambea-main.zip` (o similar).
3. Haz **doble clic** para descomprimir.
4. Renombra la carpeta a `Chambea` si quieres (opcional).

### Opción B — Desde la app Chambea

1. Abre Chambea → **Ajustes** → **Instalar en iPhone**.
2. Comparte el enlace o escanea el QR.
3. En el Mac, abre la guía y pulsa **Descargar código (ZIP)**.

### Opción C — Paquete local generado

Si tienes el repositorio en tu Mac:

```bash
cd Chambea
./scripts/package-for-iphone.sh
```

El ZIP quedará en: `dist/Chambea-Instalar-iPhone.zip`

---

## 2. Requisitos del sistema

| Componente | Requisito |
|------------|-----------|
| Mac | macOS Sonoma 14+ (recomendado) |
| Xcode | 15.0 o superior |
| iPhone | iOS 17.0 o superior |
| Cuenta | Apple ID (gratuito o Developer) |
| Conexión | Cable USB o depuración inalámbrica |

### Instalar Xcode (si no lo tienes)

1. Abre **App Store** en el Mac.
2. Busca **Xcode** → **Obtener** / **Instalar**.
3. Al terminar, abre Xcode una vez y acepta la licencia.
4. Xcode → **Settings** → **Platforms** → instala **iOS** si falta.

---

## 3. Abrir el proyecto

1. Entra en la carpeta descomprimida.
2. Lee primero **`LEEME-PRIMERO.txt`** (resumen rápido).
3. Haz doble clic en:

```
Chambea.xcodeproj
```

4. Espera a que Xcode indexe el proyecto (barra de progreso arriba).

---

## 4. Configurar firma (Signing)

Sin este paso **no** podrás instalar en el iPhone.

1. En el panel izquierdo, clic en **Chambea** (icono azul del proyecto).
2. En **TARGETS**, selecciona **Chambea**.
3. Pestaña **Signing & Capabilities**.
4. Activa **Automatically manage signing**.
5. En **Team**, elige tu Apple ID.

### Si no aparece ningún Team

1. **Xcode** → **Settings…** (o Preferences) → **Accounts**.
2. Pulsa **+** → **Apple ID** → inicia sesión.
3. Vuelve a **Signing & Capabilities** y selecciona tu equipo.

El **Bundle Identifier** debe ser único. Si hay conflicto, cámbialo a algo como:

```
com.tunombre.chambea
```

---

## 5. Conectar el iPhone

1. Conecta el iPhone al Mac con cable USB.
2. Desbloquea el iPhone.
3. Si aparece **¿Confiar en este ordenador?** → **Confiar**.
4. En Xcode, en la barra superior central, abre el selector de destino.
5. Elige **tu iPhone** (nombre del dispositivo), no un simulador.

### Modo desarrollador (iOS 16+)

La primera vez que instales una app de desarrollo:

1. En el iPhone: **Ajustes** → **Privacidad y seguridad**.
2. Baja hasta **Modo desarrollador** → **Activar**.
3. Reinicia el iPhone si lo pide.
4. Vuelve a ejecutar desde Xcode.

---

## 6. Compilar e instalar

1. En Xcode, pulsa **Run** ▶ o `⌘ + R`.
2. La primera compilación puede tardar 1–3 minutos.
3. Si todo va bien, Chambea se abrirá en tu iPhone.

### Si aparece "Untrusted Developer"

1. **Ajustes** → **General** → **VPN y gestión de dispositivos**.
2. Toca tu perfil de desarrollador.
3. **Confiar en "[tu Apple ID]"**.

---

## 7. Contenido del paquete

```
Chambea/
├── LEEME-PRIMERO.txt              ← Empieza aquí
├── GUIA-INSTALACION-IPHONE.md     ← Esta guía (copia en el ZIP)
├── Chambea.xcodeproj              ← Abrir en Xcode
├── Chambea/                       ← Código fuente de la app
├── ChambeaTests/                  ← Tests
├── docs/                          ← QR y guía web
├── scripts/                       ← Utilidades
├── INSTALAR-IPHONE.md
├── README.md
└── ESPECIFICACION_CHAMBEA.txt
```

---

## 8. Uso de la app

| Pestaña | Función |
|---------|---------|
| Buscar | Vacantes remotas multi-fuente |
| Guardados | Ofertas guardadas |
| Perfil y CV | Perfil multimedia + QR instalación |
| IA | Asistente de empleabilidad |
| Ajustes | Idioma, fuentes, **QR instalar en iPhone** |

---

## 9. Renovación (Apple ID gratuito)

Con cuenta gratuita, la app instalada **expira a los 7 días**.

Para renovar:

1. Conecta el iPhone al Mac.
2. Abre `Chambea.xcodeproj`.
3. Pulsa **Run** ▶ otra vez.

---

## 10. Solución de problemas

| Error | Solución |
|-------|----------|
| Signing requires a development team | Añade Apple ID en Xcode → Settings → Accounts |
| No signing certificate | Team vacío → selecciona tu Apple ID |
| iPhone no listado | Cable, confiar, desbloquear pantalla |
| Build failed iPhone 16 | Usa simulador **iPhone 17** o dispositivo físico |
| App expirada | Vuelve a Run desde Xcode |
| Module not found | Product → Clean Build Folder, luego Run |

---

## 11. Enlaces útiles

- Repositorio: https://github.com/jomstudiovzla/Chambea
- Descargar ZIP: https://github.com/jomstudiovzla/Chambea/archive/refs/heads/main.zip
- Guía móvil: https://jomstudiovzla.github.io/Chambea/install.html
- QR instalación: `docs/Chambea-QR-Instalar-iPhone.png`

---

## 12. Próximo paso: TestFlight

Para instalar **sin Xcode** (un enlace o QR directo), se necesita:

1. Cuenta Apple Developer Program (99 USD/año).
2. Subir build a App Store Connect.
3. Distribuir por TestFlight.

Eso se configurará en una versión posterior del proyecto.

---

**Chambea** — Empleo remoto para hispanohablantes  
JOM Studio · jomstudiovzla