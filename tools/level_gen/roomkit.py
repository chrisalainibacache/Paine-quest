# Utilidades compartidas para armar salas (genera .tscn legibles).
import math
from tscn import *
KB = "res://levels/kit/kit_block.gd"
M = lambda n: "res://levels/kit/materials/%s.tres" % n
PROP = lambda n: "res://levels/kit/props/%s.tscn" % n
ITEM = lambda n: "res://data/items/%s.tres" % n
DOC = lambda n: "res://data/documents/%s.tres" % n
IA = lambda n: "res://levels/kit/interact/%s.gd" % n
INF = "res://actors/enemies/infected.tscn"

class Kit:
    def __init__(self, root_name, room_name, dark=False, intro=None):
        self.s = Scene()
        extra = {"dark": "true"} if dark else {}
        if intro:
            extra["intro_lines"] = "PackedStringArray(%s)" % ", ".join('"%s"' % l for l in intro)
        self.s.node(root_name, "Node3D", script=self.s.res("res://levels/kit/room.gd", "Script"), room_name='"%s"' % room_name, **extra)
        for n in ("Interactables", "Enemies", "Cameras", "Spawns"):
            pass
        self._groups = set()

    def group(self, name, parent="."):
        if (parent, name) not in self._groups:
            self.s.node(name, "Node3D", parent)
            self._groups.add((parent, name))

    def env(self, bg, ambient, energy, fog, fog_density):
        e = self.s.subres("Environment", {"background_mode": "1", "background_color": col(bg),
            "ambient_light_source": "2", "ambient_light_color": col(ambient), "ambient_light_energy": fmt(energy),
            "fog_enabled": "true", "fog_light_color": col(fog), "fog_density": fmt(fog_density)})
        self.s.node("Environment", "WorldEnvironment", ".", environment=e)

    def block(self, name, parent, pos, size, mat, solid=True, rot=None):
        self.group(parent) if "/" not in parent and parent != "." else None
        p = {"position": v3(pos)}
        if rot: p["rotation"] = v3(rot)
        p.update({"script": self.s.res(KB, "Script"), "size": v3(size), "surface": self.s.res(M(mat), "Material")})
        if not solid: p["solid"] = "false"
        self.s.node(name, "StaticBody3D", parent, **p)

    def prop(self, name, parent, scene, pos, rot=None, **extra):
        self.group(parent) if "/" not in parent and parent != "." else None
        p = {"position": v3(pos)}
        if rot: p["rotation"] = v3(rot)
        p.update(extra)
        self.s.node(name, None, parent, instance=self.s.res(PROP(scene), "PackedScene"), **p)

    def mesh(self, name, parent, size, material, pos, rot=None):
        self.group(parent) if "/" not in parent and parent != "." else None
        p = {"position": v3(pos)}
        if rot: p["rotation"] = v3(rot)
        p["mesh"] = self.s.subres("BoxMesh", {"size": v3(size)})
        p["material_override"] = material
        self.s.node(name, "MeshInstance3D", parent, **p)

    def emissive(self, color, energy):
        return self.s.subres("StandardMaterial3D", {"albedo_color": col(color), "emission_enabled": "true",
                                                    "emission": col(color), "emission_energy_multiplier": fmt(energy)})

    def light(self, name, parent, pos, color, energy, rng, flicker=False):
        self.group(parent) if "/" not in parent and parent != "." else None
        p = {"position": v3(pos), "light_color": col(color), "light_energy": fmt(energy), "omni_range": fmt(rng)}
        if flicker: p["script"] = self.s.res("res://levels/kit/flicker_light.gd", "Script")
        self.s.node(name, "OmniLight3D", parent, **p)

    def label(self, name, parent, pos, text, size, color, rot=None):
        self.group(parent) if "/" not in parent and parent != "." else None
        p = {"position": v3(pos)}
        if rot: p["rotation"] = v3(rot)
        p.update({"text": '"%s"' % text, "font_size": str(size), "pixel_size": "0.004", "modulate": col(color), "outline_size": "0"})
        self.s.node(name, "Label3D", parent, **p)

    # --- Interactuables
    def door(self, name, pos, target_room, target_spawn, key=None, lock_id="", locked_text=None, prompt=None, reach=1.3):
        self.group("Interactables")
        p = {"position": v3(pos), "script": self.s.res(IA("door"), "Script"), "reach": fmt(reach)}
        if target_room: p["target_room"] = '"%s"' % target_room
        if target_spawn: p["target_spawn"] = '"%s"' % target_spawn
        if key: p["key_item"] = self.s.res(ITEM(key), "Resource")
        if lock_id: p["lock_id"] = '"%s"' % lock_id
        if locked_text: p["locked_text"] = '"%s"' % locked_text
        if prompt: p["prompt"] = '"%s"' % prompt
        self.s.node(name, "Node3D", "Interactables", **p)

    def pickup(self, name, pos, item, count=1, rot=(0, 0, 0), sets_flag=None):
        self.group("Interactables")
        p = {"position": v3(pos), "script": self.s.res(IA("pickup"), "Script"), "item": self.s.res(ITEM(item), "Resource"),
             "count": str(count), "model_rotation": v3(rot)}
        if sets_flag: p["sets_flag"] = '"%s"' % sets_flag
        self.s.node(name, "Node3D", "Interactables", **p)

    def note(self, name, pos, doc, paper_rot=(0, 0, 0), paper_scale=1.0, reach=1.4):
        self.group("Interactables")
        self.s.node(name, "Node3D", "Interactables", position=v3(pos), script=self.s.res(IA("note"), "Script"),
                    document=self.s.res(DOC(doc), "Resource"), reach=fmt(reach))
        extra = {"scale": v3((paper_scale,) * 3)} if paper_scale != 1.0 else {}
        self.s.node("Paper", None, "Interactables/" + name, instance=self.s.res("res://levels/kit/items/paper.tscn", "PackedScene"),
                    rotation=v3(paper_rot), **extra)

    def examine(self, name, pos, lines, reach=1.4):
        self.group("Interactables")
        self.s.node(name, "Node3D", "Interactables", position=v3(pos), script=self.s.res(IA("examine_spot"), "Script"),
                    reach=fmt(reach), lines="PackedStringArray(%s)" % ", ".join('"%s"' % t for t in lines))

    def interact(self, name, script, pos, **props):
        self.group("Interactables")
        self.s.node(name, "Node3D", "Interactables", position=v3(pos), script=self.s.res(IA(script), "Script"), **props)

    # --- Infectados
    def infected(self, name, pos, yaw=0.0, state="idle", heavy=False, requires_flag=None, kind=None):
        self.group("Enemies")
        p = {"position": v3(pos)}
        if yaw: p["rotation"] = v3((0, yaw, 0))
        if heavy: kind = "infected_heavy"
        if kind: p["data"] = self.s.res("res://data/enemies/%s.tres" % kind, "Resource")
        if state != "idle": p["start_state"] = '"%s"' % state
        if requires_flag: p["requires_flag"] = '"%s"' % requires_flag
        self.s.node(name, None, "Enemies", instance=self.s.res(INF, "PackedScene"), **p)

    # --- Cámaras y apariciones
    def camera(self, name, zone_center, zone_size, cam_pos, target, fov=60.0, priority=0):
        self.group("Cameras")
        p = {"position": v3(zone_center), "script": self.s.res("res://levels/kit/camera_zone.gd", "Script")}
        if priority: p["camera_priority"] = str(priority)
        self.s.node(name, "Area3D", "Cameras", **p)
        self.s.node("Zone", "CollisionShape3D", "Cameras/" + name, shape=self.s.subres("BoxShape3D", {"size": v3(zone_size)}))
        rel = tuple(cam_pos[i] - zone_center[i] for i in range(3))
        self.s.node("Camera", "Camera3D", "Cameras/" + name, position=v3(rel), rotation=v3(look_rotation(cam_pos, target)),
                    fov=fmt(float(fov)), near="0.1", far="30.0")

    def spawn(self, name, pos, facing):
        """facing: dirección hacia donde mira Cony al aparecer (vector XZ)."""
        self.group("Spawns")
        # El marcador mira hacia -Z; su giro debe apuntar -Z hacia `facing`.
        yaw = math.atan2(-facing[0], -facing[1])
        self.s.node(name, "Marker3D", "Spawns", position=v3(pos), rotation=v3((0, yaw, 0)))

    # --- Caja cerrada (piso, cielo y 4 muros) con zócalo opcional
    def shell(self, x0, x1, z0, z1, h, floor="concrete_floor", wall="plaster_wall", ceiling="concrete_wall", wainscot=None, walls=None):
        W, D = x1 - x0, z1 - z0
        cx, cz = (x0 + x1) / 2, (z0 + z1) / 2
        walls = walls or {}
        self.block("Floor", "Shell", (cx, -0.5, cz), (W + 0.6, 1, D + 0.6), floor)
        if ceiling:
            self.block("Ceiling", "Shell", (cx, h + 0.05, cz), (W + 0.6, 0.1, D + 0.6), ceiling)
        self.block("NorthWall", "Shell", (cx, h / 2, z0 - 0.15), (W + 0.6, h, 0.3), walls.get("N", wall))
        self.block("SouthWall", "Shell", (cx, h / 2, z1 + 0.15), (W + 0.6, h, 0.3), walls.get("S", wall))
        self.block("WestWall", "Shell", (x0 - 0.15, h / 2, cz), (0.3, h, D), walls.get("W", wall))
        self.block("EastWall", "Shell", (x1 + 0.15, h / 2, cz), (0.3, h, D), walls.get("E", wall))
        if wainscot:
            for n, pos, size in [("N", (cx, 0.6, z0 + 0.02), (W, 1.2, 0.04)), ("S", (cx, 0.6, z1 - 0.02), (W, 1.2, 0.04)),
                                 ("W", (x0 + 0.02, 0.6, cz), (0.04, 1.2, D)), ("E", (x1 - 0.02, 0.6, cz), (0.04, 1.2, D))]:
                self.block("Wainscot" + n, "Shell", pos, size, wainscot, solid=False)

    def door_frame(self, name, x, z, axis, width=1.1, wall_side=1, panel="planks"):
        """Puerta dibujada en un muro. axis 'x' = muro a lo largo de X (norte/sur); 'z' = muro este/oeste.
        wall_side: hacia dónde queda la sala respecto del muro (+1/-1) para separar del muro."""
        g = "Doors"
        off = 0.04 * wall_side
        if axis == "x":
            self.block(name + "Panel", g, (x, 1.1, z + off), (width, 2.2, 0.06), panel, solid=False)
            self.block(name + "FrameL", g, (x - width / 2 - 0.06, 1.2, z + off * 1.5), (0.1, 2.4, 0.1), "wood", solid=False)
            self.block(name + "FrameR", g, (x + width / 2 + 0.06, 1.2, z + off * 1.5), (0.1, 2.4, 0.1), "wood", solid=False)
            self.block(name + "Lintel", g, (x, 2.45, z + off * 1.5), (width + 0.22, 0.1, 0.1), "wood", solid=False)
        else:
            self.block(name + "Panel", g, (x + off, 1.1, z), (0.06, 2.2, width), panel, solid=False)
            self.block(name + "FrameL", g, (x + off * 1.5, 1.2, z - width / 2 - 0.06), (0.1, 2.4, 0.1), "wood", solid=False)
            self.block(name + "FrameR", g, (x + off * 1.5, 1.2, z + width / 2 + 0.06), (0.1, 2.4, 0.1), "wood", solid=False)
            self.block(name + "Lintel", g, (x + off * 1.5, 2.45, z), (0.1, 0.1, width + 0.22), "wood", solid=False)

    def save(self, path):
        self.s.save(path)


