"""Generate isolated height/normal-map candidates from existing albedos.

This is a diagnostic pilot only: it never edits game assets or materials.
"""
from pathlib import Path

import numpy as np
from PIL import Image, ImageFilter

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "artifacts/hd_stage1"
OUT.mkdir(parents=True, exist_ok=True)

SOURCES = {
    "concrete": ("assets/environment/textures/concrete.png", 0.42, 0.55),
    "old_bricks": ("assets/environment/textures/bricks_old.png", 0.72, 0.82),
    "asphalt_cracked": ("assets/environment/textures/asphalt_cracked.png", 0.60, 0.72),
}


def make_maps(path: Path, gain: float, normal_strength: float):
    rgb = Image.open(path).convert("RGB")
    lum = np.asarray(rgb.convert("L"), dtype=np.float32) / 255.0
    # Separate broad color variation from material relief; retain boundaries
    # already present in the source rather than synthesizing new geometry.
    blurred = np.asarray(
        rgb.convert("L").filter(ImageFilter.GaussianBlur(radius=2.0)),
        dtype=np.float32,
    ) / 255.0
    detail = lum - blurred
    height = np.clip(0.5 + (lum - 0.5) * 0.42 + detail * gain, 0.0, 1.0)

    # Repeat-aware central differences. This exposes any source-edge mismatch
    # in the seam report instead of silently hiding it.
    dx = (np.roll(height, -1, axis=1) - np.roll(height, 1, axis=1)) * 0.5
    dy = (np.roll(height, -1, axis=0) - np.roll(height, 1, axis=0)) * 0.5
    nx = -dx * normal_strength
    ny = -dy * normal_strength
    nz = np.ones_like(height)
    length = np.sqrt(nx * nx + ny * ny + nz * nz)
    normal = np.stack(
        (nx / length * 0.5 + 0.5, ny / length * 0.5 + 0.5,
         nz / length * 0.5 + 0.5), axis=-1
    )

    height_u16 = np.round(height * 65535).astype("<u2")
    h_img = Image.frombytes("I;16", (rgb.width, rgb.height), height_u16.tobytes())
    n_img = Image.fromarray(np.round(np.clip(normal, 0, 1) * 255).astype(np.uint8), "RGB")
    size = (rgb.width * 2, rgb.height * 2)
    h_img = h_img.resize(size, Image.Resampling.BICUBIC)
    n_img = n_img.resize(size, Image.Resampling.BICUBIC)
    return h_img, n_img, height


reports = []
for name, (relative, gain, strength) in SOURCES.items():
    source = ROOT / relative
    if not source.exists():
        raise FileNotFoundError(source)
    height_img, normal_img, height = make_maps(source, gain, strength)
    height_img.save(OUT / f"{name}_height_512.png", optimize=True)
    normal_img.save(OUT / f"{name}_normal_512.png", optimize=True)
    # Difference across opposing borders, measured in normalized height units.
    seam_x = float(np.mean(np.abs(height[:, 0] - height[:, -1])))
    seam_y = float(np.mean(np.abs(height[0, :] - height[-1, :])))
    reports.append(
        f"{name}: {height_img.width}x{height_img.height}; "
        f"edge_delta_x={seam_x:.4f}; edge_delta_y={seam_y:.4f}"
    )

(OUT / "normal_map_pilot_report.txt").write_text(
    "ISOLATED HEIGHT/NORMAL MAP PILOT\n"
    "No game material or source texture was modified.\n"
    + "\n".join(reports) + "\n",
    encoding="utf-8",
)
print("NORMAL_MAP_PILOT_OK")
print("\n".join(reports))
