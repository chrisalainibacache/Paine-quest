from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageEnhance, ImageFilter

ROOT = Path(__file__).resolve().parents[2]
SOURCES = {
    "concrete": ROOT / "assets/environment/textures/concrete.png",
    "old_bricks": ROOT / "assets/environment/textures/bricks_old.png",
    "asphalt_cracked": ROOT / "assets/environment/textures/asphalt_cracked.png",
}
OUT = ROOT / "artifacts/texture_pilot"
OUT.mkdir(parents=True, exist_ok=True)


def periodic_microdetail(width: int, height: int, seed: int, strength: float) -> np.ndarray:
    """Tile-periodic fine grain built from many low-amplitude integer harmonics."""
    rng = np.random.default_rng(seed)
    yy, xx = np.mgrid[0:height, 0:width]
    field = np.zeros((height, width), dtype=np.float32)
    # Integer cycles in both axes guarantee that the added grain joins at all four edges.
    # Many weak harmonics avoid the obvious crosshatch caused by a few strong waves.
    for _ in range(48):
        kx = int(rng.integers(17, 145))
        ky = int(rng.integers(17, 145))
        phase = float(rng.uniform(0, 2 * np.pi))
        amplitude = float(rng.uniform(0.65, 1.0))
        field += amplitude * np.sin(
            2 * np.pi * (kx * xx / width + ky * yy / height) + phase
        )
    field /= max(float(np.std(field)), 1e-5)
    return field * strength

def remaster(path: Path, material: str, seed: int) -> Image.Image:
    source = Image.open(path).convert("RGB")
    width, height = source.width * 2, source.height * 2
    # Upscale without changing silhouettes, cracks, joints or stone boundaries.
    base = source.resize((width, height), Image.Resampling.LANCZOS)
    base = base.filter(ImageFilter.UnsharpMask(radius=1.0, percent=32, threshold=5))
    rgb = np.asarray(base, dtype=np.float32)

    # Each material receives its own restrained albedo treatment.
    settings = {
        "concrete": {"grain": 3.4, "contrast": 1.035, "edge_guard": False},
        "old_bricks": {"grain": 2.8, "contrast": 1.045, "edge_guard": True},
        "asphalt_cracked": {"grain": 4.8, "contrast": 1.055, "edge_guard": False},
    }[material]

    detail = periodic_microdetail(width, height, seed, settings["grain"])
    if settings["edge_guard"]:
        # Protect stone contours and mortar gaps: add grain mostly inside stone faces.
        edges = np.asarray(base.filter(ImageFilter.FIND_EDGES).convert("L"), dtype=np.float32) / 255.0
        mask = np.clip(1.0 - edges * 2.4, 0.12, 1.0)
        detail *= mask

    # Luminance-correlated grain retains original material hue and palette.
    rgb += detail[:, :, None]
    rgb = np.clip(rgb, 0, 255).astype(np.uint8)
    result = Image.fromarray(rgb, "RGB")
    result = ImageEnhance.Contrast(result).enhance(settings["contrast"])
    return result


def comparison_card(name: str, original: Image.Image, candidate: Image.Image) -> Image.Image:
    left = original.resize((512, 512), Image.Resampling.NEAREST)
    right = candidate.resize((512, 512), Image.Resampling.LANCZOS)
    card = Image.new("RGB", (1040, 570), (22, 22, 26))
    card.paste(left, (8, 42))
    card.paste(right, (520, 42))
    draw = ImageDraw.Draw(card)
    draw.text((12, 12), f"{name} — ORIGINAL (nearest enlarged)", fill=(235, 235, 235))
    draw.text((524, 12), f"{name} — MATERIAL DETAIL 2x", fill=(235, 235, 235))
    return card


cards = []
for index, (name, path) in enumerate(SOURCES.items(), start=1):
    if not path.exists():
        raise FileNotFoundError(path)
    original = Image.open(path).convert("RGB")
    candidate = remaster(path, name, index * 7919)
    candidate.save(OUT / f"{name}_hd_candidate.png", optimize=True)
    cards.append(comparison_card(name, original, candidate))

sheet = Image.new("RGB", (1040, 570 * len(cards)), (12, 12, 16))
for index, card in enumerate(cards):
    sheet.paste(card, (0, index * 570))
sheet.save(OUT / "comparison.png", optimize=True)
print("PILOT_OK: 3 material-specific candidates + comparison.png")
