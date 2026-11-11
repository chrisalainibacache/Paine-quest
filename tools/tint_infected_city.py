#!/usr/bin/env python3
"""Re-tiñe el infectado moderno (infected_city): el original es casi todo rojo.

Piel: gris verdosa pálida; ropa: tela gris oscura. El rojo intenso queda como
sangre seca (granate oscuro), menos saturado. Trabaja sobre las texturas que
dejó la importación del GLB (assets/characters/infected/infected_city_*_albedo.png).
Uso: python3 tools/tint_infected_city.py  (una sola vez sobre los originales)
"""
from pathlib import Path

import numpy as np
from PIL import Image

DIR = Path(__file__).resolve().parents[1] / "assets/characters/infected"
SKIN = np.array([0.62, 0.62, 0.55])
CLOTH = np.array([0.36, 0.35, 0.33])
BLOOD = np.array([0.30, 0.05, 0.04])


def retint(name: str, base: np.ndarray, gain: float, blood_amount: float) -> None:
    path = DIR / f"infected_city_{name}_albedo.png"
    img = np.asarray(Image.open(path).convert("RGB")).astype(np.float32) / 255.0
    lum = img @ np.array([0.299, 0.587, 0.114])
    red = np.clip((img[..., 0] - np.maximum(img[..., 1], img[..., 2])) * 2.2, 0.0, 1.0)
    col = base[None, None, :] * np.clip(lum * gain, 0.15, 1.3)[..., None]
    blood = BLOOD[None, None, :] * (0.6 + lum[..., None])
    col = col * (1.0 - red[..., None] * blood_amount) + blood * red[..., None] * blood_amount
    Image.fromarray((np.clip(col, 0.0, 1.0) * 255).astype(np.uint8)).save(path)
    print("re-teñida:", path.name)


if __name__ == "__main__":
    retint("Body", SKIN, 2.6, 0.55)
    retint("Outfit", CLOTH, 3.2, 0.45)
