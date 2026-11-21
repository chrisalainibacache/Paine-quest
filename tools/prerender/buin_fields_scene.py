#!/usr/bin/env python3
"""Escenas de detalle SOLO para el render del Potrero y la Viña (no se cargan en el teléfono).
Reemplazan los árboles y cerros de cajas/conos del juego por vegetación real de Poly Haven (CC0): árboles,
arbustos, pasto, helechos, rocas y cerros lejanos, con cielo de amanecer. Uso: python3 tools/prerender/buin_fields_scene.py
Antes: python3 tools/prerender/fetch_polyhaven.py tree_small_02 island_tree_01 island_tree_02 shrub_01 shrub_03 grass_bermuda_01 fern_02 mountainside
"""
import math, os, random, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "level_gen"))
from tscn import Scene, v3, col, fmt

import subprocess
ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
PH = "res://render_src/polyhaven/%s/%s_1k.gltf"
PI = math.pi
LITE = ("tree_small_02", "island_tree_01", "island_tree_02", "shrub_01")   # los modelos de Poly Haven traen millones de triángulos: se simplifican


def ensure_lite():
    gt = os.environ.get("GLTF_TRANSFORM", "gltf-transform")
    os.makedirs(ROOT + "/render_src/polyhaven_lite", exist_ok=True)
    for n in LITE:
        out = "%s/render_src/polyhaven_lite/%s.glb" % (ROOT, n)
        if not os.path.exists(out):
            subprocess.run([gt, "simplify", "%s/render_src/polyhaven/%s/%s_1k.gltf" % (ROOT, n, n), out, "--ratio", "0.03", "--error", "0.03"], check=True)


ensure_lite()


def build(room, x0, x1, z0, z1, extra_rows=False):
    rng = random.Random(hash(room) % 1000)
    s = Scene()
    # Se oculta lo de cajas del juego que se reemplaza: árboles y cerros de relleno y las cajas de cielo (el cielo es el del entorno).
    hide = ["Props/Trunk%d" % i for i in range(32)] + ["Props/Crown%d" % i for i in range(32)]
    hide += ["Backdrop/HillN", "Backdrop/HillS", "Backdrop/SkyN", "Backdrop/SkyS", "Backdrop/SkyW", "Backdrop/SkyE", "Backdrop/SkyTop"]
    s.node("%sDetail" % room.capitalize(), "Node3D", **{"metadata/hide": "[%s]" % ", ".join('"%s"' % h for h in hide), "metadata/sky": "true"})

    def ph(name, pos, yaw=0.0, sc=1.0):
        path = ("res://render_src/polyhaven_lite/%s.glb" % name) if name in LITE else (PH % (name, name))
        s.node("%s_%d" % (name, len(s.nodes)), None, ".", instance=s.res(path, "PackedScene"),
               position=v3(pos), rotation=v3((0, yaw, 0)), scale=v3((sc,) * 3))

    W = x1 - x0
    # Árboles a los lados (norte y sur), por delante de los cerros.
    trees = ["tree_small_02", "island_tree_01", "island_tree_02"]
    for side in (-1, 1):
        for i in range(7):
            x = x0 - 3 + i * ((W + 6) / 6) + rng.uniform(-1.2, 1.2)
            z = (z0 - 5.5 - rng.uniform(0, 4)) if side < 0 else (z1 + 5.5 + rng.uniform(0, 4))
            ph(rng.choice(trees), (x, 0.0, z), rng.uniform(0, 2 * PI), rng.uniform(1.3, 2.0))
    # Cerros lejanos.
    for side in (-1, 1):
        for i, xx in enumerate((-18, 0, 18)):
            zz = (z0 - 22) if side < 0 else (z1 + 22)
            ph("mountainside", (xx + rng.uniform(-3, 3), -1.0, zz), rng.uniform(0, 2 * PI), 4.4)
    # Pasto, maleza y helechos pegados al cerco por fuera, y manchones por dentro.
    for i in range(90):
        side = rng.choice((-1, 1))
        z = (z0 - rng.uniform(0.3, 6.0)) if side < 0 else (z1 + rng.uniform(0.3, 6.0))
        ph(rng.choice(["grass_medium_01", "grass_bermuda_01", "shrub_03", "fern_02", "weed_plant_02", "nettle_plant"]),
           (rng.uniform(x0 - 6, x1 + 6), 0.0, z), rng.uniform(0, 2 * PI), rng.uniform(0.9, 1.7))
    for side in (-1, 1):
        for i in range(8):
            x = rng.uniform(x0 - 2, x1 + 2)
            z = (z0 - 2.2 - rng.uniform(0, 2.5)) if side < 0 else (z1 + 2.2 + rng.uniform(0, 2.5))
            ph("shrub_01", (x, 0.0, z), rng.uniform(0, 2 * PI), rng.uniform(1.6, 2.6))
    for i in range(22):  # pasto seco dentro del campo, en manchones junto al cerco
        side = rng.choice((-1, 1))
        z = (z0 + rng.uniform(0.3, 1.2)) if side < 0 else (z1 - rng.uniform(0.3, 1.2))
        ph(rng.choice(["grass_medium_01", "grass_bermuda_01"]), (rng.uniform(x0 + 1, x1 - 1), 0.0, z), rng.uniform(0, 2 * PI), rng.uniform(0.8, 1.3))
    for i in range(10):
        ph(rng.choice(["rock_07", "rock_09", "boulder_01", "rock_moss_set_01"]),
           (rng.uniform(x0 - 4, x1 + 4), 0.0, (z0 - rng.uniform(1, 4)) if rng.random() < 0.5 else (z1 + rng.uniform(1, 4))), rng.uniform(0, 2 * PI), rng.uniform(0.5, 1.1))
    if extra_rows:  # la viña sigue más allá del cerco
        vine = "res://levels/kit/props/vine_row.tscn"
        for j, zz in enumerate((z0 - 3.0, z0 - 5.0, z1 + 3.0, z1 + 5.0)):
            for xx in (-6.0, 2.0):
                s.node("OuterVines%d_%d" % (j, int(xx)), None, ".", instance=s.res(vine, "PackedScene"), position=v3((xx, 0.0, zz)))
    # Luz de amanecer: el Sol del juego ya proyecta sombras; un relleno cálido bajo y niebla suave con luz.
    s.node("DawnFill", "OmniLight3D", ".", position=v3((0.0, 6.0, 0.0)), light_color=col((1.0, 0.86, 0.7)), light_energy="2.0",
           omni_range="24.0", shadow_enabled="false")
    s.node("MistFog", "FogVolume", ".", position=v3(((x0 + x1) / 2, 1.2, (z0 + z1) / 2)), size=v3((W + 30, 3.0, (z1 - z0) + 30)),
           material=s.subres("FogMaterial", {"density": "0.05", "albedo": col((0.85, 0.85, 0.88)), "emission": col((0.18, 0.17, 0.15)),
                                             "height_falloff": "1.4", "edge_fade": "0.4"}))
    os.makedirs(ROOT + "/render_src/scenes", exist_ok=True)
    s.save(ROOT + "/render_src/scenes/%s_detail.tscn" % room)
    print("detalle %s: %d nodos" % (room, len(s.nodes)))


build("field", -10.0, 10.0, -6.0, 6.0)
build("vineyard", -10.0, 10.0, -5.0, 5.0, extra_rows=True)
