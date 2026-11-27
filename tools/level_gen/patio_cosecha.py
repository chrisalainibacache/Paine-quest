import sys, math, os; sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
from buin_common import *
import detail
import vertical
# Patio de cosecha (cap. 3, ala B): patio alto con galpón de herramientas, plataforma de carga (2,4 m) y escalera.
# Palancas «marca» y «portón» abren la caja de cosecha. Atajo B: pestillo alto hacia el galpón (solo desde aquí).
k = Kit("HarvestYard", "Patio de cosecha", ambience="day_fields")
k.env((0.13, 0.135, 0.15), (0.6, 0.6, 0.62), 1.0, (0.35, 0.36, 0.4), 0.02)
H = 5.5
k.shell(-7.0, 7.0, -4.0, 4.0, H, floor="gravel", wall="planks", ceiling="concrete_wall", wainscot="rust")
vertical.block_corner(k, "ToolShed", -7.0, -4.2, -4.0, -1.6, h=3.0, mat="planks")        # galpón de herramientas (NO)
k.door_frame("ToWarehouse", -7.0, 1.2, "z", width=1.4, wall_side=1, panel="planks")
k.door_frame("ToShedShortcut", -1.5, 4.0, "x", width=1.1, wall_side=-1, panel="metal")
k.door_frame("ToWalkwayFrame", 7.0, -2.4, "z", width=1.1, wall_side=-1, panel="metal", group="Interactables", base_y=2.4)
k.door("ToWarehouse", (-6.6, 0, 1.2), B % "warehouse", "from_patio", prompt="VOLVER", reach=1.3, marker="BODEGA AGRÍCOLA")
k.door("door_shortcut_patio_shed", (-1.5, 0, 3.6), B % "shed", "from_patio", prompt="LEVANTAR PESTILLO", reach=1.3,
       lock_id="buin_shortcut_patio_shed", one_way=True, one_way_origin=True, metal_door=True, marker="GALPÓN")
k.door("ToWalkway", (6.6, 2.4, -2.4), B % "pasarela_vina", "from_patio", prompt="SUBIR", reach=1.3, marker="PASARELA DE LA VIÑA")
k.spawn("from_warehouse", (-6.0, 0.05, 1.2), (1, 0))
k.spawn("from_shed", (-1.5, 0.05, 3.0), (0, -1))
k.spawn("from_walkway", (6.0, 2.45, -2.4), (-1, 0))
# Plataforma de carga (2,4 m) en el noreste, con escalera desde el oeste.
vertical.balcony(k, "Dock", 2.5, 6.9, -3.9, -0.9, y=2.4, rail_sides="SW", gap=("W", -2.8, -1.6))
vertical.stairs(k, "DockStairs", -0.3, -2.2, "+x", width=1.2, rise=2.4)
# Carro de cosecha y palancas (marca, portón) -> caja de cosecha.
k.block("Cart", "Props", (-2.2, 0.45, -0.8), (1.6, 0.5, 0.9), "planks")
k.block("CartWheelA", "Props", (-2.2, 0.25, -1.3), (0.5, 0.5, 0.08), "metal", solid=False)
k.block("CartWheelB", "Props", (-2.2, 0.25, -0.3), (0.5, 0.5, 0.08), "metal", solid=False)
k.lever_sequence("YardSequence", (4.5, 2.4, -3.5), "buin_patio_levers", reach=1.6)
k.lever("MarkLever", (3.6, 2.4, -3.5), "buin_patio_levers", "marca", unlock_id="buin_patio", reach=1.2)
k.lever("GateLever", (5.4, 2.4, -3.5), "buin_patio_levers", "portón", unlock_id="buin_patio", reach=1.2)
k.note("HarvestManifest", (-3.6, 1.1, 3.6), "buin_harvest_manifest", paper_scale=0.7, reach=1.4)
k.container("HarvestCrate", (3.2, 0, 2.6), "buin_patio_cache", item_ids=("ammo_shells", "handroll"), counts=(4, 1), required_flag="unlocked:buin_patio", reach=1.3)
k.infected("Picker", (0.8, 0.05, 1.0), yaw=2.2)
k.pickup("YardAmmo", (5.6, 0.0, 3.0), "ammo_9mm", 10, rot=(0, 0.2, 0))
k.camera("West", (-3.0, 2.3, 0.0), (7.0, 4.6, 7.8), (2.4, 4.8, 3.4), (-4.0, 0.6, -0.4), fov=62)
k.camera("East", (3.5, 2.3, 0.0), (7.0, 4.6, 7.8), (-2.0, 4.8, 3.4), (4.2, 1.0, -1.0), fov=62)
k.leo_hint("LeoYard", (-4.0, 0, 1.2), [
    "Leo: Hay marcas de ruedas en el suelo y una plataforma alta.",
    "Leo: Arriba se ve una marca; abajo, la caja que no se abre sola.",
    "Leo: Sube a la plataforma, acciona la marca y luego el portón; después registra la caja."])
detail.dress(k, -6.7, 6.7, -3.7, 3.7, H, theme="storage", seed=703, extra=20, avoid_rects=[(-7.0, -4.0, -4.1, -1.5), (2.4, 7.0, -4.0, -0.8)], avoid=[(-6.0, 1.2, 1.4), (-1.5, 3.0, 1.4), (-1.5, 3.6, 1.2)])
k.save(REPO + "/levels/buin/patio_cosecha.tscn")
print("patio_cosecha ok")
