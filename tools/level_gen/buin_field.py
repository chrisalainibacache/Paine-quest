import sys, math, os; sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
from buin_common import *
# Potrero junto a la vía, entre la estación de Buin y la viña: un lugar
# despejado... demasiado. Sin escena guionada: la sala la rehace P17.
k = Kit("Field", "Potrero", ambience="day_fields")
dawn(k, 0.014)
X0, X1, Z0, Z1 = -10.0, 10.0, -6.0, 6.0
k.block("Ground", "Ground", (0, -0.5, 0), (X1 - X0 + 0.6, 1, Z1 - Z0 + 0.6), "dirt")
open_field(k, X0, X1, Z0, Z1, gates=(("W", 0.0), ("E", 0.0)))
# Pasto seco en manchones y algunos fardos de paja: el resto, despejado.
for i, (x, z, r) in enumerate([(-7.5, -4.2, 0.2), (6.8, 4.4, 1.1), (-6.4, 4.6, 0.6), (7.6, -4.6, 2.0)]):
    k.block("Bale%d" % i, "Props", (x, 0.4, z), (1.2, 0.8, 0.8), "sandbag", rot=(0, r, 0))
k.prop("PlantA", "Props", "plant_pot", (-8.8, 0, -2.6))
k.prop("PlantB", "Props", "plant_pot", (9.0, 0, 2.6))
k.block("Trough", "Props", (0.0, 0.3, -5.2), (2.4, 0.6, 0.7), "metal")
k.decal("Drag", "blood_drag", (3.0, 0.02, -2.0), (3.0, 1.0), "up", rot=0.4)
k.decal("Pool", "blood_pool", (-3.5, 0.02, 2.5), 1.6, "up")
# Interactuables.
# Portones de campo en los dos extremos del potrero (se llega y se sale por un portón, no por un muro liso).
k.door("ToStation", (-9.4, 0, 0.0), B % "station", "from_field", prompt="VOLVER", reach=1.4)
k.door("ToVineyard", (9.4, 0, 0.0), B % "vineyard", "from_field", prompt="SEGUIR", reach=1.4)
k.label("VineyardSign", "Details", (9.7, 2.3, -1.6), "VIÑA SANTA ROSA →", 32, (0.9, 0.86, 0.75), rot=(0, -math.pi / 2, 0))
# Tres salidas nuevas: bodega (suroeste), canal de riego (noreste) y la ruta rural al control (noroeste).
k.door("door_field_warehouse", (-4.6, 0, 5.2), B % "warehouse", "from_field", prompt="ENTRAR", reach=1.4, marker="BODEGA AGRÍCOLA")
k.door("door_field_canal", (5.0, 0, -5.2), B % "canal_riego", "from_field", prompt="SEGUIR", reach=1.4, marker="CANAL DE RIEGO")
k.door("door_field_checkpoint", (-4.5, 0, -5.2), B % "checkpoint", "from_field", prompt="SEGUIR", reach=1.4, marker="CONTROL MILITAR")
k.spawn("from_warehouse", (-4.6, 0.05, 4.3), (0, -1))
k.spawn("from_canal", (5.0, 0.05, -4.3), (0, 1))
k.spawn("from_checkpoint", (-4.5, 0.05, -4.3), (0, 1))
# La huella: lo único que se ve de lo que pasó por aquí (nunca el cuerpo).
k.examine("GiantPrint", (3.6, 0, -1.2), ["Una huella en el barro, más ancha que un camión. El borde está húmedo.",
    "Más allá, entre los árboles, hay ramas quebradas a seis metros de altura.", "Leo bufa con el pelo erizado. Lo que sea que pasó por aquí ya no está."], reach=1.6)
k.pickup("Ammo", (2.0, 0.0, 4.8), "ammo_9mm", 20, rot=(0, 0.6, 0))
k.pickup("Handroll", (-2.4, 0.0, -4.8), "handroll", rot=(0, 1.0, 0))
k.camera("West", (-5.0, 1.5, 0.0), (10.0, 3.0, 12.0), (0.5, 4.4, 5.6), (-5.5, 0.3, -0.8), fov=60)
k.camera("East", (5.0, 1.5, 0.0), (10.0, 3.0, 12.0), (-0.5, 4.4, 5.6), (5.5, 0.3, -0.8), fov=60)
k.spawn("from_station", (-8.6, 0.05, 0.0), (1, 0))
k.spawn("from_vineyard", (8.6, 0.05, 0.0), (-1, 0))
k.leo_hint("LeoQuiet", (2.5, 0, 0.0), ["Leo: Todo despejado... demasiado despejado. Mira las ramas rotas.", "Leo: No sigas la huella: mira lo que dejó. Hay tres salidas.", "Leo: Hacia la viña por SEGUIR, la bodega al suroeste, el canal de riego al noreste."])
k.save(REPO + "/levels/buin/field.tscn")
print("field ok")
