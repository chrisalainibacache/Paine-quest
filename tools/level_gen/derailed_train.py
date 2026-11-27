import sys, math, os; sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
from tracks_common import *
from tunnels import carve
T = "res://levels/tracks/%s.tscn"
# El tren descarrilado, a ESCALA REAL (locomotora ~20 m, coche de pasajeros 24 m, vagón de carga 16,5 m).
# La sala mide 26 m: la locomotora volcada al norte, el coche de pasajeros fuera de la vía al sur (se sube por su
# costado) y, al este, un vagón de carga empujado hasta la boca del túnel que cierra el paso. Entre la locomotora y el
# coche queda el pasillo por la vía. Las cajas de aquí son SOLO choque y oclusión: el aspecto real (modelos CC0) se
# pone al renderizar el fondo (tools/prerender/derailed_train_scene.py).
k = Kit("DerailedTrain", "Tren descarrilado", ambience="fire_wreck")
night(k, 0.055)
X0, X1, Z0, Z1 = -13.0, 13.0, -5.2, 6.0
TZ = 1.0                                           # eje de la vía
track_bed(k, X0, X1, Z0, Z1, track_z=TZ, track_len=7.0, track_x=-9.5)
# La vía se tuerce donde descarriló el tren y quedan tramos de riel sueltos.
for name, pos, yaw, ln in (("TrackBent", (-3.8, 0.0, 1.05), 0.16, 6.0), ("TrackTorn1", (1.2, 0.0, 0.55), 0.55, 3.2),
                           ("TrackTorn2", (-0.6, 0.0, 2.1), -0.3, 2.6), ("TrackTorn3", (6.2, 0.0, 1.5), 0.2, 3.0)):
    k.s.node(name, "Node3D", "Ground", position=v3(pos), rotation=v3((0, yaw, 0)),
             script=k.s.res("res://levels/kit/rail_track.gd", "Script"), length=fmt(ln),
             sleeper_material=k.s.res(M("wood"), "Material"), rail_material=k.s.res(M("metal"), "Material"))
walls(k, X0, X1, Z0, Z1, north="old_bricks_wall", south="concrete_wall", skip=("E",))
carve(k.block, k.prop, +1, X1, TZ, 0.0, -0.3, 5.5, Z0, Z1, "concrete_wall", prefix="EastTunnel")   # túnel este, tapado por el vagón
# Locomotora volcada de costado (norte): 19,9 x 4,7 de alto (de costado) x 3,4. Solo choque/oclusión.
k.block("Locomotive", "Props", (-1.0, 1.7, -2.75), (19.9, 3.4, 4.7), "train_red")
# Coche de pasajeros fuera de la vía (sur): 24 x 3 x 4,2.
k.block("Wagon", "Props", (0.5, 2.1, 3.95), (24.0, 4.2, 3.0), "train_blue")
# Vagón de carga empujado contra la boca del túnel este: cierra el paso.
k.block("JackknifeWagon", "Props", (15.6, 2.1, 0.4), (16.0, 4.2, 3.3), "rust", rot=(0, 0.18, 0))
k.prop("FireCab", "Props", "fire", (6.3, 0, -0.1))
k.prop("FireMid", "Props", "fire", (-3.6, 0, -0.3))
for i, (x, z, r) in enumerate([(-8.5, 0.2, 0.3), (-5.2, 2.2, 1.7), (2.0, 2.0, -0.6), (-10.5, -1.5, 0.9)]):
    luggage(k, "Luggage%d" % i, (x, 0, z), r)
