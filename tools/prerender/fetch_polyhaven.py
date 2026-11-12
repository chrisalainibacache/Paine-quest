#!/usr/bin/env python3
"""Descarga los modelos de Poly Haven (CC0) que se usan para armar los fondos
prerenderizados. Quedan en render_src/polyhaven/<id>/ (no se suben al repo: se
vuelven a bajar con este script). Uso: python3 tools/prerender/fetch_polyhaven.py
"""
import json
import os
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "render_src" / "polyhaven"
MODELS = [
    "metal_trash_can", "cardboard_box_01", "wooden_crate_01", "wooden_crate_02", "vintage_suitcase",
    "barrel_03", "cement_bag", "korean_fire_extinguisher_01", "fire_alarm", "industrial_wall_lamp",
    "WetFloorSign_01", "plastic_bottle_gallon", "spray_paint_bottles", "wooden_bucket_01",
    "metal_jerrycan_green", "old_military_crate", "street_lamp_01", "modular_electric_cables",
    # Capítulo 1 (interiores).
    "plastic_monobloc_chair_01", "trashbag", "potted_plant_04", "standing_chalkboard_01",
    "drawer_cabinet", "binder_notebook", "clipboard", "desk_lamp_arm_01", "vintage_telephone_wall_clock",
    "painted_wooden_chair_02", "medical_box", "power_box_01", "utility_box_01", "plastic_broom",
    "wooden_bucket_02", "bleach_bottle", "multi_cleaner_bottle", "portable_generator", "wooden_ladder",
    "compost_bags", "oil_tin", "old_gas_mask", "pipe_wrench", "plastic_crate_01", "plastic_crate_02",
    "portable_searchlight", "street_lamp_02", "wooden_military_crate",
]


def get(url: str) -> bytes:
    req = urllib.request.Request(url, headers={"User-Agent": "paine-prerender"})
    with urllib.request.urlopen(req, timeout=60) as r:
        return r.read()


def fetch(model: str) -> None:
    if (OUT / model / ("%s_1k.gltf" % model)).exists():
        return
    files = json.loads(get("https://api.polyhaven.com/files/" + model))
    entry = files["gltf"]["1k"]["gltf"]
    dest = OUT / model
    dest.mkdir(parents=True, exist_ok=True)
    (dest / Path(entry["url"]).name).write_bytes(get(entry["url"]))
    for rel, inc in entry.get("include", {}).items():
        target = dest / rel
        target.parent.mkdir(parents=True, exist_ok=True)
        if not target.exists():
            target.write_bytes(get(inc["url"]))
    print("listo:", model)


if __name__ == "__main__":
    for m in MODELS:
        fetch(m)
    (OUT / "LICENSE.txt").write_text("Modelos de Poly Haven (https://polyhaven.com), licencia CC0.\n")
