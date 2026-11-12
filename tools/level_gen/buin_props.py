import sys, math, os; sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
from tscn import *
# Piezas del capítulo 3 (Buin): control militar, viña y galpón.
# También crea los materiales nuevos (oliva militar, lona, sacos, tierra, vino).
KB = "res://levels/kit/kit_block.gd"
M = lambda n: "res://levels/kit/materials/%s.tres" % n
OUT = REPO + "/levels/kit/props/"
TEX = "res://assets/environment/textures/%s.png"

MATERIALS = {
    # nombre: (textura, tinte, metros por repetición, suciedad)
    "olive": ("metal", (0.36, 0.4, 0.24), 1.5, 0.4),
    "canvas": ("plaster", (0.58, 0.52, 0.38), 1.2, 0.35),
    "sandbag": ("plaster", (0.62, 0.55, 0.42), 0.5, 0.5),
    "dirt": ("gravel", (0.62, 0.5, 0.38), 1.6, 0.2),
    "barrel_wood": ("wood", (0.62, 0.42, 0.28), 0.8, 0.3),
}
for name, (tex, tint, tile, grime) in MATERIALS.items():
    with open(REPO + "/levels/kit/materials/%s.tres" % name, "w") as f:
        f.write('[gd_resource type="ShaderMaterial" format=3]\n\n'
                '[ext_resource type="Shader" path="res://shaders/ps1_surface.gdshader" id="1_shader"]\n'
                '[ext_resource type="Texture2D" path="%s" id="2_tex"]\n\n'
                '[resource]\nrender_priority = 0\nshader = ExtResource("1_shader")\n'
                'shader_parameter/albedo_tex = ExtResource("2_tex")\n'
                'shader_parameter/tint = Color(%s, %s, %s, 1)\n'
                'shader_parameter/tile_meters = %s\n'
                'shader_parameter/grime_strength = %s\n'
                'shader_parameter/macro_strength = 0.3\n' % ((TEX % tex,) + tuple(fmt(c) for c in tint) + (fmt(tile), fmt(grime))))


# Cielo nublado de la mañana y agua del río: sin luz (siempre se ven igual).
for name, c in {"sky_dawn": (0.62, 0.64, 0.7), "river": (0.24, 0.21, 0.16)}.items():
    with open(REPO + "/levels/kit/materials/%s.tres" % name, "w") as f:
        f.write('[gd_resource type="StandardMaterial3D" format=3]\n\n[resource]\nshading_mode = 0\n'
                'albedo_color = Color(%s, %s, %s, 1)\n' % tuple(fmt(v) for v in c))


def blk(s, name, pos, size, mat, solid=True, rot=None, parent="."):
    p = {"position": v3(pos)}
    if rot: p["rotation"] = v3(rot)
    p.update({"script": s.res(KB, "Script"), "size": v3(size), "surface": s.res(M(mat), "Material")})
    if not solid: p["solid"] = "false"
    s.node(name, "StaticBody3D", parent, **p)

def cyl(s, name, pos, r_top, r_bot, h, mat, seg=10, rot=None, parent="."):
    p = {"position": v3(pos)}
    if rot: p["rotation"] = v3(rot)
    p["mesh"] = s.subres("CylinderMesh", {"top_radius": fmt(r_top), "bottom_radius": fmt(r_bot), "height": fmt(h),
                                           "radial_segments": str(seg), "rings": "1"})
    p["material_override"] = mat if mat.startswith("SubResource") else s.res(M(mat), "Material")
    s.node(name, "MeshInstance3D", parent, **p)

def emissive(s, c, e):
    return s.subres("StandardMaterial3D", {"albedo_color": col(c), "emission_enabled": "true", "emission": col(c), "emission_energy_multiplier": fmt(e)})

def foliage(s):
    return s.subres("StandardMaterial3D", {"albedo_texture": s.res("res://assets/environment/station/foliage.png", "Texture2D"),
                                           "texture_filter": "0", "transparency": "2", "alpha_scissor_threshold": "0.5", "cull_mode": "2"})

