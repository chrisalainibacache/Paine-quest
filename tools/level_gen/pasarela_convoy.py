import sys, os
HERE = os.path.dirname(os.path.abspath(__file__))
if HERE not in sys.path: sys.path.insert(0, HERE)
REPO = os.path.abspath(os.path.join(HERE, "..", ".."))
from maestranza_common import create_room
import vertical
from tracks_room_common import add_north_door, add_detail_props, finish_tracks_room

T = "res://levels/tracks/%s.tscn"
k = create_room("PasarelaConvoy", "Pasarela elevada del convoy", "tracks_night",
                theme="corridor", size=(20.0, 4.0), height=5.6)
add_north_door(k, width=1.8)
k.door("ToHub", (-6.45, 0.0, 0.0), T % "derailed_train", "from_catwalk", prompt="VOLVER AL PATIO")
k.door("ToCargo", (6.45, 0.0, 0.0), T % "galpon_carga", "from_pasarela", prompt="BAJAR AL GALPÓN")
k.door("ToDrainage", (0.0, 0.0, -4.7), T % "cuarto_drenaje", "from_pasarela", prompt="ENTRAR A DRENAJE")
k.spawn("from_hub", (-6.2, 0.05, 0.0), (1, 0))
k.spawn("from_cargo", (6.2, 0.05, 0.0), (-1, 0))
k.spawn("from_drainage", (0.0, 0.05, -4.2), (0, 1))

for side, z in (("N", -4.3), ("S", 4.3)):
    for i in range(12):
        x = -9.3 + i * 1.7
        k.block("RailPost%s%d" % (side, i), "Rails", (x, 0.55, z), (0.07, 1.1, 0.07), "metal", solid=False)
    k.block("RailTop" + side, "Rails", (0.0, 1.05, z), (19.0, 0.06, 0.08), "metal", solid=False)
    k.block("RailMid" + side, "Rails", (0.0, 0.55, z), (19.0, 0.04, 0.06), "metal", solid=False)
vertical.balcony(k, "Lookout", -7.0, 7.0, -1.5, 1.5, y=2.6,
                 rail_sides="NSEW", gap=("W", -0.7, 0.7), columns=True)
vertical.stairs(k, "LookoutStairs", -8.2, 0.0, "+x", width=1.2, rise=2.6)
k.pickup("LookoutAmmo", (3.0, 2.65, -2.5), "ammo_9mm", 10)
k.note("WalkwayNote", (-2.8, 0.8, 1.7), "tracks_freight_manifest", paper_scale=0.6)
k.label("CatwalkSign", "Details", (0.0, 4.8, -1.9), "PASARELA DE INSPECCIÓN", 28, (0.86, 0.8, 0.67))
k.label("WarningSign", "Details", (0.0, 2.6, 1.9), "NO CRUZAR BAJO CARGA SUSPENDIDA", 16, (0.9, 0.38, 0.24), rot=(0, 3.1416, 0))
k.label("HubViewSign", "Details", (-8.8, 2.0, 0.0), "VISTA AL PATIO", 18, (0.75, 0.82, 0.9), rot=(0, 1.5708, 0))
k.light("AmberRailLight", "Lights", (-6.5, 4.8, 0.0), (1.0, 0.52, 0.23), 0.95, 6.0)
k.light("BlueRailLight", "Lights", (6.5, 4.8, 0.0), (0.35, 0.58, 1.0), 0.8, 6.0)
add_detail_props(k, "Walkway")
finish_tracks_room(k, "pasarela_convoy", seed=57, avoid_rects=[(-8.0, 8.0, -1.8, 1.8)])
