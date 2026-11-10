from pathlib import Path

from PIL import Image, ImageChops, ImageEnhance, ImageFilter, ImageDraw

ROOT = Path(__file__).resolve().parents[2]
SOURCES = {
    "concrete": ROOT / "assets/environment/textures/concrete.png",
    "old_bricks": ROOT / "assets/environment/textures/bricks_old.png",
    "asphalt_cracked": ROOT / "assets/environment/textures/asphalt_cracked.png",
}
OUT = ROOT / "artifacts/texture_pilot"
OUT.mkdir(parents=True, exist_ok=True)

# Faithful 2x restoration: recover only high-frequency information already present
# in the source. No procedural grain, generated cracks, colorization or geometry edits.
SETTINGS = {
    "concrete": {"detail": 0.78, "contrast": 1.025},
    "old_bricks": {"detail": 0.62, "contrast": 1.025},
    "asphalt_cracked": {"detail": 0.72, "contrast": 1.035},
}


def remaster(path: Path, material: str) -> Image.Image:
    original = Image.open(path).convert("RGB")
    cfg = SETTINGS[material]
    # Separate existing fine detail from broad lighting and material color.
    low_frequency = original.filter(ImageFilter.GaussianBlur(radius=1.15))
    high_frequency = ImageChops.subtract(original, low_frequency, scale=1.0, offset=128)
    # Resample base and residual independently, retaining source color and silhouettes.
    size = (original.width * 2, original.height * 2)
    base = original.resize(size, Image.Resampling.LANCZOS)
    detail = high_frequency.resize(size, Image.Resampling.BICUBIC)
    # Residual is centered at 128; blend it back gently to restore existing surface detail.
    detail = ImageChops.subtract(detail, Image.new("RGB", size, (128, 128, 128)))
    restored = ImageChops.add(base, ImageEnhance.Brightness(detail).enhance(cfg["detail"]))
    restored = ImageEnhance.Contrast(restored).enhance(cfg["contrast"])
    return restored


def card(name: str, original: Image.Image, candidate: Image.Image) -> Image.Image:
    # Same display dimensions: left is nearest-neighbor reference, right is restored.
    left = original.resize((512, 512), Image.Resampling.NEAREST)
    right = candidate.resize((512, 512), Image.Resampling.LANCZOS)
    result = Image.new("RGB", (1040, 570), (22, 22, 26))
    result.paste(left, (8, 42))
    result.paste(right, (520, 42))
    draw = ImageDraw.Draw(result)
    draw.text((12, 12), f"{name} — ORIGINAL", fill=(235, 235, 235))
    draw.text((524, 12), f"{name} — FAITHFUL 2x DETAIL RESTORE", fill=(235, 235, 235))
    return result


cards = []
for name, path in SOURCES.items():
    if not path.exists():
        raise FileNotFoundError(path)
    original = Image.open(path).convert("RGB")
    candidate = remaster(path, name)
    candidate.save(OUT / f"{name}_hd_candidate.png", optimize=True)
    cards.append(card(name, original, candidate))

sheet = Image.new("RGB", (1040, 570 * len(cards)), (12, 12, 16))
for index, item in enumerate(cards):
    sheet.paste(item, (0, index * 570))
sheet.save(OUT / "comparison.png", optimize=True)
print("PILOT_OK: faithful 2x detail restoration; no synthetic grain")
