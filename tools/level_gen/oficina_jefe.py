import sys, math, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
from roomkit import *
import detail

k = Kit("OfficeChief", "Oficina del jefe", ambience="office")
k.env((0.018, 0.016, 0.014), (0.32, 0.30, 0.27), 0.52, (0.045, 0.035, 0.025), 0.055)
H = 3.0
# Oficina en L: sala de archivo amplia y brazo de acceso hacia la cabina.
k.shell(-5.0, 5.0, -4.0, 4.0, H, floor="planks", wall="plaster_wall",
        ceiling="concrete_wall", wainscot="wood", walls={"N": "old_bricks_wall"})
k.block("InnerWingWall", "Architecture", (2.1, 1.45, -1.65), (5.7, 2.9, 0.18), "old_bricks_wall")
k.block("WingReturnNorth", "Architecture", (4.85, 1.45, -2.6), (0.18, 2.9, 1.0), "old_bricks_wall")
k.block("WingReturnSouth", "Architecture", (4.85, 1.45, 2.6), (0.18, 2.9, 1.0), "old_bricks_wall")
k.block("Lintel", "Architecture", (2.1, 2.55, -2.05), (1.3, 0.16, 0.2), "wood", solid=False)
k.block("ArchiveStep", "Architecture", (-2.8, 0.08, -2.4), (2.6, 0.16, 1.4), "concrete_wall")
# Mostrador, escritorio, archivadores y armario de personal.
k.block("ChiefDeskTop", "Furniture", (-1.5, 0.78, 0.8), (2.8, 0.08, 1.1), "wood")
for i, x in enumerate((-2.65, -0.35)):
    for j, z in enumerate((0.35, 1.25)):
        k.block("DeskLeg%d_%d" % (i, j), "Furniture", (x, 0.38, z), (0.08, 0.76, 0.08), "wood")
k.block("DeskDrawer", "Furniture", (-1.5, 0.55, 0.55), (1.1, 0.3, 0.72), "planks")
k.block("Wardrobe", "Furniture", (-4.25, 1.0, -1.4), (1.1, 2.0, 0.65), "wood")
k.block("CoatRail", "Furniture", (-4.25, 1.8, -1.4), (0.8, 0.05, 0.05), "metal", solid=False)
k.block("Coat", "Furniture", (-4.2, 1.25, -1.45), (0.45, 1.0, 0.08), "rust", solid=False)
for row, y in enumerate((0.45, 1.15, 1.85)):
    k.block("ArchiveShelf%d" % row, "Furniture", (1.0, y, -3.55), (3.3, 0.06, 0.5), "wood")
    for col_idx in range(7):
        k.block("ArchiveBox%d_%d" % (row, col_idx), "Furniture",
                (-0.45 + col_idx * 0.48, y + 0.18, -3.55), (0.34, 0.32, 0.4), "planks", solid=False)
# Cableado, tubos, vigas y lámparas: arquitectura con capas, no una caja vacía.
for i, x in enumerate((-4.4, -2.2, 0.0, 2.2, 4.4)):
    k.block("CeilingBeam%d" % i, "Architecture", (x, 2.82, 0.0), (0.12, 0.12, 7.4), "rust", solid=False)
for i, z in enumerate((-3.3, -2.7, 2.7, 3.3)):
    k.block("Cable%d" % i, "Architecture", (0.0, 2.65, z), (9.2, 0.045, 0.045), "metal", solid=False)
for i, x in enumerate((-3.8, -1.0, 1.8, 4.0)):
    k.block("Pipe%d" % i, "Architecture", (x, 2.45, 3.45), (0.08, 0.08, 0.9), "rust", solid=False)
