#!/usr/bin/env python3
"""Detalle extra de cada sala para los fondos prerenderizados (solo se usa al
renderizar; el juego en el teléfono no carga estos modelos).
Genera render_src/scenes/<sala>_detail.tscn para cada sala de ROOMS.
Uso: python3 tools/prerender/room_details.py [sala ...]

Reglas: pegado a muros y rincones, nunca en el camino de Isabella ni encima de
ítems, notas o puertas (el detalle no existe en el juego: no choca ni tapa).
"""
import math
import os
import sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "level_gen"))
from tscn import Scene, v3, col

ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
PH = "res://render_src/polyhaven/%s/%s_1k.gltf"
PI = math.pi

# sala: (lista de (modelo, posición, giro Y, escala), luces extra (pos, color, energía, alcance))
ROOMS = {
    "platform": ([
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
        ("korean_fire_extinguisher_01", (-2.55, 0, 5.12), PI, 1.0),
        ("fire_alarm", (-1.95, 1.55, 5.29), PI, 1.0),
        ("industrial_wall_lamp", (6.99, 2.7, 3.6), -PI / 2, 1.0),
        ("WetFloorSign_01", (-0.9, 0, 3.3), 0.7, 1.0),
        ("plastic_bottle_gallon", (2.25, 0, 4.95), 0.0, 1.0),
        ("spray_paint_bottles", (-3.7, 0, -0.55), 0.8, 1.0),
        ("wooden_bucket_01", (5.75, 0, 1.75), 0.0, 1.0),
        ("metal_jerrycan_green", (6.45, 0, 3.25), 1.1, 1.0),
        ("old_military_crate", (-6.35, 0, -0.45), 0.1, 1.0),
        ("street_lamp_01", (-6.2, -1.0, -4.9), 0.0, 1.0),
        ("street_lamp_01", (5.8, -1.0, -4.9), 0.0, 1.0),
        # Segunda pasada de detalle: cabina, cámara, vegetación junto a la vía, basura.
        ("korean_public_payphone_01", (-5.25, 0, 5.1), PI, 1.0),
        ("security_camera_01", (-5.3, 3.05, 5.25), PI, 1.0),
        ("grass_medium_01", (-5.0, -1.0, -2.0), 0.3, 1.0),
        ("grass_medium_02", (1.5, -1.0, -2.2), 1.1, 1.0),
        ("weed_plant_02", (-1.2, -1.0, -4.4), 0.5, 1.0),
        ("grass_medium_01", (5.2, -1.0, -4.3), 2.0, 1.1),
        ("nettle_plant", (-3.0, -1.0, -4.6), 0.0, 1.0),
        ("old_tyre", (0.6, -1.0, -4.6), 0.4, 1.0),
        ("can_rusted", (5.0, 0, -0.7), 0.7, 1.0),
        ("street_rat", (-1.6, 0, -0.62), 1.9, 1.0),
        ("Megaphone_01", (-6.5, 0, 1.65), 0.5, 1.0),
        ("dirty_football", (4.0, 0, -0.65), 0.0, 1.0),
    ], [((-6.2, 3.0, -4.6), (1.0, 0.72, 0.42), 1.6, 7.0), ((5.8, 3.0, -4.6), (1.0, 0.72, 0.42), 1.6, 7.0)]),

    # Sala de espera: 9 x 7 m (x -4.5..4.5, z -3.5..3.5).
    "waiting_room": ([
        ("plastic_monobloc_chair_01", (-4.0, 0, 0.4), PI / 2 + 0.3, 1.0),
        ("plastic_monobloc_chair_01", (-3.7, 0, 1.4), PI / 2 - 0.5, 1.0),
        ("trashbag", (-4.15, 0, 2.85), 0.4, 1.0),
        ("trashbag", (-3.7, 0, 3.1), 1.7, 0.85),
        ("potted_plant_04", (4.15, 0, 3.05), 0.0, 1.0),
        ("cardboard_box_01", (1.3, 0, 3.15), 0.3, 0.9),
        ("vintage_suitcase", (-0.7, 0, 3.05), 0.2, 1.0),
        ("metal_trash_can", (3.1, 0, 3.15), 0.0, 1.0),
        ("standing_chalkboard_01", (-4.05, 0, -1.25), PI / 2, 1.0),
        ("korean_fire_extinguisher_01", (4.3, 0, -3.15), -PI / 2, 1.0),
        ("fire_alarm", (4.48, 1.5, -2.4), -PI / 2, 1.0),
        ("spray_paint_bottles", (-2.0, 0, -3.05), 0.6, 1.0),
    ], []),

    # Boletería: 5 x 4 m (x -2.5..2.5, z -2..2). Escritorio del guardia al oeste.
    "ticket_office": ([
        ("drawer_cabinet", (2.15, 0, -1.65), -PI / 2, 1.0),
        ("binder_notebook", (-1.9, 1.05, 1.72), 0.3, 1.0),
        ("binder_notebook", (-1.55, 1.05, 1.7), 1.2, 1.0),
        ("medical_box", (0.35, 1.05, 1.7), 0.2, 1.0),
        ("clipboard", (-2.1, 0.77, 0.35), 0.4, 1.0),
        ("desk_lamp_arm_01", (-2.2, 0.77, -0.95), PI / 2, 1.0),
        ("vintage_telephone_wall_clock", (-2.47, 1.55, 0.95), PI / 2, 1.0),
        ("painted_wooden_chair_02", (-1.35, 0, -0.35), -PI / 2 + 0.2, 1.0),
        ("trashbag", (0.8, 0, -1.6), 0.9, 0.8),
        ("cardboard_box_01", (1.2, 0, 1.0), 0.6, 0.7),
    ], []),

    # Pasillo de servicio: 12 x 2 m (x -6..6, z -1..1). Casilleros al norte.
    "service_corridor": ([
        ("power_box_01", (2.0, 1.35, 0.95), PI, 1.0),
        ("utility_box_01", (3.0, 1.55, 0.96), PI, 1.0),
        ("utility_box_01", (-4.3, 1.6, -0.96), 0.0, 1.0),
        ("plastic_broom", (4.75, 0, -0.85), 0.2, 1.0),
        ("wooden_bucket_02", (4.25, 0, -0.75), 0.0, 1.0),
        ("bleach_bottle", (3.9, 0, -0.85), 0.5, 1.0),
        ("multi_cleaner_bottle", (3.7, 0, -0.8), 1.4, 1.0),
        ("trashbag", (-0.6, 0, 0.8), 0.3, 0.8),
        ("plastic_crate_02", (0.9, 0, -0.75), 0.1, 1.0),
        ("WetFloorSign_01", (-4.6, 0, 0.7), 0.9, 1.0),
    ], []),

    # Bodega: 7 x 6 m (x -3.5..3.5, z -3..3). Cajones al este, mesa al sureste.
    "storeroom": ([
        ("portable_generator", (-2.75, 0, -0.6), PI / 2, 1.0),
        ("wooden_ladder", (-1.0, 0, 2.85), 0.0, 1.0),
        ("compost_bags", (1.5, 0, 2.55), 0.2, 1.0),
        ("metal_jerrycan_green", (-2.85, 0, -1.7), 0.7, 1.0),
        ("oil_tin", (-2.5, 0, 0.35), 0.0, 1.0),
        ("old_gas_mask", (0.25, 0.76, 0.55), 0.8, 1.0),
        ("pipe_wrench", (1.0, 0, -1.25), 1.1, 1.0),
        ("plastic_crate_01", (-2.9, 0, 2.55), 0.3, 1.0),
        ("cement_bag", (1.9, 0, -2.6), 0.2, 1.0),
        ("wooden_military_crate", (-0.5, 0, -2.55), 0.0, 1.0),
    ], []),

    # Andén sur: como el norte (x -6..6, andén z -1..5, vía al norte).
    "south_platform": ([
        ("metal_trash_can", (-3.6, 0, 4.7), 0.0, 1.0),
        ("vintage_suitcase", (2.5, 0, 3.0), 0.7, 1.0),
        ("vintage_suitcase", (0.9, 0.49, 3.6), -0.3, 0.9),
        ("cardboard_box_01", (5.4, 0, 4.4), 0.4, 1.0),
        ("trashbag", (4.6, 0, 4.6), 0.0, 1.0),
        ("wooden_crate_02", (5.5, 0, 3.3), 0.2, 1.0),
        ("plastic_crate_02", (-5.5, 0, 4.4), -0.4, 1.0),
        ("portable_searchlight", (-4.4, 0, -0.6), 0.6, 1.0),
        ("spray_paint_bottles", (2.0, 0, -0.6), 0.4, 1.0),
        ("street_lamp_02", (-4.5, -1.0, -4.6), 0.0, 1.0),
        ("street_lamp_02", (4.5, -1.0, -4.6), 0.0, 1.0),
    ], [((-4.5, 3.0, -4.3), (1.0, 0.72, 0.42), 1.4, 7.0), ((4.5, 3.0, -4.3), (1.0, 0.72, 0.42), 1.4, 7.0)]),
}


