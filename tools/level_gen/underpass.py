import sys, math, os; sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
from roomkit import *
T = "res://levels/tracks/%s.tscn"
# Paso bajo nivel en apagón: solo la linterna de Cony y una luz roja de
# emergencia al fondo. Infectados rápidos.
k = Kit("Underpass", "Paso bajo nivel", dark=True)
k.env((0.02, 0.02, 0.03), (0.3, 0.31, 0.38), 0.75, (0.05, 0.05, 0.065), 0.05)
X0, X1, Z0, Z1, H = -7.0, 7.0, -1.8, 1.8, 2.8
k.shell(X0, X1, Z0, Z1, H, floor="concrete_floor", wall="concrete_wall", ceiling="concrete_wall", wainscot="tiles_wall")
k.door_frame("ToConvoy", X0, 0.0, "z", width=1.2, wall_side=1, panel="metal")
k.door_frame("ToSwitch", X1, 0.0, "z", width=1.1, wall_side=-1, panel="planks")
for i in range(5):
    k.block("Step%d" % i, "Details", (-6.6 + i * 0.12, 0.05 + i * 0.0, 0.0), (0.12, 0.1, 1.4), "concrete_wall", solid=False)
k.block("Pipe", "Details", (0.0, 2.5, -1.6), (14.0, 0.1, 0.1), "rust", solid=False)
k.mesh("EmergencyLamp", "Lights", (0.25, 0.12, 0.08), k.emissive((1.0, 0.1, 0.05), 2.5), (6.2, 2.4, 1.7))
k.light("Stairs", "Lights", (-6.4, 2.3, 0.0), (0.5, 0.6, 0.85), 0.9, 5.0)
k.light("Emergency", "Lights", (6.0, 2.2, 1.2), (1.0, 0.12, 0.06), 1.4, 5.5, flicker=True)
k.decal("GraffitiNoche", "graffiti_noche", (-2.5, 1.8, -1.79), (2.6, 1.3), "+z", wear=0.3)
k.decal("GraffitiPaine", "graffiti_paine", (2.5, 1.8, 1.79), (2.6, 1.3), "-z", wear=0.4)
k.decal("HandNorth", "blood_handprint", (4.0, 1.2, -1.79), 0.4, "+z", rot=-0.3)
k.decal("BloodSouth", "blood_splatter_b", (-4.5, 1.0, 1.79), 1.2, "-z")
k.decal("HoleNorth", "wall_hole_a", (0.5, 0.9, -1.79), 0.9, "+z")
for i, (x, z, s) in enumerate([(-3.5, 0.4, 1.8), (1.0, -0.5, 2.2), (4.6, 0.6, 1.6)]):
    k.decal("Water%d" % i, "damp_stain", (x, 0.013, z), s, "up", rot=i * 1.3)
k.decal("Drag", "blood_drag", (2.0, 0.015, 0.2), (3.0, 1.0), "up", rot=3.1)
# Interactuables.
k.door("ToConvoy", (-6.6, 0, 0.0), T % "convoy_side", "from_underpass", prompt="SUBIR", reach=1.3)
k.door("ToSwitchHouse", (6.6, 0, 0.0), T % "switch_house", "from_underpass", reach=1.3)
k.pickup("Ammo", (-1.5, 0.0, -1.5), "ammo_9mm", 15, rot=(0, 0.6, 0))
k.pickup("Handroll", (3.6, 0.0, 1.5), "handroll", rot=(0, 1.0, 0))
k.examine("Pipe", (0.0, 0, -1.3), ["Se cortó la luz en todo el paso.", "Escucho algo correr al fondo."], reach=1.1)
# Infectados.
k.infected("RunnerA", (2.2, 0.05, 0.6), yaw=-math.pi / 2, kind="infected_fast")
k.infected("RunnerB", (5.2, 0.05, -0.8), yaw=-math.pi / 2, kind="infected_fast")
k.infected("Lying", (-2.6, 0.05, -0.6), yaw=0.2, state="lying", kind="infected_worker")
k.infected("Body", (4.3, 0.05, 1.2), yaw=2.6, state="corpse", kind="infected_burnt")
# Cámaras: tres tramos del túnel.
k.camera("West", (-4.7, 1.4, 0.0), (4.6, 2.8, 3.6), (-2.0, 2.5, 1.5), (-6.5, 0.4, -0.4), fov=64)
k.camera("Middle", (0.0, 1.4, 0.0), (4.8, 2.8, 3.6), (-2.6, 2.5, -1.5), (2.8, 0.4, 0.4), fov=64)
k.camera("East", (4.7, 1.4, 0.0), (4.6, 2.8, 3.6), (6.6, 2.5, 1.5), (1.8, 0.4, -0.4), fov=64)
k.spawn("from_convoy", (-6.1, 0.05, 0.0), (1, 0))
k.spawn("from_switch", (6.1, 0.05, 0.0), (-1, 0))
k.save(REPO + "/levels/tracks/underpass.tscn")
print("underpass ok")
