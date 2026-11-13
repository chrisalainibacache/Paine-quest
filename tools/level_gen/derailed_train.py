import sys, math, os; sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
from tracks_common import *
T = "res://levels/tracks/%s.tscn"
# El tren descarrilado: la locomotora volcada a un lado y un vagón fuera de
# la vía al otro; Cony avanza por el pasillo entre ambos y entra al vagón.
k = Kit("DerailedTrain", "Tren descarrilado")
night(k, 0.055)
X0, X1, Z0, Z1 = -9.0, 9.0, -4.2, 5.0
track_bed(k, X0, X1, Z0, Z1, track_z=0.9, track_len=8.0, track_x=-5.0)
k.s.node("TrackBent", "Node3D", "Ground", position=v3((1.8, 0.0, 0.3)), rotation=v3((0, 0.18, 0)),
         script=k.s.res("res://levels/kit/rail_track.gd", "Script"), length="6.0",
         sleeper_material=k.s.res(M("wood"), "Material"), rail_material=k.s.res(M("metal"), "Material"))
walls(k, X0, X1, Z0, Z1, north="old_bricks_wall", south="concrete_wall")
# Locomotora volcada sobre su costado (norte).
k.prop("Locomotive", "Props", "locomotive", (1.2, 1.5, -0.25), rot=(-math.pi / 2, 0, 0))
# Vagón fuera de la vía (sur), entero: se entra por su puerta.
k.prop("Wagon", "Props", "train_wagon", (-1.0, 0, 3.25))
k.block("Step", "Props", (5.25, 0.2, 1.6), (0.7, 0.4, 0.35), "metal")
# Segundo vagón atravesado (este) cierra el paso.
k.prop("JackknifeWagon", "Props", "train_wagon", (8.6, 0, 1.6), rot=(0, 1.15, 0.12))
k.prop("FireCab", "Props", "fire", (6.6, 0, 0.6))
k.prop("FireMid", "Props", "fire", (-3.2, 0, 0.5))
for i, (x, z, r) in enumerate([(-6.5, 1.3, 0.3), (0.5, 1.4, 1.7), (3.4, 0.7, -0.6)]):
    luggage(k, "Luggage%d" % i, (x, 0, z), r)
k.decal("Pool", "blood_pool", (2.0, 0.03, 0.9), 1.5, "up")
k.decal("Drag", "blood_drag", (-1.2, 0.03, 1.0), (2.6, 0.9), "up", rot=-0.2)
k.decal("Oil", "oil_stain", (4.6, 0.025, 0.4), 1.8, "up", rot=0.8)
k.decal("Debris", "debris", (-5.5, 0.028, 0.6), 1.6, "up")
# Interactuables.
k.door("ToTrackNorth", (-8.4, 0, 0.9), T % "track_north", "from_derailed", prompt="VOLVER", reach=1.4)
k.door("ToWagon", (5.25, 0, 1.25), T % "wagon_interior", "from_derailed", prompt="ENTRAR", reach=1.3)
k.examine("Cab", (6.0, 0, 0.2), ["La cabina de la locomotora está aplastada contra el suelo.", "El asiento del maquinista está vacío. Hay sangre en la palanca de freno."], reach=1.4)
k.examine("Jackknife", (7.3, 0, 1.4), ["Otro vagón atravesado. Por aquí no se puede pasar.", "Tendré que cruzar por dentro del vagón."], reach=1.3)
k.pickup("RifleAmmo", (-5.6, 0.0, 0.2), "ammo_rifle", 15, rot=(0, 0.6, 0))
# Infectados.
k.infected("Heavy", (2.2, 0.05, 1.0), yaw=-math.pi / 2, state="feeding", heavy=True)
k.infected("Lying", (-1.8, 0.05, 0.6), yaw=1.0, state="lying", kind="infected_pale")
k.infected("Body", (0.3, 0.05, 1.2), yaw=2.0, state="corpse", kind="infected_worker")
# Rincón muerto detrás de la locomotora: pared invisible (Cony no tiene nada que hacer
# ahí y ninguna cámara lo ve).
k.s.node("BackAlcoveBlock", "StaticBody3D", ".", position=v3((0.0, 1.5, -3.5)))
k.s.node("Shape", "CollisionShape3D", "BackAlcoveBlock", shape=k.s.subres("BoxShape3D", {"size": v3((19.0, 3.0, 1.5))}))
# Cámaras.
k.camera("West", (-4.5, 1.5, 0.8), (9.0, 3.0, 3.0), (2.4, 3.3, 1.6), (-7.0, 0.3, 0.6), fov=58)
k.camera("East", (4.5, 1.5, 0.8), (9.0, 3.0, 3.0), (-2.4, 3.3, 1.6), (7.0, 0.4, 0.8), fov=58)
k.spawn("from_track_north", (-7.7, 0.05, 0.9), (1, 0))
k.spawn("from_wagon", (4.6, 0.05, 0.9), (-1, 0))
# Pistas de Leo: adonde guía a Cony cuando se queda quieta y qué le explica.
k.leo_hint('LeoWagon', (4.6, 0, 1.25), ['Leo: Por fuera no se pasa: el vagón quedó atravesado.', 'Leo: Hay que cruzar por dentro. Yo cabía en todas partes, ¿te acuerdas? Tú no tanto.'])
k.save(REPO + "/levels/tracks/derailed_train.tscn")
print("derailed ok")