# --- Reparto automático por los bordes de la sala (tools/prerender/edge_slots.gd) ---
# tema -> lista de (modelo, escala mínima, escala máxima)
THEMES = {
    "vias": [("rock_07", 0.7, 1.2), ("rock_09", 0.6, 1.1), ("stone_01", 0.8, 1.3), ("grass_medium_01", 0.9, 1.3),
             ("grass_medium_02", 0.9, 1.3), ("weed_plant_02", 0.9, 1.2), ("nettle_plant", 0.9, 1.2), ("old_tyre", 1.0, 1.0),
             ("wooden_crate_02", 0.9, 1.1), ("metal_jerrycan_green", 1.0, 1.0), ("can_rusted", 1.0, 1.0),
             ("dry_branches_medium_01", 0.8, 1.2), ("rusted_wheel_rim_01", 1.0, 1.0), ("barrel_03", 1.0, 1.0),
             ("trashbag", 0.8, 1.0), ("cardboard_box_01", 0.8, 1.0), ("sledgehammer_01", 1.0, 1.0)],
    "casilla": [("wooden_crate_01", 0.9, 1.1), ("metal_toolbox", 1.0, 1.0), ("metal_tool_chest", 1.0, 1.0),
                ("cardboard_box_01", 0.8, 1.0), ("wooden_bucket_01", 1.0, 1.0), ("plastic_crate_01", 1.0, 1.0),
                ("trashbag", 0.8, 1.0), ("wooden_broom", 1.0, 1.0), ("wooden_ladder_02", 1.0, 1.0), ("tire_pump", 1.0, 1.0),
                ("steel_frame_shelves_01", 1.0, 1.0)],
    "tunel": [("trashbag", 0.8, 1.0), ("cardboard_box_01", 0.8, 1.0), ("barrel_03", 1.0, 1.0), ("wooden_crate_01", 0.9, 1.1),
              ("plastic_crate_02", 1.0, 1.0), ("old_military_crate", 1.0, 1.0), ("can_rusted", 1.0, 1.0),
              ("stone_01", 0.8, 1.3), ("rock_07", 0.6, 1.0), ("metal_jerrycan_green", 1.0, 1.0)],
    "vagon": [("vintage_suitcase", 0.9, 1.0), ("trashbag", 0.8, 1.0), ("wicker_basket_01", 1.0, 1.0)],
    "campo": [("shrub_02", 0.9, 1.4), ("shrub_03", 0.9, 1.4), ("shrub_04", 0.9, 1.4), ("grass_medium_01", 1.0, 1.5),
              ("grass_medium_02", 1.0, 1.5), ("weed_plant_02", 1.0, 1.3), ("rock_07", 0.8, 1.4), ("stone_01", 0.8, 1.4),
              ("tree_stump_01", 0.8, 1.2), ("dead_tree_trunk_02", 0.5, 0.8), ("dry_branches_medium_01", 0.8, 1.2),
              ("wooden_crate_02", 0.9, 1.1), ("old_tyre", 1.0, 1.0)],
    "viña": [("shrub_02", 0.9, 1.3), ("shrub_03", 0.9, 1.3), ("grass_medium_01", 1.0, 1.5), ("grass_medium_02", 1.0, 1.5),
             ("wine_barrel_01", 1.0, 1.0), ("wooden_barrels_01", 1.0, 1.0), ("wooden_crate_02", 0.9, 1.1),
             ("wicker_basket_01", 1.0, 1.0), ("watering_can_metal_01", 1.0, 1.0), ("planter_box_01", 1.0, 1.0),
             ("hand_truck", 1.0, 1.0), ("rock_07", 0.7, 1.2)],
    "militar": [("old_military_crate", 1.0, 1.0), ("wooden_military_crate", 1.0, 1.0), ("ammo_box", 1.0, 1.0),
                ("propane_tank", 1.0, 1.0), ("plastic_jerrycan", 1.0, 1.0), ("metal_jerrycan_green", 1.0, 1.0),
                ("old_military_compressor", 1.0, 1.0), ("trashbag", 0.8, 1.0), ("cardboard_box_01", 0.8, 1.0),
                ("grass_medium_02", 0.9, 1.2), ("rock_09", 0.7, 1.0)],
    "galpon": [("wooden_crate_01", 0.9, 1.1), ("wine_barrel_01", 1.0, 1.0), ("wooden_barrels_01", 1.0, 1.0),
               ("metal_tool_chest", 1.0, 1.0), ("hand_truck", 1.0, 1.0), ("wooden_ladder_02", 1.0, 1.0),
               ("plastic_jerrycan", 1.0, 1.0), ("propane_tank", 1.0, 1.0), ("tire_pump", 1.0, 1.0),
               ("rusted_spade_01", 1.0, 1.0), ("cement_bag", 1.0, 1.0)],
}
# sala -> (tema, cada cuántos metros como mínimo, máximo de objetos)
SCATTER = {
    "convoy_side": ("vias", 1.6, 22), "derailed_train": ("vias", 1.5, 22),     "switch_house": ("casilla", 1.3, 12), "underpass": ("tunel", 1.8, 18), "wagon_interior": ("vagon", 1.5, 4),
    "bridge": ("militar", 1.8, 18), "checkpoint": ("militar", 1.6, 22), "field": ("campo", 2.0, 28),
    "vineyard": ("viña", 1.7, 28), "shed": ("galpon", 1.4, 14), "warehouse": ("galpon", 1.4, 14),
    "station": ("casilla", 1.5, 14),
}
KEEP_OUT = 1.2  # metros libres alrededor de puertas, ítems, apariciones y pistas


