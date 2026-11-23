#!/usr/bin/env python3
"""Genera las texturas de la interfaz (mochila, opciones, menús) con el aspecto del juego: metal oscuro envejecido con grano,
arañazos, bordes de bronce biselados y remaches. Todo procedural (sin recursos de terceros). Uso: python3 tools/ui/build_ui_kit.py
Salida: assets/ui/kit/*.png (se usan como StyleBoxTexture de 9 cortes en ui/theme/paine_theme.tres)."""
import os
import numpy as np
from PIL import Image, ImageDraw, ImageFilter

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "assets", "ui", "kit")
os.makedirs(OUT, exist_ok=True)
rng = np.random.default_rng(2611)


def grain(h, w, base, amount=0.035, scratch=0.6):
    """Metal oscuro con grano fino, manchas grandes y arañazos verticales/diagonales."""
    img = np.zeros((h, w, 3), dtype=np.float32) + np.array(base, dtype=np.float32)
    noise = rng.normal(0, amount, (h, w, 1))
    big = np.array(Image.fromarray((rng.random((max(h // 8, 2), max(w // 8, 2))) * 255).astype(np.uint8)).resize((w, h), Image.BICUBIC), dtype=np.float32)[..., None] / 255.0
    img += noise + (big - 0.5) * 0.05
    sc = Image.new("L", (w, h), 0)
    d = ImageDraw.Draw(sc)
    for _ in range(int(w * h / 900 * scratch)):
        x, y = rng.integers(0, w), rng.integers(0, h)
        ln = rng.integers(4, 30)
        ang = rng.choice([0.0, 0.05, -0.05, 1.5708]) + rng.normal(0, 0.1)
        d.line((x, y, x + ln * np.cos(ang), y + ln * np.sin(ang)), fill=int(rng.integers(30, 90)))
    img += (np.array(sc, dtype=np.float32)[..., None] / 255.0) * 0.18
    return img


def to_img(a):
    return Image.fromarray(np.clip(a * 255, 0, 255).astype(np.uint8), "RGB")


def bevel(img, color_hi, color_lo, width=3, outer=(0.30, 0.26, 0.18)):
    """Marco de bronce: línea exterior oscura, luz arriba/izquierda, sombra abajo/derecha."""
    w, h = img.size
    d = ImageDraw.Draw(img)
    d.rectangle((0, 0, w - 1, h - 1), outline=tuple(int(c * 255) for c in outer))
    for i in range(1, width + 1):
        d.line((i, i, w - 1 - i, i), fill=color_hi)
        d.line((i, i, i, h - 1 - i), fill=color_hi)
        d.line((i, h - 1 - i, w - 1 - i, h - 1 - i), fill=color_lo)
        d.line((w - 1 - i, i, w - 1 - i, h - 1 - i), fill=color_lo)
    return img


def rivets(img, inset=9, r=2):
    w, h = img.size
    d = ImageDraw.Draw(img)
    for x, y in ((inset, inset), (w - inset, inset), (inset, h - inset), (w - inset, h - inset)):
        d.ellipse((x - r, y - r, x + r, y + r), fill=(90, 80, 62))
        d.point((x - 1, y - 1), fill=(170, 150, 110))


def vignette(a, strength=0.55):
    h, w = a.shape[:2]
    yy, xx = np.mgrid[0:h, 0:w]
    d = np.sqrt(((xx - w / 2) / (w / 2)) ** 2 + ((yy - h / 2) / (h / 2)) ** 2)
    return a * (1.0 - strength * np.clip(d - 0.35, 0, 1)[..., None])


def save(img, name):
    img.save(os.path.join(OUT, name))
    print("escrito", name, img.size)


# Panel (9 cortes, margen 18): placa oscura con borde de bronce y remaches.
a = grain(192, 192, (0.075, 0.07, 0.065))
p = to_img(vignette(a, 0.25))
p = bevel(p, (118, 96, 62), (28, 22, 14), 2)
rivets(p, 10)
save(p, "panel.png")

# Botón en cuatro estados (9 cortes, margen 14).
for name, base, hi, lo in (("button_normal", (0.115, 0.105, 0.095), (120, 100, 66), (22, 18, 12)),
                           ("button_hover", (0.16, 0.14, 0.11), (170, 140, 90), (30, 24, 14)),
                           ("button_pressed", (0.27, 0.19, 0.095), (232, 184, 110), (60, 40, 18)),
                           ("button_disabled", (0.06, 0.058, 0.055), (52, 48, 42), (18, 17, 15))):
    a = grain(72, 160, base, 0.03, 0.5)
    yy = np.linspace(1.12, 0.84, 72)[:, None, None]          # luz de arriba, sombra abajo: se lee como relieve
    a = a * yy
    img = to_img(a)
    img = bevel(img, hi, lo, 2)
    rivets(img, 8, 1)
    save(img, name + ".png")

# Casilla de la mochila: hueco hundido (sombra interior) y versión seleccionada (brillo ámbar).
for name, rim, glow in (("slot", (70, 60, 44), 0.0), ("slot_selected", (236, 184, 104), 0.45)):
    a = grain(112, 112, (0.045, 0.043, 0.04), 0.03, 0.4)
    h, w = a.shape[:2]
    yy, xx = np.mgrid[0:h, 0:w]
    edge = np.minimum.reduce([xx, yy, w - 1 - xx, h - 1 - yy]).astype(np.float32)
    a *= (0.55 + 0.45 * np.clip(edge / 14.0, 0, 1))[..., None]    # sombra interior hacia los bordes
    a += glow * np.exp(-edge / 9.0)[..., None] * np.array([0.5, 0.33, 0.12])
    img = to_img(a)
    d = ImageDraw.Draw(img)
    d.rectangle((0, 0, w - 1, h - 1), outline=rim, width=2)
    save(img, name + ".png")

# Fondo de pantalla completa: casi negro con viñeta, grano y bruma cálida muy leve.
a = grain(720, 1280, (0.022, 0.021, 0.02), 0.02, 0.2)
a = vignette(a, 0.8)
a[..., 0] += 0.012
save(to_img(a), "background.png")

# Barra de encabezado (9 cortes horizontal).
a = grain(96, 192, (0.05, 0.047, 0.043), 0.025, 0.3)
h = to_img(a)
d = ImageDraw.Draw(h)
d.line((0, 95, 191, 95), fill=(118, 96, 62), width=2)
d.line((0, 0, 191, 0), fill=(40, 32, 22), width=1)
save(h, "header.png")

# Control deslizante: perilla de bronce con remache (normal y resaltada).
for name, fill, rim in (("slider_grabber", (176, 140, 84), (60, 44, 24)), ("slider_grabber_hi", (236, 194, 120), (90, 64, 30))):
    img = Image.new("RGBA", (40, 40), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.ellipse((2, 2, 37, 37), fill=rim + (255,))
    d.ellipse((5, 5, 34, 34), fill=fill + (255,))
    d.ellipse((9, 8, 24, 20), fill=tuple(min(255, c + 40) for c in fill) + (160,))
    d.ellipse((17, 17, 22, 22), fill=rim + (255,))
    img.save(os.path.join(OUT, name + ".png"))
    print("escrito", name, img.size)
