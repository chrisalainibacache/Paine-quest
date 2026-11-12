#!/usr/bin/env python3
"""Detalle extra de cada sala para los fondos prerenderizados (solo se usa al
renderizar; el juego en el teléfono no carga estos modelos).
Genera render_src/scenes/<sala>_detail.tscn para cada sala de ROOMS.
Uso: python3 tools/prerender/room_details.py [sala ...]

Reglas: pegado a muros y rincones, nunca en el camino de Cony ni encima de
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


def build(room: str) -> None:
    items, lights = ROOMS[room]
    s = Scene()
    s.node("%sDetail" % "".join(w.capitalize() for w in room.split("_")), "Node3D")
    for i, (model, pos, yaw, scale) in enumerate(items):
        p = {"position": v3(pos), "rotation": v3((0, yaw, 0))}
        if scale != 1.0:
            p["scale"] = v3((scale,) * 3)
        s.node("%s_%d" % (model, i), None, ".", instance=s.res(PH % (model, model), "PackedScene"), **p)
    for i, (pos, color, energy, rng) in enumerate(lights):
        s.node("ExtraLight%d" % i, "OmniLight3D", ".", position=v3(pos), light_color=col(color),
               light_energy=str(energy), omni_range=str(rng), shadow_enabled="true")
    os.makedirs(ROOT + "/render_src/scenes", exist_ok=True)
    s.save(ROOT + "/render_src/scenes/%s_detail.tscn" % room)
    print("detalle:", room)


if __name__ == "__main__":
    for room in (sys.argv[1:] or ROOMS.keys()):
        build(room)
