import sys, math, os; sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
from roomkit import *
import detail
import vertical
T = "res://levels/tracks/%s.tscn"
# Galpón de carga junto a la vía (cap. 2, ala B): tablero de carga (sello «energía») y estiba alta con el fusible.
k = Kit("CargoShed", "Galpón de carga", ambience="barn")
k.env((0.05, 0.05, 0.065), (0.5, 0.52, 0.6), 1.2, (0.09, 0.095, 0.11), 0.02)
H = 6.2
k.shell(-9.0, 9.0, -3.0, 3.0, H, floor="gravel", wall="rust", ceiling="concrete_wall", wainscot="planks")
k.door_frame("ToConvoy", -9.0, 0.0, "z", width=1.4, wall_side=1, panel="metal")
k.door("ToConvoy", (-8.6, 0, 0.0), T % "convoy_side", "from_shed", prompt="VOLVER", reach=1.3)
k.spawn("from_convoy", (-8.0, 0.05, 0.0), (1, 0))
k.spawn("from_walkway", (7.0, 2.75, -1.9), (-1, 0))
# Entrepiso de estiba (2,7 m) con escalera desde el oeste; arriba, el contenedor del fusible y la subida a la pasarela.
vertical.balcony(k, "Loft", -2.0, 8.0, -2.9, -0.9, y=2.7, rail_sides="SE", gap=("E", -2.4, -1.4))
vertical.stairs(k, "LoftStairs", -6.5, -1.9, "+x", width=1.3, rise=2.7)
k.door("ToWalkway", (7.4, 2.7, -1.9), T % "pasarela_convoy", "from_shed", prompt="SUBIR", reach=1.3, marker="PASARELA")
k.container("CargoStock", (5.4, 2.7, -2.5), "cap2_cargo_stock", item_ids=("fuse_10a",), counts=(1,), reach=1.3)
k.note("Manifest", (-3.6, 0.9, 2.4), "cargo_manifest", paper_scale=0.7, reach=1.4)
k.fuse_box("CargoPanel", (-7.4, 0, -2.4), "cap2_cargo_panel", unlock_id="tracks_power", fuse_item="fuse_10a", reach=1.5)
k.infected("Stowaway", (3.0, 0.05, 1.5), yaw=2.6)
k.pickup("ShedShells", (6.5, 0.0, 2.2), "ammo_shells", 4)
k.camera("West", (-4.5, 3.0, 0.0), (9.0, 6.0, 5.8), (-1.0, 5.2, 2.7), (-5.0, 0.5, -0.4), fov=62)
k.camera("East", (4.5, 3.0, 0.0), (9.0, 6.0, 5.8), (1.0, 5.2, 2.7), (5.0, 0.8, -0.6), fov=62)
k.leo_hint("LeoCargo", (-6.0, 0, 1.2), [
    "Leo: Hay un tablero apagado junto a la puerta y algo guardado arriba.",
    "Leo: Lo pesado se guarda alto. Lo liviano, cerca de la puerta.",
    "Leo: Sube por la escalera, registra la estiba, baja el fusible y úsalo en el tablero de carga."])
detail.dress(k, -8.7, 8.7, -2.7, 2.7, H, theme="storage", seed=602, avoid_rects=[(-6.9, 8.3, -3.2, -0.5)], extra=26)
k.save(REPO + "/levels/tracks/galpon_carga.tscn")
print("galpon_carga ok")
