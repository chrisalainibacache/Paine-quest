import sys, math, os; sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
from buin_common import *
# Viña Santa Rosa: hileras de parras en la neblina de la mañana y, al fondo,
# el galpón cerrado con llave. Entre las parras hay infectados (y un soldado).
k = Kit("Vineyard", "Viña Santa Rosa")
dawn(k, 0.02)
X0, X1, Z0, Z1 = -10.0, 10.0, -5.0, 5.0
k.block("Ground", "Ground", (0, -0.5, 0), (X1 - X0 + 0.6, 1, Z1 - Z0 + 0.6), "dirt")
walls(k, X0, X1, Z0, Z1, north="old_bricks_wall", south="old_bricks_wall", west="plaster_wall", east="old_bricks_wall")
# Hileras de parras (dejando un camino al medio, z = 0).
rows = [(-6.0, -3.6), (2.0, -3.6), (-6.0, -1.8), (2.0, -1.8), (-6.0, 1.8), (2.0, 1.8), (-6.0, 3.6), (2.0, 3.6)]
for i, (x, z) in enumerate(rows):
    k.prop("Vines%d" % i, "Props", "vine_row", (x, 0, z))
# El galpón al fondo (este): su fachada y el portón.
k.block("ShedFront", "Shed", (9.85, 2.6, 0), (0.3, 5.2, 9.8), "barrel_wood")
k.block("ShedDoor", "Shed", (9.68, 1.3, 0.0), (0.06, 2.6, 1.8), "planks", solid=False)
k.label("ShedSign", "Shed", (9.64, 3.4, 0.0), "GALPÓN · VIÑA SANTA ROSA", 30, (0.92, 0.88, 0.75), rot=(0, -math.pi / 2, 0))
k.block("Cart", "Props", (-2.6, 0.45, 0.9), (1.4, 0.5, 0.8), "barrel_wood")
for i, (x, z) in enumerate([(-8.4, -0.8), (5.6, 0.7)]):
    k.block("Basket%d" % i, "Props", (x, 0.2, z), (0.5, 0.4, 0.4), "planks", solid=False)
k.decal("Pool", "blood_pool", (0.4, 0.02, -0.4), 1.5, "up")
k.decal("Drag", "blood_drag", (4.0, 0.02, 0.3), (2.8, 0.9), "up", rot=0.1)
# Interactuables.
k.door("ToStation", (-9.4, 0, 0.0), B % "station", "from_vineyard", prompt="VOLVER", reach=1.4)
k.door("ToShed", (9.2, 0, 0.0), B % "shed", "from_vineyard", key="shed_key", lock_id="shed_door", prompt="ABRIR", reach=1.4,
       locked_text="El portón del galpón. Tiene un candado grande y alguien lo trancó por dentro también.")
k.examine("Grapes", (-3.0, 0, -1.2), ["Racimos maduros que nadie cosechó.", "Ayer era la vendimia."], reach=1.0)
k.pickup("Handroll", (-2.5, 0.72, 0.9), "handroll", rot=(0, 0.4, 0))
k.pickup("RifleAmmo", (6.4, 0.0, -0.6), "ammo_rifle", 15, rot=(0, 1.1, 0))
k.infected("Picker1", (-1.0, 0.05, -0.4), yaw=-math.pi / 2, kind="infected_worker")
k.infected("Soldier", (5.0, 0.05, 0.3), yaw=-math.pi / 2, kind="infected_soldier")
k.infected("Picker2", (1.8, 0.05, 0.5), yaw=1.8, state="lying")
k.infected("Runner", (7.6, 0.05, -0.5), yaw=-math.pi / 2, kind="infected_fast", state="feeding")
k.camera("West", (-5.0, 1.5, 0.0), (10.0, 3.0, 10.0), (-0.5, 4.0, 4.6), (-6.4, 0.4, -0.4), fov=60)
k.camera("East", (5.0, 1.5, 0.0), (10.0, 3.0, 10.0), (0.5, 4.0, -4.6), (6.8, 0.6, 0.4), fov=60)
k.spawn("from_station", (-8.6, 0.05, 0.0), (1, 0))
k.spawn("from_shed", (8.4, 0.05, 0.0), (-1, 0))
k.leo_hint("LeoShed", (8.4, 0, 0.0), ["Leo: El galpón. Rosa está ahí adentro, Cony. Respira despacio.", "Leo: Usa la llave del tractor."], hide_if="unlocked:shed_door")
k.save(REPO + "/levels/buin/vineyard.tscn")
print("vineyard ok")
