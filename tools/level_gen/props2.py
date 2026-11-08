import sys, math, os; sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
from tscn import *
KB = "res://levels/kit/kit_block.gd"
M = lambda n: "res://levels/kit/materials/%s.tres" % n
OUT = REPO + "/levels/kit/props/"

def blk(s, name, parent, pos, size, mat, solid=True, rot=None):
    p = {"position": v3(pos)}
    if rot: p["rotation"] = v3(rot)
    p.update({"script": s.res(KB, "Script"), "size": v3(size), "surface": s.res(M(mat), "Material")})
    if not solid: p["solid"] = "false"
    s.node(name, "StaticBody3D", parent, **p)

def mesh(s, name, parent, kind, props, material, pos, rot=None):
    p = {"position": v3(pos)}
    if rot: p["rotation"] = v3(rot)
    p["mesh"] = s.subres(kind, props); p["material_override"] = material
    s.node(name, "MeshInstance3D", parent, **p)

def smat(s, c, rough=0.8, emit=None, metal=0.0):
    d = {"albedo_color": col(c), "roughness": fmt(rough), "metallic": fmt(metal)}
    if emit: d.update({"emission_enabled": "true", "emission": col(emit[0]), "emission_energy_multiplier": fmt(emit[1])})
    return s.subres("StandardMaterial3D", d)

# --- Mesa pequeña con máquina de escribir (la interacción se agrega en la sala)
s = Scene(); s.node("TypewriterDesk", "Node3D")
blk(s, "Top", ".", (0, 0.74, 0), (1.0, 0.05, 0.6), "wood")
for i, (x, z) in enumerate([(-0.44, -0.24), (0.44, -0.24), (-0.44, 0.24), (0.44, 0.24)]):
    blk(s, "Leg%d" % i, ".", (x, 0.36, z), (0.05, 0.72, 0.05), "wood")
body = smat(s, (0.12, 0.2, 0.16), 0.5, metal=0.3); keys = smat(s, (0.08, 0.08, 0.08), 0.6); paper = smat(s, (0.88, 0.85, 0.76))
chrome = smat(s, (0.6, 0.6, 0.6), 0.3, metal=0.9)
s.node("Typewriter", "Node3D", ".", position=v3((0.05, 0.765, 0.02)))
mesh(s, "Body", "Typewriter", "BoxMesh", {"size": v3((0.42, 0.12, 0.34))}, body, (0, 0.06, 0))
mesh(s, "Keys", "Typewriter", "BoxMesh", {"size": v3((0.36, 0.03, 0.14))}, keys, (0, 0.09, 0.12), rot=(0.35, 0, 0))
mesh(s, "Roller", "Typewriter", "CylinderMesh", {"top_radius": "0.035", "bottom_radius": "0.035", "height": "0.5", "radial_segments": "10"},
     keys, (0, 0.15, -0.1), rot=(0, 0, math.pi / 2))
mesh(s, "Knob", "Typewriter", "CylinderMesh", {"top_radius": "0.025", "bottom_radius": "0.025", "height": "0.03", "radial_segments": "8"},
     chrome, (0.27, 0.15, -0.1), rot=(0, 0, math.pi / 2))
mesh(s, "Sheet", "Typewriter", "BoxMesh", {"size": v3((0.22, 0.2, 0.004))}, paper, (0, 0.26, -0.12), rot=(-0.25, 0, 0))
s.node("Lamp", "OmniLight3D", ".", position=v3((-0.3, 1.3, 0.1)), light_color=col((1.0, 0.8, 0.55)), light_energy="0.8", omni_range="2.6")
s.save(OUT + "typewriter_desk.tscn")

# --- Máquina de bebidas (vidrio roto, luz fría que parpadea poco)
s = Scene(); s.node("VendingMachine", "Node3D")
blk(s, "Cabinet", ".", (0, 0.95, 0), (0.9, 1.9, 0.7), "metal")
glow = smat(s, (0.1, 0.12, 0.14), 0.2, emit=((0.45, 0.65, 0.8), 0.9))
dark = smat(s, (0.05, 0.05, 0.06), 0.5)
mesh(s, "Glass", ".", "BoxMesh", {"size": v3((0.62, 1.1, 0.02))}, glow, (-0.08, 1.15, 0.36))
mesh(s, "Slot", ".", "BoxMesh", {"size": v3((0.6, 0.18, 0.03))}, dark, (-0.08, 0.3, 0.36))
mesh(s, "Panel", ".", "BoxMesh", {"size": v3((0.14, 0.5, 0.03))}, dark, (0.33, 1.2, 0.36))
s.node("Glow", "OmniLight3D", ".", position=v3((0, 1.1, 0.8)), light_color=col((0.55, 0.75, 1.0)), light_energy="0.6", omni_range="3.0")
s.save(OUT + "vending_machine.tscn")

# --- Reloj de pared detenido a las 7:12
s = Scene(); s.node("WallClock", "Node3D")
face = smat(s, (0.85, 0.83, 0.75)); rim = smat(s, (0.1, 0.1, 0.1), 0.4); hand = smat(s, (0.05, 0.05, 0.05))
mesh(s, "Rim", ".", "CylinderMesh", {"top_radius": "0.22", "bottom_radius": "0.22", "height": "0.05", "radial_segments": "16"}, rim, (0, 0, 0), rot=(math.pi / 2, 0, 0))
mesh(s, "Face", ".", "CylinderMesh", {"top_radius": "0.195", "bottom_radius": "0.195", "height": "0.052", "radial_segments": "16"}, face, (0, 0, 0.002), rot=(math.pi / 2, 0, 0))
# Horario hacia las 7 (210° desde las 12), minutero hacia los 12 minutos (72°).
for name, ang, length, width in [("Hour", 210 + 6, 0.1, 0.014), ("Minute", 72, 0.16, 0.009)]:
    a = math.radians(ang)
    mesh(s, name, ".", "BoxMesh", {"size": v3((width, length, 0.006))}, hand,
         (math.sin(a) * length / 2, math.cos(a) * length / 2, 0.03), rot=(0, 0, -a))
s.save(OUT + "wall_clock.tscn")
print("props2 ok")
