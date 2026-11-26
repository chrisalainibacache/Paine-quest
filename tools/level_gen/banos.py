import sys, math, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
from roomkit import *
from station_detail import add_station_detail

k = Kit("Bathrooms", "Baños", ambience="service_corridor")
k.env((0.015, 0.016, 0.018), (0.28, 0.3, 0.34), 0.48, (0.035, 0.045, 0.06), 0.065)
H = 2.8
k.shell(-4.5, 4.5, -4.0, 4.0, H, floor="tiles_wall", wall="plaster_wall",
        ceiling="concrete_wall", wainscot="tiles_wall", walls={"N": "old_bricks_wall"})
# Forma en L: recodo hacia las cabinas; no se ve la cisterna desde la entrada.
k.block("LPartition", "Architecture", (1.9, 1.35, -2.15), (5.2, 2.7, 0.18), "tiles_wall")
k.block("PartitionReturn", "Architecture", (4.35, 1.35, -0.15), (0.18, 2.7, 3.8), "tiles_wall")
# Dos cabinas con puertas rotas y un cubículo de limpieza.
for index, x in enumerate((-2.5, -0.8, 1.0)):
    k.block("CubicleSide%d" % index, "Architecture", (x, 1.2, -2.8), (0.08, 2.4, 2.1), "tiles_wall")
    k.block("CubicleFront%d" % index, "Architecture", (x + 0.75, 1.2, -1.8), (1.5, 2.4, 0.08), "tiles_wall")
    k.block("CubicleDoor%d" % index, "Architecture", (x + 0.75, 1.05, -1.75), (0.72, 2.1, 0.06), "wood", solid=False)
# Lavamanos, espejos y cañerías.
for index, x in enumerate((-3.2, -1.1, 1.1)):
    k.block("Sink%d" % index, "Fixtures", (x, 0.85, 3.35), (1.1, 0.16, 0.65), "concrete_wall")
    k.block("SinkBase%d" % index, "Fixtures", (x, 0.42, 3.4), (0.72, 0.8, 0.5), "tiles_wall")
    k.mesh("Mirror%d" % index, "Fixtures", (0.82, 0.95, 0.025), k.s.res(M("window_glow"), "Material"), (x, 1.85, 3.78))
    k.block("Tap%d" % index, "Fixtures", (x, 1.02, 3.1), (0.08, 0.22, 0.08), "metal", solid=False)
for index, y in enumerate((2.25, 2.45, 2.65)):
    k.block("WaterPipe%d" % index, "Fixtures", (-4.25, y, 0.0), (0.08, 0.08, 7.0), "rust", solid=False)
# Cistern de inspección, válvula y tapa en el recodo.
k.block("CisternBase", "Fixtures", (-3.3, 0.25, -0.2), (1.4, 0.5, 1.2), "concrete_wall")
k.block("CisternTank", "Fixtures", (-3.3, 0.9, -0.2), (1.2, 0.9, 1.0), "tiles_wall")
k.block("CisternLid", "Fixtures", (-3.3, 1.38, -0.2), (1.0, 0.06, 0.8), "metal", solid=False)
k.block("ValvePipe", "Fixtures", (-2.65, 1.05, -0.2), (0.55, 0.08, 0.08), "rust", solid=False)
k.block("ValveWheel", "Fixtures", (-2.35, 1.05, -0.2), (0.08, 0.4, 0.4), "metal", solid=False)
# Puertas, spawns y conexión del hub.
k.door_frame("ToWaiting", -4.35, 1.0, "z", width=1.1, wall_side=1)
k.door_frame("ToService", 4.35, -0.1, "z", width=1.1, wall_side=-1, panel="metal")
k.label("WaitingSign", "Signs", (-4.42, 2.25, 1.0), "SALA DE ESPERA", 24, (0.75, 0.68, 0.52), rot=(0, math.pi / 2, 0))
k.label("ServiceSign", "Signs", (4.42, 2.25, -0.1), "SERVICIO", 24, (0.75, 0.68, 0.52), rot=(0, -math.pi / 2, 0))
k.door("door_banos_espera", (-4.1, 0, 1.0), "res://levels/station/waiting_room.tscn", "from_banos", prompt="VOLVER")
k.door("door_banos_pasillo", (4.1, 0, -0.1), "res://levels/station/service_corridor.tscn", "from_banos")
k.spawn("from_waiting_room", (-3.75, 0.05, 1.0), (1, 0))
k.spawn("from_service_corridor", (3.75, 0.05, -0.1), (-1, 0))
# Interacciones: la válvula precede a REGISTRAR la cisterna.
k.examine("Valve", (-2.35, 0, -0.2), ["Una válvula vieja. La inscripción dice: CERRAR ANTES DE ABRIR.", "El agua deja de correr cuando la giro."])
k.examine("Cistern", (-3.3, 0, -0.2), ["La tapa de inspección está trabada por la presión del agua.", "Primero tengo que cerrar la válvula; después podré registrar el interior."])
k.examine("BrokenMirror", (2.8, 0, 3.7), ["El espejo está roto desde dentro.", "Entre las grietas hay marcas de dedos húmedos."])
k.leo_hint("LeoFuseBathroom", (-3.3, 0, -0.2), [
    "Leo: El agua suena debajo de esa tapa. La válvula está al lado.",
    "Leo: Si el agua no para, no vas a poder abrirla.",
    "Leo: Cierra la válvula de paso y registra la cisterna para buscar el fusible."
])
# Propiedades de baño + utilería de estación, organizada en recodos.
prop_types = [
    "wall_lantern", "plant_pot", "crate", "station_sign", "wall_clock",
    "park_bench", "window_arch", "travel_poster", "iron_column", "sodium_lamp",
    "bench", "vending_machine", "typewriter_desk", "paper", "key", "ammo_box",
    "seat_pair", "fire",
]
camera_specs = [
    ("Entry", (-3.0, 1.5, 1.0), (5.0, 3.0, 5.5), (0.0, 3.0, 4.8), (-3.4, 0.5, 0.2)),
    ("Cubicles", (0.0, 1.5, -2.0), (5.5, 3.0, 5.5), (-2.8, 3.0, 1.0), (1.2, 0.5, -2.5)),
    ("Cistern", (-3.2, 1.5, -0.2), (5.0, 3.0, 5.5), (0.5, 3.0, 2.2), (-3.2, 0.5, -0.2)),
    ("Service", (3.0, 1.5, 0.0), (5.5, 3.0, 5.5), (-1.0, 3.0, -1.0), (3.8, 0.5, 0.0)),
]
add_station_detail(k, "Bathrooms", prop_types,
                   ["BAÑOS", "PERSONAL", "CERRAR ANTES DE ABRIR", "AGUA POTABLE",
                    "NO PASAR", "LIMPIEZA", "SERVICIO", "SALIDA"],
                   camera_specs, (-4.5, 4.5, -4.0, 4.0))
k.save(REPO + "/levels/station/banos.tscn")
print("banos ok")