# Props de estación: más de 40 instancias y al menos 14 familias distintas.
# Pasada oficial de detalle de oficina; los objetos narrativos quedan protegidos por avoid.
detail.dress(k, -4.7, 4.7, -3.7, 3.7, H, theme="office", seed=504,
             avoid=[(-1.5, 0.8, 1.3), (-4.25, -1.4, 1.0), (1.0, -3.55, 1.2),
                    (-2.0, 3.6, 0.9), (4.6, 0.0, 0.9), (0.0, -3.6, 0.9),
                    (-4.2, -1.4, 1.0), (1.0, -3.25, 1.0)])
own_props = [
    ("ChiefTypewriter", "typewriter_desk", (-2.8, 0.0, 0.0)),
    ("VendingMachine", "vending_machine", (3.7, 0.0, 1.4)),
    ("StationSign", "station_sign", (0.0, 2.3, 3.6)),
    ("ArchiveCrate", "crate", (-3.8, 0.0, -3.0)),
    ("ArchiveCrate2", "crate", (-3.0, 0.0, -3.0)),
    ("PaperStack", "paper", (-1.4, 0.9, 0.7)),
    ("AmmoBox", "ammo_box", (0.8, 0.0, -3.0)),
    ("WaitingSeat", "seat_pair", (2.4, 0.0, -3.0)),
    ("Plant", "plant_pot", (-3.6, 0.0, 2.2)),
    ("Poster", "travel_poster", (-4.8, 1.5, 3.82)),
    ("WallClock", "wall_clock", (-1.8, 2.2, 3.82)),
]
for prop_name, scene_name, prop_pos in own_props:
    k.prop(prop_name, "Props", scene_name, prop_pos, scale=v3((0.48, 0.48, 0.48)))
# Carteles y etiquetas legibles en cuatro puntos de la oficina.
for i, (pos, label) in enumerate([
    ((-4.8, 2.5, -0.1), "JEFATURA"), ((-1.4, 2.5, -3.8), "ARCHIVO"),
    ((4.8, 2.4, 1.5), "CABINA"), ((0.0, 2.5, 3.8), "ESTACIÓN DE PAINE"),
    ((-4.8, 1.8, 2.0), "PERSONAL"), ((2.5, 2.0, -3.8), "PLANOS"),
    ((4.8, 1.7, -2.5), "SEÑALES"), ((-2.0, 2.0, -3.8), "INVENTARIO"),
]):
    k.label("Label%d" % i, "Signs", pos, label, 26, (0.78, 0.68, 0.48))
# Iluminación cálida de escritorio y luz fría de emergencia.
k.light("DeskLight", "Lights", (-1.5, 1.9, 0.8), (1.0, 0.72, 0.42), 1.25, 4.8)
k.light("ArchiveLight", "Lights", (1.2, 2.5, -3.1), (0.6, 0.72, 1.0), 0.75, 4.0, flicker=True)
k.light("HallLight", "Lights", (3.8, 2.5, 1.5), (1.0, 0.55, 0.28), 0.9, 4.2)
k.light("EmergencyLight", "Lights", (-4.2, 2.4, -1.4), (0.65, 0.08, 0.05), 0.6, 3.5, flicker=True)
# Puertas del hub: tres alas; todas con rutas de regreso.
k.door_frame("ToTicketOffice", -2.0, 3.85, "x", width=1.1, wall_side=-1)
k.door_frame("ToSignalCabin", 4.85, 0.0, "z", width=1.1, wall_side=-1)
k.door_frame("ToMachineRoom", 0.0, -3.85, "x", width=1.1, wall_side=1)
k.door("door_boleteria_oficina", (-2.0, 0, 3.6), "res://levels/station/ticket_office.tscn", "from_office")
k.door("door_oficina_cabina", (4.6, 0, 0.0), "res://levels/station/cabina_senales.tscn", "from_office")
k.door("door_oficina_maquinas", (0.0, 0, -3.6), "res://levels/station/sala_maquinas.tscn", "from_office")
# Marcadores de aparición; las cámaras cubren las entradas.
k.spawn("from_ticket_office", (-2.0, 0.05, 3.0), (0, -1))
k.spawn("from_signal_cabin", (4.0, 0.05, 0.0), (-1, 0))
k.spawn("from_machine_room", (0.0, 0.05, -3.0), (0, 1))
k.spawn("start", (-4.0, 0.05, 1.0), (1, 0))
# Interacción provisional de la oficina; P15-c conecta llaves, fusibles y mapa.
k.examine("ChiefDesk", (-1.5, 0, 0.8), ["El escritorio del jefe de estación.", "Los documentos están revueltos. Hay marcas de que alguien buscó algo a oscuras."])
k.container("Coat", (-4.2, 0, -1.4), "station_office_coat",
            item_ids=("office_key",), counts=(1,), reach=1.3)
