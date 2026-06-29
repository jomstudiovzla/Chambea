#!/usr/bin/env python3
"""Generate Chambea QR poster images for GitHub and iPhone install."""

from pathlib import Path

import qrcode
from PIL import Image, ImageDraw, ImageFont
from qrcode.constants import ERROR_CORRECT_H

ROOT = Path(__file__).resolve().parent.parent
DOCS = ROOT / "docs"
GITHUB_USER = "jomstudiovzla"
REPO = "Chambea"

URLS = {
    "github": f"https://github.com/{GITHUB_USER}/{REPO}",
    "install": f"https://github.com/{GITHUB_USER}/{REPO}/blob/main/docs/install.html",
}

POSTERS = {
    "Chambea-QR-GitHub.png": {
        "url_key": "github",
        "subtitle": "Repositorio GitHub",
        "lines": ["Escanea para clonar el proyecto", "y abrirlo en Xcode"],
    },
    "Chambea-QR-Instalar-iPhone.png": {
        "url_key": "install",
        "subtitle": "Instalar en iPhone",
        "lines": ["Escanea para ver cómo instalar", "en tu iPhone con Xcode"],
    },
}

WIDTH = 900
HEIGHT = 1100
PRIMARY = (37, 99, 235)
TEXT = (15, 23, 42)
MUTED = (100, 116, 139)
BG = (248, 250, 252)


def load_font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    candidates = []
    if bold:
        candidates.extend([
            "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
            "/System/Library/Fonts/Helvetica.ttc",
            "/Library/Fonts/Arial Bold.ttf",
        ])
    else:
        candidates.extend([
            "/System/Library/Fonts/Supplemental/Arial.ttf",
            "/System/Library/Fonts/Helvetica.ttc",
            "/Library/Fonts/Arial.ttf",
        ])
    for path in candidates:
        if Path(path).exists():
            try:
                return ImageFont.truetype(path, size)
            except OSError:
                continue
    return ImageFont.load_default()


def make_qr_image(data: str, size: int) -> Image.Image:
    qr = qrcode.QRCode(
        version=None,
        error_correction=ERROR_CORRECT_H,
        box_size=12,
        border=2,
    )
    qr.add_data(data)
    qr.make(fit=True)
    img = qr.make_image(fill_color="black", back_color="white").convert("RGB")
    return img.resize((size, size), Image.Resampling.NEAREST)


def draw_centered(draw: ImageDraw.ImageDraw, text: str, y: int, font, fill) -> int:
    bbox = draw.textbbox((0, 0), text, font=font)
    w = bbox[2] - bbox[0]
    draw.text(((WIDTH - w) / 2, y), text, font=font, fill=fill)
    return y + (bbox[3] - bbox[1]) + 8


def render_poster(filename: str, config: dict) -> Path:
    url = URLS[config["url_key"]]
    img = Image.new("RGB", (WIDTH, HEIGHT), BG)
    draw = ImageDraw.Draw(img)

    draw.rectangle((0, 0, WIDTH, 180), fill=PRIMARY)
    title_font = load_font(56, bold=True)
    subtitle_font = load_font(30)
    body_font = load_font(28)
    small_font = load_font(22)

    draw_centered(draw, "Chambea", 42, title_font, "white")
    draw_centered(draw, config["subtitle"], 108, subtitle_font, (230, 240, 255))

    qr_size = 460
    qr = make_qr_image(url, qr_size)
    pad = 28
    box = (
        (WIDTH - qr_size) // 2 - pad,
        230,
        (WIDTH + qr_size) // 2 + pad,
        230 + qr_size + pad * 2,
    )
    draw.rounded_rectangle(box, radius=24, fill="white", outline=(226, 232, 240), width=2)
    img.paste(qr, ((WIDTH - qr_size) // 2, 230 + pad))

    y = 780
    for line in config["lines"]:
        y = draw_centered(draw, line, y, body_font, TEXT)

    draw_centered(draw, url, HEIGHT - 70, small_font, MUTED)

    out = DOCS / filename
    img.save(out, format="PNG", optimize=True)
    return out


def main() -> None:
    DOCS.mkdir(exist_ok=True)
    for filename, config in POSTERS.items():
        path = render_poster(filename, config)
        print(f"Generated {path}")


if __name__ == "__main__":
    main()