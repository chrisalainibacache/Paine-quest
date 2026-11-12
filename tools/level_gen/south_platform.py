import sys, math, os; sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
from roomkit import *
k = Kit("SouthPlatform", "Andén sur")
k.env((0.05, 0.055, 0.07), (0.36, 0.38, 0.46), 0.55, (0.06, 0.065, 0.08), 0.045)
k.s.node("Moon", "DirectionalLight3D", ".", rotation=v3((-0.9, -0.6, 0)), light_color=col((0.55, 0.62, 0.8)), light_energy="0.25")
# Piso del andén, vía y muros altos (cerrado por los 4 lados).
k.block("PlatformSlab", "Ground", (0, -0.5, 1.7), (12.4, 1, 6.4), "paving_floor")
k.block("SafetyLine", "Ground", (0, 0.015, -1.25), (12.0, 0.03, 0.3), "safety_yellow", solid=False)
k.block("TrackBed", "Ground", (0, -1.1, -3.4), (12.4, 0.2, 3.8), "gravel")
k.s.node("Track", "Node3D", "Ground", position=v3((0, -1.0, -3.3)), script=k.s.res("res://levels/kit/rail_track.gd", "Script"),
         length="12.0", sleeper_material=k.s.res(M("wood"), "Material"), rail_material=k.s.res(M("metal"), "Material"))
k.block("BackWall", "Walls", (0, 2.0, 5.05), (12.6, 4.0, 0.3), "old_bricks_wall")
k.block("RetainingWall", "Walls", (0, 1.25, -5.45), (12.6, 4.5, 0.3), "old_bricks_wall")
k.block("WestWall", "Walls", (-6.15, 1.3, 0), (0.3, 4.6, 10.8), "bricks_wall")
k.block("EastWall", "Walls", (6.15, 1.3, 0), (0.3, 4.6, 10.8), "concrete_wall")
# Túnel bajo el paso superior: por ahí sigue la vía (resplandor rojo al fondo).
k.mesh("TunnelMouth", "Walls", (0.05, 2.6, 3.0), k.emissive((0.12, 0.02, 0.01), 0.35), (5.98, 0.0, -3.4))
k.block("TunnelArch", "Walls", (5.9, 1.45, -3.4), (0.3, 0.3, 3.6), "concrete_wall", solid=False)
k.light("FireGlow", "Lights", (5.4, 0.2, -3.4), (1.0, 0.3, 0.12), 1.6, 5.5)
# Reja del borde: Cony no puede caer a la vía.
for i in range(7):
    k.block("Post%d" % i, "EdgeFence", (-5.4 + i * 1.6, 0.55, -1.12), (0.07, 1.1, 0.07), "metal", solid=False)
k.block("RailTop", "EdgeFence", (-0.6, 1.07, -1.12), (10.0, 0.06, 0.05), "metal", solid=False)
k.s.node("EdgeBlocker", "StaticBody3D", ".", position=v3((0, 1.0, -1.15)))
k.s.node("Shape", "CollisionShape3D", "EdgeBlocker", shape=k.s.subres("BoxShape3D", {"size": v3((12.0, 2.0, 0.2))}))
# Rampa de bajada a la vía (extremo este, sin reja).
k.block("Ramp", "Ground", (5.0, -0.5, -1.6), (1.6, 0.1, 1.4), "concrete_floor", solid=False, rot=(0.6, 0, 0))
# Techo y pilares.
k.block("Roof", "Canopy", (0, 3.6, 2.2), (12.4, 0.12, 5.6), "rust")
k.block("RoofBoards", "Canopy", (0, 3.535, 2.2), (12.3, 0.02, 5.5), "planks", solid=False)
for i in range(10):
    k.block("Rafter%d" % i, "Canopy", (-5.4 + i * 1.2, 3.46, 2.2), (0.08, 0.12, 5.5), "wood", solid=False)
k.block("Fascia", "Canopy", (0, 3.5, -0.58), (12.4, 0.26, 0.05), "wood", solid=False)
for i, x in enumerate((-4.0, 0.0, 4.0)):
    k.prop("Pillar%d" % i, "Canopy", "iron_column", (x, 0, 0.15))
# Portón de vuelta al andén norte (muro oeste).
k.block("GateFrame", "Walls", (-6.0, 1.4, 2.0), (0.1, 2.8, 2.6), "rust", solid=False)
for j in range(7):
    k.block("GateBar%d" % j, "Walls", (-5.95, 1.4, 0.85 + j * 0.38), (0.04, 2.6, 0.04), "metal", solid=False)
# Utilería.
k.prop("Bench", "Props", "park_bench", (-2.0, 0, 4.4), rot=(0, math.pi, 0))
k.prop("Plant", "Props", "plant_pot", (0.2, 0, 4.55))
for i, x in enumerate((-4.6, 2.4)):
    k.prop("Lantern%d" % i, "Props", "wall_lantern", (x, 2.4, 4.89), rot=(0, math.pi, 0))
