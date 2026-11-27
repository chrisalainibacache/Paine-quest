import sys, os
HERE = os.path.dirname(os.path.abspath(__file__))
if HERE not in sys.path: sys.path.insert(0, HERE)
REPO = os.path.abspath(os.path.join(HERE, "..", ".."))
from maestranza_common import create_room
import vertical
from tracks_room_common import add_north_door, add_detail_props, finish_tracks_room

T = "res://levels/tracks/%s.tscn"
k = create_room("CuartoDrenaje", "Cuarto de drenaje", "tracks_night", dark=True,
                theme="bathroom", size=(8.0, 6.0), height=3.4)
add_north_door(k, width=1.6, wall="concrete_wall")
k.door("ToUnderpass", (-6.45, 0.0, 0.0), T % "underpass", "from_drainage", prompt="VOLVER AL PASO BAJO NIVEL")
k.door("ToSwitchHouse", (6.45, 0.0, 0.0), T % "switch_house", "from_drainage", prompt="IR A LA CASA DE CAMBIOS")
k.door("ToCatwalk", (0.0, 0.0, -4.7), T % "pasarela_convoy", "from_drainage", prompt="SUBIR A LA PASARELA")
k.spawn("from_underpass", (-6.2, 0.05, 0.0), (1, 0))
k.spawn("from_switch", (6.2, 0.05, 0.0), (-1, 0))
k.spawn("from_pasarela", (0.0, 0.05, -4.2), (0, 1))

k.lever_sequence("ManualPumpController", (0.0, 0.0, 2.3), "tracks_drain_pump")
k.lever("DrainIsolate", (-2.2, 0.0, -1.8), "tracks_drain_pump", "isolate")
k.lever("DrainPrime", (0.0, 0.0, -1.8), "tracks_drain_pump", "prime")
k.lever("DrainPump", (2.2, 0.0, -1.8), "tracks_drain_pump", "pump")
k.label("DrainStep1", "Details", (-2.2, 1.6, -2.0), "1 · AISLAR", 16, (0.8, 0.85, 0.9))
k.label("DrainStep2", "Details", (0.0, 1.6, -2.0), "2 · CEBAR", 16, (0.8, 0.85, 0.9))
k.label("DrainStep3", "Details", (2.2, 1.6, -2.0), "3 · BOMBEAR", 16, (0.8, 0.85, 0.9))
k.note("DrainNote", (-2.7, 0.7, 1.8), "tracks_drain_note", paper_scale=0.65)
k.container("SignalPinCabinet", (2.9, 0.0, 1.8), "tracks_signal_pin_cache",
            item_ids=("signal_pin",), counts=(1,), required_flag="drain:empty")
k.examine("DrainChannel", (0.0, 0.0, 0.9), [
    "El agua cubre el registro y oculta un gabinete de señales.",
    "La bomba eléctrica está sin corriente. La bomba manual funciona de manera independiente."
])
k.light("EmergencyRed", "Lights", (-2.8, 2.7, 0.0), (1.0, 0.12, 0.08), 0.7, 4.0, flicker=True)
k.light("HandLamp", "Lights", (2.8, 2.7, 0.0), (0.45, 0.72, 1.0), 0.6, 3.5)
k.label("DrainRoomSign", "Details", (0.0, 2.8, -2.8), "DRENAJE · ACCESO RESTRINGIDO", 18, (0.82, 0.78, 0.66))
k.label("WetFloorSign", "Details", (0.0, 2.4, 2.8), "PISO MOJADO", 18, (0.92, 0.74, 0.34), rot=(0, 3.1416, 0))
k.label("ManualSign", "Details", (-3.6, 2.0, 0.0), "BOMBA MANUAL", 16, (0.8, 0.82, 0.9), rot=(0, 1.5708, 0))
k.infected("DrainWorker", (0.8, 0.05, 0.8), yaw=1.4, kind="infected_worker")
add_detail_props(k, "Drain")
finish_tracks_room(k, "cuarto_drenaje", seed=69, avoid_rects=[(-3.0, 3.0, -3.0, -1.2)])
