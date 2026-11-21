#!/usr/bin/env python3
"""Escena de detalle SOLO para el render de «Vía norte» (no se carga en el teléfono).
Genera render_src/scenes/track_north_detail.tscn con: pasto y maleza al pie de los muros, rocas, restos del
tren, y el INCENDIO REAL dentro del túnel este (luces naranjas con niebla volumétrica, llamas, humo, el resto
del convoy volcado) en lugar del plano rojo plano del juego. Oculta ese plano al renderizar (metadato «hide»).
Uso: python3 tools/prerender/track_north_scene.py
"""
import math, os, random, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "level_gen"))
from tscn import Scene, v3, col, fmt

ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
PH = "res://render_src/polyhaven/%s/%s_1k.gltf"
PI = math.pi
rng = random.Random(42)
s = Scene()
s.node("TrackNorthDetail", "Node3D", **{"metadata/hide": '["Walls/EastTunnelPortal/EndGlow"]'})


def model(name, pos, yaw=0.0, sc=1.0, label=None):
    p = {"position": v3(pos), "rotation": v3((0, yaw, 0))}
    if abs(sc - 1.0) > 1e-3:
        p["scale"] = v3((sc,) * 3)
    s.node("%s_%d" % (label or name, len(s.nodes)), None, ".", instance=s.res(PH % (name, name), "PackedScene"), **p)


# Pasto y maleza al pie de los muros (nunca en el camino central).
for i in range(26):
    x = rng.uniform(-8.6, 8.4)
    model(rng.choice(["grass_medium_01", "grass_medium_02", "weed_plant_02", "nettle_plant", "dandelion_01"]),
          (x, 0.0, rng.uniform(-5.05, -4.5)), rng.uniform(0, 2 * PI), rng.uniform(0.8, 1.4))
for i in range(16):
    x = rng.uniform(-8.6, 8.4)
    model(rng.choice(["grass_medium_01", "weed_plant_02", "nettle_plant"]), (x, 0.0, rng.uniform(3.1, 3.4)),
          rng.uniform(0, 2 * PI), rng.uniform(0.8, 1.3))
# Rocas y escombro entre el balasto y el muro.
for i in range(10):
    model(rng.choice(["rock_07", "rock_09", "boulder_01", "rock_moss_set_01"]), (rng.uniform(-8, 8), 0.0, rng.uniform(-5.1, -4.3)),
          rng.uniform(0, 2 * PI), rng.uniform(0.35, 0.8))
for i in range(5):
    model(rng.choice(["rock_07", "rock_09"]), (rng.uniform(-8, 8), 0.0, rng.uniform(3.15, 3.4)), rng.uniform(0, 2 * PI), rng.uniform(0.3, 0.6))
# Restos del tren y de la gente que huyó hacia Paine.
model("vintage_suitcase", (-1.5, 0.0, 2.2), 0.7, 1.0)
model("vintage_suitcase", (2.2, 0.0, 2.9), -0.5, 1.0)
model("vintage_suitcase", (-5.4, 0.0, -3.6), 1.9, 1.0)
model("trashbag", (-3.0, 0.0, 3.0), 0.5, 1.0)
model("can_rusted", (0.8, 0.0, 1.6), 1.0, 1.0)
model("wooden_crate_02", (6.3, 0.0, 3.0), 0.2, 0.9)
model("dry_branches_medium_01", (-7.3, 0.0, -4.6), 0.4, 1.0)
model("old_tyre", (4.8, 0.0, 3.1), 0.0, 1.0)
model("modular_electric_cables", (-2.0, 3.6, -4.95), 0.0, 1.0)
model("modular_electric_cables", (3.0, 3.6, -4.95), 0.0, 1.0)

# Incendio real dentro del túnel este (x = 9..21): el resto del convoy volcado, llamas, humo y luz.
s.node("TunnelWreck", None, ".", instance=s.res("res://levels/kit/props/train_wagon_wrecked.tscn", "PackedScene"),
       position=v3((16.0, 0.4, -0.4)), rotation=v3((0.55, 0.08, 0.0)))
