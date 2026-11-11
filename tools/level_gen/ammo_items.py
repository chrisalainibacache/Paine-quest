import sys, math, os; sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
from tscn import *
OUT = REPO + "/levels/kit/items/"

def mat(s, c, rough=0.8, metal=0.0):
    return s.subres("StandardMaterial3D", {"albedo_color": col(c), "roughness": fmt(rough), "metallic": fmt(metal)})

def mesh(s, name, kind, props, material, pos, rot=None):
    p = {"position": v3(pos)}
    if rot: p["rotation"] = v3(rot)
    p["mesh"] = s.subres(kind, props); p["material_override"] = material
    s.node(name, "MeshInstance3D", ".", **p)

def cyl(r1, r2, h, seg=8):
    return {"top_radius": fmt(r1), "bottom_radius": fmt(r2), "height": fmt(h), "radial_segments": str(seg), "rings": "1"}

# Caja de cartuchos de escopeta (roja) con cartuchos asomando.
s = Scene(); s.node("ShellBox", "Node3D")
red = mat(s, (0.55, 0.08, 0.06)); brass = mat(s, (0.78, 0.6, 0.3), 0.4, 0.8); label = mat(s, (0.85, 0.82, 0.7))
mesh(s, "Box", "BoxMesh", {"size": v3((0.13, 0.07, 0.08))}, red, (0, 0.035, 0))
mesh(s, "Label", "BoxMesh", {"size": v3((0.08, 0.03, 0.0815))}, label, (0, 0.04, 0))
for i in range(4):
    mesh(s, "Shell%d" % i, "CylinderMesh", cyl(0.009, 0.009, 0.05), red, (-0.045 + i * 0.03, 0.08, 0.0))
    mesh(s, "Base%d" % i, "CylinderMesh", cyl(0.0095, 0.0095, 0.012), brass, (-0.045 + i * 0.03, 0.06, 0.0))
s.save(OUT + "shell_box.tscn")

# Caja de balas de fusil (verde militar, más larga).
s = Scene(); s.node("RifleBox", "Node3D")
green = mat(s, (0.2, 0.26, 0.14)); brass = mat(s, (0.78, 0.6, 0.3), 0.4, 0.8); stencil = mat(s, (0.85, 0.8, 0.55))
mesh(s, "Box", "BoxMesh", {"size": v3((0.2, 0.08, 0.1))}, green, (0, 0.04, 0))
mesh(s, "Stencil", "BoxMesh", {"size": v3((0.12, 0.02, 0.101))}, stencil, (0, 0.05, 0))
for i in range(6):
    mesh(s, "Round%d" % i, "CylinderMesh", cyl(0.003, 0.0055, 0.045), brass, (-0.075 + i * 0.03, 0.1, 0.02))
s.save(OUT + "rifle_box.tscn")

# Granadas de 40 mm (tres, en fila).
s = Scene(); s.node("Grenades", "Node3D")
olive = mat(s, (0.3, 0.33, 0.2), 0.6); brass = mat(s, (0.72, 0.56, 0.28), 0.4, 0.8); band = mat(s, (0.75, 0.65, 0.2))
for i in range(3):
    x = -0.05 + i * 0.05
    mesh(s, "Case%d" % i, "CylinderMesh", cyl(0.02, 0.02, 0.04, 10), brass, (x, 0.02, 0))
    mesh(s, "Head%d" % i, "CylinderMesh", cyl(0.012, 0.02, 0.05, 10), olive, (x, 0.065, 0))
    mesh(s, "Band%d" % i, "CylinderMesh", cyl(0.0202, 0.0202, 0.006, 10), band, (x, 0.044, 0))
s.save(OUT + "grenades.tscn")

# Cohete de bazuca acostado.
s = Scene(); s.node("Rocket", "Node3D")
olive = mat(s, (0.32, 0.36, 0.22), 0.6); dark = mat(s, (0.12, 0.12, 0.1)); red = mat(s, (0.6, 0.1, 0.06))
mesh(s, "Body", "CylinderMesh", cyl(0.035, 0.035, 0.32, 10), olive, (0, 0.035, 0), rot=(math.pi / 2, 0, 0))
mesh(s, "Nose", "CylinderMesh", cyl(0.004, 0.035, 0.12, 10), olive, (0, 0.035, 0.22), rot=(math.pi / 2, 0, 0))
mesh(s, "Band", "CylinderMesh", cyl(0.036, 0.036, 0.02, 10), red, (0, 0.035, 0.12), rot=(math.pi / 2, 0, 0))
for i, a in enumerate((0, 1.57, 3.14, 4.71)):
    mesh(s, "Fin%d" % i, "BoxMesh", {"size": v3((0.002, 0.06, 0.07))}, dark, (math.sin(a) * 0.03, 0.035 + math.cos(a) * 0.03, -0.17), rot=(0, 0, a))
s.save(OUT + "rocket.tscn")
print("ammo items ok")