k.prop("Sign", "Props", "station_sign", (0, 2.95, 0.15))
k.block("CartBed", "Props", (1.6, 0.45, 3.6), (2.0, 0.08, 1.0), "planks")
for i, (x, z) in enumerate([(0.75, 3.2), (2.45, 3.2), (0.75, 4.0), (2.45, 4.0)]):
    k.block("CartWheel%d" % i, "Props", (x, 0.2, z), (0.12, 0.4, 0.4), "rust")
k.block("Luggage", "Props", (1.3, 0.75, 3.6), (0.7, 0.5, 0.45), "planks", solid=False)
for i, (x, z, sz, seed) in enumerate([(3.6, 0.6, 1.7, 2.2), (-3.4, 2.6, 1.0, 5.8), (4.6, -0.6, 1.3, 0.9)]):
    k.prop("Stain%d" % i, "Props", "stain", (x, 0.012, z), rot=(0, seed, 0), scale=v3((sz, 1, sz)))
k.prop("LampWest", "Lights", "sodium_lamp", (-3.0, 3.34, 2.2))
k.prop("LampEast", "Lights", "sodium_lamp", (3.0, 3.34, 2.2))
# Interactuables.
k.door("GateToNorth", (-5.6, 0, 2.0), "res://levels/station/platform.tscn", "from_south_platform",
       key="gate_key", lock_id="gate_south", prompt="ABRIR")
k.pickup("Ammo", (0.4, 0.0, 4.35), "ammo_9mm", 10, rot=(0, 2.6, 0))
k.interact("TrackExit", "chapter_exit", (5.0, 0, -0.75), reach="1.4", chapter="1",
           question='"Al fondo del túnel se ve un resplandor rojo, sobre la vía.\\n¿Bajar a la vía y seguir hacia el norte? No podré volver a la estación."')
k.examine("Cart", (1.6, 0, 2.9), ["Un carro de equipaje volcado a medias.", "Las maletas siguen ahí. Nadie volvió por ellas."], reach=1.0)
# Infectados.
k.infected("Feeding", (3.4, 0.05, 1.2), yaw=-2.2, state="feeding", kind="infected_pale")
k.infected("Lying", (-0.8, 0.05, 1.0), yaw=0.8, state="lying")
k.infected("Body", (4.3, 0.05, 1.7), yaw=1.9, state="corpse", kind="infected_worker")
# Calcomanías.
k.decal("MuralTracks", "mural_station_b", (0, 1.4, -5.29), (12.2, 3.05), "+z")
k.decal("GraffitiRuta", "graffiti_ruta5", (-3.8, 2.0, 4.89), (3.2, 1.6), "-z", wear=0.35)
k.decal("GraffitiSur", "graffiti_sur", (5.99, 2.1, 2.2), (2.8, 1.4), "-x", wear=0.5)
k.decal("BloodBack", "blood_splatter_b", (2.5, 1.25, 4.89), 1.2, "-z")
k.decal("BulletsBack", "bullet_holes", (0.3, 1.65, 4.89), 1.0, "-z")
k.decal("HoleBack", "wall_hole_a", (-1.4, 0.8, 4.89), 0.9, "-z")
k.decal("PoolBody", "blood_pool", (4.1, 0.017, 1.5), 1.6, "up", rot=0.5)
k.decal("DragRamp", "blood_drag", (4.4, 0.018, 0.25), (2.0, 0.9), "up", rot=-1.2)
k.decal("Footprints", "blood_footprints", (-3.0, 0.018, 2.0), (2.0, 1.0), "up", rot=0.1)
k.decal("Debris", "debris", (-1.0, 0.015, 3.6), 1.6, "up")
k.decal("Oil", "oil_stain", (1.0, 0.014, -0.4), 1.2, "up", rot=1.3)
# Cámaras.
k.camera("West", (-3.0, 1.5, 1.6), (6.0, 3.0, 6.0), (2.6, 3.2, 4.3), (-4.2, 0.3, 0.9), fov=58)
k.camera("East", (3.0, 1.5, 1.6), (6.0, 3.0, 6.0), (-2.6, 3.2, 4.3), (4.4, 0.0, -0.6), fov=58)
k.spawn("from_north_platform", (-5.1, 0.05, 2.0), (1, 0))
# Pistas de Leo: adonde guía a Cony cuando se queda quieta y qué le explica.
k.leo_hint('LeoTracks', (4.3, 0, -0.75), ['Leo: La vía va hacia el norte. Hacia Santiago. Hacia Javiera.', 'Leo: No va a venir ningún tren. Pero yo camino rápido, y tú también.'])
k.save(REPO + "/levels/station/south_platform.tscn")
print("south platform ok")