flame = s.subres("StandardMaterial3D", {"albedo_color": col((1.0, 0.45, 0.1)), "emission_enabled": "true",
                                        "emission": col((1.0, 0.42, 0.08)), "emission_energy_multiplier": "5.0"})
core = s.subres("StandardMaterial3D", {"albedo_color": col((1.0, 0.8, 0.4)), "emission_enabled": "true",
                                       "emission": col((1.0, 0.75, 0.35)), "emission_energy_multiplier": "7.0"})
for i, (x, y, z, r) in enumerate([(14.2, 0.5, 0.7, 0.35), (15.3, 0.8, -0.6, 0.5), (16.4, 0.6, 0.5, 0.4), (17.5, 1.0, -0.3, 0.55),
                                  (13.0, 0.3, -0.9, 0.3), (18.6, 0.7, 0.8, 0.4)]):
    s.node("Flame%d" % i, "MeshInstance3D", ".", position=v3((x, y, z)), scale=v3((1.0, 1.7, 1.0)),
           mesh=s.subres("SphereMesh", {"radius": fmt(r), "height": fmt(2 * r)}), material_override=flame, cast_shadow="0")
    s.node("FlameCore%d" % i, "MeshInstance3D", ".", position=v3((x, y - 0.05, z)), scale=v3((0.5, 1.2, 0.5)),
           mesh=s.subres("SphereMesh", {"radius": fmt(r), "height": fmt(2 * r)}), material_override=core, cast_shadow="0")
for i, (x, y, z, e, r) in enumerate([(13.5, 1.2, 0.0, 9.0, 14.0), (16.5, 1.6, 0.4, 11.0, 16.0), (19.0, 1.2, -0.5, 9.0, 14.0)]):
    s.node("FireLight%d" % i, "OmniLight3D", ".", position=v3((x, y, z)), light_color=col((1.0, 0.45, 0.14)), light_energy=fmt(e),
           omni_range=fmt(r), shadow_enabled="true", light_volumetric_fog_energy="4.0")
# Niebla volumétrica con resplandor: el túnel se ve «lleno de luz» y de humo, no un plano rojo.
s.node("TunnelFog", "FogVolume", ".", position=v3((15.5, 2.0, 0.0)), size=v3((13.0, 5.0, 5.0)),
       material=s.subres("FogMaterial", {"density": "1.6", "albedo": col((0.35, 0.3, 0.28)), "emission": col((0.9, 0.32, 0.08)),
                                         "height_falloff": "1.2", "edge_fade": "0.4"}))
s.node("MouthSmoke", "FogVolume", ".", position=v3((9.5, 2.6, -1.2)), size=v3((5.0, 4.5, 5.0)),
       material=s.subres("FogMaterial", {"density": "0.8", "albedo": col((0.22, 0.2, 0.2)), "emission": col((0.35, 0.12, 0.04)),
                                         "height_falloff": "0.5", "edge_fade": "0.6"}))
# Brasas junto al vagón destrozado del ramal (luz baja y cálida sobre el piso).
s.node("EmberLight", "OmniLight3D", ".", position=v3((6.2, 0.4, -2.2)), light_color=col((1.0, 0.4, 0.12)), light_energy="2.2",
       omni_range="5.0", shadow_enabled="true", light_volumetric_fog_energy="2.0")
# Resplandor de la luna sobre el balasto (relleno frío para separar los planos).
s.node("MoonFill", "OmniLight3D", ".", position=v3((-1.0, 4.5, 0.5)), light_color=col((0.55, 0.65, 0.95)), light_energy="1.6",
       omni_range="14.0", shadow_enabled="true")
os.makedirs(ROOT + "/render_src/scenes", exist_ok=True)
s.save(ROOT + "/render_src/scenes/track_north_detail.tscn")
print("detalle track_north: %d nodos" % len(s.nodes))
