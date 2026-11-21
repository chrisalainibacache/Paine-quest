import sys, math, os; sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
from tracks_common import *
T = "res://levels/tracks/%s.tscn"
# Vía norte: Isabella y Leo bajaron del andén sur y siguen por la vía. Al fondo,
# un vagón volcado cruza la vía y hay fuego: el tren de las 6:30.
# Lo que piensa Isabella al empezar el capítulo 2.
INTRO = ['Pasada la medianoche. La vía hacia el norte.', 'Allá adelante se ve un resplandor rojo y humo. Tiene que ser el tren de las 6:30, el que nunca llegó a Santiago.', 'Paz, aguanta. Vamos caminando.', 'Leo: Yo voy adelante, como siempre.']
k = Kit("TrackNorth", "Vía norte", intro=INTRO, ambience="tracks_night")
night(k)
X0, X1, Z0, Z1 = -9.0, 9.0, -5.2, 3.5   # trinchera más ancha al norte: cabe el ramal con el vagón
track_bed(k, X0, X1, Z0, Z1, track_z=0.0)
walls(k, X0, X1, Z0, Z1, north="old_bricks_wall", south="concrete_wall", skip=("W", "E"))
# Túnel de regreso a la estación (oeste): portal de ladrillo y tubo con la vía.
from tunnels import carve
carve(k.block, k.prop, -1, X0, 0.0, 0.0, -0.3, 5.5, Z0, Z1, "concrete_wall", prefix="WestTunnel")
# Baranda al pie del muro sur, interrumpida en la puerta de servicio (un paso libre, sin rejas).
# Túnel de la vía principal (este): sigue hacia el norte; adentro todavía arde el resto del tren (resplandor rojo).
carve(k.block, k.prop, +1, X1, 0.0, 0.0, -0.3, 5.5, Z0, Z1, "concrete_wall", red=True, prefix="EastTunnel")
fence_top(k, X0, 5.6, 3.42, 0.0, prefix="FenceA")
fence_top(k, 8.4, X1, 3.42, 0.0, prefix="FenceB")
# Túnel por el que vinieron (oeste): está abierto (el tren de las 6:30 también pasó por ahí), pero a oscuras;
# una pared invisible en la boca evita que Isabella se meta a un tubo sin salida. Sin reja: nadie la cerró.
k.s.node("TunnelMouthBlock", "StaticBody3D", ".", position=v3((-8.75, 1.5, 0.0)))
k.s.node("Shape", "CollisionShape3D", "TunnelMouthBlock", shape=k.s.subres("BoxShape3D", {"size": v3((0.3, 3.0, 4.2))}))
# Puerta de servicio de la trinchera (muro sur): el personal la usaba para rodear el desvío. Es el paso que sigue.
DX = 7.0
for s in (-1, 1):
    k.block("ServiceFrame%d" % (s > 0), "Walls", (DX + s * 0.58, 1.1, 3.42), (0.14, 2.2, 0.14), "metal", solid=False)
k.block("ServiceLintel", "Walls", (DX, 2.25, 3.42), (1.3, 0.14, 0.14), "metal", solid=False)
k.block("ServiceLeaf", "Walls", (DX - 0.35, 1.05, 3.28), (0.12, 2.1, 0.9), "rust", solid=False, rot=(0, 0.9, 0))
k.light("ServiceLamp", "Lights", (DX, 2.5, 3.0), (1.0, 0.45, 0.2), 0.9, 3.5)
k.mesh("ServiceBulb", "Props", (0.16, 0.1, 0.1), k.emissive((1.0, 0.5, 0.2), 1.6), (DX, 2.45, 3.4))
# La boca del túnel este también queda cerrada al paso: adentro arde el resto del tren.
k.s.node("EastMouthBlock", "StaticBody3D", ".", position=v3((8.75, 1.5, 0.0)))
k.s.node("Shape", "CollisionShape3D", "EastMouthBlock", shape=k.s.subres("BoxShape3D", {"size": v3((0.3, 3.0, 4.2))}))
# Desvío: de la vía principal sale un ramal al norte. El maquinista metió el tren por ahí a propósito (nota del
# maquinista); el ramal termina en un tope de vía y ahí quedó descarrilado el último vagón (la mitad delantera: el
# vagón se partió en el choque). Todo cabe dentro de la trinchera: nada atraviesa los muros.
ANG = 0.26
SX = -3.0                                  # punto del cambio de vía, sobre la vía principal
SLEN = 9.0
cx, cz = SX + SLEN / 2 * math.cos(ANG), -SLEN / 2 * math.sin(ANG)
k.s.node("Siding", "Node3D", "Ground", position=v3((cx, 0.0, cz)), rotation=v3((0, ANG, 0)),
         script=k.s.res("res://levels/kit/rail_track.gd", "Script"), length=fmt(SLEN),
         sleeper_material=k.s.res(M("wood"), "Material"), rail_material=k.s.res(M("metal"), "Material"))