k.container("Archive", (1.0, 0, -3.25), "station_office_archive",
            item_ids=("map_station", "fuse_station_b"), counts=(1, 1),
            key_item="office_key", lock_id="office_archive", reach=1.3)
k.note("OfficeInventory", (-0.5, 0.95, 0.7), "station_fuse_inventory", paper_rot=(0, 0.2, 0))
k.leo_hint("LeoOfficeMap", (-3.8, 0, -1.4), [
    "Leo: El jefe guardaba los planos en el archivador, no en el suelo.",
    "Leo: La oficina conecta con las señales y con la sala de máquinas.",
    "Leo: Registra el archivador de la oficina para encontrar el mapa de la estación."
])
# Decals: 16 manchas y señales de desgaste con causas visibles.
for i, (x, z, size, seed) in enumerate([
    (-4.2, 2.2, 1.1, 0.2), (-3.2, 1.5, 0.8, 1.1), (-2.0, 0.1, 1.3, 2.0),
    (-1.0, -0.8, 0.9, 3.0), (0.4, -1.5, 1.2, 4.1), (1.4, -2.4, 0.8, 5.0),
    (2.5, 1.1, 1.0, 0.5), (3.5, 0.4, 1.4, 1.5), (4.2, -1.8, 0.9, 2.5),
    (-4.4, -2.5, 1.3, 3.5), (-3.1, -3.2, 0.8, 4.5), (-1.6, 2.4, 1.1, 5.5),
    (0.2, 2.6, 0.9, 0.8), (1.8, 2.1, 1.2, 1.8), (3.0, -2.9, 1.0, 2.8),
    (4.4, 2.6, 0.8, 3.8), (-2.6, -1.8, 1.4, 4.8)
]):
    k.decal("Stain%d" % i, "blood_splatter_a" if i % 3 == 0 else "damp_stain",
            (x, 0.014, z), size, "up", rot=seed, opacity=0.65 if i % 2 else 0.9)
k.decal("BulletWall", "bullet_holes", (4.95, 1.4, 0.8), 0.9, "-x")
k.decal("CrackWall", "cracks", (-4.95, 1.7, -2.4), 1.1, "+x")
# Cuatro cámaras prerenderizadas; zonas solapadas para los spawns y el recorrido.
k.camera("Desk", (-2.5, 1.5, 0.8), (6.0, 3.0, 5.5), (0.5, 3.0, 4.8), (-2.2, 0.5, 0.2), fov=62)
k.camera("Archive", (1.8, 1.5, -2.4), (6.0, 3.0, 5.5), (-1.0, 3.0, 1.5), (2.5, 0.5, -3.1), fov=62)
k.camera("Wing", (3.6, 1.5, 1.5), (5.0, 3.0, 5.5), (1.0, 3.0, 3.8), (4.2, 0.5, -0.2), fov=62)
k.camera("Entry", (-4.0, 1.5, 1.0), (5.5, 3.0, 5.5), (0.8, 3.0, 4.0), (-4.0, 0.5, 0.5), fov=62)
k.save(REPO + "/levels/station/oficina_jefe.tscn")
print("oficina_jefe ok")
