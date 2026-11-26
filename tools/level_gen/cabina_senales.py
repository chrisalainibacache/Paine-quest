import sys, math, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
from roomkit import *
from station_detail import add_station_detail

k = Kit("SignalCabin", "Cabina de señales", ambience="office")
k.env((0.018, 0.016, 0.014), (0.32, 0.3, 0.26), 0.5, (0.05, 0.04, 0.03), 0.06)
H = 2.9
k.shell(-4.0, 4.0, -4.0, 4.0, H, floor="planks", wall="old_bricks_wall",
        ceiling="concrete_wall", wainscot="wood")
# Forma en L: cabina de mando al norte y brazo estrecho hacia el andén sur.
k.block("LWallNorth", "Architecture", (1.8, 1.4, -2.1), (4.2, 2.8, 0.18), "old_bricks_wall")
k.block("LWallReturn", "Architecture", (3.8, 1.4, -0.2), (0.18, 2.8, 3.8), "old_bricks_wall")
# Panel de señales, tres palancas y diagrama enmarcado.
k.block("SignalPanel", "SignalControls", (-1.1, 1.55, -3.65), (3.4, 1.9, 0.18), "metal")
for index, x in enumerate((-2.0, -1.1, -0.2)):
    k.block("LeverBase%d" % index, "SignalControls", (x, 0.85, -3.35), (0.5, 0.16, 0.5), "iron_green")
    k.block("LeverStem%d" % index, "SignalControls", (x, 1.2, -3.35), (0.08, 0.65, 0.08), "metal", solid=False)
    k.block("LeverHandle%d" % index, "SignalControls", (x, 1.55, -3.35), (0.28, 0.12, 0.12), "rust", solid=False)
    k.label("LeverLabel%d" % index, "SignalControls", (x, 2.1, -3.55),
            ["LIBRE", "DESVÍO", "BLOQUEO"][index], 18, (0.8, 0.7, 0.5))
k.block("DiagramFrame", "SignalControls", (1.0, 1.75, -3.65), (1.8, 1.3, 0.12), "wood", solid=False)
k.block("DiagramPaper", "SignalControls", (1.0, 1.75, -3.56), (1.55, 1.05, 0.025), "planks", solid=False)
# Consola, silla y teléfono de emergencia.
k.block("ConsoleTop", "Furniture", (-1.2, 0.85, -1.8), (3.2, 0.08, 0.85), "wood")
k.block("ConsoleFront", "Furniture", (-1.2, 0.48, -1.45), (3.0, 0.72, 0.12), "metal")
k.block("ConsoleSideL", "Furniture", (-2.65, 0.48, -1.8), (0.12, 0.72, 0.8), "metal")
k.block("ConsoleSideR", "Furniture", (0.25, 0.48, -1.8), (0.12, 0.72, 0.8), "metal")
k.block("PhoneBase", "Furniture", (1.9, 0.85, -1.8), (0.5, 0.08, 0.35), "metal", solid=False)
k.block("PhoneHandset", "Furniture", (1.9, 1.05, -1.8), (0.12, 0.28, 0.08), "rust", solid=False)
k.block("ChairSeat", "Furniture", (-1.2, 0.45, -0.4), (0.7, 0.08, 0.7), "wood")
k.block("ChairBack", "Furniture", (-1.2, 0.85, -0.75), (0.7, 0.8, 0.08), "wood", solid=False)
# Puertas hacia las tres conexiones.
k.door_frame("ToOffice", 0.0, 3.85, "x", width=1.1, wall_side=-1)
k.door_frame("ToTicket", -3.85, 0.0, "z", width=1.1, wall_side=1)
k.door_frame("ToSouth", 3.85, 1.0, "z", width=1.1, wall_side=-1)
k.door("door_cabina_oficina", (0.0, 0, 3.6), "res://levels/station/oficina_jefe.tscn", "from_signal_cabin", prompt="VOLVER")
k.door("door_cabina_boleteria", (-3.6, 0, 0.0), "res://levels/station/ticket_office.tscn", "from_signal_cabin",
       key="office_key", lock_id="station_cabina",
       locked_text="La puerta de la cabina necesita la llave de servicio o que el panel de señales libere el cierre.")
k.door("door_cabina_sur", (3.6, 0, 1.0), "res://levels/station/south_platform.tscn", "from_signal_cabin",
       lock_id="station_power", requires_flag=True,
       locked_text="El portón sur no tiene energía. Hay que activar el tablero de la sala de máquinas.")
k.spawn("from_office", (0.0, 0.05, 3.0), (0, -1))
k.spawn("from_ticket_office", (-3.0, 0.05, 0.0), (1, 0))
k.spawn("from_south_platform", (3.0, 0.05, 1.0), (-1, 0))
# Controlador de secuencia y palancas; el orden se lee en el diagrama de la oficina.
k.lever_sequence("SignalSequence", (0.0, 0, -3.2), "station_levers", reach=1.5)
for index, lever_id in enumerate(("free", "diversion", "lock")):
    k.lever("Lever%s" % lever_id.capitalize(), (-2.0 + index * 0.9, 0, -3.0),
            "station_levers", lever_id, unlock_id="station_cabina", reach=1.2)
k.container("SignalToolbox", (2.4, 0, 2.3), "station_signal_toolbox",
            item_ids=("signal_key",), counts=(1,), required_flag="puzzle:station_levers:lever_solved", reach=1.3
k.examine("Diagram", (1.0, 0, -3.2), ["El diagrama muestra tres señales: libre, desvío y bloqueo.", "Las posiciones numeradas son 2, 1 y 3."])
k.leo_hint("LeoSignals", (0.0, 0, -3.1), [
    "Leo: Las tres palancas tienen nombres y el diagrama también.",
    "Leo: No es un juego de fuerza. Sigue el orden del dibujo.",
    "Leo: Acciona libre, desvío y bloqueo; en el panel corresponden a las posiciones 2, 1 y 3."
])
prop_types = [
    "iron_column", "park_bench", "wall_lantern", "window_arch", "travel_poster",
    "plant_pot", "bench", "sodium_lamp", "station_sign", "crate",
    "typewriter_desk", "vending_machine", "wall_clock", "seat_pair",
    "fire", "ammo_box", "paper", "key",
]
camera_specs = [
    ("Panel", (-1.2, 1.5, -2.8), (5.5, 3.0, 5.5), (2.0, 3.0, 2.5), (-1.1, 0.5, -3.3)),
    ("Console", (-1.5, 1.5, -1.0), (5.5, 3.0, 5.5), (2.5, 3.0, 1.8), (-1.0, 0.5, -1.8)),
    ("Ticket", (-3.0, 1.5, 0.0), (5.0, 3.0, 5.5), (0.0, 3.0, 3.8), (-3.4, 0.5, 0.0)),
    ("South", (3.0, 1.5, 1.2), (5.0, 3.0, 5.5), (-1.0, 3.0, 3.5), (3.4, 0.5, 1.0)),
]
add_station_detail(k, "SignalCabin", prop_types,
                   ["CABINA DE SEÑALES", "LIBRE", "DESVÍO", "BLOQUEO",
                    "NO TOCAR", "SEÑALES", "SERVICIO", "ANDÉN SUR"],
                   camera_specs, (-4.0, 4.0, -4.0, 4.0))
k.save(REPO + "/levels/station/cabina_senales.tscn")
print("cabina_senales ok")
