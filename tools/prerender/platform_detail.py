#!/usr/bin/env python3
"""Detalle extra del andén norte para el fondo prerenderizado (solo se usa al
renderizar; el juego en el teléfono no carga estos modelos).
Genera render_src/scenes/platform_detail.tscn.
Uso: python3 tools/prerender/platform_detail.py
"""
import math
import os
import sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "level_gen"))
from tscn import Scene, v3, col, fmt

ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
PH = "res://render_src/polyhaven/%s/%s_1k.gltf"

# (modelo, posición, giro en Y, escala)
ITEMS = [
    ("metal_trash_can", (5.3, 0, 4.85), 0.3, 1.0),
    ("cardboard_box_01", (-6.3, 0, 4.4), 0.2, 1.0),
    ("cardboard_box_01", (-5.55, 0, 4.75), -0.5, 0.85),
    ("cardboard_box_01", (-6.25, 0.45, 4.45), 0.9, 0.75),
    ("wooden_crate_01", (6.2, 0, 4.55), 0.15, 1.0),
    ("wooden_crate_02", (6.3, 0, 0.55), -0.3, 1.0),
    ("vintage_suitcase", (-2.15, 0, 4.35), 1.2, 1.0),
    ("vintage_suitcase", (-4.5, 0, 4.1), -0.4, 1.0),
    ("barrel_03", (-6.5, 0, 0.45), 0.0, 1.0),
    ("cement_bag", (-5.8, 0, 1.05), 0.4, 1.0),
    ("cement_bag", (-5.85, 0.14, 1.15), -0.2, 1.0),
    ("korean_fire_extinguisher_01", (-2.55, 0, 5.12), math.pi, 1.0),
    ("fire_alarm", (-1.95, 1.55, 5.29), math.pi, 1.0),
    ("industrial_wall_lamp", (6.99, 2.7, 3.6), -math.pi / 2, 1.0),
    ("WetFloorSign_01", (-0.9, 0, 3.3), 0.7, 1.0),
    ("plastic_bottle_gallon", (2.25, 0, 4.95), 0.0, 1.0),
    ("spray_paint_bottles", (-3.7, 0, -0.55), 0.8, 1.0),
    ("wooden_bucket_01", (5.75, 0, 1.75), 0.0, 1.0),
    ("metal_jerrycan_green", (6.45, 0, 3.25), 1.1, 1.0),
    ("old_military_crate", (-6.35, 0, -0.45), 0.1, 1.0),
    ("street_lamp_01", (-6.2, -1.0, -4.9), 0.0, 1.0),
    ("street_lamp_01", (5.8, -1.0, -4.9), 0.0, 1.0),
]

s = Scene()
s.node("PlatformDetail", "Node3D")
for i, (model, pos, yaw, scale) in enumerate(ITEMS):
    p = {"position": v3(pos), "rotation": v3((0, yaw, 0))}
    if scale != 1.0:
        p["scale"] = v3((scale,) * 3)
    s.node("%s_%d" % (model, i), None, ".", instance=s.res(PH % (model, model), "PackedScene"), **p)
# Luz de los faroles de la vía (solo para el render: luz cálida de sodio).
for i, x in enumerate((-6.2, 5.8)):
    s.node("StreetLight%d" % i, "OmniLight3D", ".", position=v3((x, 3.0, -4.6)), light_color=col((1.0, 0.72, 0.42)),
           light_energy="1.6", omni_range="7.0", shadow_enabled="true")
os.makedirs(ROOT + "/render_src/scenes", exist_ok=True)
s.save(ROOT + "/render_src/scenes/platform_detail.tscn")
print("detalle del andén ok")
