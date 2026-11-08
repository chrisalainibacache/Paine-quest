import sys, math, os; sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
from tscn import *
OUT = REPO + "/levels/kit/items/"

def mat(s, c, rough=0.85, metal=0.0):
    return s.subres("StandardMaterial3D", {"albedo_color": col(c), "roughness": fmt(rough), "metallic": fmt(metal),
                                           "specular_mode": "2" if metal == 0 else "0"})

def mesh(s, name, parent, kind, props, material, pos=(0, 0, 0), rot=None):
    m = s.subres(kind, props)
    p = {"position": v3(pos)}
    if rot: p["rotation"] = v3(rot)
    p["mesh"] = m
    p["material_override"] = material
    s.node(name, "MeshInstance3D", parent, **p)

def box(s, name, parent, size, material, pos, rot=None):
    mesh(s, name, parent, "BoxMesh", {"size": v3(size)}, material, pos, rot)

def cyl(s, name, parent, r_top, r_bot, h, material, pos, rot=None, seg=10):
    mesh(s, name, parent, "CylinderMesh", {"top_radius": fmt(r_top), "bottom_radius": fmt(r_bot), "height": fmt(h),
                                           "radial_segments": str(seg), "rings": "1"}, material, pos, rot)

# --- Caja de balas 9 mm
s = Scene(); s.node("AmmoBox", "Node3D")
card = mat(s, (0.24, 0.27, 0.17)); label = mat(s, (0.78, 0.64, 0.26)); brass = mat(s, (0.78, 0.6, 0.3), 0.4, 0.8)
dark = mat(s, (0.08, 0.08, 0.07))
box(s, "Box", ".", (0.14, 0.07, 0.09), card, (0, 0.035, 0))
box(s, "Label", ".", (0.1, 0.035, 0.0915), label, (0.0, 0.037, 0))
box(s, "Text", ".", (0.06, 0.008, 0.092), dark, (0.0, 0.04, 0))
box(s, "Lid", ".", (0.14, 0.004, 0.09), card, (0, 0.105, -0.07), rot=(-1.2, 0, 0))
for i in range(5):
    cyl(s, "Bullet%d" % i, ".", 0.003, 0.0055, 0.03, brass, (-0.05 + i * 0.025, 0.08, 0.02 - (i % 2) * 0.025), seg=6)
s.save(OUT + "ammo_box.tscn")

# --- Sushi (bandeja con 3 piezas)
s = Scene(); s.node("Sushi", "Node3D")
tray = mat(s, (0.05, 0.05, 0.05), 0.4); rice = mat(s, (0.93, 0.91, 0.85)); nori = mat(s, (0.07, 0.11, 0.07))
salmon = mat(s, (0.96, 0.46, 0.26), 0.5); avocado = mat(s, (0.55, 0.7, 0.25))
box(s, "Tray", ".", (0.2, 0.012, 0.09), tray, (0, 0.006, 0))
box(s, "TrayRim", ".", (0.205, 0.02, 0.003), tray, (0, 0.01, 0.045))
for i, x in enumerate((-0.06, 0.0, 0.06)):
    cyl(s, "Rice%d" % i, ".", 0.024, 0.024, 0.036, rice, (x, 0.03, 0))
    cyl(s, "Nori%d" % i, ".", 0.0262, 0.0262, 0.032, nori, (x, 0.028, 0))
    cyl(s, "Fill%d" % i, ".", 0.011, 0.011, 0.038, salmon if i != 1 else avocado, (x, 0.031, 0), seg=6)
s.save(OUT + "sushi.tscn")

# --- Handroll (cono de alga)
s = Scene(); s.node("Handroll", "Node3D")
nori = mat(s, (0.07, 0.11, 0.07)); rice = mat(s, (0.93, 0.91, 0.85)); salmon = mat(s, (0.96, 0.46, 0.26), 0.5)
avocado = mat(s, (0.55, 0.7, 0.25)); paper = mat(s, (0.85, 0.82, 0.72))
s.node("Roll", "Node3D", ".", position=v3((0, 0.035, 0)), rotation=v3((0, 0, -1.35)))
cyl(s, "Cone", "Roll", 0.042, 0.004, 0.17, nori, (0, 0, 0), seg=10)
cyl(s, "Rice", "Roll", 0.039, 0.039, 0.012, rice, (0, 0.082, 0))
box(s, "Salmon", "Roll", (0.03, 0.03, 0.018), salmon, (0.008, 0.094, 0.006), rot=(0.2, 0.3, 0))
box(s, "Avocado", "Roll", (0.02, 0.025, 0.014), avocado, (-0.012, 0.092, -0.01), rot=(-0.2, 0.5, 0))
cyl(s, "Wrap", "Roll", 0.02, 0.01, 0.05, paper, (0, -0.06, 0), seg=8)
s.save(OUT + "handroll.tscn")

# --- Llave con etiqueta
s = Scene(); s.node("Key", "Node3D")
brass = mat(s, (0.72, 0.56, 0.24), 0.35, 0.85); tag = mat(s, (0.86, 0.8, 0.62)); ink = mat(s, (0.15, 0.1, 0.08))
box(s, "Shaft", ".", (0.065, 0.006, 0.006), brass, (0.0, 0.004, 0))
mesh(s, "Bow", ".", "TorusMesh", {"inner_radius": "0.009", "outer_radius": "0.017", "rings": "10", "ring_segments": "5"},
     brass, (-0.045, 0.004, 0))
box(s, "Bit1", ".", (0.006, 0.006, 0.016), brass, (0.025, 0.004, 0.009))
box(s, "Bit2", ".", (0.008, 0.006, 0.011), brass, (0.012, 0.004, 0.007))
box(s, "Tag", ".", (0.05, 0.002, 0.03), tag, (-0.085, 0.002, 0.012), rot=(0, 0.4, 0))
box(s, "TagInk", ".", (0.03, 0.0025, 0.006), ink, (-0.085, 0.002, 0.012), rot=(0, 0.4, 0))
s.save(OUT + "key.tscn")

# --- Hoja de papel (notas)
s = Scene(); s.node("Paper", "Node3D")
paper = mat(s, (0.86, 0.83, 0.72)); ink = mat(s, (0.18, 0.17, 0.2))
box(s, "Sheet", ".", (0.21, 0.002, 0.28), paper, (0, 0.001, 0))
for i in range(9):
    w = 0.16 if i % 4 != 3 else 0.09
    box(s, "Line%d" % i, ".", (w, 0.0024, 0.006), ink, (-0.08 + w / 2, 0.0012, -0.11 + i * 0.025))
s.save(OUT + "paper.tscn")

# --- Pistola (para el suelo, el ícono y examinar): el agarre sin la rotación de la mano.
s = Scene(); s.node("PistolItem", "Node3D")
s.node("Pistol", None, ".", instance=s.res("res://actors/player/pistol.tscn", "PackedScene"), rotation=v3((0, 0, math.pi / 2)))
s.node("Grip", None, "Pistol", position=v3((0, 0, 0)), rotation=v3((0, 0, 0)))
s.save(OUT + "pistol_item.tscn")
print("items ok")
