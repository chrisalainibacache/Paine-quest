import sys, math, os; sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
from tracks_common import *
T = "res://levels/tracks/%s.tscn"
# Costado del convoy: Cony sale del vagón al otro lado del tren. Entre los
# vagones y el terraplén hay infectados; al fondo, la reja del paso bajo nivel.
k = Kit("ConvoySide", "Costado del convoy")
night(k)
X0, X1, Z0, Z1 = -9.0, 9.0, -4.2, 3.5
track_bed(k, X0, X1, Z0, Z1)
walls(k, X0, X1, Z0, Z1, north="old_bricks_wall", south="concrete_wall", east="concrete_wall")
fence_top(k, X0, X1, 3.42, 0.0)
k.prop("WagonA", "Props", "train_wagon", (-2.0, 0, -2.0))
k.prop("WagonB", "Props", "train_wagon", (11.0, 0, -2.4), rot=(0, 0.12, 0.08))
k.block("Coupler", "Props", (5.2, 0.8, -2.0), (0.6, 0.35, 0.4), "rust")
k.prop("Fire", "Props", "fire", (1.6, 0, -0.2))
# Reja del paso bajo nivel (este) con letrero.
k.block("GateFrame", "Walls", (8.98, 1.3, 1.2), (0.1, 2.6, 2.2), "rust", solid=False)
for j in range(6):
    k.block("GateBar%d" % j, "Walls", (8.93, 1.3, 0.25 + j * 0.38), (0.04, 2.5, 0.04), "metal", solid=False)
k.label("UnderpassSign", "Walls", (8.95, 2.85, 1.2), "PASO BAJO NIVEL", 40, (0.85, 0.82, 0.7), rot=(0, -math.pi / 2, 0))
for i, (x, z, r) in enumerate([(-6.0, 2.6, 0.3), (3.6, 2.9, 1.1)]):
    luggage(k, "Luggage%d" % i, (x, 0, z), r)
k.decal("GraffitiRuta", "graffiti_ruta5", (-3.5, 2.0, 3.49), (3.0, 1.5), "-z", wear=0.35)
k.decal("GraffitiKm", "graffiti_km42", (4.5, 1.9, 3.49), (2.6, 1.3), "-z", wear=0.45)
k.decal("BloodWall", "blood_splatter_c", (0.5, 1.2, 3.49), 1.2, "-z")
k.decal("Pool", "blood_pool", (6.4, 0.03, 0.4), 1.5, "up")
k.decal("Drag", "blood_drag", (-1.0, 0.03, 1.7), (3.0, 1.0), "up", rot=0.2)
k.decal("Footprints", "blood_footprints", (2.8, 0.03, 1.2), (2.0, 1.0), "up", rot=3.0)
# Interactuables.
k.door("ToWagon", (-8.25, 0, -0.25), T % "wagon_interior", "from_convoy", prompt="ENTRAR", reach=1.3)
k.door("ToUnderpass", (8.4, 0, 1.2), T % "underpass", "from_convoy", key="engineer_key", lock_id="underpass_gate",
       locked_text="La reja del paso bajo nivel. Tiene un candado de EFE.", reach=1.4)
k.pickup("Grenades", (0.5, 0.0, 3.0), "ammo_grenades", 2, rot=(0, 0.3, 0))
k.pickup("Sushi", (7.6, 0.0, 2.9), "sushi", rot=(0, 2.0, 0))
# Infectados.
k.infected("Runner", (3.2, 0.05, 1.6), yaw=-math.pi / 2, kind="infected_fast")
k.infected("Feeding", (6.6, 0.05, 0.6), yaw=-2.0, state="feeding", kind="infected_worker")
k.infected("Lying", (-2.6, 0.05, 1.9), yaw=0.4, state="lying")
# Cámaras.
k.camera("West", (-4.5, 1.5, 0.3), (9.0, 3.0, 6.4), (1.2, 3.2, 3.0), (-7.0, 0.4, -0.6), fov=58)
k.camera("East", (4.5, 1.5, 0.3), (9.0, 3.0, 6.4), (-1.2, 3.2, 3.0), (7.6, 0.4, 0.0), fov=58)
k.spawn("from_wagon", (-7.8, 0.05, 0.5), (1, 0))
k.spawn("from_underpass", (7.6, 0.05, 1.2), (-1, 0))
k.save(REPO + "/levels/tracks/convoy_side.tscn")
print("convoy ok")
