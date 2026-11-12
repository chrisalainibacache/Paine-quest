import sys, math, os; sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
from buin_common import *
# Bodega agrícola (sin luz: Cony usa la linterna). Sacos, cajones y un tractor
# viejo; la llave del galpón cuelga del tractor, con la carta de Ana.
k = Kit("Warehouse", "Bodega agrícola", dark=True)
k.env((0.0, 0.0, 0.0), (0.3, 0.29, 0.27), 0.7, (0.04, 0.04, 0.04), 0.05)
X0, X1, Z0, Z1, H = -6.0, 6.0, -4.0, 4.0, 4.4
k.shell(X0, X1, Z0, Z1, H, floor="concrete_floor", wall="bricks_wall", ceiling="planks")
k.door_frame("ToStation", -1.5, Z1, "x", width=1.4, wall_side=-1, panel="metal")
for i in range(4):
    k.block("Rafter%d" % i, "Shell", (X0 + 2.4 + i * 2.4, H - 0.3, 0), (0.2, 0.3, Z1 - Z0), "wood", solid=False)
# Rayos de luz por las rendijas del techo.
for i, (x, z) in enumerate([(-3.5, -1.0), (2.0, 1.5), (4.5, -2.0)]):
    k.mesh("Crack%d" % i, "Details", (0.08, 0.02, 1.4), k.emissive((0.9, 0.88, 0.8), 1.6), (x, H - 0.02, z))
k.light("CrackLight", "Lights", (2.0, H - 0.6, 1.5), (0.9, 0.88, 0.8), 0.6, 4.5)
k.prop("Tractor", "Props", "tractor", (3.2, 0, -1.6), rot=(0, math.pi, 0))
for i, (x, z, r) in enumerate([(-4.8, -3.0, 0.0), (-3.4, -3.1, 0.2), (-4.9, -1.5, 1.57), (-4.2, 2.8, 0.1)]):
    k.prop("Crate%d" % i, "Props", "crate", (x, 0, z), rot=(0, r, 0))
for i in range(6):
    k.block("Sack%d" % i, "Props", (0.4 + (i % 3) * 0.75, 0.2 + (i // 3) * 0.35, 3.2), (0.7, 0.35, 0.55), "sandbag", rot=(0, 0.1 * (i % 2), 0))
for i, x in enumerate((-5.5, -4.9)):
    k.prop("Barrel%d" % i, "Props", "wine_barrel", (x, 0, 0.8 + i * 1.0), rot=(0, math.pi / 2, 0))
k.decal("Oil", "oil_stain", (3.0, 0.012, -0.4), 2.0, "up")
k.decal("Pool", "blood_pool", (-1.0, 0.012, -0.5), 1.4, "up")
k.decal("Drag", "blood_drag", (0.5, 0.012, 1.2), (2.4, 0.8), "up", rot=0.9)
# Interactuables.
k.door("ToStation", (-1.5, 0, 3.6), B % "station", "from_warehouse", prompt="SALIR", reach=1.3)
k.pickup("ShedKey", (1.9, 1.3, -1.6), "shed_key", rot=(0, 0.5, 0))
k.note("Letter", (3.0, 1.5, -1.3), "worker_letter", paper_rot=(0, 0.6, 0), paper_scale=0.6, reach=1.5)
k.pickup("Shells", (-4.3, 0.85, -3.0), "ammo_shells", 6, rot=(0, 0.2, 0))
k.pickup("Sushi", (-4.2, 0.85, 2.8), "sushi", rot=(0, 1.0, 0))
k.examine("Calendar", (5.5, 0, 2.5), ["Un calendario de la viña. Viernes marcado con lápiz rojo:", "«Vendimia. Llegan los temporeros de Paine.»"], reach=1.2)
k.infected("Runner1", (4.0, 0.05, 2.4), yaw=-2.2, kind="infected_fast")
k.infected("Runner2", (-3.0, 0.05, 0.6), yaw=1.2, kind="infected_fast", state="lying")
k.infected("Body", (0.6, 0.05, -2.8), yaw=0.4, state="corpse", kind="infected_worker")
k.camera("West", (-3.0, 1.5, 0.0), (6.0, 3.0, 8.0), (1.6, 3.8, 3.4), (-3.4, 0.3, -1.0), fov=62)
k.camera("East", (3.0, 1.5, 0.0), (6.0, 3.0, 8.0), (-1.4, 3.8, 3.4), (3.6, 0.3, -1.2), fov=62)
k.spawn("from_station", (-1.5, 0.05, 3.1), (0, -1))
k.leo_hint("LeoTractor", (2.2, 0, -0.4), ["Leo: Aquí adentro no ves nada. Yo sí: sígueme.", "Leo: En el tractor cuelga una llave grande... y hay una carta. Alguien la dejó para nosotras."], hide_item="shed_key")
k.leo_hint("LeoOut", (-1.5, 0, 2.9), ["Leo: Ya la tienes. Salgamos de aquí, que esos corren."], show_item="shed_key")
k.save(REPO + "/levels/buin/warehouse.tscn")
print("warehouse ok")
