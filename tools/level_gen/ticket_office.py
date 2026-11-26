import sys, math, os; sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
from roomkit import *
import detail
k = Kit("TicketOffice", "Boletería", ambience="office")
k.env((0.02, 0.02, 0.025), (0.34, 0.32, 0.3), 0.5, (0.04, 0.035, 0.03), 0.05)
H = 2.9
k.shell(-4.0, 4.0, -3.5, 3.5, H, floor="planks", wall="plaster_wall", ceiling="concrete_wall", wainscot="wood")
# Planta en U: el mostrador divide la entrada y la caja fuerte queda en un rincón.
k.block("UPartition", "Architecture", (1.8, 1.35, 0.15), (0.16, 2.7, 3.6), "old_bricks_wall")
k.block("UReturn", "Architecture", (-0.2, 1.35, -1.8), (3.6, 2.7, 0.16), "plaster_wall")
# Mesón de atención con las ventanillas (muro sur, mirando a la sala de espera).
k.block("Counter", "Office", (-0.8, 0.5, 2.7), (4.2, 1.0, 0.5), "wood")
k.block("CounterTop", "Office", (-0.8, 1.02, 2.68), (4.3, 0.05, 0.6), "planks", solid=False)
for i, x in enumerate((-2.2, 0.0)):
    k.mesh("Window%d" % i, "Office", (1.2, 0.85, 0.02), k.s.res(M("window_glow"), "Material"), (x, 1.6, 2.99))
    for j in range(5):
        k.block("Bar%d_%d" % (i, j), "Office", (x - 0.5 + j * 0.25, 1.6, 2.96), (0.03, 0.85, 0.03), "metal", solid=False)
k.block("Stool", "Office", (-0.8, 0.35, 2.1), (0.4, 0.7, 0.4), "metal")
# Estantes con rollos de boletos y una caja fuerte (muro norte).
for i, y in enumerate((0.45, 1.15, 1.85)):
    k.block("Shelf%d" % i, "Office", (-0.6, y, -3.15), (2.6, 0.05, 0.4), "wood")
    for j in range(5):
        k.block("Tickets%d_%d" % (i, j), "Office", (-1.6 + j * 0.5, y + 0.12, -3.15), (0.25, 0.2, 0.25), "planks", solid=False)
for i, x in enumerate((-1.9, 0.7)):
    k.block("Upright%d" % i, "Office", (x, 1.1, -3.15), (0.06, 2.2, 0.4), "wood")
k.block("Safe", "Office", (2.8, 0.45, -2.65), (0.7, 0.9, 0.6), "metal")
# Escritorio del guardia (muro oeste) con la pistola y las balas.
k.block("DeskTop", "Office", (-3.25, 0.74, -0.3), (0.7, 0.05, 1.5), "wood")
for i, z in enumerate((-0.95, 0.35)):
    k.block("DeskLeg%d" % i, "Office", (-3.25, 0.36, z), (0.6, 0.72, 0.06), "wood")
k.mesh("LampShade", "Office", (0.18, 0.1, 0.18), k.emissive((0.3, 0.6, 0.35), 0.4), (-3.5, 1.05, 0.25))
k.block("LampArm", "Office", (-3.5, 0.9, 0.25), (0.03, 0.3, 0.03), "metal", solid=False)
k.light("DeskLight", "Lights", (-3.2, 1.25, 0.1), (1.0, 0.85, 0.6), 1.1, 4.0)
k.light("CeilingBulb", "Lights", (0.6, 2.6, 0.0), (1.0, 0.75, 0.5), 0.7, 5.0, flicker=True)
k.prop("Stain0", "Props", "stain", (0.4, 0.012, -0.4), rot=(0, 2.3, 0), scale=v3((1.1, 1, 1.1)))
# Puertas: a la sala de espera (sur) y al pasillo de servicio (este).
k.door_frame("ToWaiting", 1.7, 3.5, "x", width=1.0, wall_side=-1)
k.door_frame("ToCorridor", 4.0, -0.6, "z", width=1.0, wall_side=-1)
k.label("CorridorSign", "Office", (3.95, 1.75, -0.6), "SERVICIO", 26, (0.8, 0.75, 0.6), rot=(0, -math.pi / 2, 0))
k.door("DoorToWaitingRoom", (1.7, 0, 3.1), "res://levels/station/waiting_room.tscn", "from_ticket_office", prompt="VOLVER")
k.door("DoorToCorridor", (3.6, 0, -0.6), "res://levels/station/oficina_jefe.tscn", "from_ticket_office")
k.door("door_boleteria_cabina", (-3.6, 0, -1.2), "res://levels/station/cabina_senales.tscn", "from_ticket_office",
       key="office_key", lock_id="station_cabina",
       locked_text="La cabina está cerrada con llave de servicio. El panel de señales también puede liberar el cierre.")
