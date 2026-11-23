#!/usr/bin/env python3
"""Texturas procedurales de sangre para los infectados (sin recursos de terceros):
  gore/overlay_N.png  — capa de manchas y salpicaduras (RGBA) que se pone sobre el cuerpo (varía por infectado);
  gore/wound_N.png    — herida con salpicadura radial para marcar los impactos;
  gore/stump.png      — muñón rojo para el corte (cuello/miembro).
Uso: python3 tools/ui/build_gore_textures.py"""
import os
import numpy as np
from PIL import Image, ImageDraw, ImageFilter

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "assets", "characters", "infected", "gore")
os.makedirs(OUT, exist_ok=True)
rng = np.random.default_rng(777)


def blob(draw, cx, cy, r, color, jag=0.35, n=18):
    pts = []
    for i in range(n):
        a = 2 * np.pi * i / n
        rr = r * (1 + rng.uniform(-jag, jag))
        pts.append((cx + rr * np.cos(a), cy + rr * np.sin(a)))
    draw.polygon(pts, fill=color)


def drips(draw, x, y, length, w, color):
    for _ in range(int(rng.integers(2, 5))):
        dx = x + rng.uniform(-12, 12)
        ln = length * rng.uniform(0.4, 1.0)
        draw.line((dx, y, dx + rng.uniform(-3, 3), y + ln), fill=color, width=int(w * rng.uniform(0.5, 1)))
        blob(draw, dx, y + ln, w * 0.9, color, 0.2, 8)


def finish(img, soften=1.2):
    return img.filter(ImageFilter.GaussianBlur(soften))


# Capas de manchas sobre la textura del cuerpo (alfa = cuánta sangre; color rojo oscuro a casi negro).
for k in range(4):
    img = Image.new("RGBA", (512, 512), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    for _ in range(int(rng.integers(5, 10))):
        x, y = rng.uniform(20, 492), rng.uniform(20, 492)
        c = (int(rng.integers(44, 80)), int(rng.integers(0, 8)), int(rng.integers(0, 8)), int(rng.integers(120, 190)))
        blob(d, x, y, rng.uniform(10, 55), c)
        if rng.random() < 0.55:
            drips(d, x, y, rng.uniform(25, 90), rng.uniform(3, 7), c)
    for _ in range(90):                                        # salpicaduras finas
        x, y = rng.uniform(0, 512), rng.uniform(0, 512)
        blob(d, x, y, rng.uniform(1.5, 4), (60, 2, 2, 190), 0.3, 8)
    for _ in range(int(rng.integers(2, 4))):                   # arrastres secos (marrón)
        x, y = rng.uniform(40, 470), rng.uniform(40, 470)
        d.line((x, y, x + rng.uniform(-80, 80), y + rng.uniform(20, 100)), fill=(52, 22, 14, 150), width=int(rng.integers(8, 22)))
    finish(img).save(os.path.join(OUT, "overlay_%d.png" % k))

# Herida con salpicadura radial (se pega en el punto de impacto).
for k in range(3):
    S = 256
    img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    c0 = (84, 4, 4, 235)
    for _ in range(15):                                        # rayos de salpicadura
        a = rng.uniform(0, 2 * np.pi)
        ln = rng.uniform(40, 118)
        w = rng.uniform(3, 10)
        x2, y2 = S / 2 + ln * np.cos(a), S / 2 + ln * np.sin(a)
        d.line((S / 2, S / 2, x2, y2), fill=c, width=int(w))
        blob(d, x2, y2, w * rng.uniform(0.8, 1.6), c, 0.3, 10)
    blob(d, S / 2, S / 2, rng.uniform(30, 44), (56, 2, 2, 245), 0.25, 14)   # herida central
    blob(d, S / 2, S / 2, rng.uniform(10, 16), (20, 0, 0, 255), 0.2, 10)   # agujero oscuro
    drips(d, S / 2, S / 2 + 20, 60, 6, c0)
    finish(img, 1.4).save(os.path.join(OUT, "wound_%d.png" % k))

# Muñón: carne roja con borde húmedo (disco).
img = Image.new("RGBA", (128, 128), (0, 0, 0, 0))
d = ImageDraw.Draw(img)
d.ellipse((4, 4, 124, 124), fill=(92, 8, 8, 255))
d.ellipse((22, 22, 106, 106), fill=(140, 18, 14, 255))
d.ellipse((44, 44, 84, 84), fill=(200, 160, 140, 255))      # hueso
finish(img, 1.0).save(os.path.join(OUT, "stump.png"))
print("texturas de sangre escritas en", OUT)