# Cambio de vía: caja y palanca junto al desvío (quedó puesta hacia el ramal).
k.block("SwitchStand", "Props", (SX + 0.7, 0.35, 1.15), (0.3, 0.7, 0.3), "metal", solid=False)
k.block("SwitchLever", "Props", (SX + 0.7, 0.85, 1.15), (0.06, 0.06, 0.7), "rust", solid=False, rot=(0.9, 0, 0))
k.mesh("SwitchLamp", "Props", (0.12, 0.12, 0.12), k.emissive((1.0, 0.15, 0.08), 1.8), (SX + 0.7, 1.0, 1.15))
# Tope de vía al final del ramal, doblado por el impacto.
ex, ez = SX + SLEN * math.cos(ANG), -SLEN * math.sin(ANG)
k.block("BufferStop", "Props", (ex + 0.1, 0.45, ez), (0.4, 0.9, 1.7), "rust", solid=False, rot=(0, ANG, 0.2))
k.block("BufferBeam", "Props", (ex - 0.1, 0.2, ez), (0.5, 0.3, 1.9), "metal", solid=False, rot=(0, ANG, 0))
# Mitad delantera del último vagón, salida del ramal y ladeada contra el talud, con daños.
k.prop("CrossWagon", "Props", "train_wagon_half_wrecked", (ex - 1.0, 0.12, ez - 1.35), rot=(-0.2, ANG - 0.04, 0))
# Restos tirados en el suelo: una puerta arrancada y un bogie salido del vagón.
k.block("FallenDoor", "Props", (ex - 3.6, 0.04, ez + 0.9), (0.9, 0.07, 1.9), "rust", solid=False, rot=(0, 0.9, 0.0))
k.block("LooseBogie", "Props", (ex - 0.2, 0.3, ez + 2.0), (1.9, 0.6, 1.0), "rust", solid=False, rot=(0, 0.5, 0.12))
k.prop("FireEast", "Props", "fire", (ex + 0.9, 0, ez + 1.2))
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
k.examine("EastTunnel", (7.9, 0, 0.0), ["La vía principal sigue por ese túnel, pero adentro todo es rojo y humo.", "Por ahí no se puede. Habrá que rodear por la puerta de servicio."], reach=1.4)
k.examine("Signal", (-3.5, 0, -2.3), ["Una señal en rojo. Nadie la cambió desde la mañana."], reach=1.2)
k.note("Ticket", (-1.2, 0.03, 2.5), "passenger_ticket", paper_rot=(0, 0.7, 0), paper_scale=0.6)
k.pickup("Shells", (-4.2, 0.0, 3.0), "ammo_shells", 6, rot=(0, 0.4, 0))
k.pickup("Sushi", (-6.3, 0.0, -3.0), "sushi", rot=(0, 1.2, 0))
# Infectados: uno caminando y el primer rápido.
k.infected("Walker", (3.0, 0.05, 1.3), yaw=-math.pi / 2, kind="infected_worker")
k.infected("Runner", (5.4, 0.05, 1.3), yaw=-math.pi / 2, kind="infected_fast")
k.infected("Body1", (0.4, 0.05, 1.9), yaw=0.8, state="corpse", kind="infected_burnt")
k.infected("Body2", (2.2, 0.05, 2.5), yaw=2.4, state="corpse")
# Cámaras.
k.camera("West", (-4.5, 1.5, -0.85), (9.0, 3.0, 8.7), (1.6, 3.2, 3.1), (-6.5, 0.3, -1.0), fov=58)
k.camera("East", (4.5, 1.5, -0.85), (9.0, 3.0, 8.7), (-1.6, 3.2, 3.1), (6.5, 0.5, -0.4), fov=58)
k.spawn("start", (-7.4, 0.05, 0.8), (1, 0))
k.spawn("from_derailed", (6.2, 0.05, 2.1), (-1, 0))
# Pistas de Leo: adonde guía a Isabella cuando se queda quieta y qué le explica.
k.leo_hint('LeoFire', (6.3, 0, 2.7), ['Leo: Ese humo es del tren de las 6:30. Huele a fierro quemado... y a ellos.', 'Leo: Por ahí se sigue. Pégate a mí.', 'Leo: Sigue la flecha amarilla hacia TREN DESCARRILADO.'])
k.save(REPO + "/levels/tracks/track_north.tscn")
print("track north ok")