# --- Muro de sacos de arena (2,4 m de largo, 1 m de alto). Frente hacia +Z.
s = Scene(); s.node("Sandbags", "Node3D")
blk(s, "Collision", (0, 0.5, 0), (2.4, 1.0, 0.7), "sandbag")
s.nodes[-1][1]["visible"] = "false"
for row in range(4):
    off = 0.15 if row % 2 else 0.0
    for i in range(4):
        x = -0.9 + i * 0.6 + off
        if x > 1.0: continue
        blk(s, "Bag%d_%d" % (row, i), (x, 0.13 + row * 0.25, -0.02 * row), (0.58, 0.24, 0.62 - row * 0.04), "sandbag",
            solid=False, rot=(0, 0.04 * ((i + row) % 3 - 1), 0))
s.save(OUT + "sandbags.tscn")

# --- Carpa militar (4 x 3 m), abierta por el frente (+Z).
s = Scene(); s.node("ArmyTent", "Node3D")
for side in (1, -1):
    blk(s, "Roof%s" % ("L" if side > 0 else "R"), (side * 1.0, 2.0, 0), (2.3, 0.05, 3.0), "canvas", solid=False, rot=(0, 0, side * 0.55))
    blk(s, "Wall%s" % ("L" if side > 0 else "R"), (side * 1.95, 0.75, 0), (0.05, 1.5, 3.0), "canvas")
blk(s, "Back", (0, 1.2, -1.5), (3.9, 2.4, 0.05), "canvas")
blk(s, "Ridge", (0, 2.55, 0), (0.08, 0.08, 3.1), "wood", solid=False)
for z in (-1.45, 1.45):
    blk(s, "Pole%s" % ("B" if z < 0 else "F"), (0, 1.3, z), (0.07, 2.6, 0.07), "wood", solid=False)
blk(s, "Cot", (-1.2, 0.3, -0.3), (0.7, 0.12, 1.8), "olive", solid=False)
blk(s, "Table", (0.8, 0.72, -0.9), (1.2, 0.05, 0.7), "barrel_wood")
blk(s, "TableLegs", (0.8, 0.36, -0.9), (1.1, 0.7, 0.6), "metal")
s.nodes[-1][1]["visible"] = "false"
s.save(OUT + "army_tent.tscn")

# --- Camión militar (6 m), mirando a +X.
s = Scene(); s.node("ArmyTruck", "Node3D")
blk(s, "Chassis", (0, 0.75, 0), (5.8, 0.35, 2.1), "olive")
blk(s, "Cab", (2.2, 1.55, 0), (1.5, 1.3, 2.1), "olive")
blk(s, "Windshield", (2.96, 1.75, 0), (0.04, 0.6, 1.8), "metal", solid=False)
blk(s, "Hood", (2.95, 1.1, 0), (0.4, 0.5, 1.9), "olive", solid=False)
blk(s, "Bed", (-0.8, 1.15, 0), (4.0, 0.45, 2.1), "olive")
for side in (1, -1):
    blk(s, "Cover%s" % ("L" if side > 0 else "R"), (-0.8, 2.0, side * 0.75), (4.0, 0.05, 0.75), "canvas", solid=False, rot=(side * 0.45, 0, 0))
    blk(s, "CoverSide%s" % ("L" if side > 0 else "R"), (-0.8, 1.7, side * 1.04), (4.0, 0.7, 0.04), "canvas", solid=False)
    for x in (-2.2, -0.9, 2.2):
        cyl(s, "Wheel%s%s" % ("L" if side > 0 else "R", fmt(x).replace("-", "m").replace(".", "_")), (x, 0.48, side * 1.0), 0.48, 0.48, 0.32, "rust", seg=12, rot=(math.pi / 2, 0, 0))
s.save(OUT + "army_truck.tscn")

# --- Barrera de control (pluma roja y blanca) sobre un poste. Pluma a lo largo de +X.
s = Scene(); s.node("Barrier", "Node3D")
blk(s, "Post", (0, 0.55, 0), (0.25, 1.1, 0.25), "olive")
for i in range(6):
    blk(s, "Arm%d" % i, (0.35 + i * 0.5, 1.0, 0), (0.5, 0.1, 0.1), "paint_red" if i % 2 == 0 else "train_cream", solid=False)
s.save(OUT + "barrier.tscn")

# --- Hilera de parras (6 m a lo largo de X): postes, alambre y follaje.
s = Scene(); s.node("VineRow", "Node3D")
leaf = foliage(s)
blk(s, "Collision", (0, 0.6, 0), (6.0, 1.2, 0.4), "wood")
s.nodes[-1][1]["visible"] = "false"
for i in range(4):
    blk(s, "Post%d" % i, (-3.0 + i * 2.0, 0.8, 0), (0.08, 1.6, 0.08), "wood", solid=False)
