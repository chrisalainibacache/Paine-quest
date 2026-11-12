import sys, math, os; sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
from tscn import *
KB = "res://levels/kit/kit_block.gd"
M = lambda n: "res://levels/kit/materials/%s.tres" % n
PROP = lambda n: "res://levels/kit/props/%s.tscn" % n
ITEM = lambda n: "res://data/items/%s.tres" % n
IA = lambda n: "res://levels/kit/interact/%s.gd" % n
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

def interact(name, script, pos, **props):
    s.node(name, "Node3D", "Interactables", position=v3(pos), script=s.res(IA(script), "Script"), **props)

def lines(*texts):
    return "PackedStringArray(%s)" % ", ".join('"%s"' % t for t in texts)

env = s.subres("Environment", {
    "background_mode": "1", "background_color": col((0.02, 0.02, 0.025)),
    "ambient_light_source": "2", "ambient_light_color": col((0.34, 0.33, 0.36)), "ambient_light_energy": "0.5",
    "fog_enabled": "true", "fog_light_color": col((0.04, 0.04, 0.05)), "fog_density": "0.05",
})
s.node("WaitingRoom", "Node3D", script=s.res("res://levels/kit/room.gd", "Script"), room_name='"Sala de espera"')
s.node("Environment", "WorldEnvironment", ".", environment=env)

# --- Piso, cielo y muros (cerrada por los 4 lados) ----------------------
W, D, H = 9.0, 7.0, 3.2   # interior: x -4.5..4.5, z -3.5..3.5
s.node("Shell", "Node3D", ".")
block("Floor", "Shell", (0, -0.5, 0), (W + 0.6, 1, D + 0.6), "concrete_floor")
block("Ceiling", "Shell", (0, H + 0.05, 0), (W + 0.6, 0.1, D + 0.6), "concrete_wall")
block("NorthWall", "Shell", (0, H / 2, -D / 2 - 0.15), (W + 0.6, H, 0.3), "plaster_wall")
block("SouthWall", "Shell", (0, H / 2, D / 2 + 0.15), (W + 0.6, H, 0.3), "plaster_wall")
block("WestWall", "Shell", (-W / 2 - 0.15, H / 2, 0), (0.3, H, D), "plaster_wall")
block("EastWall", "Shell", (W / 2 + 0.15, H / 2, 0), (0.3, H, D), "plaster_wall")
# Zócalo de azulejos y guardapolvo en todo el perímetro.
for name, pos, size in [("N", (0, 0.6, -D / 2 + 0.02), (W, 1.2, 0.04)), ("S", (0, 0.6, D / 2 - 0.02), (W, 1.2, 0.04)),
                        ("W", (-W / 2 + 0.02, 0.6, 0), (0.04, 1.2, D)), ("E", (W / 2 - 0.02, 0.6, 0), (0.04, 1.2, D))]:
    block("Tiles" + name, "Shell", pos, size, "tiles_wall", solid=False)
    trim = (size[0] + (0.02 if size[0] < 1 else 0), 0.06, size[2] + (0.02 if size[2] < 1 else 0))
    block("Trim" + name, "Shell", (pos[0], 1.22, pos[2]), trim, "wood", solid=False)

# --- Muro norte: ventanillas de la boletería y su puerta -----------------
s.node("TicketOffice", "Node3D", ".")
for i, x in enumerate((-2.2, -0.2)):
    s.node("Window%d" % i, "MeshInstance3D", "TicketOffice", position=v3((x, 1.65, -D / 2 + 0.01)),
           mesh=s.subres("BoxMesh", {"size": v3((1.2, 0.85, 0.02))}), material_override=s.res(M("window_glow"), "Material"))
    block("Counter%d" % i, "TicketOffice", (x, 1.18, -D / 2 + 0.15), (1.4, 0.06, 0.3), "wood", solid=False)
    block("Frame%d" % i, "TicketOffice", (x, 2.1, -D / 2 + 0.04), (1.4, 0.08, 0.08), "wood", solid=False)
    for j in range(5):
        block("Bar%d_%d" % (i, j), "TicketOffice", (x - 0.5 + j * 0.25, 1.65, -D / 2 + 0.06), (0.03, 0.85, 0.03), "metal", solid=False)
s.node("Sign", "Label3D", "TicketOffice", position=v3((-1.2, 2.55, -D / 2 + 0.03)), text='"BOLETERÍA"', font_size="72",
       pixel_size="0.004", modulate=col((0.85, 0.8, 0.65)), outline_size="0")
s.node("Hours", "Label3D", "TicketOffice", position=v3((-1.2, 2.3, -D / 2 + 0.03)), text='"Lunes a domingo · 6:00 a 22:00"', font_size="40",
       pixel_size="0.004", modulate=col((0.6, 0.58, 0.5)), outline_size="0")
