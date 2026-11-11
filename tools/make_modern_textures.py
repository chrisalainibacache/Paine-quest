#!/usr/bin/env python3
"""Texturas del modo gráfico Moderno (PBR) desde los originales 1K de ambientCG.

Por cada material deja en assets/environment/textures_modern/:
  <nombre>_color.jpg  (1024 px)  color sin el tratamiento PS1
  <nombre>_normal.jpg (512 px)   mapa normal OpenGL (relieve)
  <nombre>_rough.jpg  (256 px)   rugosidad

Uso: python3 tools/make_modern_textures.py <carpeta_ambientcg>
La carpeta tiene una subcarpeta por ID (Concrete034/, ...) con los JPG del zip 1K.
"""
import sys
from pathlib import Path

from PIL import Image

NAMES = {
    "Concrete034": "concrete", "Plaster001": "plaster", "Tiles101": "tiles",
    "Bricks074": "bricks_red", "Bricks075A": "bricks_old", "Gravel022": "gravel",
    "Metal032": "metal", "Rust004": "rust", "Wood049": "wood", "Planks012": "planks",
    "PavingStones070": "paving", "Asphalt012": "asphalt", "Asphalt025C": "asphalt_cracked",
    "RoofingTiles006": "roof_tiles",
}
MAPS = [("Color", "color", 1024, "RGB"), ("NormalGL", "normal", 512, "RGB"), ("Roughness", "rough", 256, "L")]
OUT = Path(__file__).resolve().parents[1] / "assets/environment/textures_modern"


def main() -> None:
    src = Path(sys.argv[1])
    OUT.mkdir(parents=True, exist_ok=True)
    for acg_id, name in NAMES.items():
        for suffix, kind, size, mode in MAPS:
            path = src / acg_id / f"{acg_id}_1K-JPG_{suffix}.jpg"
            img = Image.open(path).convert(mode)
            if img.size != (size, size):
                img = img.resize((size, size), Image.LANCZOS)
            img.save(OUT / f"{name}_{kind}.jpg", quality=88, optimize=True)
        print("listo:", name)
    (OUT / "LICENSE.txt").write_text(
        "Texturas: ambientCG (https://ambientcg.com), licencia CC0 1.0.\n"
        "Modo gráfico Moderno: color 1024, normal 512, rugosidad 256.\n"
        "Generadas por tools/make_modern_textures.py.\n")


if __name__ == "__main__":
    main()
