#!/usr/bin/env python3
"""Escena de detalle SOLO para el render de «Tren descarrilado» (no se carga en el teléfono).
Pone los TRENES REALES (modelos CC0 de tevy.dev y grab3d.com, ver fetch_trains.py) en lugar de las cajas de
choque del juego, a escala 1:1, más luces de incendio, humo volumétrico, maleza y restos.
Primero: python3 tools/prerender/fetch_trains.py   Luego: python3 tools/prerender/derailed_train_scene.py
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
s.node("DerailedTrainDetail", "Node3D", **{"metadata/hide": '["Props/Locomotive", "Props/Wagon", "Props/JackknifeWagon"]'})
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


# Locomotora volcada: techo hacia el norte (contra el muro), ruedas y bogies hacia el pasillo.
train("Loco", "locomotive", (-1.0, 1.72, -2.75), (0.0, PI / 2, -PI / 2))
# Coche de pasajeros fuera de la vía, ladeado sobre el balasto.
train("Coach", "passenger_car", (0.5, 2.0, 3.95), (0.0, PI / 2, 0.11))
# Vagón de carga clavado en la boca del túnel este.
train("Freight", "freight_wagon", (15.8, 2.65, 0.4), (0.0, PI / 2 + 0.18, 0.05))

# Maleza, rocas y restos en los costados libres.
for i in range(28):
    ph(rng.choice(["grass_medium_01", "grass_medium_02", "weed_plant_02", "nettle_plant", "dandelion_01"]),
       (rng.uniform(-12.8, -8.0), 0.0, rng.uniform(-1.0, 5.8)), rng.uniform(0, 2 * PI), rng.uniform(0.8, 1.4))
for i in range(18):
    ph(rng.choice(["grass_medium_01", "weed_plant_02", "nettle_plant"]), (rng.uniform(-8.0, 6.5), 0.0, rng.uniform(2.0, 2.45)),
       rng.uniform(0, 2 * PI), rng.uniform(0.7, 1.2))
for i in range(10):
    ph(rng.choice(["rock_07", "rock_09", "boulder_01", "rock_moss_set_01"]), (rng.uniform(-12.5, -7.5), 0.0, rng.uniform(-0.2, 5.5)),
       rng.uniform(0, 2 * PI), rng.uniform(0.3, 0.7))
for pos, yaw in (((-9.5, 0, 3.2), 0.4), ((-5.5, 0, 2.3), 1.7), ((2.8, 0, 2.2), -0.6), ((-2.0, 0, -0.1), 2.4)):
    ph("vintage_suitcase", pos, yaw)
ph("trashbag", (-11.0, 0.0, 4.6), 0.3)
ph("can_rusted", (-3.0, 0.0, 1.9), 0.0)
ph("wooden_crate_02", (-10.6, 0.0, 1.9), 0.5, 0.9)
ph("dry_branches_medium_01", (-8.3, 0.0, 4.4), 0.3)

# Luces del incendio y humo volumétrico.
for i, (x, y, z, e, r) in enumerate([(6.3, 1.3, -0.1, 3.2, 9.0), (-3.6, 1.0, -0.3, 2.4, 8.0), (11.5, 1.6, 0.6, 3.5, 10.0), (16.0, 1.6, 1.0, 3.0, 9.0)]):
    s.node("FireLight%d" % i, "OmniLight3D", ".", position=v3((x, y, z)), light_color=col((1.0, 0.45, 0.14)), light_energy=fmt(e),
           omni_range=fmt(r), shadow_enabled="true", light_volumetric_fog_energy="3.5")
s.node("SmokeLoco", "FogVolume", ".", position=v3((-1.0, 3.2, -1.2)), size=v3((22.0, 6.0, 5.0)),
       material=s.subres("FogMaterial", {"density": "0.55", "albedo": col((0.26, 0.24, 0.24)), "emission": col((0.1, 0.04, 0.02)),
                                         "height_falloff": "0.35", "edge_fade": "0.5"}))
s.node("SmokeTunnel", "FogVolume", ".", position=v3((14.0, 2.4, 0.8)), size=v3((8.0, 5.0, 5.0)),
       material=s.subres("FogMaterial", {"density": "1.2", "albedo": col((0.3, 0.27, 0.26)), "emission": col((0.3, 0.1, 0.03)),
                                         "height_falloff": "0.8", "edge_fade": "0.5"}))
# Lámpara de la puerta de servicio (muro oeste): que se vea la puerta por la que llegó Isabella.
s.node("DoorLamp", "OmniLight3D", ".", position=v3((-12.0, 2.5, 1.0)), light_color=col((1.0, 0.6, 0.28)), light_energy="7.0",
       omni_range="9.0", shadow_enabled="true", light_volumetric_fog_energy="1.5")
# Relleno frío en el extremo oeste, para que se vea la puerta y la llegada de Isabella.
s.node("WestFill", "OmniLight3D", ".", position=v3((-9.0, 3.2, 1.0)), light_color=col((0.55, 0.65, 0.95)), light_energy="3.0",
       omni_range="9.0", shadow_enabled="true")
s.node("MoonFill", "OmniLight3D", ".", position=v3((-2.0, 5.2, 1.2)), light_color=col((0.55, 0.65, 0.95)), light_energy="4.0",
       omni_range="22.0", shadow_enabled="true")
os.makedirs(ROOT + "/render_src/scenes", exist_ok=True)
s.save(ROOT + "/render_src/scenes/derailed_train_detail.tscn")
print("detalle derailed_train: %d nodos" % len(s.nodes))