block("DoorPanel", "TicketOffice", (2.9, 1.1, -D / 2 + 0.04), (1.0, 2.2, 0.06), "planks", solid=False)
block("DoorFrameL", "TicketOffice", (2.34, 1.18, -D / 2 + 0.06), (0.1, 2.36, 0.1), "wood", solid=False)
block("DoorFrameR", "TicketOffice", (3.46, 1.18, -D / 2 + 0.06), (0.1, 2.36, 0.1), "wood", solid=False)
block("DoorLintel", "TicketOffice", (2.9, 2.32, -D / 2 + 0.06), (1.22, 0.1, 0.1), "wood", solid=False)
s.node("DoorSign", "Label3D", "TicketOffice", position=v3((2.9, 1.75, -D / 2 + 0.08)), text='"SOLO PERSONAL"', font_size="22",
       pixel_size="0.004", modulate=col((0.75, 0.2, 0.15)), outline_size="0")
# Tubo fluorescente frío sobre las ventanillas.
tube = s.subres("StandardMaterial3D", {"albedo_color": col((0.8, 0.85, 0.9)), "emission_enabled": "true",
                                       "emission": col((0.75, 0.85, 1.0)), "emission_energy_multiplier": "1.4"})
s.node("Tube", "MeshInstance3D", "TicketOffice", position=v3((-1.2, 3.1, -2.6)),
       mesh=s.subres("BoxMesh", {"size": v3((1.4, 0.05, 0.08))}), material_override=tube)
s.node("TubeLight", "OmniLight3D", "TicketOffice", position=v3((-1.2, 2.8, -2.4)), light_color=col((0.72, 0.82, 1.0)),
       light_energy="0.9", omni_range="5.0")

# --- Muro sur: puerta al andén y reloj detenido --------------------------
s.node("SouthDetails", "Node3D", ".")
block("DoorPanel", "SouthDetails", (-2.5, 1.1, D / 2 - 0.04), (1.2, 2.2, 0.06), "planks", solid=False)
block("DoorFrameL", "SouthDetails", (-3.16, 1.2, D / 2 - 0.06), (0.12, 2.4, 0.12), "wood", solid=False)
block("DoorFrameR", "SouthDetails", (-1.84, 1.2, D / 2 - 0.06), (0.12, 2.4, 0.12), "wood", solid=False)
block("DoorLintel", "SouthDetails", (-2.5, 2.46, D / 2 - 0.06), (1.44, 0.12, 0.12), "wood", solid=False)
s.node("ExitSign", "Label3D", "SouthDetails", position=v3((-2.5, 2.75, D / 2 - 0.03)), rotation=v3((0, math.pi, 0)),
       text='"ANDÉN 1"', font_size="48", pixel_size="0.004", modulate=col((0.85, 0.8, 0.65)), outline_size="0")
prop("Clock", "SouthDetails", "wall_clock", (0.6, 2.45, D / 2 - 0.03), rot=(0, math.pi, 0))

# --- Bancas, máquina de bebidas, basurero ---------------------------------
s.node("Props", "Node3D", ".")
for i, (x, z) in enumerate([(-3.4, 0.7), (-1.5, 0.7), (-3.4, -1.0), (-1.5, -1.0)]):
    prop("Bench%d" % i, "Props", "bench", (x, 0, z))
prop("Vending", "Props", "vending_machine", (-4.08, 0, -2.6), rot=(0, math.pi / 2, 0))
block("TrashBin", "Props", (-4.15, 0.4, 2.9), (0.42, 0.8, 0.42), "rust")
prop("Desk", "Props", "typewriter_desk", (4.1, 0, 1.4), rot=(0, -math.pi / 2, 0))
prop("CrateA", "Props", "crate", (3.9, 0, -1.4), rot=(0, 0.3, 0))
for i, (x, z, sz, seed) in enumerate([(1.2, -2.0, 1.6, 2.1), (2.3, -2.9, 1.0, 5.2), (-0.4, 1.9, 1.2, 8.3), (3.2, 2.6, 0.8, 1.7)]):
    prop("Stain%d" % i, "Props", "stain", (x, 0.012, z), rot=(0, seed, 0), scale=v3((sz, 1, sz)))

s.node("Lights", "Node3D", ".")
prop("Lamp", "Lights", "sodium_lamp", (-1.0, H - 0.05, 0.6))

# --- Calcomanías ---
from roomkit import add_decal
s.node("Decals", "Node3D", ".")
DC = lambda *a, **k: add_decal(s, "Decals", *a, **k)
DC("GraffitiSur", "graffiti_sur", (-4.48, 1.95, 0.0), (3.0, 1.5), "+x", wear=0.35)
DC("BloodVending", "blood_splatter_b", (-3.1, 1.05, -3.47), 1.2, "+z")
DC("HandSouth", "blood_handprint", (-1.4, 1.25, 3.47), 0.4, "-z", rot=-0.3)
DC("HoleSouth", "wall_hole_b", (1.9, 1.7, 3.47), 0.9, "-z")
DC("CracksEast", "cracks", (4.48, 2.2, -1.6), 1.3, "-x")
DC("PoolFeeder", "blood_pool", (-2.3, 0.016, -2.55), 1.7, "up", rot=0.7)
DC("DragTicket", "blood_drag", (0.6, 0.017, -2.5), (2.6, 1.1), "up", rot=0.08)
DC("Footprints", "blood_footprints", (-2.3, 0.018, 1.7), (1.9, 0.95), "up", rot=-1.45)
DC("DebrisEast", "debris", (3.2, 0.016, -0.3), 1.3, "up")
DC("DampCenter", "damp_stain", (0.9, 0.014, 1.5), 2.0, "up", rot=0.9)

