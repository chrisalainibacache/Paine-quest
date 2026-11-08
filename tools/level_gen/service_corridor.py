import sys, math, os; sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
from roomkit import *
k = Kit("ServiceCorridor", "Pasillo de servicio")
k.env((0.01, 0.01, 0.012), (0.28, 0.3, 0.32), 0.45, (0.03, 0.03, 0.035), 0.07)
H = 2.7
k.shell(-6.0, 6.0, -1.0, 1.0, H, floor="concrete_floor", wall="concrete_wall", ceiling="concrete_wall", wainscot="tiles_wall",
        walls={"N": "old_bricks_wall"})
k.door_frame("ToOffice", -6.0, 0.0, "z", width=1.0, wall_side=1)
k.door_frame("ToStore", 6.0, 0.0, "z", width=1.1, wall_side=-1, panel="metal")
k.label("StoreSign", "Details", (5.95, 2.3, 0.0), "BODEGA", 30, (0.8, 0.75, 0.6), rot=(0, -math.pi / 2, 0))
# Casilleros, banca y cañerías.
for i in range(4):
    k.block("Locker%d" % i, "Details", (-3.3 + i * 0.58, 0.95, -0.76), (0.55, 1.9, 0.44), "metal")
k.block("Bench", "Details", (-1.9, 0.22, -0.4), (1.4, 0.44, 0.3), "wood")
for i, (z, y) in enumerate(((-0.78, 2.45), (-0.6, 2.5))):
    k.block("Pipe%d" % i, "Details", (0.0, y, z), (12.0, 0.08, 0.08), "rust", solid=False)
k.mesh("FuseBox", "Details", (0.4, 0.5, 0.1), k.s.res(M("metal"), "Material"), (2.0, 1.5, 0.95))
k.block("Bucket", "Details", (4.1, 0.2, 0.72), (0.35, 0.4, 0.35), "rust")
k.block("Debris", "Details", (0.6, 0.12, -0.7), (0.8, 0.24, 0.4), "planks")
for i, (x, z, sz, seed) in enumerate([(-3.4, 0.4, 1.3, 1.1), (-2.6, 0.1, 0.8, 4.0), (1.2, 0.2, 1.2, 2.5), (4.6, -0.3, 1.0, 6.2)]):
    k.prop("Stain%d" % i, "Details", "stain", (x, 0.012, z), rot=(0, seed, 0), scale=v3((sz, 1, sz)))
# Luces: una normal y una que parpadea.
bulb = k.emissive((1.0, 0.85, 0.6), 1.2)
for i, x in enumerate((-3.0, 3.0)):
    k.mesh("Bulb%d" % i, "Lights", (0.08, 0.12, 0.08), bulb, (x, H - 0.12, 0.0))
k.light("BulbWest", "Lights", (-3.0, H - 0.3, 0.0), (1.0, 0.78, 0.5), 0.9, 4.8)
k.light("BulbEast", "Lights", (3.0, H - 0.3, 0.0), (1.0, 0.78, 0.5), 0.85, 4.8, flicker=True)
# Puertas, ítems y objetos.
k.door("DoorToTicketOffice", (-5.6, 0, 0.0), "res://levels/station/ticket_office.tscn", "from_corridor")
k.door("DoorToStoreroom", (5.6, 0, 0.0), "res://levels/station/storeroom.tscn", "from_corridor")
k.pickup("Handroll", (-1.7, 0.45, -0.4), "handroll", rot=(0, 0.8, 0))
k.pickup("Ammo", (4.45, 0.0, 0.7), "ammo_9mm", 10, rot=(0, 2.0, 0))
k.examine("FuseBox", (2.0, 0, 0.55), ["Una caja de fusibles.", "Alguien arrancó los cables a tirones."], reach=1.1)
k.examine("Lockers", (-2.4, 0, -0.3), ["Casilleros del personal. Todos con candado,", "menos uno: adentro solo hay un uniforme con sangre."], reach=1.0)
# Infectados: un cadáver de verdad, uno haciéndose el muerto y uno de espaldas.
k.infected("Corpse", (-3.6, 0.05, 0.45), yaw=0.4, state="corpse", kind="infected_burnt")
k.infected("Lying", (1.2, 0.05, 0.25), yaw=1.3, state="lying", kind="infected_pale")
k.infected("Standing", (4.7, 0.05, -0.35), yaw=math.pi / 2, kind="infected_worker")
# Calcomanías.
k.decal("GraffitiNoche", "graffiti_noche", (-4.6, 2.05, -0.98), (2.4, 1.2), "+z", wear=0.4)
k.decal("GraffitiSignal", "graffiti_no_signal", (3.4, 1.85, -0.98), (2.8, 1.4), "+z", wear=0.3)
k.decal("HandSouth", "blood_handprint", (-4.4, 1.15, 0.98), 0.4, "-z", rot=0.4)
k.decal("SmearNorth", "blood_smear", (0.1, 1.0, -0.98), (1.2, 0.6), "+z", rot=0.1)
k.decal("BloodSouth", "blood_splatter_c", (-3.0, 1.05, 0.98), 1.0, "-z")
k.decal("HoleSouth", "wall_hole_a", (2.9, 0.75, 0.98), 0.8, "-z")
k.decal("BulletsNorth", "bullet_holes", (4.9, 1.45, -0.98), 0.9, "+z")
k.decal("DragCorpse", "blood_drag", (-2.5, 0.017, 0.3), (2.4, 0.9), "up", rot=3.0)
k.decal("Footprints", "blood_footprints", (4.0, 0.018, 0.2), (1.8, 0.85), "up", rot=3.14)
k.decal("Damp", "damp_stain", (-5.0, 0.015, -0.3), 1.4, "up")
# Cámaras: tres tramos del pasillo.
k.camera("West", (-4.0, 1.3, 0.0), (4.0, 2.6, 2.0), (-1.4, 2.35, 0.75), (-5.6, 0.4, -0.3), fov=62)
k.camera("Middle", (0.1, 1.3, 0.0), (4.2, 2.6, 2.0), (-1.0, 2.2, 0.75), (2.8, 0.5, -0.3), fov=62)
k.camera("East", (4.1, 1.3, 0.0), (3.8, 2.6, 2.0), (5.7, 2.35, 0.75), (1.4, 0.5, -0.3), fov=62)
k.spawn("from_ticket_office", (-5.2, 0.05, 0.0), (1, 0))
k.spawn("from_storeroom", (5.2, 0.05, 0.0), (-1, 0))
k.save(REPO + "/levels/station/service_corridor.tscn")
print("corridor ok")