k.pickup("GuardPistol", (-3.25, 0.78, -0.3), "pistol", rot=(0, 0.5, 0), sets_flag="found:pistol")
k.pickup("GuardAmmo", (-3.2, 0.77, -0.65), "ammo_9mm", 12, rot=(0, 0.5, 0))
k.pickup("Ammo", (-3.25, 0.77, -0.05), "ammo_9mm", 15, rot=(0, 1.2, 0))
k.note("Log", (-1.3, 1.05, 2.55), "ticket_log", paper_rot=(0, 0.2, 0))
k.note("SignalDiagram", (2.8, 0.0, -2.5), "station_signal_diagram",
       required_flag="puzzle:station_safe:code_solved",
       locked_text="La caja fuerte todavía está cerrada.")
k.examine("Safe", (2.8, 0, -2.5), ["Una caja fuerte. Está cerrada con clave.", "No tengo idea de la combinación."], reach=1.2)
k.code_lock("SafeCode", (2.8, 0, -2.5), "station_safe", unlock_id="station_safe", reach=1.2)
k.container("SafeContents", (2.8, 0, -2.5), "station_safe",
            item_ids=("ammo_9mm",), counts=(10,),
            required_flag="puzzle:station_safe:code_solved", reach=1.2)
k.examine("Windows", (-0.8, 0, 2.2), ["Por la ventanilla se ve la sala de espera.", "Desde aquí todo parece más tranquilo."], reach=1.0)
# Calcomanías.
k.decal("Bullets", "bullet_holes", (2.8, 2.15, -3.48), 0.9, "+z")
k.decal("SmearDesk", "blood_smear", (-3.88, 1.5, 0.95), (1.0, 0.5), "+x", rot=-0.2)
k.decal("Debris", "debris", (0.4, 0.016, 0.6), 1.2, "up")
k.decal("Footprints", "blood_footprints", (2.2, 0.018, 1.0), (1.6, 0.8), "up", rot=1.57)
# Cámaras.
k.camera("West", (-1.1, 1.4, 0.0), (2.8, 2.8, 4.0), (2.2, 2.6, 1.7), (-1.9, 0.5, -0.7), fov=64)
k.camera("East", (1.4, 1.4, 0.0), (2.2, 2.8, 4.0), (-2.2, 2.6, -1.6), (1.8, 0.4, 1.0), fov=64)
k.spawn("from_waiting_room", (1.7, 0.05, 2.5), (0, -1))
k.spawn("from_corridor", (3.0, 0.05, -0.6), (-1, 0))
k.spawn("from_office", (3.0, 0.05, -0.6), (-1, 0))
k.spawn("from_signal_cabin", (-2.4, 0.05, -1.7), (1, 0))
# Pistas de Leo: adonde guía a Isabella cuando se queda quieta y qué le explica.
k.leo_hint('LeoGuardDesk', (-1.5, 0, -0.65), ['Leo: El escritorio de don Héctor. Rosa dejó aquí sus balas.', 'Leo: No me gusta ese ruido, Isabella. Pero es mejor que lo tengas tú.'], hide_if='found:pistol')
k.leo_hint('LeoCorridor', (1.6, 0, -0.6), ['Leo: La llave del portón está en la bodega. Este pasillo lleva allá.', 'Leo: Yo voy adelante. Si me erizo y bufo, es que alguien nos espera.', 'Leo: Sal por la puerta PASILLO DE SERVICIO; allí sigue la puerta BODEGA para buscar la llave del portón.'], show_if='found:pistol', hide_item='gate_key')
detail.dress(k, -3.7, 3.7, -3.2, 3.2, H, theme="office", seed=507,
             avoid=[(-0.8, 2.7, 1.3), (-3.25, -0.3, 1.2), (2.8, -2.5, 1.1),
                    (1.7, 3.1, 0.9), (3.6, -0.6, 0.9), (-3.6, -1.2, 0.9)])
own_props = [
    ("DeskRadio", "field_radio", (-3.2, 0.9, -0.3)), ("Filing", "filing_cabinet", (-3.6, 0.0, -2.8)),
    ("Shelf", "shelf_unit", (-2.8, 0.0, -2.8)), ("NoticeBoard", "notice_board", (3.6, 0.0, 2.8)),
    ("PipeRack", "pipe_rack", (-3.6, 0.0, 1.2)), ("Extinguisher", "extinguisher", (3.6, 0.0, -2.8)),
    ("WallClock", "wall_clock", (0.0, 2.3, 3.4)), ("Plant", "plant_pot", (3.2, 0.0, 2.4)),
    ("TravelPoster", "travel_poster", (-3.8, 1.5, 1.0)), ("StationSign", "station_sign", (0.0, 2.2, 3.4)),
    ("CrateA", "crate", (2.8, 0.0, -3.0)), ("CrateB", "crate", (3.2, 0.0, -3.0)),
    ("Paper", "paper", (-3.2, 0.9, -0.3)), ("KeyProp", "key", (-3.0, 0.9, -0.3)),
    ("AmmoBox", "ammo_box", (2.4, 0.0, -3.0)), ("Bench", "bench", (3.0, 0.0, 2.0)),
]
for prop_name, scene_name, prop_pos in own_props:
    k.prop(prop_name, "DetailProps", scene_name, prop_pos, scale=v3((0.42, 0.42, 0.42)))
k.save(REPO + "/levels/station/ticket_office.tscn")
print("ticket office ok")
