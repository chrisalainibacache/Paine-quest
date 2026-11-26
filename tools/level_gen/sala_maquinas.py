import sys, math, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
from roomkit import *
from station_detail import add_station_detail

k = Kit("MachineRoom", "Sala de máquinas", ambience="service_corridor")
k.env((0.012, 0.014, 0.016), (0.26, 0.29, 0.33), 0.42, (0.035, 0.045, 0.06), 0.07)
H = 3.1
k.shell(-4.5, 4.5, -4.0, 4.0, H, floor="concrete_floor", wall="concrete_wall",
        ceiling="concrete_wall", wainscot="tiles_wall", walls={"E": "old_bricks_wall"})
# Planta en U: dos brazos técnicos y un tablero central protegido.
k.block("UWallNorth", "Architecture", (0.0, 1.5, -2.1), (7.0, 3.0, 0.18), "old_bricks_wall")
k.block("UWallWest", "Architecture", (-3.4, 1.5, -0.1), (0.18, 3.0, 4.0), "concrete_wall")
k.block("UWallEast", "Architecture", (3.4, 1.5, -0.1), (0.18, 3.0, 4.0), "concrete_wall")
k.block("UWallReturn", "Architecture", (0.0, 1.5, 1.8), (3.0, 3.0, 0.18), "concrete_wall")
# Tablero de señales, transformadores y canaletas.
k.block("PowerBoard", "Electrical", (0.0, 1.5, -3.75), (2.4, 2.2, 0.18), "metal")
for index, x in enumerate((-0.85, 0.0, 0.85)):
    k.block("FuseSlot%d" % index, "Electrical", (x, 1.6, -3.62), (0.42, 0.62, 0.08), "rust", solid=False)
    k.block("FuseLabel%d" % index, "Electrical", (x, 2.05, -3.62), (0.38, 0.08, 0.04), "wood", solid=False)
k.block("MainSwitch", "Electrical", (1.65, 1.0, -3.65), (0.42, 0.85, 0.16), "iron_green")
k.block("Transformer", "Electrical", (-2.8, 0.9, -2.4), (1.0, 1.8, 1.0), "rust")
k.block("TransformerTop", "Electrical", (-2.8, 1.85, -2.4), (1.1, 0.08, 1.1), "metal", solid=False)
for index, z in enumerate((-1.8, -1.2, -0.6, 0.0, 0.6, 1.2)):
    k.block("CableTray%d" % index, "Electrical", (-3.9, 2.45, z), (0.08, 0.08, 0.5), "metal", solid=False)
# Rejillas de ventilación y soportes de tubería.
for index, x in enumerate((-2.8, -1.4, 0.0, 1.4, 2.8)):
    k.block("VentFrame%d" % index, "Architecture", (x, 2.55, 3.75), (0.7, 0.12, 0.12), "rust", solid=False)
    for slat in range(4):
        k.block("VentSlat%d_%d" % (index, slat), "Architecture",
                (x, 2.35 + slat * 0.1, 3.7), (0.58, 0.035, 0.05), "metal", solid=False)
# Puertas de la ala de máquinas.
k.door_frame("ToOffice", 0.0, 3.85, "x", width=1.1, wall_side=-1)
k.door_frame("ToSouth", 4.35, 1.0, "z", width=1.1, wall_side=-1)
k.door_frame("ToCorridor", -4.35, -0.1, "z", width=1.1, wall_side=1, panel="metal")
k.door("door_maquinas_oficina", (0.0, 0, 3.6), "res://levels/station/oficina_jefe.tscn", "from_machine_room", prompt="VOLVER")
k.door("door_maquinas_sur", (4.1, 0, 1.0), "res://levels/station/south_platform.tscn", "from_machine_room")
k.door("door_maquinas_pasillo", (-4.1, 0, -0.1), "res://levels/station/service_corridor.tscn", "from_machine_room",
       lock_id="station_power", requires_flag=True,
       locked_text="La compuerta eléctrica no libera el pestillo. El tablero necesita dos fusibles de 10 A.")
k.spawn("from_office", (0.0, 0.05, 3.0), (0, -1))
k.spawn("from_south_platform", (3.75, 0.05, 1.0), (-1, 0))
k.spawn("from_service_corridor", (-3.75, 0.05, -0.1), (1, 0))
# El tablero usa los fusibles que se registran en baños y oficina.
k.fuse_box("FuseBoard", (0.0, 0, -3.25), "station_fuses", unlock_id="station_power", reach=1.5)
k.examine("MainSwitch", (1.65, 0, -3.3), ["El interruptor principal está abajo.", "Primero debo instalar los dos fusibles; después puedo devolver la energía."])
k.examine("Transformer", (-2.8, 0, -2.0), ["Un transformador de señales.", "La carcasa está caliente, pero el circuito está muerto."])
k.leo_hint("LeoFuses", (0.0, 0, -3.2), [
    "Leo: El tablero tiene dos ranuras vacías y una placa de diez amperes.",
    "Leo: El olor del fusible del baño y el de la oficina es el mismo.",
    "Leo: Registra el fusible de la cisterna y el cajón inferior de la oficina; instala ambos en este tablero."
])
prop_types = [
    "iron_column", "park_bench", "wall_lantern", "window_arch", "travel_poster",
    "plant_pot", "bench", "sodium_lamp", "station_sign", "crate",
    "typewriter_desk", "vending_machine", "wall_clock", "seat_pair",
    "fire", "ammo_box", "paper", "key",
]
camera_specs = [
    ("Board", (0.0, 1.5, -2.8), (6.0, 3.0, 5.5), (0.5, 3.0, 2.8), (0.0, 0.5, -3.4)),
    ("West", (-3.0, 1.5, 0.0), (5.5, 3.0, 5.5), (0.0, 3.0, 3.0), (-3.2, 0.5, -0.2)),
    ("South", (3.0, 1.5, 1.4), (5.5, 3.0, 5.5), (-1.0, 3.0, 3.8), (3.5, 0.5, 1.2)),
    ("Entry", (0.0, 1.5, 3.0), (5.5, 3.0, 5.5), (3.8, 3.0, 3.8), (-0.2, 0.5, 2.8)),
]
add_station_detail(k, "MachineRoom", prop_types,
                   ["SALA DE MÁQUINAS", "SEÑALES", "10 A", "CORTE GENERAL",
                    "ALTA TENSIÓN", "MANTENIMIENTO", "NO PUENTEAR", "SALIDA"],
                   camera_specs, (-4.5, 4.5, -4.0, 4.0))
k.save(REPO + "/levels/station/sala_maquinas.tscn")
print("sala_maquinas ok")
