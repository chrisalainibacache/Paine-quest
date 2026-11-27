import sys, math, os; sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
from roomkit import *
import detail
T = "res://levels/tracks/%s.tscn"
# Cuarto de drenaje (cap. 2, ala C): compuertas de la bomba y el gabinete de señales con la clavija del cambio de vías.
k = Kit("DrainRoom", "Cuarto de drenaje", ambience="underpass")
k.env((0.02, 0.025, 0.03), (0.28, 0.32, 0.36), 0.55, (0.04, 0.06, 0.08), 0.045)
H = 3.4
k.shell(-4.0, 4.0, -3.0, 3.0, H, floor="concrete_floor", wall="concrete_wall", ceiling="concrete_wall", wainscot="tiles_wall")
k.door_frame("ToWalkway", -4.0, 0.0, "z", width=1.1, wall_side=1, panel="metal")
k.door_frame("ToUnderpass", 4.0, 0.0, "z", width=1.1, wall_side=-1, panel="metal")
k.door("ToWalkway", (-3.6, 0, 0.0), T % "pasarela_convoy", "from_drain", prompt="SUBIR", reach=1.3, marker="PASARELA")
# Escotilla al paso bajo nivel: se libera desde este lado (atajo persistente).
k.door("ToUnderpass", (3.6, 0, 0.0), T % "underpass", "from_drain", prompt="BAJAR", reach=1.3,
       lock_id="tracks_shortcut_drain", one_way=True, one_way_origin=True, metal_door=True)
k.spawn("from_walkway", (-3.2, 0.05, 0.0), (1, 0))
k.spawn("from_underpass", (3.2, 0.05, 0.0), (-1, 0))
# Canal de agua (decorativo) y compuertas de la bomba: primero la bomba, luego la compuerta.
k.block("Canal", "Details", (0.0, 0.03, 2.0), (7.0, 0.04, 1.2), "river", solid=False)
k.lever_sequence("DrainSequence", (0.0, 0, -2.5), "cap2_drain_valves", reach=1.6)
k.lever("PumpLever", (-1.2, 0, -2.5), "cap2_drain_valves", "bomba", unlock_id="tracks_drain", reach=1.2)
k.lever("GateLever", (1.2, 0, -2.5), "cap2_drain_valves", "compuerta", unlock_id="tracks_drain", reach=1.2)
k.note("DrainNote", (-2.6, 0.9, -2.5), "crossing_drain_note", paper_scale=0.7, reach=1.4)
k.note("CabinetLabel", (1.4, 0.9, -2.5), "signal_cabinet_label", paper_scale=0.7, reach=1.3)
k.container("DrainCabinet", (2.6, 0, -2.5), "cap2_drain_cabinet", item_ids=("signal_pin",), counts=(1,), required_flag="unlocked:tracks_drain", reach=1.3)
k.infected("Drowned", (0.6, 0.05, 1.0), yaw=1.0, state="lying", kind="infected_pale")
k.camera("West", (-1.8, 1.5, 0.0), (4.0, 3.0, 5.8), (1.4, 3.0, 2.6), (-2.2, 0.5, -0.4), fov=64)
k.camera("East", (2.2, 1.5, 0.0), (4.0, 3.0, 5.8), (-1.4, 3.0, -2.6), (2.4, 0.5, 0.4), fov=64)
k.leo_hint("LeoDrain", (0.0, 0, -1.6), [
    "Leo: Escucha el agua. Algo está atascado en el gabinete.",
    "Leo: El encargado dejó escrito el orden de las compuertas.",
    "Leo: Acciona la bomba y después la compuerta; luego registra el gabinete."])
detail.dress(k, -3.7, 3.7, -2.7, 2.7, H, theme="storage", seed=604, extra=60)
k.save(REPO + "/levels/tracks/cuarto_drenaje.tscn")
print("cuarto_drenaje ok")
