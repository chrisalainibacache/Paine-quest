import sys, math, os; sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
from buin_common import *
# Control militar de Buin: carpas, sacos de arena, un camión y la barrera. Los
# soldados se convirtieron aquí mismo. En la carpa, la orden del día.
k = Kit("Checkpoint", "Control militar")
dawn(k, 0.014)
X0, X1, Z0, Z1 = -9.0, 9.0, -5.0, 5.0
k.block("Ground", "Ground", (0, -0.5, 0), (X1 - X0 + 0.6, 1, Z1 - Z0 + 0.6), "dirt")
k.block("Road", "Ground", (1.0, 0.005, 0), (16.0, 0.01, 3.6), "asphalt", solid=False)
walls(k, X0, X1, Z0, Z1, north="bricks_wall", south="plaster_wall", west="sky_dawn", east="plaster_wall")
fence_top(k, X0, X1, Z1 - 0.1, 0.0)
# Carpa (noroeste) con la mesa del capitán.
k.prop("Tent", "Props", "army_tent", (-5.5, 0, -2.9))
k.prop("Radio", "Props", "field_radio", (-4.9, 0.75, -3.9))
# Camión (sureste) y sacos de arena alrededor de la barrera.
k.prop("Truck", "Props", "army_truck", (4.6, 0, 3.3), rot=(0, 0.08, 0))
k.prop("Barrier", "Props", "barrier", (0.5, 0, -1.9), rot=(0, 0, 0))
for i, (x, z, r) in enumerate([(-1.2, -2.6, 0.0), (-1.2, 2.6, 0.0), (6.0, -3.6, 0.3), (-6.8, 3.6, 0.3)]):
    k.prop("Sandbags%d" % i, "Props", "sandbags", (x, 0, z), rot=(0, r, 0))
# Foco apagado y bidones.
k.block("FloodPole", "Props", (2.2, 2.0, -4.4), (0.14, 4.0, 0.14), "olive")
k.block("FloodHead", "Props", (2.2, 3.9, -4.2), (0.6, 0.4, 0.3), "olive", solid=False)
for i, (x, z) in enumerate([(7.6, -0.4), (8.0, 0.4), (7.7, 1.2)]):
    k.block("Drum%d" % i, "Props", (x, 0.45, z), (0.55, 0.9, 0.55), "olive")
k.decal("Pool", "blood_pool", (-2.6, 0.02, 0.6), 1.6, "up")
k.decal("Drag", "blood_drag", (2.6, 0.02, -0.6), (3.0, 1.0), "up", rot=-0.3)
k.decal("Footprints", "blood_footprints", (-4.0, 0.02, 1.8), (2.0, 1.0), "up", rot=0.6)
k.decal("HandTruck", "blood_handprint", (3.2, 1.5, 2.2), 0.4, "-z")
# Interactuables.
k.door("ToBridge", (-8.4, 0, 0.0), B % "bridge", "from_checkpoint", prompt="VOLVER", reach=1.4)
k.door("ToStation", (8.4, 0, -2.6), B % "station", "from_checkpoint", prompt="SEGUIR", reach=1.4)
k.label("StationSign", "Details", (8.97, 2.6, -2.6), "ESTACIÓN BUIN →", 34, (0.9, 0.88, 0.8), rot=(0, -math.pi / 2, 0))
k.note("Order", (-4.7, 0.78, -3.6), "military_order", paper_rot=(0, 0.3, 0), paper_scale=0.7, reach=1.4)
k.interact("Typewriter", "typewriter", (-6.2, 0.78, -3.6), reach="1.3")
k.examine("TruckBed", (4.6, 0, 1.8), ["La caja del camión está llena de camillas.", "Todas tienen correas. Para los brazos y para las piernas."], reach=1.3)
k.pickup("RifleAmmo", (6.5, 0.0, -2.8), "ammo_rifle", 20, rot=(0, 0.3, 0))
k.pickup("Grenades", (-6.8, 0.0, 0.9), "ammo_grenades", 2, rot=(0, 1.2, 0))
k.pickup("Handroll", (-3.6, 0.32, -3.1), "handroll", rot=(0, 0.5, 0))
# Infectados: soldados con casco (aguantan más).
k.infected("Soldier1", (1.8, 0.05, 0.8), yaw=-math.pi / 2, kind="infected_soldier")
k.infected("Soldier2", (-2.6, 0.05, 0.6), yaw=1.2, state="feeding", kind="infected_soldier")
k.infected("Civilian", (6.2, 0.05, 0.2), yaw=-math.pi / 2, state="lying")
k.infected("Body", (-3.0, 0.05, 1.6), yaw=0.3, state="corpse", kind="infected_worker")
# Cámaras.
k.camera("West", (-4.5, 1.5, 0.0), (9.0, 3.0, 10.0), (0.6, 4.2, 4.4), (-5.0, 0.4, -1.4), fov=60)
k.camera("East", (4.5, 1.5, 0.0), (9.0, 3.0, 10.0), (-0.8, 4.2, -4.4), (5.0, 0.4, 0.6), fov=60)
k.spawn("from_bridge", (-7.6, 0.05, 0.0), (1, 0))
k.spawn("from_station", (7.6, 0.05, -2.6), (-1, 0))
k.leo_hint("LeoTent", (-4.6, 0, -2.2), ["Leo: En la carpa hay papeles con sellos. Léelos, Cony.", "Leo: Y esa máquina de escribir sirve igual que las otras."], hide_if="read:military_order")
k.leo_hint("LeoStation", (7.5, 0, -2.6), ["Leo: La estación de Buin está por ahí.", "Leo: Los soldados tienen casco. Apúntales al cuerpo y no te quedes cerca."])
k.save(REPO + "/levels/buin/checkpoint.tscn")
print("checkpoint ok")
