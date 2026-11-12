import sys, os; sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
from tscn import *
KB = "res://levels/kit/kit_block.gd"
M = lambda n: "res://levels/kit/materials/%s.tres" % n
PROP = lambda n: "res://levels/kit/props/%s.tscn" % n
s = Scene()

def block(name, parent, pos, size, mat, solid=True, rot=None):
    props = {"position": v3(pos)}
    if rot: props["rotation"] = v3(rot)
    props.update({"script": s.res(KB, "Script"), "size": v3(size), "surface": s.res(M(mat), "Material")})
    if not solid: props["solid"] = "false"
    s.node(name, "StaticBody3D", parent, **props)

def prop(name, parent, scene, pos, rot=None, **extra):
    props = {"position": v3(pos)}
    if rot: props["rotation"] = v3(rot)
    props.update(extra)
    s.node(name, None, parent, instance=s.res(PROP(scene), "PackedScene"), **props)

env = s.subres("Environment", {
    "background_mode": "1", "background_color": col((0.05, 0.055, 0.07)),
    "ambient_light_source": "2", "ambient_light_color": col((0.36, 0.38, 0.46)), "ambient_light_energy": "0.8",
    "fog_enabled": "true", "fog_light_color": col((0.06, 0.065, 0.08)), "fog_density": "0.045",
    "fog_sky_affect": "1.0",
})
s.node("Platform", "Node3D", script=s.res("res://levels/kit/room.gd", "Script"), room_name='"Andén norte"',
       # Introducción del juego (lo que piensa Cony al llegar).
       intro_lines='PackedStringArray("Viernes, 23:40. Estación de Paine.", "Mensaje de Javiera, 22:10: «Dicen en la tele que esta noche pasa un tren de evacuación por Paine. Súbete con Leo. Te espero en Alameda.»", "No hay nadie. Ni guardia, ni pasajeros. Ni un solo tren en la vía.", "Leo no se despega de mis pies. Ella también lo siente.", "Leo: Tranquila, Cony. Si no sabes por dónde seguir, quédate quieta un momento y mírame.", "Leo: Yo te llevo. Siempre te he llevado yo.")')
s.node("Environment", "WorldEnvironment", ".", environment=env)
s.node("Moon", "DirectionalLight3D", ".", rotation=v3((-0.9, 0.5, 0)), light_color=col((0.6, 0.68, 0.88)), light_energy="0.55")

# --- Piso y vía ---------------------------------------------------------
s.node("Ground", "Node3D", ".")
block("PlatformSlab", "Ground", (0, -0.5, 1.9), (14, 1, 6.8), "paving_floor")
block("SafetyLine", "Ground", (0, 0.015, -1.25), (14, 0.03, 0.3), "safety_yellow", solid=False)
block("TrackBed", "Ground", (0, -1.1, -3.4), (14, 0.2, 3.8), "gravel")
s.node("Track", "Node3D", "Ground", position=v3((0, -1.0, -3.3)), script=s.res("res://levels/kit/rail_track.gd", "Script"),
       length="14.0", sleeper_material=s.res(M("wood"), "Material"), rail_material=s.res(M("metal"), "Material"))

# --- Muros: la sala queda cerrada por los 4 lados ----------------------
s.node("Walls", "Node3D", ".")
block("Facade", "Walls", (0, 2.0, 5.45), (14.6, 4.0, 0.3), "plaster_wall")
block("Wainscot", "Walls", (0, 0.55, 5.29), (14.0, 1.1, 0.04), "paint_red", solid=False)
block("WainscotCap", "Walls", (0, 1.12, 5.27), (14.0, 0.06, 0.08), "wood", solid=False)
# Pilastras rojas entre puertas y ventanas (como la estación real).
for i, x in enumerate((-6.6, -2.9, 0.7, 4.3, 6.85)):
    block("Pilaster%d" % i, "Walls", (x, 1.8, 5.27), (0.32, 3.6, 0.06), "paint_red", solid=False)
block("Baseboard", "Walls", (0, 0.08, 5.27), (14.0, 0.16, 0.08), "concrete_wall", solid=False)
block("RetainingWall", "Walls", (0, 1.25, -5.45), (14.6, 4.5, 0.3), "old_bricks_wall")
block("WestWall", "Walls", (-7.15, 1.3, 0), (0.3, 4.6, 11.2), "concrete_wall")
block("EastWall", "Walls", (7.15, 1.3, 0), (0.3, 4.6, 11.2), "bricks_wall")

