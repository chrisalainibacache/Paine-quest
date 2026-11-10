"""Stage 1 HD material pilot. Generates temporary 2x albedos for CI only."""
from pathlib import Path
import math
import numpy as np
from PIL import Image, ImageFilter, ImageEnhance

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "artifacts/hd_stage1"
OUT.mkdir(parents=True, exist_ok=True)
MATERIALS = {
    "concrete": ("assets/environment/textures/concrete.png", 0.018, 54, 0.78),
    "bricks_old": ("assets/environment/textures/bricks_old.png", 0.010, 38, 0.92),
    "asphalt_cracked": ("assets/environment/textures/asphalt_cracked.png", 0.024, 72, 0.68),
}

def periodic_detail(width, height, seed, components):
    rng = np.random.default_rng(seed)
    yy, xx = np.mgrid[0:height, 0:width]
    field = np.zeros((height, width), dtype=np.float32)
    total = 0.0
    for _ in range(components):
        fx, fy = int(rng.integers(-48, 49)), int(rng.integers(-48, 49))
        if fx == 0 and fy == 0:
            fx = 1
        weight, phase = float(rng.uniform(0.35, 1.0)), float(rng.uniform(0.0, math.tau))
        field += np.sin(math.tau * (fx * xx / width + fy * yy / height) + phase) * weight
        total += weight
    return field / max(total, 1e-6)

report = ["PAINE QUEST — HD STAGE 1 MATERIAL PILOT",
          "Temporary 2x albedos. Original assets are backed up in this artifact."]
for index, (name, (relative, amplitude, seed, contrast)) in enumerate(MATERIALS.items()):
    source = ROOT / relative
    if not source.exists():
        raise FileNotFoundError(source)
    original = Image.open(source).convert("RGB")
    original.save(OUT / f"{name}_original.png")
    crisp = ImageEnhance.Contrast(
        original.filter(ImageFilter.UnsharpMask(radius=1.35, percent=115, threshold=4))
    ).enhance(contrast)
    size = (original.width * 2, original.height * 2)
    enlarged = crisp.resize(size, Image.Resampling.LANCZOS)
    rgb = np.asarray(enlarged, dtype=np.float32) / 255.0
    lum = rgb[..., 0] * 0.2126 + rgb[..., 1] * 0.7152 + rgb[..., 2] * 0.0722
    detail = periodic_detail(size[0], size[1], seed, 64 + index * 16)
    edge = np.abs(np.roll(lum, 1, 0) - np.roll(lum, -1, 0))
    edge += np.abs(np.roll(lum, 1, 1) - np.roll(lum, -1, 1))
    modulation = 0.72 + np.clip(edge * 3.0, 0.0, 0.7)
    textured = np.clip(rgb + (detail * amplitude * modulation)[..., None], 0.0, 1.0)
    result = Image.fromarray(np.round(textured * 255.0).astype(np.uint8), "RGB")
    result.save(OUT / f"{name}_hd_2x.png", optimize=True)
    report.append(f"{name}: {original.width}x{original.height} -> {size[0]}x{size[1]}; grain_amp={amplitude:.3f}")
(OUT / "README.txt").write_text("\n".join(report) + "\n", encoding="utf-8")
print("\n".join(report))
