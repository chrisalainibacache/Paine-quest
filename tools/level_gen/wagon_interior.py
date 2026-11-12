import sys, math, os; sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
from roomkit import *
T = "res://levels/tracks/%s.tscn"
# Interior del vagón: pasillo angosto entre asientos, ventanas rotas, luces
# que parpadean. Aquí quedó la planilla del conductor y la llave del maquinista.
k = Kit("WagonInterior", "Interior del vagón")
k.env((0.02, 0.022, 0.03), (0.34, 0.36, 0.43), 0.75, (0.05, 0.05, 0.065), 0.045)
X0, X1, Z0, Z1, H = -7.0, 7.0, -1.35, 1.35, 2.5
k.shell(X0, X1, Z0, Z1, H, floor="planks", wall="train_cream", ceiling="train_cream", wainscot="train_blue")
glass = k.emissive((0.08, 0.1, 0.16), 0.5)
for side, z in (("N", Z0 + 0.01), ("S", Z1 - 0.01)):
    for i in range(6):
        x = -5.5 + i * 2.2
        k.mesh("Win%s%d" % (side, i), "Windows", (1.3, 0.75, 0.02), glass, (x, 1.55, z))
for i, x in enumerate((-5.5, -3.3, -1.1, 1.1, 3.3, 5.5)):
    for side, z in (("N", -0.85), ("S", 0.85)):
        if (x, side) in ((1.1, "S"), (-3.3, "N")):
            continue  # asientos arrancados: espacio para pelear
        k.prop("Seats%s%d" % (side, i), "Seats", "seat_pair", (x, 0, z))
for side, z in (("N", -1.15), ("S", 1.15)):
    k.block("Rack" + side, "Details", (0, 2.0, z), (13.6, 0.04, 0.35), "metal", solid=False)
k.door_frame("ToTrain", -7.0, 0.0, "z", width=0.9, wall_side=1, panel="rust")
k.door_frame("ToConvoy", 7.0, 0.0, "z", width=0.9, wall_side=-1, panel="rust")
lamp = k.emissive((1.0, 0.92, 0.75), 1.0)
for i, x in enumerate((-4.5, 0.0, 4.5)):
    k.mesh("Lamp%d" % i, "Lights", (1.2, 0.04, 0.12), lamp, (x, H - 0.03, 0.0))
k.light("LampWest", "Lights", (-4.5, H - 0.3, 0.0), (1.0, 0.9, 0.72), 0.8, 4.5)
k.light("LampMid", "Lights", (0.0, H - 0.3, 0.0), (1.0, 0.9, 0.72), 0.7, 4.5, flicker=True)
k.light("LampEast", "Lights", (4.5, H - 0.3, 0.0), (1.0, 0.9, 0.72), 0.6, 4.5, flicker=True)
k.decal("BloodWin", "blood_splatter_a", (-1.1, 1.4, -1.34), 1.0, "+z")
k.decal("HandWin", "blood_handprint", (3.3, 1.5, 1.34), 0.35, "-z", rot=0.4)
k.decal("CracksWin", "cracks", (5.5, 1.55, -1.34), 0.9, "+z")
k.decal("Smear", "blood_smear", (-5.0, 0.9, 1.34), (1.0, 0.5), "-z")
k.decal("Drag", "blood_drag", (0.5, 0.012, 0.0), (3.0, 0.7), "up", rot=3.1)
k.decal("Pool", "blood_pool", (1.2, 0.013, 0.55), 1.1, "up")
k.decal("Footprints", "blood_footprints", (-3.6, 0.014, 0.0), (1.6, 0.7), "up")
# Interactuables.
k.door("ToDerailed", (-6.6, 0, 0.0), T % "derailed_train", "from_wagon", prompt="SALIR", reach=1.2)
k.door("ToConvoy", (6.6, 0, 0.0), T % "convoy_side", "from_wagon", prompt="SALIR", reach=1.2)
k.pickup("EngineerKey", (-3.3, 0.5, -0.85), "engineer_key", rot=(0, 0.6, 0))
k.note("ConductorLog", (-2.9, 0.5, -0.55), "conductor_log", paper_rot=(0, 1.2, 0), paper_scale=0.6, reach=1.3)
k.pickup("Handroll", (3.3, 0.5, 0.85), "handroll", rot=(0, 0.3, 0))
k.examine("Window", (1.1, 0, 0.5), ["Por la ventana rota se ve la locomotora volcada.", "Afuera, algo se mueve entre los vagones."], reach=1.0)
# Infectados.
k.infected("Lying", (0.2, 0.05, 0.0), yaw=1.57, state="lying", kind="infected_burnt")
k.infected("Standing", (5.7, 0.05, 0.0), yaw=math.pi / 2, kind="infected_pale")
k.infected("Seated", (-5.5, 0.05, 0.9), yaw=0.3, state="corpse")
# Cámaras: tres tramos del pasillo.
k.camera("West", (-4.7, 1.25, 0.0), (4.6, 2.5, 2.7), (-2.0, 2.2, 1.05), (-6.5, 0.5, -0.3), fov=64)
k.camera("Middle", (0.0, 1.25, 0.0), (4.8, 2.5, 2.7), (-2.6, 2.2, -1.05), (2.6, 0.5, 0.3), fov=64)
k.camera("East", (4.7, 1.25, 0.0), (4.6, 2.5, 2.7), (6.6, 2.2, 1.05), (1.8, 0.5, -0.3), fov=64)
k.spawn("from_derailed", (-6.2, 0.05, 0.0), (1, 0))
k.spawn("from_convoy", (6.2, 0.05, 0.0), (-1, 0))
# Pistas de Leo: adonde guía a Cony cuando se queda quieta y qué le explica.
k.leo_hint('LeoKey', (-3.3, 0, -0.3), ['Leo: En ese asiento. El conductor dejó una llave: tiene el sello de EFE.', 'Leo: Él quería que alguien siguiera. Seamos nosotras.'], hide_item='engineer_key')
k.leo_hint('LeoExit', (6.0, 0, 0.0), ['Leo: Ya la tienes. Salgamos por el otro lado.'], show_item='engineer_key', hide_if='unlocked:underpass_gate')
k.save(REPO + "/levels/tracks/wagon_interior.tscn")
print("wagon interior ok")
