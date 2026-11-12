import sys, math, os; sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
from buin_common import *
# Potrero junto a la vía, entre la estación de Buin y la viña: un lugar
# despejado... demasiado. Aquí aparecen Kiara y Nala (levels/kit/rescue_scene.gd).
k = Kit("Field", "Potrero")
dawn(k, 0.014)
X0, X1, Z0, Z1 = -10.0, 10.0, -6.0, 6.0
k.block("Ground", "Ground", (0, -0.5, 0), (X1 - X0 + 0.6, 1, Z1 - Z0 + 0.6), "dirt")
walls(k, X0, X1, Z0, Z1, north="old_bricks_wall", south="old_bricks_wall", west="plaster_wall", east="old_bricks_wall")
fence_top(k, X0, X1, Z0 + 0.1, 0.0)
# Pasto seco en manchones y algunos fardos de paja: el resto, despejado.
for i, (x, z, r) in enumerate([(-7.5, -4.2, 0.2), (6.8, 4.4, 1.1), (-6.4, 4.6, 0.6), (7.6, -4.6, 2.0)]):
    k.block("Bale%d" % i, "Props", (x, 0.4, z), (1.2, 0.8, 0.8), "sandbag", rot=(0, r, 0))
k.prop("PlantA", "Props", "plant_pot", (-8.8, 0, -2.6))
k.prop("PlantB", "Props", "plant_pot", (9.0, 0, 2.6))
k.block("Trough", "Props", (0.0, 0.3, -5.2), (2.4, 0.6, 0.7), "metal")
k.decal("Drag", "blood_drag", (3.0, 0.02, -2.0), (3.0, 1.0), "up", rot=0.4)
k.decal("Pool", "blood_pool", (-3.5, 0.02, 2.5), 1.6, "up")
# Interactuables.
k.door("ToStation", (-9.4, 0, 0.0), B % "station", "from_field", prompt="VOLVER", reach=1.4)
k.door("ToVineyard", (9.4, 0, 0.0), B % "vineyard", "from_field", prompt="SEGUIR", reach=1.4)
k.label("VineyardSign", "Details", (9.96, 2.6, 0.0), "VIÑA SANTA ROSA →", 32, (0.9, 0.86, 0.75), rot=(0, -math.pi / 2, 0))
k.pickup("Ammo", (2.0, 0.0, 4.8), "ammo_9mm", 20, rot=(0, 0.6, 0))
k.pickup("Handroll", (-2.4, 0.0, -4.8), "handroll", rot=(0, 1.0, 0))
# La escena: el disparador en el centro y su cámara (plano abierto, en alto).
k.s.node("Rescue", "Node3D", ".", position=v3((0.0, 0.0, 0.0)), script=k.s.res("res://levels/kit/rescue_scene.gd", "Script"))
k.s.node("Camera", "Camera3D", "Rescue", position=v3((-0.6, 3.4, 4.6)), rotation=v3(look_rotation((-0.6, 3.4, 4.6), (-1.0, 0.5, -1.0))),
         fov="62.0", near="0.1", far="40.0")
k.camera("West", (-5.0, 1.5, 0.0), (10.0, 3.0, 12.0), (0.5, 4.4, 5.6), (-5.5, 0.3, -0.8), fov=60)
k.camera("East", (5.0, 1.5, 0.0), (10.0, 3.0, 12.0), (-0.5, 4.4, 5.6), (5.5, 0.3, -0.8), fov=60)
k.spawn("from_station", (-8.6, 0.05, 0.0), (1, 0))
k.spawn("from_vineyard", (8.6, 0.05, 0.0), (-1, 0))
k.leo_hint("LeoQuiet", (2.5, 0, 0.0), ["Leo: Todo despejado... demasiado despejado, Cony.", "Leo: No me gusta. Camina conmigo."], hide_if="rescue:kiara_nala")
k.leo_hint("LeoAfter", (8.6, 0, 0.0), ["Leo: Kiara y Nala van a estar bien. Ahora nos toca a nosotras.", "Leo: La viña está por aquí."], show_if="rescue:kiara_nala")
k.save(REPO + "/levels/buin/field.tscn")
print("field ok")