def scatter_items(room: str) -> list:
    import json
    import random
    theme, spacing, limit = SCATTER[room]
    path = ROOT + "/render_src/slots/%s.json" % room
    if not os.path.exists(path):
        print("sin bordes para", room, "(corre edge_slots.gd)")
        return []
    data = json.load(open(path))
    rng = random.Random(room)
    slots = data["slots"][:]
    rng.shuffle(slots)
    chosen = []
    for sl in slots:
        if len(chosen) >= limit:
            break
        if any(math.hypot(sl["x"] - k[0], sl["z"] - k[1]) < KEEP_OUT for k in data["keep_out"]):
            continue
        if any(math.hypot(sl["x"] - c[0], sl["z"] - c[2]) < spacing * 0.7 for c in chosen):
            continue
        model, lo, hi = rng.choice(THEMES[theme])
        chosen.append((sl["x"], sl["y"], sl["z"], model, sl["yaw"] + rng.uniform(-0.5, 0.5), rng.uniform(lo, hi)))
    return [(m, (x, y, z), yaw, sc) for (x, y, z, m, yaw, sc) in chosen]


def build(room: str) -> None:
    items, lights = ROOMS.get(room, ([], []))
    items = list(items)
    if room in SCATTER:
        items += scatter_items(room)
    s = Scene()
    s.node("%sDetail" % "".join(w.capitalize() for w in room.split("_")), "Node3D")
    for i, (model, pos, yaw, scale) in enumerate(items):
        p = {"position": v3(pos), "rotation": v3((0, yaw, 0))}
        if abs(scale - 1.0) > 1e-3:
            p["scale"] = v3((scale,) * 3)
        s.node("%s_%d" % (model, i), None, ".", instance=s.res(PH % (model, model), "PackedScene"), **p)
    for i, (pos, color, energy, rng) in enumerate(lights):
        s.node("ExtraLight%d" % i, "OmniLight3D", ".", position=v3(pos), light_color=col(color),
               light_energy=str(energy), omni_range=str(rng), shadow_enabled="true")
    os.makedirs(ROOT + "/render_src/scenes", exist_ok=True)
    s.save(ROOT + "/render_src/scenes/%s_detail.tscn" % room)
    print("detalle:", room, len(items), "objetos")


if __name__ == "__main__":
    for room in (sys.argv[1:] or list(ROOMS.keys()) + list(SCATTER.keys())):
        build(room)
