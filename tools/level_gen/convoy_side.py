import sys, math, os; sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
from tracks_common import *
T = "res://levels/tracks/%s.tscn"
# Costado del convoy, a ESCALA REAL: un coche de pasajeros (24 m) entra por el túnel oeste y un vagón de carga
# (16,5 m) sale por el túnel este, enganchados en la vía del norte. Isabella camina por el costado sur y sube al
# coche por un estribo. Las cajas son solo choque/oclusión; el aspecto real se pone al renderizar el fondo
# (tools/prerender/convoy_side_scene.py). Al este, la reja del paso bajo nivel.
k = Kit("ConvoySide", "Costado del convoy", ambience="tracks_night")
night(k)
X0, X1, Z0, Z1 = -13.0, 13.0, -4.0, 3.5
TZ = -2.0                                          # eje de la vía del convoy
track_bed(k, X0, X1, Z0, Z1, track_z=TZ, track_len=26.0)
walls(k, X0, X1, Z0, Z1, north="old_bricks_wall", south="concrete_wall", skip=("W", "E"))
from tunnels import carve
carve(k.block, k.prop, -1, X0, TZ, 0.0, -0.3, 5.5, Z0, Z1, "concrete_wall", prefix="WestTunnel")   # el coche entra por aquí
carve(k.block, k.prop, +1, X1, TZ, 0.0, -0.3, 5.5, Z0, Z1, "concrete_wall", prefix="EastTunnel")   # y el vagón de carga sale por aquí
fence_top(k, X0, X1, 3.42, 0.0)
# Coche de pasajeros (24 x 4,2 x 3,0) y vagón de carga (16,5 x 4,2 x 3,3): solo choque y oclusión.
k.block("Coach", "Props", (-4.0, 2.2, TZ), (24.0, 4.2, 3.2), "train_blue")
k.block("Freight", "Props", (16.7, 2.2, TZ), (16.5, 4.2, 3.2), "rust")
k.block("Coupler", "Props", (8.2, 0.8, TZ), (0.6, 0.35, 0.4), "rust")
k.block("BoardingStep", "Props", (-6.0, 0.2, -0.15), (1.0, 0.4, 0.6), "metal")
k.prop("Fire", "Props", "fire", (3.8, 0, 1.0))
# Reja del paso bajo nivel (este, al sur de la vía) con letrero.
GX = X1 - 0.02
k.block("GateFrame", "Walls", (GX, 1.3, 1.6), (0.1, 2.6, 2.2), "rust", solid=False)
for j in range(6):
    k.block("GateBar%d" % j, "Walls", (GX - 0.05, 1.3, 0.65 + j * 0.38), (0.04, 2.5, 0.04), "metal", solid=False)
k.label("UnderpassSign", "Walls", (GX - 0.03, 2.85, 1.6), "PASO BAJO NIVEL", 40, (0.85, 0.82, 0.7), rot=(0, -math.pi / 2, 0))
for i, (x, z, r) in enumerate([(-9.5, 2.4, 0.3), (6.0, 2.7, 1.1), (-1.0, 1.0, 0.7)]):
    luggage(k, "Luggage%d" % i, (x, 0, z), r)
k.decal("GraffitiRuta", "graffiti_ruta5", (-8.0, 2.0, 3.49), (3.0, 1.5), "-z", wear=0.35)
k.decal("GraffitiKm", "graffiti_km42", (3.0, 1.9, 3.49), (2.6, 1.3), "-z", wear=0.45)
k.decal("BloodWall", "blood_splatter_c", (-2.0, 1.2, 3.49), 1.2, "-z")
k.decal("Pool", "blood_pool", (9.0, 0.03, 0.6), 1.5, "up")
k.decal("Drag", "blood_drag", (-3.0, 0.03, 1.0), (3.0, 1.0), "up", rot=0.2)
k.decal("Footprints", "blood_footprints", (1.0, 0.03, 0.9), (2.0, 1.0), "up", rot=3.0)
# Interactuables.
k.door("ToWagon", (-6.0, 0, 0.45), T % "wagon_interior", "from_convoy", prompt="ENTRAR", reach=1.3, marker="SUBIR AL COCHE")
k.door("ToUnderpass", (X1 - 0.6, 0, 1.6), T % "underpass", "from_convoy", key="engineer_key", lock_id="underpass_gate",
       locked_text="La reja del paso bajo nivel. Tiene un candado de EFE.", reach=1.4, metal_door=True)
k.pickup("Grenades", (0.5, 0.0, 3.0), "ammo_grenades", 2, rot=(0, 0.3, 0))
k.pickup("Sushi", (11.2, 0.0, 2.9), "sushi", rot=(0, 2.0, 0))
# Infectados.
k.infected("Runner", (4.5, 0.05, 1.6), yaw=-math.pi / 2, kind="infected_fast")
k.infected("Feeding", (9.6, 0.05, 0.4), yaw=-2.0, state="feeding", kind="infected_worker")
k.infected("Lying", (-2.6, 0.05, 1.9), yaw=0.4, state="lying")
# Cámaras (tres franjas; el plan definitivo lo calcula tools/plan_cameras.gd).
k.camera("West", (-8.6, 1.5, -0.25), (8.8, 3.0, 7.5), (-11.5, 4.0, 3.3), (-6.0, 0.4, 0.4), fov=58)
k.camera("Mid", (0.0, 1.5, -0.25), (8.8, 3.0, 7.5), (-3.0, 4.0, 3.3), (3.0, 0.4, 0.4), fov=58)
k.camera("East", (8.6, 1.5, -0.25), (8.8, 3.0, 7.5), (4.0, 4.0, 3.3), (10.0, 0.4, 0.8), fov=58)
k.spawn("from_wagon", (-6.0, 0.05, 1.2), (0, 1))
k.spawn("from_underpass", (X1 - 1.4, 0.05, 1.6), (-1, 0))
# Pistas de Leo: adonde guía a Isabella cuando se queda quieta y qué le explica.
k.leo_hint('LeoGate', (X1 - 1.6, 0, 1.6), ['Leo: La reja del paso bajo nivel. La llave del maquinista la abre.', 'Leo: Abajo está oscuro. No importa: yo veo en la oscuridad. Tú sigue mis ojos.', 'Leo: Acércate a la reja del paso bajo nivel y usa la llave del maquinista.'], hide_if='unlocked:underpass_gate')
k.save(REPO + "/levels/tracks/convoy_side.tscn")
print("convoy ok")