for y in (0.9, 1.4):
    blk(s, "Wire%s" % fmt(y).replace(".", "_"), (0, y, 0), (6.0, 0.015, 0.015), "metal", solid=False)
for i in range(9):
    x = -2.7 + i * 0.68
    for j, r in enumerate((0.0, math.pi / 2)):
        s.node("Leaves%d_%d" % (i, j), "MeshInstance3D", ".", position=v3((x, 1.15, 0)), rotation=v3((0, r + i * 0.4, 0)),
               mesh=s.subres("QuadMesh", {"size": "Vector2(0.9, 0.85)"}), material_override=leaf)
    blk(s, "Trunk%d" % i, (x, 0.45, 0), (0.06, 0.9, 0.06), "barrel_wood", solid=False, rot=(0, 0, 0.1 * (i % 3 - 1)))
s.save(OUT + "vine_row.tscn")

# --- Barrica de vino (1 m) acostada a lo largo de X.
s = Scene(); s.node("WineBarrel", "Node3D")
cyl(s, "Body", (0, 0.45, 0), 0.42, 0.42, 1.0, "barrel_wood", seg=12, rot=(0, 0, math.pi / 2))
for x in (-0.38, 0.38):
    cyl(s, "Hoop%s" % ("L" if x < 0 else "R"), (x, 0.45, 0), 0.435, 0.435, 0.05, "metal", seg=12, rot=(0, 0, math.pi / 2))
blk(s, "Collision", (0, 0.45, 0), (1.0, 0.9, 0.85), "barrel_wood")
s.nodes[-1][1]["visible"] = "false"
blk(s, "Cradle", (0, 0.06, 0), (0.9, 0.12, 0.7), "wood", solid=False)
s.save(OUT + "wine_barrel.tscn")

# --- Tractor viejo (3 m), mirando a +X.
s = Scene(); s.node("Tractor", "Node3D")
blk(s, "Body", (0.3, 0.95, 0), (2.2, 0.7, 0.9), "paint_red")
blk(s, "Hood", (1.1, 1.1, 0), (0.9, 0.5, 0.7), "paint_red", solid=False)
blk(s, "Seat", (-0.5, 1.45, 0), (0.45, 0.1, 0.45), "seat_fabric", solid=False)
blk(s, "Wheel", (-0.6, 0.2, 0), (0.1, 0.1, 0.1), "rust", solid=False)
for side in (1, -1):
    cyl(s, "BigWheel%s" % ("L" if side > 0 else "R"), (-0.6, 0.7, side * 0.7), 0.7, 0.7, 0.35, "rust", seg=12, rot=(math.pi / 2, 0, 0))
    cyl(s, "SmallWheel%s" % ("L" if side > 0 else "R"), (1.2, 0.4, side * 0.55), 0.4, 0.4, 0.22, "rust", seg=10, rot=(math.pi / 2, 0, 0))
blk(s, "Collision", (0.2, 0.8, 0), (2.8, 1.6, 1.7), "rust")
s.nodes[-1][1]["visible"] = "false"
cyl(s, "Exhaust", (0.9, 1.75, 0.25), 0.04, 0.04, 0.8, "metal")
s.save(OUT + "tractor.tscn")

# --- Radio militar sobre una mesa (frente hacia +Z): dial encendido.
s = Scene(); s.node("FieldRadio", "Node3D")
blk(s, "Box", (0, 0.15, 0), (0.5, 0.3, 0.3), "olive", solid=False)
blk(s, "Panel", (0, 0.17, 0.152), (0.42, 0.2, 0.01), "metal", solid=False)
s.node("Dial", "MeshInstance3D", ".", position=v3((-0.1, 0.19, 0.16)),
       mesh=s.subres("BoxMesh", {"size": "Vector3(0.14, 0.06, 0.01)"}), material_override=emissive(s, (0.4, 1.0, 0.45), 1.6))
blk(s, "Antenna", (0.2, 0.55, -0.08), (0.015, 0.8, 0.015), "metal", solid=False, rot=(0, 0, -0.15))
blk(s, "Handset", (-0.32, 0.06, 0.05), (0.08, 0.06, 0.22), "rust", solid=False)
s.save(OUT + "field_radio.tscn")
print("props de Buin ok")