# --- Calcomanías (grafitis, sangre, hoyos, manchas) -----------------------
DECAL_SCENE = "res://levels/kit/props/decal.tscn"
DECAL_TEX = lambda n: ("res://assets/environment/graffiti/%s.png" % n) if (n.startswith("graffiti") or n.startswith("mural")) \
    else "res://assets/environment/decals/%s.png" % n
NORMALS = {"+z": (0.0, 0.0), "-z": (0.0, math.pi), "+x": (0.0, math.pi / 2), "-x": (0.0, -math.pi / 2)}

def add_decal(s, parent, name, tex, pos, size, normal, rot=0.0, tint=None, opacity=1.0, wear=0.0):
    """normal: hacia dónde mira la calcomanía (+z, -z, +x, -x) o 'up' para el piso (rot = giro en el piso)."""
    if isinstance(size, (int, float)):
        size = (size, size)
    if normal == "up":
        r = (-math.pi / 2, rot, 0.0)
    else:
        r = (NORMALS[normal][0], NORMALS[normal][1], rot)
    p = {"position": v3(pos), "rotation": v3(r), "texture": s.res(DECAL_TEX(tex), "Texture2D"), "size": "Vector2(%s, %s)" % (fmt(float(size[0])), fmt(float(size[1])))}
    if tint: p["tint"] = col(tint)
    if opacity != 1.0: p["opacity"] = fmt(float(opacity))
    if wear: p["wear"] = fmt(float(wear))
    s.node(name, None, parent, instance=s.res(DECAL_SCENE, "PackedScene"), **p)

def decal(self, name, tex, pos, size, normal, rot=0.0, tint=None, opacity=1.0, wear=0.0):
    self.group("Decals")
    add_decal(self.s, "Decals", name, tex, pos, size, normal, rot, tint, opacity, wear)

Kit.decal = decal