# Puerta a la sala de espera y ventanas iluminadas.
s.node("Facade_Details", "Node3D", ".")
block("DoorPanel", "Facade_Details", (3, 1.1, 5.26), (1.2, 2.2, 0.08), "planks")
block("DoorFrameL", "Facade_Details", (2.34, 1.2, 5.24), (0.12, 2.4, 0.16), "wood")
block("DoorFrameR", "Facade_Details", (3.66, 1.2, 5.24), (0.12, 2.4, 0.16), "wood")
block("DoorLintel", "Facade_Details", (3, 2.46, 5.24), (1.44, 0.12, 0.16), "wood")
prop("DoorArch", "Facade_Details", "window_arch", (3, 2.48, 5.27), rot=(0, math.pi, 0))
prop("Clock", "Facade_Details", "wall_clock", (1.65, 2.62, 5.26), rot=(0, math.pi, 0))
prop("Poster", "Facade_Details", "travel_poster", (-6.0, 1.75, 5.27), rot=(0, math.pi, 0))
for i, x in enumerate((-2.9, 0.7, 4.3)):
    prop("Lantern%d" % i, "Facade_Details", "wall_lantern", (x, 2.35, 5.24), rot=(0, math.pi, 0))
for i, x in enumerate((-4.6, -1.2, 5.6)):
    s.node("Window%d" % i, "MeshInstance3D", "Facade_Details", position=v3((x, 1.85, 5.29)),
           mesh=s.subres("BoxMesh", {"size": v3((1.3, 1.1, 0.03))}), material_override=s.res(M("window_glow"), "Material"))
    block("WindowSill%d" % i, "Facade_Details", (x, 1.25, 5.24), (1.5, 0.08, 0.16), "wood", solid=False)
    block("WindowTop%d" % i, "Facade_Details", (x, 2.45, 5.24), (1.5, 0.1, 0.16), "wood", solid=False)
    prop("Arch%d" % i, "Facade_Details", "window_arch", (x, 2.42, 5.27), rot=(0, math.pi, 0))
    for j in range(4):
        block("Bar%d_%d" % (i, j), "Facade_Details", (x - 0.45 + j * 0.3, 1.85, 5.22), (0.035, 1.1, 0.035), "metal", solid=False)

# --- Andén: reja de borde, techo y pilares -----------------------------
s.node("Canopy", "Node3D", ".")
block("Roof", "Canopy", (0, 3.6, 2.5), (14.6, 0.12, 5.9), "rust")
# Cielo del alero: tablas de madera con vigas a la vista y tapa del borde.
block("RoofBoards", "Canopy", (0, 3.535, 2.5), (14.5, 0.02, 5.8), "planks", solid=False)
for i in range(12):
    block("Rafter%d" % i, "Canopy", (-6.6 + i * 1.2, 3.46, 2.5), (0.08, 0.12, 5.8), "wood", solid=False)
block("Fascia", "Canopy", (0, 3.5, -0.42), (14.6, 0.26, 0.05), "wood", solid=False)
for i, z in enumerate((0.15, 2.5, 4.85)):
    block("Beam%d" % i, "Canopy", (0, 3.44, z), (14.0, 0.2, 0.12), "metal", solid=False)
for i, x in enumerate((-5.0, -1.6, 1.6, 5.0)):
    prop("Pillar%d" % i, "Canopy", "iron_column", (x, 0, 0.15))

s.node("EdgeFence", "Node3D", ".")
for i in range(8):
    x = -6.6 + i * 1.9
    block("Post%d" % i, "EdgeFence", (x, 0.55, -1.12), (0.07, 1.1, 0.07), "metal", solid=False)
block("RailTop", "EdgeFence", (0, 1.07, -1.12), (13.8, 0.06, 0.05), "metal", solid=False)
block("RailMid", "EdgeFence", (0, 0.55, -1.12), (13.8, 0.05, 0.04), "metal", solid=False)
# Colisión invisible del borde: Cony no puede caer a la vía.
s.node("EdgeBlocker", "StaticBody3D", ".", position=v3((0, 1.0, -1.15)))
s.node("Shape", "CollisionShape3D", "EdgeBlocker", shape=s.subres("BoxShape3D", {"size": v3((14, 2.0, 0.2))}))