k.decal("Pool", "blood_pool", (2.5, 0.03, 1.2), 1.5, "up")
k.decal("Drag", "blood_drag", (-2.2, 0.03, 1.3), (2.6, 0.9), "up", rot=-0.2)
k.decal("Oil", "oil_stain", (4.8, 0.025, 0.1), 1.8, "up", rot=0.8)
k.decal("Debris", "debris", (-6.5, 0.028, 0.0), 1.6, "up")
# Puerta de servicio en el muro oeste: por ahí se llega desde la trinchera de «Vía norte» (la misma que se ve allá en el muro sur).
k.door_frame("ServiceWest", X0, TZ, "z", width=1.2, wall_side=1, panel="metal")
k.light("ServiceWestLamp", "Lights", (X0 + 0.5, 2.6, TZ), (1.0, 0.45, 0.2), 0.8, 3.5)
# Rincón muerto al noroeste, detrás de la locomotora: pared invisible (nada que hacer ahí y ninguna cámara lo ve).
k.s.node("NorthWestBlock", "StaticBody3D", ".", position=v3((-12.0, 1.5, -3.0)))
k.s.node("Shape", "CollisionShape3D", "NorthWestBlock", shape=k.s.subres("BoxShape3D", {"size": v3((2.2, 3.0, 4.8))}))
# Interactuables.
k.door("ToTrackNorth", (-12.3, 0, TZ), T % "track_north", "from_derailed", prompt="VOLVER", reach=1.4)
k.block("BoardingStep", "Props", (5.4, 0.2, 2.0), (1.0, 0.4, 0.6), "metal")
k.door("ToWagon", (5.4, 0, 1.55), T % "wagon_interior", "from_derailed", prompt="ENTRAR", reach=1.3, marker="SUBIR AL VAGÓN")
k.examine("Cab", (6.6, 0, 0.3), ["La cabina de la locomotora está aplastada contra el suelo.", "El asiento del maquinista está vacío. Hay sangre en la palanca de freno."], reach=1.4)
k.examine("Jackknife", (6.9, 0, 1.3), ["Un vagón de carga se metió a la fuerza en el túnel. Por aquí no se puede pasar.", "Tendré que cruzar por dentro del coche de pasajeros."], reach=1.3)
k.pickup("RifleAmmo", (-6.4, 0.0, -0.3), "ammo_rifle", 15, rot=(0, 0.6, 0))
# Ala A: la locomotora (cabina de inspección). Ala B/C: se llega por el coche de pasajeros y el costado del convoy.
k.door("ToLocomotive", (-3.2, 0, -0.6), T % "sala_locomotora", "from_hub", prompt="ENTRAR", reach=1.3, marker="LOCOMOTORA")
# Retorno desde la pasarela del convoy: solo se abre desde el otro lado (atajo).
k.door("ToWalkway", (-8.4, 0, -0.8), T % "pasarela_convoy", "from_hub", prompt="SUBIR", reach=1.3,
       lock_id="tracks_shortcut_walkway", one_way=True, one_way_origin=False, metal_door=True)
# El mapa de la zona está en el equipaje del coche, al inicio del recorrido (REGISTRAR), no en el piso.
k.container("LostLuggage", (-2.0, 0, 2.15), "cap2_hub_locker", item_ids=("map_tracks",), counts=(1,), reach=1.4)
# Infectados.
k.infected("Heavy", (-0.5, 0.05, 1.5), yaw=-math.pi / 2, state="feeding", heavy=True)
k.infected("Lying", (-4.6, 0.05, 0.4), yaw=1.0, state="lying", kind="infected_pale")
k.infected("Body", (2.2, 0.05, 1.9), yaw=2.0, state="corpse", kind="infected_worker")
# Cámaras (tres franjas; el plan definitivo lo calcula tools/plan_cameras.gd).
k.camera("West", (-8.6, 1.5, 0.4), (8.8, 3.0, 11.2), (-12.0, 4.8, 3.6), (-6.0, 0.4, 0.8), fov=58)
k.camera("Mid", (0.0, 1.5, 0.4), (8.8, 3.0, 11.2), (-4.0, 4.8, 3.6), (3.0, 0.4, 0.8), fov=58)
k.camera("East", (8.6, 1.5, 0.4), (8.8, 3.0, 11.2), (3.5, 4.8, 3.6), (9.5, 0.4, 0.6), fov=58)
k.spawn("from_track_north", (-11.5, 0.05, TZ), (1, 0))
k.spawn("from_wagon", (4.4, 0.05, 0.9), (-1, 0))
k.spawn("from_locomotive", (-3.2, 0.05, 0.3), (0, 1))
k.spawn("from_walkway", (-7.6, 0.05, 0.6), (1, 0))
# Pistas de Leo: adonde guía a Isabella cuando se queda quieta y qué le explica.
k.leo_hint('LeoWagon', (4.6, 0, 1.25), ['Leo: Por fuera no se pasa: el vagón de carga cerró el túnel.', 'Leo: Hay que subirse al coche de pasajeros y cruzarlo por dentro. Se sube por el estribo.'])
k.door_frame("FrameLoco", -3.2, -0.45, "x", width=1.1, wall_side=1, panel="metal", group="Interactables")
k.door_frame("FrameWalkway", -8.4, -0.45, "x", width=1.0, wall_side=1, panel="metal", group="Interactables")
k.save(REPO + "/levels/tracks/derailed_train.tscn")
print("derailed ok")
