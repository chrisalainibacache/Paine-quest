"""Stage 1 HD material pilot: tile-safe recovery of source detail.

No synthetic grain or periodic pattern is added. Original assets remain untouched.
"""
from pathlib import Path
import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "artifacts/hd_stage1"
OUT.mkdir(parents=True, exist_ok=True)

# High-frequency gain is conservative and material-specific. Asphalt gets the
# lightest treatment because its source already contains substantial fine noise.
MATERIALS = {
    "concrete": ("assets/environment/textures/concrete.png", 0.72),
    "bricks_old": ("assets/environment/textures/bricks_old.png", 0.48),
    "asphalt_cracked": ("assets/environment/textures/asphalt_cracked.png", 0.18),
}


def periodic_blur(rgb: np.ndarray) -> np.ndarray:
    """Small wrapped box blur; roll() keeps opposite tile edges continuous."""
    result = np.zeros_like(rgb, dtype=np.float32)
    weights = 0.0
    for dy, wy in ((-1, 1.0), (0, 2.0), (1, 1.0)):
        for dx, wx in ((-1, 1.0), (0, 2.0), (1, 1.0)):
            weight = wy * wx
            result += np.roll(np.roll(rgb, dy, axis=0), dx, axis=1) * weight
            weights += weight
    return result / weights


report = [
    "PAINE QUEST — HD STAGE 1 DETAIL RECOVERY",
    "2x upscale plus restrained source-detail recovery.",
    "No synthetic grain, noise, or new patterns are introduced.",
]
for name, (relative, gain) in MATERIALS.items():
    source = ROOT / relative
    if not source.exists():
        raise FileNotFoundError(source)

    original = Image.open(source).convert("RGB")
    original.save(OUT / f"{name}_original.png")
    rgb = np.asarray(original, dtype=np.float32) / 255.0

    # Recover only detail already present in the source. Wrapped filtering
    # avoids introducing a discontinuity at repeating texture boundaries.
    low_frequency = periodic_blur(rgb)
    detail = rgb - low_frequency
    recovered = np.clip(rgb + detail * gain, 0.0, 1.0)

    size = (original.width * 2, original.height * 2)
    recovered_image = Image.fromarray(
        np.round(recovered * 255.0).astype(np.uint8), "RGB"
    )
    enlarged = recovered_image.resize(size, Image.Resampling.LANCZOS)
    enlarged.save(OUT / f"{name}_hd_2x.png", optimize=True)

    report.append(
        f"{name}: {original.width}x{original.height} -> "
        f"{size[0]}x{size[1]}; source_detail_gain={gain:.2f}"
    )

(OUT / "README.txt").write_text("\n".join(report) + "\n", encoding="utf-8")
print("\n".join(report))
