import sys, math, os; sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
from tscn import *
OUT = REPO + "/levels/kit/items/"
TEX = lambda n: "res://assets/items/food/%s.png" % n

def tmat(s, tex, rough=0.7, scissor=False, color=None):
    d = {"albedo_texture": s.res(TEX(tex), "Texture2D"), "texture_filter": "0", "roughness": fmt(rough), "specular_mode": "2"}
    if scissor: d.update({"transparency": "2", "alpha_scissor_threshold": "0.5", "cull_mode": "2"})
    if color: d["albedo_color"] = col(color)
    return s.subres("StandardMaterial3D", d)

def cmat(s, c, rough=0.6):
    return s.subres("StandardMaterial3D", {"albedo_color": col(c), "roughness": fmt(rough), "specular_mode": "2"})

def mesh(s, name, parent, kind, props, material, pos, rot=None, scale=None):
    p = {"position": v3(pos)}
    if rot: p["rotation"] = v3(rot)
    if scale: p["scale"] = v3(scale)
    p["mesh"] = s.subres(kind, props); p["material_override"] = material
    s.node(name, "MeshInstance3D", parent, **p)

def cyl(r_top, r_bot, h, seg=12):
    return {"top_radius": fmt(r_top), "bottom_radius": fmt(r_bot), "height": fmt(h), "radial_segments": str(seg), "rings": "1"}

# --- Bandeja de sushi chileno: envueltos en palta, makis con nori, uno apanado,
#     jengibre y wasabi.
s = Scene(); s.node("Sushi", "Node3D")
tray = cmat(s, (0.03, 0.03, 0.03), 0.3)
nori, palta, tempura = tmat(s, "nori", 0.5), tmat(s, "avocado_wrap", 0.45), tmat(s, "tempura", 0.8)
maki_top, ura_top = tmat(s, "maki_section", 0.6, True), tmat(s, "uramaki_section", 0.6, True)
mesh(s, "Tray", ".", "BoxMesh", {"size": v3((0.2, 0.01, 0.13))}, tray, (0, 0.005, 0))
for i, (z, w) in enumerate(((0.064, 0.2), (-0.064, 0.2))):
    mesh(s, "RimZ%d" % i, ".", "BoxMesh", {"size": v3((w, 0.016, 0.004))}, tray, (0, 0.013, z))
for i, x in enumerate((0.099, -0.099)):
    mesh(s, "RimX%d" % i, ".", "BoxMesh", {"size": v3((0.004, 0.016, 0.13))}, tray, (x, 0.013, 0))
H = 0.026
pieces = [("Palta", palta, ura_top, -0.06, -0.03), ("Palta", palta, ura_top, -0.012, -0.03), ("Palta", palta, ura_top, 0.036, -0.03),
          ("Maki", nori, maki_top, -0.06, 0.028), ("Maki", nori, maki_top, -0.014, 0.028), ("Tempura", tempura, ura_top, 0.07, -0.028)]
for i, (kind, side, top, x, z) in enumerate(pieces):
    r = 0.021 if kind != "Tempura" else 0.022
    mesh(s, "%s%d" % (kind, i), ".", "CylinderMesh", cyl(r, r, H), side, (x, 0.01 + H / 2, z))
    mesh(s, "%s%dTop" % (kind, i), ".", "PlaneMesh", {"size": "Vector2(%s, %s)" % (fmt(r * 2.02), fmt(r * 2.02))}, top,
         (x, 0.0102 + H, z), rot=(0, i * 1.3, 0))
# Jengibre (láminas rosadas) y wasabi.
ginger = cmat(s, (0.98, 0.72, 0.68), 0.4)
for i in range(4):
    mesh(s, "Ginger%d" % i, ".", "CylinderMesh", cyl(0.012, 0.012, 0.002, 8), ginger, (0.045 + i * 0.004, 0.013 + i * 0.002, 0.03 + (i % 2) * 0.004), rot=(0.3, i * 0.8, 0.2))
mesh(s, "Wasabi", ".", "SphereMesh", {"radius": "0.009", "height": "0.012", "radial_segments": "8", "rings": "4"}, cmat(s, (0.55, 0.68, 0.25), 0.8),
     (0.078, 0.014, 0.034))
s.save(OUT + "sushi.tscn")

# --- Handroll: cono de alga con arroz, salmón, queso crema y palta asomando; papel con franja roja.
s = Scene(); s.node("Handroll", "Node3D")
nori, rice_top, paper = tmat(s, "nori", 0.5), tmat(s, "handroll_top", 0.6, True), tmat(s, "paper_sleeve", 0.9)
salmon, rice = tmat(s, "salmon", 0.4), tmat(s, "rice", 0.8)
cheese, avocado = cmat(s, (0.97, 0.96, 0.9), 0.6), tmat(s, "avocado_wrap", 0.45)
s.node("Roll", "Node3D", ".", position=v3((0, 0.05, 0)), rotation=v3((0.35, 0, -0.95)))
mesh(s, "Cone", "Roll", "CylinderMesh", cyl(0.037, 0.004, 0.16, 14), nori, (0, 0, 0))
mesh(s, "RiceRim", "Roll", "CylinderMesh", cyl(0.035, 0.035, 0.008, 14), rice, (0, 0.078, 0))
mesh(s, "Top", "Roll", "PlaneMesh", {"size": "Vector2(0.07, 0.07)"}, rice_top, (0, 0.0825, 0), rot=(0, 0.4, 0))
mesh(s, "Salmon", "Roll", "BoxMesh", {"size": v3((0.03, 0.035, 0.016))}, salmon, (-0.006, 0.095, -0.004), rot=(0.25, 0.2, 0.1))
mesh(s, "Cheese", "Roll", "BoxMesh", {"size": v3((0.012, 0.03, 0.014))}, cheese, (0.016, 0.092, 0.006), rot=(-0.15, 0.4, -0.1))
mesh(s, "Avocado", "Roll", "BoxMesh", {"size": v3((0.032, 0.028, 0.007))}, avocado, (-0.002, 0.092, 0.016), rot=(-0.35, 0.0, 0.05))
mesh(s, "Paper", "Roll", "CylinderMesh", cyl(0.0245, 0.0065, 0.09, 14), paper, (0, -0.035, 0))
s.save(OUT + "handroll.tscn")
print("food ok")
