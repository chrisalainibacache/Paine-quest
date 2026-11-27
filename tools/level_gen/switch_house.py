import sys, math, os; sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
from roomkit import *
T = "res://levels/tracks/%s.tscn"
# Casa de cambios: sala segura con máquina de escribir, la nota del
# maquinista y la salida a la vía hacia Santiago (fin del capítulo 2).
k = Kit("SwitchHouse", "Casa de cambios", ambience="switch_house")
k.env((0.03, 0.03, 0.035), (0.4, 0.38, 0.35), 0.8, (0.06, 0.055, 0.05), 0.04)
X0, X1, Z0, Z1, H = -3.0, 3.0, -2.5, 2.5, 2.8
k.shell(X0, X1, Z0, Z1, H, floor="planks", wall="bricks_wall", ceiling="concrete_wall", wainscot="wood")
k.door_frame("ToUnderpass", X0, 0.0, "z", width=1.0, wall_side=1, panel="planks")
k.door_frame("ToTracks", X1, 0.6, "z", width=1.1, wall_side=-1, panel="metal")
k.label("ExitSign", "Details", (2.96, 2.4, 0.6), "VÍA NORTE · SANTIAGO", 30, (0.85, 0.82, 0.7), rot=(0, -math.pi / 2, 0))
# Bastidor de palancas de cambios (muro norte).
k.block("LeverFrame", "Details", (0.0, 0.45, -2.2), (3.6, 0.9, 0.4), "metal")
for i in range(8):
    color = "train_red" if i % 2 == 0 else "train_cream"
    k.block("Lever%d" % i, "Details", (-1.5 + i * 0.43, 1.25, -2.15), (0.07, 0.8, 0.07), color, solid=False, rot=(0.25 if i % 3 else -0.25, 0, 0))
k.block("TrackDiagram", "Details", (0.0, 1.95, -2.48), (2.4, 0.6, 0.03), "wood", solid=False)
k.prop("Desk", "Props", "typewriter_desk", (2.5, 0, -1.4), rot=(0, -math.pi / 2, 0))
k.block("Cot", "Props", (-2.2, 0.3, 1.6), (1.4, 0.3, 0.7), "seat_fabric")
k.block("CotLegs", "Props", (-2.2, 0.08, 1.6), (1.3, 0.16, 0.6), "metal", solid=False)
k.light("Lamp", "Lights", (0.0, 2.4, 0.0), (1.0, 0.8, 0.55), 1.0, 6.0, flicker=True)
k.mesh("Bulb", "Lights", (0.1, 0.14, 0.1), k.emissive((1.0, 0.85, 0.6), 1.2), (0.0, H - 0.15, 0.0))
k.decal("HandCot", "blood_handprint", (-2.98, 1.0, 1.4), 0.38, "+x", rot=0.2)
k.decal("PoolCot", "blood_pool", (-1.6, 0.012, 1.4), 1.0, "up")
k.decal("Debris", "debris", (1.0, 0.013, 1.5), 1.2, "up")
# Interactuables.
k.door("ToUnderpass", (-2.6, 0, 0.0), T % "underpass", "from_switch", reach=1.3)
k.interact("Typewriter", "typewriter", (2.15, 0.8, -1.4), reach="1.4")
k.storage_chest("StorageChest", (0.0, 0.45, 1.8))
k.note("EngineerNote", (-1.6, 0.47, 1.6), "engineer_note", paper_rot=(0, 0.4, 0), paper_scale=0.7, reach=1.4)
k.pickup("Shells", (1.4, 0.0, 2.1), "ammo_shells", 6, rot=(0, 0.5, 0))
k.pickup("Rocket", (-0.6, 0.0, 2.1), "ammo_rockets", 1, rot=(0, 1.4, 0))
k.pickup("Handroll", (2.5, 0.77, -1.0), "handroll", rot=(0, 0.3, 0))
# Cambio de vías: tres palancas en el orden del plano (desvío, freno, norte); la clavija del drenaje encaja en el bastidor.
k.lever_sequence("SwitchSequence", (0.0, 0, -1.7), "cap2_signal_levers", reach=1.6)
for lever_id, x in (("desvio", -1.2), ("freno", 0.0), ("norte", 1.2)):
    k.lever("Switch" + lever_id.capitalize(), (x, 0, -1.9), "cap2_signal_levers", lever_id, unlock_id="tracks_line", reach=1.2)
k.fuse_box("SignalSocket", (1.9, 0, -1.3), "cap2_signal_socket", unlock_id="tracks_pin", fuse_item="signal_pin", reach=1.4)
k.examine("SwitchPlan", (-2.2, 0, -1.3), ["Plano de cambios: DESVÍO · FRENO · NORTE.", "El tren fue enviado al ramal para que el coche 3 no llegara a Alameda. La línea norte queda libre cuando el cambio vuelve a N."], reach=1.3)
k.interact("TrackExit", "chapter_exit", (2.6, 0, 0.6), reach="1.3", chapter="2",
           required_flags='PackedStringArray("unlocked:tracks_fire_out", "unlocked:tracks_power", "unlocked:tracks_pin", "unlocked:tracks_line")',
           blocked_text='"Todavía faltan pasos: apagar el incendio de la locomotora, devolver la energía, instalar la clavija y alinear el cambio."',
           question='"Afuera, la vía sigue hacia el norte, hacia Santiago. Empieza a aclarar.\\n¿Seguir caminando con Leo?"')
k.infected("Engineer", (-2.0, 0.36, 1.6), yaw=1.57, state="corpse", kind="infected_worker")
# Cámaras.
k.camera("West", (-1.5, 1.4, 0.0), (3.0, 2.8, 5.0), (2.6, 2.5, 2.1), (-2.4, 0.4, -0.6), fov=64)
k.camera("East", (1.5, 1.4, 0.0), (3.0, 2.8, 5.0), (-2.6, 2.5, -2.1), (2.4, 0.4, 0.8), fov=64)
k.spawn("from_underpass", (-2.1, 0.05, 0.0), (1, 0))
# Pistas de Leo: adonde guía a Isabella cuando se queda quieta y qué le explica.
k.leo_hint('LeoDawn', (2.0, 0, 0.6), ['Leo: Ya casi amanece, Isabella.', 'Leo: Guarda en la máquina antes de salir. Lo que viene es largo, y quiero que llegues.'])
k.save(REPO + "/levels/tracks/switch_house.tscn")
print("switch house ok")