# --- Utilería -----------------------------------------------------------
s.node("Props", "Node3D", ".")
prop("BenchA", "Props", "park_bench", (-3.2, 0, 4.6), rot=(0, math.pi, 0))
prop("BenchB", "Props", "park_bench", (0.4, 0, 4.6), rot=(0, math.pi, 0))
prop("PlantA", "Props", "plant_pot", (1.95, 0, 4.9))
prop("PlantB", "Props", "plant_pot", (4.05, 0, 4.9))
block("TrashBin", "Props", (-0.9, 0.4, 4.85), (0.42, 0.8, 0.42), "rust")
prop("Sign", "Props", "station_sign", (0, 2.95, 0.15))
prop("CrateA", "Props", "crate", (-6.2, 0, 2.2), rot=(0, 0.2, 0))
prop("CrateB", "Props", "crate", (-6.3, 0, 3.3), rot=(0, -0.1, 0))
prop("CrateC", "Props", "crate", (-6.25, 0.9, 2.7), rot=(0, 0.4, 0))
block("Gate", "Props", (6.95, 1.4, 2.6), (0.1, 2.8, 3.0), "rust")
for i, (x, z, sz, seed) in enumerate([(-2.0, 2.6, 1.4, 1.3), (2.6, 1.0, 0.9, 7.7), (4.8, 3.9, 1.8, 3.1), (-5.0, 0.4, 1.0, 9.4)]):
    prop("Stain%d" % i, "Props", "stain", (x, 0.012, z), rot=(0, seed, 0), scale=v3((sz, 1, sz)))

s.node("Lights", "Node3D", ".")
prop("LampWest", "Lights", "sodium_lamp", (-4.0, 3.34, 2.5))
prop("LampEast", "Lights", "sodium_lamp", (3.6, 3.34, 2.5))

# --- Cámaras fijas ------------------------------------------------------
s.node("Cameras", "Node3D", ".")
for name, zone_center, cam_pos, target in [
        ("West", (-3.2, 1.5, 1.9), (2.2, 3.1, 4.2), (-4.4, 0.5, 1.4)),
        ("East", (3.2, 1.5, 1.9), (-2.4, 3.1, 4.2), (4.6, 0.5, 1.4))]:
    s.node(name, "Area3D", "Cameras", position=v3(zone_center), script=s.res("res://levels/kit/camera_zone.gd", "Script"))
    s.node("Zone", "CollisionShape3D", "Cameras/" + name, shape=s.subres("BoxShape3D", {"size": v3((7.6, 3.0, 6.8))}))
    rel = tuple(cam_pos[i] - zone_center[i] for i in range(3))
    s.node("Camera", "Camera3D", "Cameras/" + name, position=v3(rel), rotation=v3(look_rotation(cam_pos, target)),
           fov="58.0", near="0.1", far="40.0")

# --- Infectados -----------------------------------------------------------
s.node("Enemies", "Node3D", ".")
INF = "res://actors/enemies/infected.tscn"
# Llegan desde la vía cuando Cony ya tiene la pistola (al empezar, el andén está tranquilo).
s.node("Feeding", None, "Enemies", instance=s.res(INF, "PackedScene"), position=v3((5.2, 0.05, 2.4)), start_state='"feeding"',
       requires_flag='"found:pistol"', data=s.res("res://data/enemies/infected_burnt.tres", "Resource"))
s.node("Lying", None, "Enemies", instance=s.res(INF, "PackedScene"), position=v3((2.4, 0.05, 1.2)), rotation=v3((0, 2.2, 0)), start_state='"lying"',
       requires_flag='"found:pistol"')

