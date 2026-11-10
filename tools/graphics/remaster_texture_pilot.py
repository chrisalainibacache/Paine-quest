from pathlib import Path
from PIL import Image, ImageEnhance, ImageFilter, ImageOps, ImageDraw
import random

ROOT = Path(__file__).resolve().parents[2]
SOURCES = {
    "concrete": ROOT / "assets/environment/textures/concrete.png",
    "old_bricks": ROOT / "assets/environment/textures/bricks_old.png",
    "asphalt_cracked": ROOT / "assets/environment/textures/asphalt_cracked.png",
}
OUT = ROOT / "artifacts/texture_pilot"
OUT.mkdir(parents=True, exist_ok=True)

def remaster(path: Path, seed: int) -> Image.Image:
    src = Image.open(path).convert("RGB")
    # 2x output: retain all source forms and colors; do not hallucinate structural detail.
    dst = src.resize((src.width * 2, src.height * 2), Image.Resampling.LANCZOS)
    # Very restrained local contrast and edge recovery, appropriate for the PS1 art direction.
    dst = ImageEnhance.Contrast(dst).enhance(1.035)
    dst = dst.filter(ImageFilter.UnsharpMask(radius=1.15, percent=42, threshold=4))
    # Fine monochrome grain is deliberately subtle; deterministic for reproducible builds.
    rng = random.Random(seed)
    px = dst.load()
    for y in range(dst.height):
        for x in range(dst.width):
            n = rng.choice((-1, 0, 0, 0, 1))
            r, g, b = px[x, y]
            px[x, y] = (max(0,min(255,r+n)), max(0,min(255,g+n)), max(0,min(255,b+n)))
    return dst

cards = []
for idx, (name, path) in enumerate(SOURCES.items(), start=1):
    if not path.exists():
        raise FileNotFoundError(path)
    original = Image.open(path).convert("RGB")
    candidate = remaster(path, idx * 7919)
    candidate.save(OUT / f"{name}_hd_candidate.png", optimize=True)
    # Contact sheet compares original enlarged with candidate at equal display size.
    left = original.resize((512, 512), Image.Resampling.NEAREST)
    right = candidate.resize((512, 512), Image.Resampling.LANCZOS)
    card = Image.new("RGB", (1040, 570), (22, 22, 26))
    card.paste(left, (8, 42))
    card.paste(right, (520, 42))
    draw = ImageDraw.Draw(card)
    draw.text((12, 12), f"{name} — ORIGINAL (nearest enlarged)", fill=(235,235,235))
    draw.text((524, 12), f"{name} — HD CANDIDATE 2x", fill=(235,235,235))
    cards.append(card)

sheet = Image.new("RGB", (1040, 570 * len(cards)), (12,12,16))
for i, card in enumerate(cards):
    sheet.paste(card, (0, i * 570))
sheet.save(OUT / "comparison.png", optimize=True)
print("PILOT_OK: 3 candidate textures + comparison.png")
