"""Audit source texture dimensions, palette and opposite-edge continuity.

Produces a text report only; it does not alter source assets.
"""
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "artifacts/hd_stage1"
OUT.mkdir(parents=True, exist_ok=True)

SOURCES = {
    "concrete": "assets/environment/textures/concrete.png",
    "bricks_old": "assets/environment/textures/bricks_old.png",
    "asphalt_cracked": "assets/environment/textures/asphalt_cracked.png",
}


def edge_delta(a: np.ndarray) -> tuple[float, float]:
    # Compare corresponding opposing border pixels, RGB normalized to [0, 1].
    x = np.abs(a[:, 0, :] - a[:, -1, :]).mean()
    y = np.abs(a[0, :, :] - a[-1, :, :]).mean()
    return float(x), float(y)


lines = [
    "PAINE QUEST — SOURCE TEXTURE AUDIT",
    "Read-only analysis. Source files are never modified.",
    "Edge deltas are mean absolute RGB differences on a 0..1 scale.",
]
for name, relative in SOURCES.items():
    path = ROOT / relative
    if not path.is_file():
        raise FileNotFoundError(path)
    with Image.open(path) as image:
        rgb = np.asarray(image.convert("RGB"), dtype=np.float32) / 255.0
    dx, dy = edge_delta(rgb)
    luminance = (
        rgb[..., 0] * 0.2126
        + rgb[..., 1] * 0.7152
        + rgb[..., 2] * 0.0722
    )
    lines.append(
        f"{name}: size={rgb.shape[1]}x{rgb.shape[0]}; "
        f"luma_min={luminance.min():.3f}; luma_max={luminance.max():.3f}; "
        f"luma_mean={luminance.mean():.3f}; "
        f"edge_delta_x={dx:.4f}; edge_delta_y={dy:.4f}"
    )

report = "\n".join(lines) + "\n"
(OUT / "source_texture_audit.txt").write_text(report, encoding="utf-8")
print(report)
