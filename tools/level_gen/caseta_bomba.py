import sys, math, os; sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
from buin_common import *
import detail
import vertical
# Caseta de bombas (cap. 3, ala C): sala en L; arriba, la plataforma con las tres válvulas (retorno, canal, bomba).
# Al estabilizar el manómetro se abre el gabinete con la batería de radio. Puerta de servicio de un solo lado hacia la estación.
k = Kit("PumpHouse", "Caseta de bombas", ambience="underpass")
k.env((0.06, 0.065, 0.075), (0.45, 0.47, 0.5), 0.85, (0.1, 0.11, 0.13), 0.02)
H = 4.5
k.shell(-4.0, 4.0, -3.0, 3.0, H, floor="concrete_floor", wall="plaster_wall", ceiling="concrete_wall", wainscot="tiles_wall")
vertical.block_corner(k, "Tank", 1.4, 4.0, 0.5, 3.0, h=H, mat="metal")           # tanque: recorta la planta en L
k.door_frame("ToCanal", -4.0, 0.0, "z", width=1.2, wall_side=1, panel="metal")
k.door_frame("ToStationDoor", -2.0, 3.0, "x", width=1.1, wall_side=-1, panel="metal")
k.door("ToCanal", (-3.6, 0, 0.0), B % "canal_riego", "from_pump", prompt="SALIR", reach=1.3, marker="CANAL DE RIEGO")
# Atajo A: se abre desde la caseta; desde la estación solo se ve el candado.
k.door("door_shortcut_pump_station", (-2.0, 0, 2.6), B % "station", "from_pump", prompt="ABRIR", reach=1.3,
       lock_id="buin_shortcut_pump_station", one_way=True, one_way_origin=True, metal_door=True, marker="ESTACIÓN")
k.spawn("from_canal", (-3.2, 0.05, 0.0), (1, 0))
k.spawn("from_station", (-2.0, 0.05, 2.0), (0, -1))
# Plataforma de válvulas (2,0 m) al norte, con escalera desde el este.
vertical.balcony(k, "Valves", -3.9, 0.9, -2.9, -1.4, y=2.0, rail_sides="SW", gap=("S", -0.3, 0.7))
vertical.stairs(k, "ValveStairs", 3.9, -2.1, "-x", width=1.1, rise=2.0)
k.lever_sequence("PumpSequence", (-1.0, 2.0, -2.5), "buin_pump_levers", reach=1.6)
k.lever("ReturnLever", (-3.0, 2.0, -2.5), "buin_pump_levers", "retorno", unlock_id="buin_pump", reach=1.2)
k.lever("CanalLever", (-2.1, 2.0, -2.5), "buin_pump_levers", "canal", unlock_id="buin_pump", reach=1.2)
k.lever("PumpLever", (-1.2, 2.0, -2.5), "buin_pump_levers", "bomba", unlock_id="buin_pump", reach=1.2)
k.label("ValveMarks", "Details", (-2.1, 3.1, -2.82), "1  ·  2  ·  3", 26, (0.9, 0.85, 0.6))
k.label("Gauge", "Details", (-3.96, 1.7, 1.6), "PRESIÓN", 20, (0.85, 0.82, 0.7), rot=(0, math.pi / 2, 0))
k.note("PumpLog", (-3.6, 1.0, 1.2), "buin_pump_log", paper_scale=0.7, reach=1.4)
k.note("BatteryNote", (0.4, 1.0, -0.4), "buin_radio_battery_note", paper_scale=0.7, reach=1.4)
k.container("BatteryCabinet", (0.9, 0, 2.4), "buin_pump_cabinet", item_ids=("radio_cell",), counts=(1,), required_flag="unlocked:buin_pump", reach=1.3)
k.infected("Flooded", (-0.8, 0.05, 0.9), yaw=0.8, state="lying", kind="infected_pale")
k.camera("West", (-2.0, 2.1, 0.0), (4.0, 4.2, 5.8), (1.1, 3.9, 2.3), (-2.4, 0.5, -0.4), fov=64)
k.camera("East", (2.2, 2.1, -1.2), (4.0, 4.2, 3.6), (0.6, 3.9, 2.4), (2.6, 0.5, -1.4), fov=64)
k.leo_hint("LeoPump", (-1.4, 0, 0.4), [
    "Leo: El manómetro tiembla. Escucha el golpeteo en las tuberías.",
    "Leo: Sigue el recorrido del agua, no el orden de las etiquetas.",
    "Leo: Sube la escalera y acciona retorno, canal y bomba; luego registra el gabinete de la batería."])
detail.dress(k, -3.7, 3.7, -2.7, 2.7, H, theme="storage", seed=702, extra=28, avoid_rects=[(1.2, 4.1, 0.3, 3.1), (-4.0, 1.0, -3.0, -1.2)], avoid=[(-3.2, 0.0, 1.4), (-2.0, 2.0, 1.4), (-2.0, 2.6, 1.2)])
k.save(REPO + "/levels/buin/caseta_bomba.tscn")
print("caseta_bomba ok")
