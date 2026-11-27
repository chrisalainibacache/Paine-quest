import sys, math, os; sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
from roomkit import *
import detail
import vertical
T = "res://levels/tracks/%s.tscn"
# Pasarela elevada sobre el convoy (cap. 2): une el galpón de carga con el cuarto de drenaje y abre un retorno al patio.
k = Kit("ConvoyWalkway", "Pasarela del convoy", ambience="tracks_night")
k.env((0.04, 0.045, 0.06), (0.38, 0.42, 0.5), 0.7, (0.07, 0.08, 0.1), 0.02)
H = 5.6
k.shell(-10.0, 10.0, -2.0, 2.0, H, floor="gravel", wall="old_bricks_wall", ceiling="concrete_wall", wainscot="rust")
vertical.balcony(k, "Walkway", -9.6, 9.6, -1.6, 1.6, y=2.6, rail_sides="NS", columns=True)
k.door("ToShed", (-9.2, 2.6, 0.0), T % "galpon_carga", "from_walkway", prompt="BAJAR", reach=1.3, marker="GALPÓN DE CARGA")
k.door("ToDrain", (9.2, 2.6, 0.0), T % "cuarto_drenaje", "from_walkway", prompt="SEGUIR", reach=1.3, marker="CUARTO DE DRENAJE")
# Retorno rápido al patio: se abre desde este lado (atajo persistente).
k.door("ToHub", (0.0, 2.6, 1.3), T % "derailed_train", "from_walkway", prompt="BAJAR AL PATIO", reach=1.3,
       lock_id="tracks_shortcut_walkway", one_way=True, one_way_origin=True, metal_door=True)
k.spawn("from_shed", (-8.6, 2.65, 0.0), (1, 0))
k.spawn("from_drain", (8.6, 2.65, 0.0), (-1, 0))
k.spawn("from_hub", (0.0, 2.65, 0.0), (0, -1))
k.note("WalkwayNote", (-3.0, 2.95, -1.2), "walkway_note", paper_scale=0.7)
k.pickup("WalkwayAmmo", (4.0, 2.6, -1.1), "ammo_9mm", 10)
k.camera("West", (-5.0, 2.8, 0.0), (10.0, 5.6, 3.8), (-1.5, 4.9, 1.7), (-5.5, 2.4, -0.3), fov=62)
k.camera("East", (5.0, 2.8, 0.0), (10.0, 5.6, 3.8), (1.5, 4.9, -1.7), (5.5, 2.4, 0.3), fov=62)
k.leo_hint("LeoWalkway", (-6.0, 2.6, 0.0), [
    "Leo: Desde aquí arriba se ve el patio entero.",
    "Leo: Hay otra manera de volver abajo, si sabes dónde mirar.",
    "Leo: Sigue la pasarela hasta el cuarto de drenaje; la puerta del medio te devuelve al patio."])
detail.dress(k, -9.7, 9.7, -1.8, 1.8, H, theme="corridor", seed=603, extra=26, base_y=2.6)
k.save(REPO + "/levels/tracks/pasarela_convoy.tscn")
print("pasarela_convoy ok")
