import sys, os
HERE = os.path.dirname(os.path.abspath(__file__))
if HERE not in sys.path: sys.path.insert(0, HERE)
REPO = os.path.abspath(os.path.join(HERE, "..", ".."))
from maestranza_common import create_room
import vertical
from tracks_room_common import add_detail_props, finish_tracks_room

T = "res://levels/tracks/%s.tscn"
k = create_room("GalponCarga", "Galpón de carga ferroviaria", "tracks_night",
                theme="storage", size=(18.0, 6.0), height=6.2)
k.door("ToConvoy", (-6.45, 0.0, 0.0), T % "convoy_side", "from_cargo", prompt="VOLVER AL CONVOY")
k.door("ToCatwalk", (6.45, 0.0, 0.0), T % "pasarela_convoy", "from_cargo", prompt="SUBIR A LA PASARELA")
k.spawn("from_convoy", (-6.2, 0.05, 0.0), (1, 0))
k.spawn("from_pasarela", (6.2, 0.05, 0.0), (-1, 0))

k.container("FuseCabinet", (4.9, 0.0, -2.0), "tracks_fuse_cache", item_ids=("fuse_10a",), counts=(1,))
k.fuse_box("LocalFuseBoard", (6.0, 0.0, 2.0), "tracks_fuse_panel")
k.label("FuseBoardLabel", "Details", (6.0, 2.2, 2.85), "TABLERO LOCAL · 10 A", 20, (0.93, 0.82, 0.42))
k.note("FreightManifest", (-5.0, 0.8, -2.3), "tracks_freight_manifest", paper_scale=0.75)
k.examine("FuseInstructions", (5.4, 0.0, 1.15), [
    "El tablero alimenta los servicios del galpón y la bomba eléctrica del drenaje.",
    "El ala C conserva una bomba manual: la corriente no es necesaria para llegar a la casa de cambios."
])

k.lever_sequence("CounterweightController", (-1.0, 0.0, -1.3), "tracks_counterweight")
k.lever("CounterweightRelease", (-6.0, 0.0, 2.0), "tracks_counterweight", "release")
k.lever("CounterweightPush", (-4.0, 0.0, 2.0), "tracks_counterweight", "push")
k.lever("CounterweightLock", (-2.0, 0.0, 2.0), "tracks_counterweight", "lock")
k.block("TrolleyBase", "Props", (-4.0, 0.25, 0.4), (2.2, 0.5, 1.0), "metal")
k.prop("TrolleyCrate", "Props", "crate", (-4.0, 0.65, 0.4), rot=(0, 0.3, 0))
k.prop("TrolleyWheelA", "Props", "tire", (-4.8, 0.2, 0.95))
k.prop("TrolleyWheelB", "Props", "tire", (-3.2, 0.2, 0.95))
k.container("CounterweightReward", (-7.0, 0.0, -1.6), "tracks_counterweight_reward",
            item_ids=("ammo_rifle",), counts=(10,), required_flag="tracks:counterweight_open")

vertical.balcony(k, "CargoMezzanine", -8.0, 8.0, -2.7, -0.4, y=2.7,
                 rail_sides="NSWE", gap=("S", -6.8, -5.2))
vertical.stairs(k, "CargoStairs", -6.0, 2.2, "-z", width=1.25, rise=2.7)
k.container("MezzanineCrate", (-2.0, 2.75, -1.6), "tracks_cargo_mezzanine_cache",
            item_ids=("ammo_shells",), counts=(8,))

k.light("SodiumLight", "Lights", (-5.5, 5.4, 0.0), (1.0, 0.55, 0.25), 1.15, 7.0)
k.light("ColdWorkLight", "Lights", (5.8, 5.3, 0.0), (0.45, 0.72, 1.0), 0.9, 6.0)
k.label("GalponSign", "Details", (0.0, 5.0, -2.9), "BODEGA D-16008", 30, (0.88, 0.76, 0.56))
k.label("LoadingSign", "Details", (0.0, 3.0, 2.9), "CARGA DE SERVICIO", 22, (0.82, 0.82, 0.72), rot=(0, 3.1416, 0))
k.label("SafetySign", "Details", (-8.0, 2.2, 0.0), "10 A", 18, (0.95, 0.78, 0.25), rot=(0, 1.5708, 0))
k.infected("FreightWorker", (1.5, 0.05, 0.6), yaw=-1.3, kind="infected_worker")
add_detail_props(k, "Cargo")
finish_tracks_room(k, "galpon_carga", seed=43, avoid_rects=[(-8.0, 8.0, -3.1, -1.0)])
