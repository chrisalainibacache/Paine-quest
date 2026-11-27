import sys, os
HERE = os.path.dirname(os.path.abspath(__file__))
if HERE not in sys.path: sys.path.insert(0, HERE)
REPO = os.path.abspath(os.path.join(HERE, "..", ".."))
from maestranza_common import create_room
import vertical
from tracks_room_common import add_detail_props, finish_tracks_room

T = "res://levels/tracks/%s.tscn"
k = create_room("SalaLocomotora", "Sala de máquinas de la locomotora", "fire_wreck",
                theme="workshop", size=(9.0, 7.0), height=3.4)
k.door("ToHub", (-6.45, 0.0, 0.0), T % "derailed_train", "from_machine",
       prompt="VOLVER AL PATIO", marker="PATIO")
k.door("ToWagon", (6.45, 0.0, 0.0), T % "wagon_interior", "from_machine",
       prompt="ENTRAR AL COCHE", marker="COCHE DE PASAJEROS")
k.spawn("from_derailed", (-6.2, 0.05, 0.0), (1, 0))
k.spawn("from_wagon", (6.2, 0.05, 0.0), (-1, 0))

k.lever_sequence("FuelCutController", (0.0, 0.0, 0.75), "tracks_fuel_cut")
k.lever("ValveReturn", (-2.4, 0.0, -2.0), "tracks_fuel_cut", "return")
k.lever("ValveMain", (0.0, 0.0, -2.0), "tracks_fuel_cut", "main")
k.lever("PressureConfirm", (2.4, 0.0, -2.0), "tracks_fuel_cut", "confirm")
k.label("ValveReturnLabel", "Details", (-2.4, 1.6, -2.2), "2 · RETORNO", 18, (0.95, 0.75, 0.35))
k.label("ValveMainLabel", "Details", (0.0, 1.6, -2.2), "3 · PRINCIPAL", 18, (0.95, 0.35, 0.25))
k.label("PressureLabel", "Details", (2.4, 1.6, -2.2), "1 · CONFIRMAR", 18, (0.8, 0.85, 0.78))
k.note("FuelReport", (-3.1, 0.7, 1.8), "tracks_fuel_report", paper_scale=0.7)
k.note("ValvePlate", (2.9, 0.7, 1.8), "tracks_valve_plate", paper_scale=0.7)
k.examine("FuelPanel", (0.0, 0.0, -1.4), [
    "La línea de combustible alimenta el fuego que alcanza el lateral de la locomotora.",
    "El orden de cierre está grabado en la placa: retorno, válvula principal y presión cero."
])

vertical.balcony(k, "InspectionWalkway", -3.7, 3.7, -3.15, -0.35, y=2.1,
                 rail_sides="NSWE", gap=("S", 1.2, 2.6))
vertical.stairs(k, "InspectionStairs", 1.9, 2.45, "-z", width=1.15, rise=2.1)
k.container("UpperToolLocker", (2.9, 2.15, -1.8), "tracks_machine_upper_cache",
            item_ids=("ammo_shells",), counts=(6,))
k.pickup("ShellsByTools", (-2.8, 0.0, 2.55), "ammo_shells", 4, rot=(0, 0.45, 0))

k.light("AmberServiceLight", "Lights", (-2.8, 2.9, 0.0), (1.0, 0.52, 0.2), 1.0, 5.0)
k.light("RedFireLight", "Lights", (3.0, 2.8, -0.8), (1.0, 0.12, 0.05), 0.8, 4.2, flicker=True)
k.label("MachineSign", "Details", (0.0, 2.7, -3.15), "LOCOMOTORA D-16008", 24, (0.9, 0.76, 0.54))
k.label("SafetySign", "Details", (0.0, 2.4, 3.15), "SOLO PERSONAL FERROVIARIO", 18, (0.8, 0.32, 0.24), rot=(0, 3.1416, 0))
k.label("PressureSign", "Details", (-3.5, 2.1, 0.8), "ALTA PRESIÓN", 16, (0.95, 0.65, 0.25), rot=(0, 1.5708, 0))
k.infected("Mechanic", (-1.5, 0.05, 0.9), yaw=1.2, kind="infected_worker")
add_detail_props(k, "Machine")
finish_tracks_room(k, "sala_locomotora", seed=31, avoid_rects=[(-3.8, 3.8, -3.4, -1.4)])
