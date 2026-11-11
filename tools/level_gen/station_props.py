import sys, math, os; sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
from tscn import *
# Detalle de arquitectura de la estación (inspirado en la estación real de
# Paine): columnas de fierro fundido, bancas de fierro y madera, faroles de
# pared, arcos de ventana, afiche turístico y maceteros.
KB = "res://levels/kit/kit_block.gd"
M = lambda n: "res://levels/kit/materials/%s.tres" % n
OUT = REPO + "/levels/kit/props/"

def blk(s, name, pos, size, mat, solid=True, rot=None, parent="."):
    p = {"position": v3(pos)}
    if rot: p["rotation"] = v3(rot)
    p.update({"script": s.res(KB, "Script"), "size": v3(size), "surface": s.res(M(mat), "Material")})
    if not solid: p["solid"] = "false"
    s.node(name, "StaticBody3D", parent, **p)

def cyl(s, name, pos, r_top, r_bot, h, mat, seg=8, rot=None, parent="."):
    p = {"position": v3(pos)}
    if rot: p["rotation"] = v3(rot)
    p["mesh"] = s.subres("CylinderMesh", {"top_radius": fmt(r_top), "bottom_radius": fmt(r_bot), "height": fmt(h),
                                           "radial_segments": str(seg), "rings": "1"})
    p["material_override"] = mat if mat.startswith("SubResource") else s.res(M(mat), "Material")
    s.node(name, "MeshInstance3D", parent, **p)

def emissive(s, c, e):
    return s.subres("StandardMaterial3D", {"albedo_color": col(c), "emission_enabled": "true", "emission": col(c), "emission_energy_multiplier": fmt(e)})

# --- Columna de fierro fundido (3,44 m hasta la viga), con ménsulas al techo.
s = Scene(); s.node("IronColumn", "Node3D")
blk(s, "Plinth", (0, 0.15, 0), (0.38, 0.3, 0.38), "iron_green")
blk(s, "Collision", (0, 1.72, 0), (0.2, 3.44, 0.2), "iron_green")
s.nodes[-1][1]["visible"] = "false"
cyl(s, "BaseMould", (0, 0.36, 0), 0.12, 0.17, 0.14, "iron_green")
cyl(s, "Shaft", (0, 1.75, 0), 0.085, 0.1, 2.7, "iron_green")
for i, y in enumerate((0.9, 2.6)):
    cyl(s, "Ring%d" % i, (0, y, 0), 0.115, 0.115, 0.06, "iron_green")
cyl(s, "Capital", (0, 3.2, 0), 0.2, 0.1, 0.24, "iron_green")
blk(s, "Abacus", (0, 3.36, 0), (0.42, 0.08, 0.42), "iron_green", solid=False)
for side in (1, -1):
    blk(s, "Bracket%s" % ("F" if side > 0 else "B"), (0, 2.95, side * 0.42), (0.05, 0.05, 0.95), "iron_green", solid=False, rot=(side * 0.62, 0, 0))
    blk(s, "BracketRib%s" % ("F" if side > 0 else "B"), (0, 3.25, side * 0.5), (0.04, 0.04, 0.85), "iron_green", solid=False)
s.save(OUT + "iron_column.tscn")

# --- Banca de andén: costados de fierro y tablas separadas (frente hacia +Z).
s = Scene(); s.node("ParkBench", "Node3D")
for i, x in enumerate((-0.72, 0.72)):
    blk(s, "LegFront%d" % i, (x, 0.22, 0.17), (0.05, 0.44, 0.05), "iron_green", solid=False)
    blk(s, "LegBack%d" % i, (x, 0.42, -0.2), (0.05, 0.84, 0.05), "iron_green", solid=False, rot=(-0.12, 0, 0))
    blk(s, "Arm%d" % i, (x, 0.64, 0.0), (0.06, 0.04, 0.45), "iron_green", solid=False)
for j in range(4):
    blk(s, "Slat%d" % j, (0, 0.45, -0.15 + j * 0.105), (1.6, 0.035, 0.08), "wood", solid=(j == 1))
