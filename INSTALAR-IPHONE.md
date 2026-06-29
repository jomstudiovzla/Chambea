# Instalar Chambea en tu iPhone

## Descargar paquete completo (ZIP)

**Enlace directo para tu Mac:**

👉 **https://github.com/jomstudiovzla/Chambea/archive/refs/heads/main.zip**

1. Descarga y descomprime el ZIP.
2. Abre **`LEEME-PRIMERO.txt`** (instrucciones rápidas).
3. Lee **`GUIA-INSTALACION-IPHONE.md`** si necesitas más detalle.
4. Abre **`Chambea.xcodeproj`** en Xcode.
5. Conecta tu iPhone y pulsa **Run** ▶.

### Generar ZIP localmente

```bash
./scripts/package-for-iphone.sh
```

El archivo quedará en: `dist/Chambea-Instalar-iPhone.zip`

---

## Código QR

![QR Instalar Chambea en iPhone](docs/Chambea-QR-Instalar-iPhone.png)

- **Guía móvil:** https://jomstudiovzla.github.io/Chambea/install.html
- **Dentro de la app:** Ajustes → Instalar en iPhone

---

## Documentación

| Documento | Contenido |
|-----------|-----------|
| `LEEME-PRIMERO.txt` | Inicio rápido (6 pasos) |
| `docs/GUIA-INSTALACION-IPHONE-COMPLETA.md` | Guía detallada con solución de problemas |
| `INSTALAR-IPHONE.md` | Este archivo |

---

## Requisitos

- Mac con Xcode 15+
- iPhone con iOS 17+
- Apple ID (gratuito funciona; la app dura 7 días y se renueva con Run en Xcode)

## TestFlight (futuro)

Para instalar sin Xcode, se necesitará TestFlight (cuenta Developer 99 USD/año).