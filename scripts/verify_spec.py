#!/usr/bin/env python3
"""Verify ESPECIFICACION_CHAMBEA.txt meets acceptance criteria."""

from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SPEC_PATH = ROOT / "ESPECIFICACION_CHAMBEA.txt"

REQUIRED_SECTIONS = [
    "1) Resumen ejecutivo",
    "2) Objetivo del producto",
    "3) Alcance funcional",
    "4) Arquitectura técnica",
    "5) Estructura de carpetas",
    "6) Diseño de UI/UX",
    "7) Módulo de perfil multimedia",
    "8) Módulo de búsqueda y filtros",
    "9) Módulo de IA",
    "10) Módulo de archivos y portafolio",
    "11) Seguridad y privacidad",
    "12) Integración con fuentes de empleo",
    "13) Riesgos y limitaciones",
    "14) Roadmap por fases",
    "15) Prompt técnico final",
]

PROFILE_ITEMS = [
    "a) Datos básicos",
    "b) Resumen/About",
    "c) Experiencia",
    "d) Educación",
    "e) Skills",
    "f) Portafolio",
    "g) Redes sociales",
    "h) Video de presentación",
    "i) Archivos adjuntos",
]


def main() -> int:
    if not SPEC_PATH.exists():
        print(f"FAIL: missing {SPEC_PATH}")
        return 1

    text = SPEC_PATH.read_text(encoding="utf-8")
    failures: list[str] = []

    # Gating 1: exact open + order
    if not text.startswith("1) Resumen ejecutivo"):
        failures.append(f"Spec must open with '1) Resumen ejecutivo.' got: {text[:40]!r}")

    positions = []
    for section in REQUIRED_SECTIONS:
        idx = text.find(section)
        positions.append((section, idx))
        if idx < 0:
            failures.append(f"Missing section: {section}")

    for i in range(len(positions) - 1):
        a, b = positions[i][1], positions[i + 1][1]
        if a >= 0 and b >= 0 and not a < b:
            failures.append(f"Section order wrong: {positions[i][0]} before {positions[i+1][0]}")

    # Gating 2: profile a-i, video, filters, AI
    for item in PROFILE_ITEMS:
        if item not in text:
            failures.append(f"Missing profile item: {item}")

    for token in ["MP4", "grabar", "galería", "trim", "español", "inglés"]:
        if token.lower() not in text.lower():
            failures.append(f"Missing video/token: {token}")

    for token in ["STAR", "cover letter", "adaptar CV", "About LinkedIn", "guion video", "encaje"]:
        if token.lower() not in text.lower():
            failures.append(f"Missing AI capability: {token}")

    for token in ["Venezuela", "LATAM", "idioma", "remoto"]:
        if token.lower() not in text.lower():
            failures.append(f"Missing filter/market token: {token}")

    # Gating 3: no scraping
    if "NO SCRAPING" not in text and "no scraping" not in text.lower():
        failures.append("Missing no-scraping prohibition")
    for token in ["RSS", "SFSafariViewController", "API"]:
        if token not in text:
            failures.append(f"Missing legal integration method: {token}")

    # Gating 4: architecture + security
    for token in ["MVVM", "SwiftData", "Keychain", "UIDocumentPicker", "PhotosPicker", "async/await", "URLSession", "Localizable", "accesibilidad", "App Store"]:
        if token not in text and token.lower() not in text.lower():
            failures.append(f"Missing architecture/security token: {token}")

    for perm in ["NSCameraUsageDescription", "NSMicrophoneUsageDescription", "NSPhotoLibraryUsageDescription", "NSUserNotificationsUsageDescription"]:
        if perm not in text:
            failures.append(f"Missing permission key: {perm}")

    # Gating 5: Spanish focus
    for token in ["español", "Computrabajo", "LinkedIn"]:
        if token.lower() not in text.lower():
            failures.append(f"Missing Spanish focus token: {token}")

    if failures:
        print("VERIFICATION FAILED")
        for f in failures:
            print(f"  - {f}")
        return 1

    print("VERIFICATION PASSED")
    print(f"Spec path: {SPEC_PATH}")
    print(f"Sections: {len(REQUIRED_SECTIONS)}/15")
    print(f"Opens with: {text[:28]!r}")
    return 0


if __name__ == "__main__":
    sys.exit(main())