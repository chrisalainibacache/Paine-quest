import sys, math, os; sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
from buin_common import *
# Puente del Maipo (inicio del capítulo 3): puente ferroviario de fierro sobre el
# río crecido, de mañana. Al otro lado, el control militar de Buin.
INTRO = ["Sábado, 6:50. Puente del Maipo.",
         "El río viene crecido y café. Al otro lado está Buin.",
         "Leo: Huele a motor, a humo y a mucha gente junta. Ya no están... pero estuvieron.",
         "Leo: Camina por el medio, Cony. Las barandas están sueltas."]
k = Kit("Bridge", "Puente del Maipo", intro=INTRO)
dawn(k)
X0, X1, Z0, Z1 = -11.0, 11.0, -2.3, 2.3
sky_box(k, X0, X1, Z0, Z1, margin=9.0)
# Tablero del puente (con el riel encima) y bordes que no dejan caer.
k.block("Deck", "Ground", (0, -0.3, 0), (X1 - X0 + 1.0, 0.6, Z1 - Z0 + 0.6), "concrete_floor")
k.block("DeckBeamN", "Ground", (0, -1.0, Z0), (X1 - X0 + 1.0, 0.9, 0.3), "rust")
k.block("DeckBeamS", "Ground", (0, -1.0, Z1), (X1 - X0 + 1.0, 0.9, 0.3), "rust")
k.s.node("Track", "Node3D", "Ground", position=v3((0, 0.0, 0.0)), script=k.s.res("res://levels/kit/rail_track.gd", "Script"),
         length=fmt(X1 - X0), sleeper_material=k.s.res(M("wood"), "Material"), rail_material=k.s.res(M("metal"), "Material"))
# Celosía de fierro a los dos lados (lo que se ve del puente).
for side, z in (("N", Z0 - 0.1), ("S", Z1 + 0.1)):
    k.block("Guard" + side, "Truss", (0, 0.6, z), (X1 - X0, 1.2, 0.12), "rust")
    k.block("TopChord" + side, "Truss", (0, 4.6, z), (X1 - X0, 0.3, 0.3), "rust", solid=False)
    k.block("Rail" + side, "Truss", (0, 1.15, z), (X1 - X0, 0.08, 0.16), "metal", solid=False)
    n = 8
    for i in range(n + 1):
        x = X0 + i * (X1 - X0) / n
        k.block("Post%s%d" % (side, i), "Truss", (x, 2.3, z), (0.25, 4.6, 0.25), "rust", solid=False)
        if i < n:
            dx = (X1 - X0) / n
            ang = math.atan2(4.3, dx) * (1 if i % 2 == 0 else -1)
            k.block("Diag%s%d" % (side, i), "Truss", (x + dx / 2, 2.4, z), (math.hypot(dx, 4.3), 0.14, 0.14), "rust", solid=False, rot=(0, 0, ang))
for i in range(5):
    x = X0 + 2.75 + i * 4.1
    k.block("CrossBeam%d" % i, "Truss", (x, 4.7, 0), (0.2, 0.2, Z1 - Z0 + 0.3), "rust", solid=False)
# Los extremos: Paine atrás (oeste) y los sacos del control (este).
k.block("EndW", "Ends", (X0 - 0.2, 1.5, 0), (0.3, 3.0, Z1 - Z0), "sky_dawn")
k.block("EndE", "Ends", (X1 + 0.2, 1.5, 0), (0.3, 3.0, Z1 - Z0), "sky_dawn")
k.prop("SandbagsE1", "Props", "sandbags", (10.2, 0, -1.3), rot=(0, math.pi / 2, 0))
k.prop("BarrierE", "Props", "barrier", (9.6, 0, 1.6), rot=(0, math.pi, 0))
for i, (x, z, r) in enumerate([(-6.0, 1.3, 0.3), (-1.0, -1.5, 1.4), (3.4, 1.2, -0.7)]):
    luggage(k, "Luggage%d" % i, (x, 0, z), r)
k.decal("Pool", "blood_pool", (1.5, 0.02, -0.6), 1.4, "up")
k.decal("Drag", "blood_drag", (5.0, 0.02, 0.6), (2.6, 0.9), "up", rot=0.2)
k.decal("Oil", "oil_stain", (-3.5, 0.02, 0.4), 1.6, "up")
# Interactuables.
k.door("ToCheckpoint", (10.2, 0, 0.4), B % "checkpoint", "from_bridge", prompt="SEGUIR", reach=1.4)
k.examine("River", (0.0, 0, -1.9), ["El Maipo viene crecido y café.", "Arrastra ramas, un colchón... y otras cosas que prefiero no mirar."], reach=1.2)
k.examine("BackToPaine", (-10.3, 0, 0.0), ["Por ahí quedó Paine.", "Leo: No mires para atrás, Cony. Ya no hay nada que buscar allá."], reach=1.3)
k.pickup("RifleAmmo", (-4.5, 0.0, -1.6), "ammo_rifle", 15, rot=(0, 0.4, 0))
k.pickup("Sushi", (6.5, 0.0, -1.7), "sushi", rot=(0, 1.0, 0))
k.infected("Walker", (2.5, 0.05, 0.4), yaw=-math.pi / 2)
k.infected("Lying", (7.2, 0.05, -1.0), yaw=2.0, state="lying", kind="infected_worker")
k.infected("Body", (-2.4, 0.05, 1.5), yaw=0.6, state="corpse", kind="infected_pale")
# Cámaras: desde afuera del puente, mirando a lo largo.
k.camera("West", (-5.5, 1.5, 0.0), (11.0, 3.0, 4.6), (0.8, 3.7, 1.7), (-8.0, 0.3, -0.5), fov=58)
k.camera("East", (5.5, 1.5, 0.0), (11.0, 3.0, 4.6), (-0.8, 3.7, -1.7), (8.0, 0.3, 0.5), fov=58)
k.spawn("start", (-9.6, 0.05, 0.0), (1, 0))
k.spawn("from_checkpoint", (9.2, 0.05, 0.0), (-1, 0))
k.leo_hint("LeoCheckpoint", (9.3, 0, 0.4), ["Leo: Sacos de arena y una barrera. Esto lo armaron los militares.", "Leo: No huelo a ningún soldado vivo. Pasemos."])
k.save(REPO + "/levels/buin/bridge.tscn")
print("bridge ok")
