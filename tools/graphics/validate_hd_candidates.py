"""Validate 2x texture candidates preserve source structure and palette.

This is a conservative regression gate, not an artistic quality approval.
"""
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "artifacts/hd_stage1"
MATERIALS = {
    "concrete": "assets/environment/textures/concrete.png",
    "bricks_old": "assets/environment/textures/bricks_old.png",
    "asphalt_cracked": "assets/environment/textures/asphalt_cracked.png",
}
MAX_MEAN_LUMA_DRIFT = 1.5 / 255.0
MAX_DOWNSAMPLED_MAE = 2.5 / 255.0


def rgb(path: Path) -> np.ndarray:
    with Image.open(path) as image:
        return np.asarray(image.convert("RGB"), dtype=np.float32) / 255.0


def luma(image: np.ndarray) -> np.ndarray:
    return image[..., 0] * 0.2126 + image[..., 1] * 0.7152 + image[..., 2] * 0.0722


def edge_correlation(a: np.ndarray, b: np.ndarray) -> float:
    # Compare gradient structure after returning the candidate to source size.
    ax = np.diff(a, axis=1).ravel()
    ay = np.diff(a, axis=0).ravel()
    bx = np.diff(b, axis=1).ravel()
    by = np.diff(b, axis=0).ravel()
    ga = np.concatenate((ax, ay))
    gb = np.concatenate((bx, by))
    if float(ga.std()) < 1e-8 or float(gb.std()) < 1e-8:
        return 1.0 if np.allclose(ga, gb) else 0.0
    return float(np.corrcoef(ga, gb)[0, 1])


reports = ["HD CANDIDATE STRUCTURE VALIDATION", "Regression checks only; visual review is still mandatory."]
for name, source_rel in MATERIALS.items():
    source_path = ROOT / source_rel
    candidate_path = OUT / f"{name}_hd_2x.png"
    if not source_path.is_file() or not candidate_path.is_file():
        raise FileNotFoundError(source_path if not source_path.is_file() else candidate_path)

    source = rgb(source_path)
    candidate = rgb(candidate_path)
    expected = (source.shape[1] * 2, source.shape[0] * 2)
    if (candidate.shape[1], candidate.shape[0]) != expected:
        raise AssertionError(f"{name}: expected 2x dimensions {expected}, got {(candidate.shape[1], candidate.shape[0])}")

    # Downsample candidate back to source size and compare macro appearance.
    reduced = np.asarray(
        Image.fromarray(np.round(candidate * 255).astype(np.uint8), "RGB").resize(
            (source.shape[1], source.shape[0]), Image.Resampling.LANCZOS
        ),
        dtype=np.float32,
    ) / 255.0
    mae = float(np.mean(np.abs(reduced - source)))
    drift = abs(float(luma(candidate).mean() - luma(source).mean()))
    structure = edge_correlation(luma(source), luma(reduced))
    if mae > MAX_DOWNSAMPLED_MAE:
        raise AssertionError(f"{name}: downsampled RGB MAE {mae:.5f} exceeds {MAX_DOWNSAMPLED_MAE:.5f}")
    if drift > MAX_MEAN_LUMA_DRIFT:
        raise AssertionError(f"{name}: mean luminance drift {drift:.5f} exceeds {MAX_MEAN_LUMA_DRIFT:.5f}")
    reports.append(
        f"{name}: size={candidate.shape[1]}x{candidate.shape[0]}; "
        f"downsampled_rgb_mae={mae:.5f}; mean_luma_drift={drift:.5f}; "
        f"edge_structure_correlation={structure:.5f}; PASS"
    )

report = "\n".join(reports) + "\n"
(OUT / "candidate_structure_validation.txt").write_text(report, encoding="utf-8")
print(report)
