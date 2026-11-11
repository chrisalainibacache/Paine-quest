"""Create read-only 3x3 tiling diagnostics for all environment textures."""
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[2]
TEXTURE_DIR = ROOT / "assets/environment/textures"
OUT = ROOT / "artifacts/hd_stage1"
OUT.mkdir(parents=True, exist_ok=True)

names = [
    "asphalt", "asphalt_cracked", "bricks_old", "bricks_red",
    "concrete", "gravel", "metal", "paving",
    "planks", "plaster", "roof_tiles", "rust",
    "tiles", "wood",
]

font = ImageFont.load_default()
cell_w = 520
cell_h = 560
columns = 2
rows = (len(names) + columns - 1) // columns
sheet = Image.new("RGB", (columns * cell_w, rows * cell_h), (24, 27, 32))
draw = ImageDraw.Draw(sheet)

for index, name in enumerate(names):
    path = TEXTURE_DIR / f"{name}.png"
    if not path.is_file():
        raise FileNotFoundError(path)
    with Image.open(path) as source:
        tile = source.convert("RGB")
    tiled = Image.new("RGB", (tile.width * 3, tile.height * 3))
    for y in range(3):
        for x in range(3):
            tiled.paste(tile, (x * tile.width, y * tile.height))
    preview = tiled.resize((512, 512), Image.Resampling.NEAREST)

    x = (index % columns) * cell_w
    y = (index // columns) * cell_h
    draw.text((x + 8, y + 8), f"{name} — 3x3 repeat", fill=(245, 245, 245), font=font)
    sheet.paste(preview, (x + 4, y + 32))

sheet.save(OUT / "environment_texture_tiling_review.png")
print(f"Saved {OUT / 'environment_texture_tiling_review.png'} ({sheet.width}x{sheet.height})")