# --- Interactuables -------------------------------------------------------
s.node("Interactables", "Node3D", ".")
interact("DoorToPlatform", "door", (-2.5, 0, D / 2 - 0.35), target_room='"res://levels/station/platform.tscn"',
         target_spawn='"from_waiting_room"', reach="1.3")
interact("DoorToTicketOffice", "door", (2.9, 0, -D / 2 + 0.35), reach="1.3",
         target_room='"res://levels/station/ticket_office.tscn"', target_spawn='"from_waiting_room"')
interact("Typewriter", "typewriter", (3.75, 0.8, 1.4), reach="1.4")
interact("Notice", "note", (1.4, 1.45, -D / 2 + 0.03), document=s.res("res://data/documents/station_notice.tres", "Resource"), reach="1.4")
s.node("Paper", None, "Interactables/Notice", instance=s.res("res://levels/kit/items/paper.tscn", "PackedScene"),
       rotation=v3((math.pi / 2, 0, 0.05)), scale=v3((1.6, 1.6, 1.6)))
interact("Clock", "examine_spot", (0.6, 0, D / 2 - 0.2), reach="1.6",
         lines=lines("Un reloj de pared. Se detuvo a las 7:12.", "Tiene un agujero de bala en el vidrio."))
interact("Vending", "examine_spot", (-3.6, 0, -2.6), reach="1.3",
         lines=lines("Una máquina de bebidas. Alguien rompió el vidrio y se llevó todo.", "Hay sangre seca en los bordes."))
interact("Ticket", "examine_spot", (-1.2, 0, -D / 2 + 0.45), reach="1.5",
         lines=lines("Las ventanillas tienen rejas.", "Adentro hay una lámpara encendida. Se entra por la puerta de SOLO PERSONAL."))
s.node("Sushi", "Node3D", "Interactables", position=v3((-1.0, 0.49, -1.0)), script=s.res(IA("pickup"), "Script"),
       item=s.res(ITEM("sushi"), "Resource"), model_rotation=v3((0, 0.4, 0)))
s.node("Ammo", "Node3D", "Interactables", position=v3((-3.55, 0.0, -1.9)), script=s.res(IA("pickup"), "Script"),
       item=s.res(ITEM("ammo_9mm"), "Resource"), count="15", model_rotation=v3((0, 0.9, 0)))

# --- Infectado comiendo junto a la máquina de bebidas -------------------
# Cony llega sin arma: se puede pasar por el lado este sin despertarlo.
s.node("Enemies", "Node3D", ".")
s.node("Feeding", None, "Enemies", instance=s.res("res://actors/enemies/infected.tscn", "PackedScene"),
       position=v3((-2.7, 0.05, -2.75)), rotation=v3((0, -math.pi / 2, 0)), start_state='"feeding"',
       data=s.res("res://data/enemies/infected_worker.tres", "Resource"))

# --- Cámaras fijas ------------------------------------------------------
s.node("Cameras", "Node3D", ".")
for name, zone_center, zone_size, cam_pos, target in [
        ("Entrance", (-2.0, 1.5, 0.0), (5.0, 3.0, 7.0), (2.4, 2.8, 3.15), (-2.6, 0.5, -0.9)),
        ("Desk", (2.5, 1.5, 0.0), (4.0, 3.0, 7.0), (-1.9, 2.8, 3.15), (3.0, 0.5, -0.9))]:
    s.node(name, "Area3D", "Cameras", position=v3(zone_center), script=s.res("res://levels/kit/camera_zone.gd", "Script"))
    s.node("Zone", "CollisionShape3D", "Cameras/" + name, shape=s.subres("BoxShape3D", {"size": v3(zone_size)}))
    rel = tuple(cam_pos[i] - zone_center[i] for i in range(3))
    s.node("Camera", "Camera3D", "Cameras/" + name, position=v3(rel), rotation=v3(look_rotation(cam_pos, target)),
           fov="62.0", near="0.1", far="30.0")

s.node("Spawns", "Node3D", ".")
s.node("from_platform", "Marker3D", "Spawns", position=v3((-2.5, 0.05, D / 2 - 0.9)))
s.node("from_ticket_office", "Marker3D", "Spawns", position=v3((2.9, 0.05, -D / 2 + 0.9)), rotation=v3((0, math.pi, 0)))
s.save(REPO + "/levels/station/waiting_room.tscn")
print("waiting room ok")