for j in range(3):
    blk(s, "BackSlat%d" % j, (0, 0.6 + j * 0.12, -0.24 - j * 0.015), (1.6, 0.07, 0.03), "wood", solid=False, rot=(-0.12, 0, 0))
s.save(OUT + "park_bench.tscn")

# --- Farol de pared (vidrio encendido, sin luz dinámica para cuidar el rendimiento).
s = Scene(); s.node("WallLantern", "Node3D")
blk(s, "Arm", (0, 0.05, 0.16), (0.04, 0.04, 0.32), "iron_green", solid=False)
blk(s, "Cap", (0, 0.02, 0.34), (0.16, 0.05, 0.16), "iron_green", solid=False)
s.node("Glass", "MeshInstance3D", ".", position=v3((0, -0.12, 0.34)), mesh=s.subres("BoxMesh", {"size": v3((0.12, 0.22, 0.12))}),
       material_override=emissive(s, (1.0, 0.78, 0.45), 1.6))
blk(s, "Bottom", (0, -0.25, 0.34), (0.1, 0.04, 0.1), "iron_green", solid=False)
s.save(OUT + "wall_lantern.tscn")

# --- Arco de ventana o puerta: medio círculo de marco rojo con vidrio adentro
#     (se pega al muro; el arco mira hacia +Z).
s = Scene(); s.node("WindowArch", "Node3D")
cyl(s, "Frame", (0, 0, 0.02), 0.66, 0.66, 0.06, "paint_red", seg=16, rot=(math.pi / 2, 0, 0))
cyl(s, "Glass", (0, 0, 0.04), 0.57, 0.57, 0.04, emissive(s, (0.09, 0.06, 0.03), 0.6), seg=16, rot=(math.pi / 2, 0, 0))
for i in range(3):
    a = math.pi * (0.25 + i * 0.25)
    blk(s, "Muntin%d" % i, (math.cos(a) * 0.28, math.sin(a) * 0.28, 0.06), (0.025, 0.56, 0.02), "iron_green", solid=False,
        rot=(0, 0, a - math.pi / 2))
s.save(OUT + "window_arch.tscn")

# --- Afiche turístico de Paine (marco de madera).
s = Scene(); s.node("TravelPoster", "Node3D")
blk(s, "Frame", (0, 0, 0.0), (0.92, 1.32, 0.04), "wood", solid=False)
poster = s.subres("StandardMaterial3D", {"albedo_texture": s.res("res://assets/environment/station/poster_paine.png", "Texture2D"),
                                         "texture_filter": "0", "roughness": "0.9"})
s.node("Print", "MeshInstance3D", ".", position=v3((0, 0, 0.022)), mesh=s.subres("QuadMesh", {"size": "Vector2(0.84, 1.24)"}),
       material_override=poster)
s.node("Name", "Label3D", ".", position=v3((0, 0.44, 0.03)), text='"Paine"', font_size="96", pixel_size="0.0025",
       modulate=col((0.12, 0.22, 0.5)), outline_size="0", italic="true")
s.save(OUT + "travel_poster.tscn")

# --- Macetero de concreto con planta.
s = Scene(); s.node("PlantPot", "Node3D")
cyl(s, "Pot", (0, 0.3, 0), 0.26, 0.2, 0.6, "concrete_wall", seg=10)
blk(s, "Collision", (0, 0.3, 0), (0.42, 0.6, 0.42), "concrete_wall")
s.nodes[-1][1]["visible"] = "false"
cyl(s, "Soil", (0, 0.6, 0), 0.24, 0.24, 0.02, "gravel", seg=10)
leaf = s.subres("StandardMaterial3D", {"albedo_texture": s.res("res://assets/environment/station/foliage.png", "Texture2D"),
                                       "texture_filter": "0", "transparency": "2", "alpha_scissor_threshold": "0.5", "cull_mode": "2"})
for i in range(4):
    s.node("Leaves%d" % i, "MeshInstance3D", ".", position=v3((0, 0.98, 0)), rotation=v3((0, i * math.pi / 4, 0)),
           mesh=s.subres("QuadMesh", {"size": "Vector2(0.85, 0.8)"}), material_override=leaf)
s.save(OUT + "plant_pot.tscn")
print("station props ok")
