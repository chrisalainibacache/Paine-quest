import sys, math, os; sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
from roomkit import *
k = Kit("TicketOffice", "Boletería")
k.env((0.02, 0.02, 0.025), (0.34, 0.32, 0.3), 0.5, (0.04, 0.035, 0.03), 0.05)
H = 2.9
k.shell(-2.5, 2.5, -2.0, 2.0, H, floor="planks", wall="plaster_wall", ceiling="concrete_wall", wainscot="wood")
# Mesón de atención con las ventanillas (muro sur, mirando a la sala de espera).
k.block("Counter", "Office", (-0.8, 0.5, 1.75), (3.4, 1.0, 0.5), "wood")
k.block("CounterTop", "Office", (-0.8, 1.02, 1.72), (3.5, 0.05, 0.6), "planks", solid=False)
for i, x in enumerate((-1.6, 0.0)):
    k.mesh("Window%d" % i, "Office", (1.2, 0.85, 0.02), k.s.res(M("window_glow"), "Material"), (x, 1.6, 1.99))
    for j in range(5):
        k.block("Bar%d_%d" % (i, j), "Office", (x - 0.5 + j * 0.25, 1.6, 1.96), (0.03, 0.85, 0.03), "metal", solid=False)
k.block("Stool", "Office", (-0.8, 0.35, 1.1), (0.4, 0.7, 0.4), "metal")
# Estantes con rollos de boletos y una caja fuerte (muro norte).
for i, y in enumerate((0.45, 1.15, 1.85)):
    k.block("Shelf%d" % i, "Office", (-0.6, y, -1.78), (2.6, 0.05, 0.4), "wood")
    for j in range(5):
        k.block("Tickets%d_%d" % (i, j), "Office", (-1.6 + j * 0.5, y + 0.12, -1.8), (0.25, 0.2, 0.25), "planks", solid=False)
for i, x in enumerate((-1.9, 0.7)):
    k.block("Upright%d" % i, "Office", (x, 1.1, -1.78), (0.06, 2.2, 0.4), "wood")
k.block("Safe", "Office", (1.85, 0.45, -1.6), (0.7, 0.9, 0.6), "metal")
# Escritorio del guardia (muro oeste) con la pistola y las balas.
k.block("DeskTop", "Office", (-2.05, 0.74, -0.3), (0.7, 0.05, 1.5), "wood")
for i, z in enumerate((-0.95, 0.35)):
    k.block("DeskLeg%d" % i, "Office", (-2.05, 0.36, z), (0.6, 0.72, 0.06), "wood")
k.mesh("LampShade", "Office", (0.18, 0.1, 0.18), k.emissive((0.3, 0.6, 0.35), 0.4), (-2.25, 1.05, 0.25))
k.block("LampArm", "Office", (-2.25, 0.9, 0.25), (0.03, 0.3, 0.03), "metal", solid=False)
k.light("DeskLight", "Lights", (-2.0, 1.25, 0.1), (1.0, 0.85, 0.6), 1.1, 4.0)
k.light("CeilingBulb", "Lights", (0.6, 2.6, 0.0), (1.0, 0.75, 0.5), 0.7, 5.0, flicker=True)
k.prop("Stain0", "Props", "stain", (0.4, 0.012, -0.4), rot=(0, 2.3, 0), scale=v3((1.1, 1, 1.1)))
# Puertas: a la sala de espera (sur) y al pasillo de servicio (este).
k.door_frame("ToWaiting", 1.7, 2.0, "x", width=1.0, wall_side=-1)
k.door_frame("ToCorridor", 2.5, -0.6, "z", width=1.0, wall_side=-1)
k.label("CorridorSign", "Office", (2.46, 1.75, -0.6), "SERVICIO", 26, (0.8, 0.75, 0.6), rot=(0, -math.pi / 2, 0))
k.door("DoorToWaitingRoom", (1.7, 0, 1.6), "res://levels/station/waiting_room.tscn", "from_ticket_office")
k.door("DoorToCorridor", (2.1, 0, -0.6), "res://levels/station/service_corridor.tscn", "from_ticket_office")
k.pickup("GuardAmmo", (-2.0, 0.77, -0.65), "ammo_9mm", 12, rot=(0, 0.5, 0), sets_flag="found:pistol")
k.pickup("Ammo", (-2.05, 0.77, -0.05), "ammo_9mm", 15, rot=(0, 1.2, 0))
k.note("Log", (-1.3, 1.05, 1.62), "ticket_log", paper_rot=(0, 0.2, 0))
k.examine("Safe", (1.85, 0, -1.15), ["Una caja fuerte. Está cerrada con clave.", "No tengo idea de la combinación."], reach=1.2)
k.examine("Windows", (-0.8, 0, 1.25), ["Por la ventanilla se ve la sala de espera.", "Desde aquí todo parece más tranquilo."], reach=1.0)
# Calcomanías.
k.decal("Bullets", "bullet_holes", (1.3, 2.15, -1.98), 0.9, "+z")
k.decal("SmearDesk", "blood_smear", (-2.48, 1.5, 0.95), (1.0, 0.5), "+x", rot=-0.2)
k.decal("Debris", "debris", (0.4, 0.016, 0.6), 1.2, "up")
k.decal("Footprints", "blood_footprints", (1.25, 0.018, 0.35), (1.6, 0.8), "up", rot=1.57)
# Cámaras.
k.camera("West", (-1.1, 1.4, 0.0), (2.8, 2.8, 4.0), (2.2, 2.6, 1.7), (-1.9, 0.5, -0.7), fov=64)
k.camera("East", (1.4, 1.4, 0.0), (2.2, 2.8, 4.0), (-2.2, 2.6, -1.6), (1.8, 0.4, 1.0), fov=64)
k.spawn("from_waiting_room", (1.7, 0.05, 1.15), (0, -1))
k.spawn("from_corridor", (1.75, 0.05, -0.6), (-1, 0))
k.save(REPO + "/levels/station/ticket_office.tscn")
print("ticket office ok")