# --- Calcomanías: mural tras la vía, grafitis, sangre, hoyos y manchas ---
from roomkit import add_decal
s.node("Decals", "Node3D", ".")
D = lambda *a, **k: add_decal(s, "Decals", *a, **k)
D("MuralTracks", "mural_station_a", (0, 1.45, -5.29), (14.4, 3.6), "+z")
D("GraffitiPaine", "graffiti_paine", (0.9, 1.75, 5.28), (2.7, 1.35), "-z", wear=0.3)
D("BloodDoor", "blood_splatter_a", (4.25, 1.15, 5.28), 1.1, "-z")
D("HandDoor", "blood_handprint", (3.3, 1.25, 5.205), 0.38, "-z", rot=0.2)
D("BulletsEast", "bullet_holes", (6.99, 1.5, 0.9), 1.2, "-x")
D("HoleWest", "wall_hole_a", (-6.99, 0.95, 0.9), 1.1, "+x")
D("CracksWest", "cracks", (-6.99, 2.4, 4.0), 1.3, "+x")
D("DragFloor", "blood_drag", (1.9, 0.016, 1.7), (2.3, 1.1), "up", rot=0.35)
D("Footprints", "blood_footprints", (-1.4, 0.018, 3.5), (2.0, 1.0), "up", rot=0.15)
D("OilFloor", "oil_stain", (-3.9, 0.014, 0.1), 1.3, "up", rot=1.0)
D("DebrisFloor", "debris", (-6.0, 0.017, 4.4), 1.5, "up")
D("DampFloor", "damp_stain", (1.6, 0.013, 4.5), 1.8, "up", rot=2.0)

# --- Interactuables -------------------------------------------------------
IA = lambda n: "res://levels/kit/interact/%s.gd" % n
s.node("Interactables", "Node3D", ".")
s.node("DoorToWaitingRoom", "Node3D", "Interactables", position=v3((3.0, 0, 4.95)), script=s.res(IA("door"), "Script"),
       target_room='"res://levels/station/waiting_room.tscn"', target_spawn='"from_platform"', reach="1.3")
s.node("Note", "Node3D", "Interactables", position=v3((-2.8, 0.49, 4.62)), script=s.res(IA("note"), "Script"),
       document=s.res("res://data/documents/platform_note.tres", "Resource"), reach="1.4")
s.node("Paper", None, "Interactables/Note", instance=s.res("res://levels/kit/items/paper.tscn", "PackedScene"), rotation=v3((0, 0.5, 0)))
s.node("Ammo", "Node3D", "Interactables", position=v3((-5.9, 0.0, 1.35)), script=s.res(IA("pickup"), "Script"),
       item=s.res("res://data/items/ammo_9mm.tres", "Resource"), count="10", model_rotation=v3((0, 2.2, 0)))
s.node("Gate", "Node3D", "Interactables", position=v3((6.55, 0, 2.6)), script=s.res(IA("door"), "Script"), reach="1.4",
       target_room='"res://levels/station/south_platform.tscn"', target_spawn='"from_north_platform"',
       key_item=s.res("res://data/items/gate_key.tres", "Resource"), lock_id='"gate_south"',
       locked_text='"El portón hacia el andén sur. Tiene una cadena con un candado nuevo."')

# --- Puntos de aparición -------------------------------------------------
s.node("Spawns", "Node3D", ".")
s.node("start", "Marker3D", "Spawns", position=v3((-5.0, 0.05, 3.0)), rotation=v3((0, -math.pi / 2, 0)))
s.node("from_waiting_room", "Marker3D", "Spawns", position=v3((3.0, 0.05, 4.35)))
s.node("from_south_platform", "Marker3D", "Spawns", position=v3((6.0, 0.05, 2.6)), rotation=v3((0, math.pi / 2, 0)))
from roomkit import add_leo_hint
# Pistas de Leo: adonde guía a Cony cuando se queda quieta y qué le explica.
add_leo_hint(s, 'LeoWaitingRoom', (3.0, 0, 4.2), ['Leo: Cony, aquí afuera no. Adentro hay luz.', 'Leo: Huele a pólvora... Alguien disparó en la estación. Busquemos de dónde salieron esas balas.'], hide_if='found:pistol')
add_leo_hint(s, 'LeoGateKey', (5.9, 0, 2.6), ['Leo: El portón del andén sur. La cadena es nueva: alguien lo cerró hace poco.', 'Leo: Las llaves se guardan donde guardan todo: en la bodega, al fondo del pasillo de servicio.'], show_if='found:pistol', hide_if='unlocked:gate_south', hide_item='gate_key')
add_leo_hint(s, 'LeoGateOpen', (5.9, 0, 2.6), ['Leo: Ya tienes la llave. Ábrelo, Cony. Yo voy contigo.'], show_item='gate_key', hide_if='unlocked:gate_south')
s.save(REPO + "/levels/station/platform.tscn")
print("platform ok")
