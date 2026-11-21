#!/usr/bin/env python3
"""Escena de detalle SOLO para el render de «Costado del convoy» (no se carga en el teléfono).
Pone los TRENES REALES (modelos CC0 de tevy.dev y grab3d.com, ver fetch_trains.py) en lugar de las cajas de
choque del juego, a escala 1:1, más luces de incendio, humo volumétrico, maleza y restos.
Primero: python3 tools/prerender/fetch_trains.py   Luego: python3 tools/prerender/convoy_side_scene.py
"""
import math, os, random, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "level_gen"))
from tscn import Scene, v3, col, fmt

ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
PH = "res://render_src/polyhaven/%s/%s_1k.gltf"
TR = "res://render_src/trains/%s.glb"
PI = math.pi
rng = random.Random(7)
s = Scene()
s.node("ConvoySideDetail", "Node3D", **{"metadata/hide": '["Props/Coach", "Props/Freight"]'})
# centro (en el marco del modelo) de cada tren: se resta para que el nodo contenedor quede en el centro.
CENTER_Y = {"locomotive": 2.9358, "freight_wagon": 2.6968, "passenger_car": 2.1094}


def train(label, model, pos, rot):
    s.node(label, "Node3D", ".", position=v3(pos), rotation=v3(rot))
    s.node(label + "Mesh", None, label, instance=s.res(TR % model, "PackedScene"), position=v3((0, -CENTER_Y[model], 0)))


def ph(name, pos, yaw=0.0, sc=1.0):
    p = {"position": v3(pos), "rotation": v3((0, yaw, 0))}
    if abs(sc - 1.0) > 1e-3:
        p["scale"] = v3((sc,) * 3)
    s.node("%s_%d" % (name, len(s.nodes)), None, ".", instance=s.res(PH % (name, name), "PackedScene"), **p)


# Coche de pasajeros que entra por el túnel oeste y vagón de carga que sale por el este, sobre la vía (z = -2).
train("Coach", "passenger_car", (-4.0, 2.25, -2.0), (0.0, -PI / 2, 0.0))
train("Freight", "freight_wagon", (16.7, 2.85, -2.0), (0.0, PI / 2, 0.0))

# Maleza, rocas y restos por el costado sur y junto a las paredes.
for i in range(40):
    ph(rng.choice(["grass_medium_01", "grass_medium_02", "weed_plant_02", "nettle_plant", "dandelion_01"]),
       (rng.uniform(-12.5, 12.0), 0.0, rng.uniform(2.3, 3.3)), rng.uniform(0, 2 * PI), rng.uniform(0.8, 1.4))
for i in range(10):
    ph(rng.choice(["rock_07", "rock_09", "boulder_01", "rock_moss_set_01"]), (rng.uniform(-12.5, 12.0), 0.0, rng.uniform(2.6, 3.3)),
       rng.uniform(0, 2 * PI), rng.uniform(0.3, 0.6))
for pos, yaw in (((-9.5, 0, 2.4), 0.3), ((6.0, 0, 2.7), 1.1), ((-1.0, 0, 1.0), 0.7)):
    ph("vintage_suitcase", pos, yaw)
ph("trashbag", (-11.0, 0.0, 2.8), 0.3)
ph("wooden_crate_02", (11.5, 0.0, 3.0), 0.5, 0.9)
ph("dry_branches_medium_01", (-4.0, 0.0, 3.0), 0.3)

# Luces: incendio al sur de la vía, resplandor rojo en el túnel este, luna fría y humo.
for i, (x, y, z, e, r) in enumerate([(3.8, 1.2, 1.0, 3.2, 9.0), (14.5, 1.6, -2.0, 3.0, 9.0), (-14.5, 1.6, -2.0, 1.2, 8.0)]):
    s.node("FireLight%d" % i, "OmniLight3D", ".", position=v3((x, y, z)), light_color=col((1.0, 0.45, 0.14)), light_energy=fmt(e),
           omni_range=fmt(r), shadow_enabled="true", light_volumetric_fog_energy="3.0")
s.node("DoorLamp", "OmniLight3D", ".", position=v3((12.0, 2.5, 1.6)), light_color=col((1.0, 0.6, 0.28)), light_energy="6.0",
       omni_range="8.0", shadow_enabled="true", light_volumetric_fog_energy="1.5")
s.node("MoonFill", "OmniLight3D", ".", position=v3((-1.0, 5.2, 1.0)), light_color=col((0.55, 0.65, 0.95)), light_energy="4.0",
       omni_range="22.0", shadow_enabled="true")
s.node("Smoke", "FogVolume", ".", position=v3((6.0, 2.2, 0.5)), size=v3((16.0, 5.0, 6.0)),
       material=s.subres("FogMaterial", {"density": "0.45", "albedo": col((0.26, 0.24, 0.24)), "emission": col((0.1, 0.04, 0.02)),
                                         "height_falloff": "0.35", "edge_fade": "0.5"}))
os.makedirs(ROOT + "/render_src/scenes", exist_ok=True)
s.save(ROOT + "/render_src/scenes/convoy_side_detail.tscn")
print("detalle convoy_side: %d nodos" % len(s.nodes))
