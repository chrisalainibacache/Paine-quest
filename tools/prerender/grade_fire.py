#!/usr/bin/env python3
"""Corrección de color de los fondos de escenas con incendio: baja la saturación y el rojo (salen muy rojizos).
Uso: python3 tools/prerender/grade_fire.py assets/backgrounds/<sala>/Cam1.png [...]   (aplícalo UNA vez por render)."""
import sys
from PIL import Image, ImageEnhance
for f in sys.argv[1:]:
    im = Image.open(f).convert("RGB")
    im = ImageEnhance.Color(im).enhance(0.72)
    r, g, b = im.split()
    r = r.point(lambda v: int(v * 0.92)); b = b.point(lambda v: min(255, int(v * 1.06)))
    ImageEnhance.Brightness(Image.merge("RGB", (r, g, b))).enhance(1.12).save(f, optimize=True)
    print("graduado", f)
