import sys, math, os; sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
from buin_common import *
import detail
import vertical
# Pasarela de la viña (cap. 3): pasarela elevada (2,4 m) sobre las hileras; une la viña con el patio de cosecha
# y baja al canal de riego por una trampilla (atajo de un solo lado).
k = Kit("VineWalkway", "Pasarela de la viña", ambience="day_fields")
k.env((0.14, 0.145, 0.16), (0.62, 0.62, 0.65), 1.0, (0.4, 0.42, 0.46), 0.015)
H = 5.2
k.shell(-8.0, 8.0, -1.75, 1.75, H, floor="gravel", wall="wood", ceiling="concrete_wall", wainscot="planks")
vertical.balcony(k, "Walkway", -7.6, 7.6, -1.4, 1.4, y=2.4, rail_sides="NS", columns=True)
k.door("ToVineyard", (-7.2, 2.4, 0.0), B % "vineyard", "from_walkway", prompt="BAJAR", reach=1.3, marker="VIÑA")
k.door("ToPatio", (7.2, 2.4, 0.0), B % "patio_cosecha", "from_walkway", prompt="BAJAR", reach=1.3, marker="PATIO DE COSECHA")
k.door("ToCanal", (0.0, 2.4, 1.15), B % "canal_riego", "from_walkway", prompt="BAJAR AL CANAL", reach=1.3,
       lock_id="buin_shortcut_walkway_canal", one_way=True, one_way_origin=True, metal_door=True)
k.spawn("from_vineyard", (-6.6, 2.45, 0.0), (1, 0))
k.spawn("from_patio", (6.6, 2.45, 0.0), (-1, 0))
k.spawn("from_canal", (0.0, 2.45, 0.0), (0, -1))
k.note("ShiftNote", (-3.0, 2.8, -1.3), "buin_vineyard_shift_note", paper_scale=0.7)
k.pickup("WalkwayAmmo", (3.6, 2.4, -0.9), "ammo_9mm", 8)
k.camera("West", (-4.0, 2.8, 0.0), (8.0, 5.6, 3.2), (-0.8, 4.6, 1.5), (-4.6, 2.4, -0.3), fov=62)
k.camera("East", (4.0, 2.8, 0.0), (8.0, 5.6, 3.2), (0.8, 4.6, -1.5), (4.6, 2.4, 0.3), fov=62)
k.leo_hint("LeoWalkwayVine", (-5.0, 2.4, 0.0), [
    "Leo: Desde aquí arriba se ven las hileras y el galpón al fondo.",
    "Leo: Hay otra manera de bajar, si sabes dónde mirar.",
    "Leo: La trampilla del medio baja al canal de riego; el otro extremo lleva al patio de cosecha."])
detail.dress(k, -7.7, 7.7, -1.6, 1.6, H, theme="corridor", seed=704, extra=26, base_y=2.4, avoid=[(-6.6, 0.0, 1.4), (6.6, 0.0, 1.4), (0.0, 0.0, 1.4)])
k.door_frame("FrameVineyard", -7.55, 0.0, "z", width=1.2, wall_side=1, panel="planks", group="Interactables", base_y=2.4)
k.door_frame("FramePatio", 7.55, 0.0, "z", width=1.2, wall_side=-1, panel="planks", group="Interactables", base_y=2.4)
k.door_frame("FrameCanal", 0.0, 1.62, "x", width=1.1, wall_side=-1, panel="metal", group="Interactables", base_y=2.4)
k.save(REPO + "/levels/buin/pasarela_vina.tscn")
print("pasarela_vina ok")
