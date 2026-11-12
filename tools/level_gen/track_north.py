import sys, math, os; sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
from tracks_common import *
T = "res://levels/tracks/%s.tscn"
# Vía norte: Cony y Leo bajaron del andén sur y siguen por la vía. Al fondo,
# un vagón volcado cruza la vía y hay fuego: el tren de las 6:30.
# Lo que piensa Cony al empezar el capítulo 2.
INTRO = ['Pasada la medianoche. La vía hacia el norte.', 'Allá adelante hay fuego. Tiene que ser el tren de las 6:30, el que nunca llegó a Santiago.', 'Javi, aguanta. Vamos caminando.']
k = Kit("TrackNorth", "Vía norte", intro=INTRO)
night(k)
X0, X1, Z0, Z1 = -9.0, 9.0, -3.5, 3.5
track_bed(k, X0, X1, Z0, Z1, track_z=0.0)
walls(k, X0, X1, Z0, Z1, north="old_bricks_wall", south="concrete_wall")
fence_top(k, X0, X1, 3.42, 0.0)
# Túnel de vuelta a la estación (oeste), tapado con reja.
k.mesh("TunnelMouth", "Walls", (0.05, 3.2, 3.6), k.emissive((0.02, 0.02, 0.025), 0.1), (-8.97, 1.3, 0.0))
for j in range(8):
    k.block("TunnelBar%d" % j, "Walls", (-8.92, 1.3, -1.6 + j * 0.46), (0.05, 3.0, 0.05), "rust", solid=False)
# Vagón volcado de través al fondo (este).
k.prop("CrossWagon", "Props", "train_wagon", (8.3, 1.45, 0.4), rot=(1.35, math.pi / 2, 0))
k.prop("FireEast", "Props", "fire", (6.4, 0, -1.6))
k.prop("FireEast2", "Props", "fire", (7.2, 0, 2.2))
# Poste de señales con la luz roja.
k.block("SignalPole", "Props", (-3.5, 2.0, -2.9), (0.15, 4.0, 0.15), "metal")
k.block("SignalHead", "Props", (-3.5, 3.6, -2.75), (0.4, 0.7, 0.25), "metal", solid=False)
k.mesh("SignalRed", "Props", (0.16, 0.16, 0.04), k.emissive((1.0, 0.1, 0.05), 2.0), (-3.5, 3.75, -2.62))
k.light("SignalLight", "Lights", (-3.5, 3.6, -2.4), (1.0, 0.15, 0.08), 0.8, 4.0)
for i, (x, z, r) in enumerate([(-1.5, 1.6, 0.4), (2.2, -2.1, 1.2), (4.6, 2.8, -0.5), (-5.6, -2.6, 0.9)]):
    luggage(k, "Luggage%d" % i, (x, 0, z), r)
# Calcomanías.
k.decal("GraffitiSur", "graffiti_sur", (-2.0, 2.0, 3.49), (2.6, 1.3), "-z", wear=0.4)
k.decal("GraffitiNoSignal", "graffiti_no_signal", (3.5, 2.2, -3.49), (2.8, 1.4), "+z", wear=0.45)
k.decal("BloodWall", "blood_splatter_b", (0.8, 1.2, 3.49), 1.2, "-z")
k.decal("HandWall", "blood_handprint", (-6.5, 1.3, -3.49), 0.4, "+z")
k.decal("Drag", "blood_drag", (1.0, 0.03, -1.0), (3.0, 1.0), "up", rot=0.3)
k.decal("Pool", "blood_pool", (4.0, 0.03, 1.2), 1.6, "up")
k.decal("Footprints", "blood_footprints", (-3.0, 0.03, 1.4), (2.0, 1.0), "up", rot=0.1)
# Interactuables.
k.door("ToDerailedTrain", (7.0, 0, 2.7), T % "derailed_train", "from_track_north", prompt="SEGUIR", reach=1.5)
k.examine("Tunnel", (-8.3, 0, 0.0), ["El túnel de vuelta a la estación.", "Detrás quedó Paine. No hay vuelta atrás."], reach=1.4)
k.examine("Signal", (-3.5, 0, -2.3), ["Una señal en rojo. Nadie la cambió desde la mañana."], reach=1.2)
k.note("Ticket", (-1.2, 0.03, 2.5), "passenger_ticket", paper_rot=(0, 0.7, 0), paper_scale=0.6)
k.pickup("Shells", (-4.2, 0.0, 3.0), "ammo_shells", 6, rot=(0, 0.4, 0))
k.pickup("Sushi", (-6.3, 0.0, -3.0), "sushi", rot=(0, 1.2, 0))
# Infectados: uno caminando y el primer rápido.
k.infected("Walker", (2.6, 0.05, -1.4), yaw=-math.pi / 2, kind="infected_worker")
k.infected("Runner", (5.4, 0.05, 1.3), yaw=-math.pi / 2, kind="infected_fast")
k.infected("Body1", (0.4, 0.05, 1.9), yaw=0.8, state="corpse", kind="infected_burnt")
k.infected("Body2", (3.6, 0.05, -2.6), yaw=2.4, state="corpse")
# Cámaras.
k.camera("West", (-4.5, 1.5, 0.0), (9.0, 3.0, 7.0), (1.6, 3.2, 3.1), (-6.5, 0.3, -1.0), fov=58)
k.camera("East", (4.5, 1.5, 0.0), (9.0, 3.0, 7.0), (-1.6, 3.2, 3.1), (6.5, 0.5, -0.4), fov=58)
k.spawn("start", (-7.4, 0.05, 0.8), (1, 0))
k.spawn("from_derailed", (6.2, 0.05, 2.1), (-1, 0))
k.save(REPO + "/levels/tracks/track_north.tscn")
print("track north ok")
