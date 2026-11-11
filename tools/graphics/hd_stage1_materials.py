"""Stage 1 HD material candidates with material-aware, tileable microdetail.

Only creates CI artifacts. Source textures and production materials are untouched.
"""
from pathlib import Path
import numpy as np
from PIL import Image, ImageFilter, ImageEnhance

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "artifacts/hd_stage1"
OUT.mkdir(parents=True, exist_ok=True)

# Subtle stochastic detail, in 8-bit channel levels at final 2x resolution.
# Values are deliberately low to preserve the original palette and PS1 look.
MATERIALS = {
    "concrete": ("assets/environment/textures/concrete.png", 1.15, 0.60),
    "bricks_old": ("assets/environment/textures/bricks_old.png", 1.45, 0.72),
    "asphalt_cracked": ("assets/environment/textures/asphalt_cracked.png", 0.65, 0.35),
}


def wrapped_smooth(noise: np.ndarray, radius: int) -> np.ndarray:
    """Tileable box smoothing using wrapped neighbors only."""
    out = np.zeros_like(noise, dtype=np.float32)
    count = 0
    for dy in range(-radius, radius + 1):
        for dx in range(-radius, radius + 1):
            out += np.roll(np.roll(noise, dy, axis=0), dx, axis=1)
            count += 1
    return out / count


def tileable_multiscale_noise(width: int, height: int, seed: int) -> np.ndarray:
    rng = np.random.default_rng(seed)
    base = rng.normal(0.0, 1.0, (height, width)).astype(np.float32)
    fine = base - wrapped_smooth(base, 2)
    broad = wrapped_smooth(base, 3)
    broad = broad - wrapped_smooth(broad, 5)
    field = fine * 0.72 + broad * 0.28
    field -= field.mean()
    field /= max(float(field.std()), 1e-6)
    return field


def build_candidate(name: str, source: Image.Image, amplitude: float, edge_guard: float, seed: int) -> Image.Image:
    size = (source.width * 2, source.height * 2)
    upscaled = source.resize(size, Image.Resampling.LANCZOS)
    rgb = np.asarray(upscaled, dtype=np.float32)
    luminance = rgb[..., 0] * 0.2126 + rgb[..., 1] * 0.7152 + rgb[..., 2] * 0.0722

    # Protect silhouettes, mortar boundaries and existing cracks from noise.
    gx = np.abs(np.roll(luminance, 1, axis=1) - np.roll(luminance, -1, axis=1))
    gy = np.abs(np.roll(luminance, 1, axis=0) - np.roll(luminance, -1, axis=0))
    edge = np.clip((gx + gy) / 28.0, 0.0, 1.0)
    mask = 1.0 - edge * edge_guard

    noise = tileable_multiscale_noise(size[0], size[1], seed)
    # Add neutral micro-relief equally to RGB; do not tint or shift the palette.
    detail = (noise * amplitude * mask)[..., None]
    result = np.clip(rgb + detail, 0.0, 255.0)
    return Image.fromarray(np.round(result).astype(np.uint8), "RGB")


report = [
    "PAINE QUEST — HD STAGE 1 MATERIAL PILOT",
    "2x Lanczos source plus subtle tileable material microdetail.",
    "Microdetail is stochastic, multiscale, edge-protected and zero-mean.",
    "Original assets and production materials are unchanged.",
]
for index, (name, (relative, amplitude, edge_guard)) in enumerate(MATERIALS.items()):
    source_path = ROOT / relative
    if not source_path.exists():
        raise FileNotFoundError(source_path)
    original = Image.open(source_path).convert("RGB")
    original.save(OUT / f"{name}_original.png")
    candidate = build_candidate(name, original, amplitude, edge_guard, 7301 + index * 97)
    candidate.save(OUT / f"{name}_hd_2x.png", optimize=True)
    report.append(
        f"{name}: {original.width}x{original.height} -> "
        f"{candidate.width}x{candidate.height}; microdetail={amplitude:.2f}/255"
    )

(OUT / "README.txt").write_text("\n".join(report) + "\n", encoding="utf-8")
print("\n".join(report))
