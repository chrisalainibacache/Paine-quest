import sys, math, os; sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
from tscn import *
KB = "res://levels/kit/kit_block.gd"
M = lambda n: "res://levels/kit/materials/%s.tres" % n
OUT = REPO + "/levels/kit/props/"
# Utilería de detalle (casilleros, estantes, bancos de trabajo, camillas…) para el estándar de docs/ESTANDAR_DETALLE.md.
# Todas miran hacia +Z (se giran al colocarlas) y tienen su origen en el piso, centrado.

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

def box(s, name, parent, size, mat, pos, rot=None):
    mesh(s, name, parent, "BoxMesh", {"size": v3(size)}, mat, pos, rot)

def cyl(s, name, parent, r, h, mat, pos, rot=None, seg=10):
    mesh(s, name, parent, "CylinderMesh", {"top_radius": fmt(r), "bottom_radius": fmt(r), "height": fmt(h), "radial_segments": str(seg)}, mat, pos, rot)

# --- Hilera de 3 casilleros metálicos (puertas con rejilla y una entreabierta)
s = Scene(); s.node("LockerRow", "Node3D")
for i in range(3):
    x = (i - 1) * 0.42
    blk(s, "Body%d" % i, ".", (x, 0.95, 0), (0.4, 1.9, 0.5), "iron_green")
dark = smat(s, (0.05, 0.06, 0.05), 0.6); metal = smat(s, (0.5, 0.52, 0.5), 0.35, metal=0.8)
for i in range(3):
    x = (i - 1) * 0.42
    for j in range(3):
        box(s, "Vent%d_%d" % (i, j), ".", (0.2, 0.018, 0.01), dark, (x, 1.62 + j * 0.05, 0.255))
    box(s, "Handle%d" % i, ".", (0.03, 0.12, 0.03), metal, (x + 0.12, 1.0, 0.27))
box(s, "AjarDoor", ".", (0.36, 1.84, 0.02), smat(s, (0.18, 0.24, 0.18), 0.6), (0.42 + 0.17, 0.95, 0.4), rot=(0, 0.9, 0))
s.save(OUT + "locker_row.tscn")

# --- Estante metálico con cajas y botellas
s = Scene(); s.node("ShelfUnit", "Node3D")
for x in (-0.55, 0.55):
    for z in (-0.18, 0.18):
        blk(s, "Post_%s_%s" % (x, z), ".", (x, 1.0, z), (0.05, 2.0, 0.05), "metal")
for i, y in enumerate((0.15, 0.7, 1.25, 1.8)):
    blk(s, "Board%d" % i, ".", (0, y, 0), (1.2, 0.04, 0.46), "planks")
cardboard = smat(s, (0.45, 0.34, 0.2), 0.95); glass = smat(s, (0.2, 0.4, 0.25), 0.3); paper = smat(s, (0.8, 0.78, 0.68), 0.9)
box(s, "BoxA", ".", (0.3, 0.26, 0.3), cardboard, (-0.35, 0.3, 0)); box(s, "BoxB", ".", (0.24, 0.2, 0.26), cardboard, (0.05, 0.27, 0.02), rot=(0, 0.2, 0))
box(s, "BoxC", ".", (0.34, 0.3, 0.3), cardboard, (0.38, 0.88, 0)); box(s, "Folders", ".", (0.4, 0.28, 0.06), paper, (-0.3, 0.86, 0.1))
cyl(s, "Can1", ".", 0.05, 0.16, smat(s, (0.5, 0.15, 0.1), 0.5, metal=0.4), (0.1, 0.84, 0.0)); cyl(s, "Bottle1", ".", 0.035, 0.24, glass, (-0.1, 1.4, 0.0), seg=8)
cyl(s, "Bottle2", ".", 0.035, 0.24, glass, (0.0, 1.4, 0.05), seg=8); box(s, "BoxD", ".", (0.4, 0.3, 0.32), cardboard, (0.3, 1.42, 0))
s.save(OUT + "shelf_unit.tscn")

# --- Banco de trabajo con tornillo de banco, herramientas y cajón
s = Scene(); s.node("Workbench", "Node3D")
blk(s, "Top", ".", (0, 0.9, 0), (1.8, 0.07, 0.75), "wood")
for x in (-0.8, 0.8):
    for z in (-0.3, 0.3):
        blk(s, "Leg_%s_%s" % (x, z), ".", (x, 0.43, z), (0.07, 0.86, 0.07), "metal")
blk(s, "Drawer", ".", (-0.45, 0.62, 0.0), (0.8, 0.22, 0.65), "iron_green")
steel = smat(s, (0.55, 0.57, 0.6), 0.35, metal=0.9); redm = smat(s, (0.6, 0.12, 0.1), 0.6)
box(s, "VisePlate", ".", (0.2, 0.14, 0.12), steel, (0.72, 1.0, 0.3)); box(s, "ViseJaw", ".", (0.12, 0.1, 0.06), steel, (0.72, 1.0, 0.18))
box(s, "Hammer", ".", (0.3, 0.035, 0.035), smat(s, (0.35, 0.25, 0.15), 0.9), (-0.2, 0.96, 0.15), rot=(0, 0.5, 0)); box(s, "HammerHead", ".", (0.05, 0.08, 0.05), steel, (-0.07, 0.97, 0.05), rot=(0, 0.5, 0))
box(s, "Toolbox", ".", (0.4, 0.2, 0.2), redm, (0.1, 1.03, -0.15)); cyl(s, "OilCan", ".", 0.06, 0.14, smat(s, (0.3, 0.3, 0.32), 0.5, metal=0.5), (0.45, 0.98, -0.1))
s.save(OUT + "workbench.tscn")

# --- Camilla / catre con colchón manchado y manta
s = Scene(); s.node("Cot", "Node3D")
for x in (-0.38, 0.38):
    for z in (-0.9, 0.9):
        blk(s, "Leg_%s_%s" % (x, z), ".", (x, 0.2, z), (0.05, 0.4, 0.05), "metal")
blk(s, "Frame", ".", (0, 0.42, 0), (0.85, 0.05, 2.0), "metal")
box(s, "Mattress", ".", (0.8, 0.1, 1.9), smat(s, (0.72, 0.7, 0.62), 0.95), (0, 0.5, 0))
box(s, "Blanket", ".", (0.82, 0.05, 1.0), smat(s, (0.25, 0.3, 0.2), 0.95), (0, 0.57, 0.4), rot=(0, 0.04, 0))
box(s, "Pillow", ".", (0.5, 0.1, 0.3), smat(s, (0.85, 0.83, 0.76), 0.95), (0, 0.6, -0.78))
box(s, "Stain", ".", (0.3, 0.004, 0.4), smat(s, (0.35, 0.05, 0.05), 0.9), (0.1, 0.556, -0.1), rot=(0, 0.3, 0))
s.save(OUT + "cot.tscn")

# --- Barril de aceite (metal oxidado con franja) y bidón
s = Scene(); s.node("OilBarrel", "Node3D")
cyl(s, "Body", ".", 0.3, 0.9, smat(s, (0.35, 0.18, 0.1), 0.7, metal=0.5), (0, 0.45, 0), seg=14)
for i, y in enumerate((0.15, 0.45, 0.75)):
    cyl(s, "Ring%d" % i, ".", 0.31, 0.04, smat(s, (0.18, 0.1, 0.07), 0.6, metal=0.6), (0, y, 0), seg=14)
cyl(s, "Lid", ".", 0.28, 0.02, smat(s, (0.2, 0.2, 0.2), 0.5, metal=0.7), (0, 0.91, 0), seg=14)
s.node("Col", "StaticBody3D", ".", position=v3((0, 0.45, 0)))
s.node("Shape", "CollisionShape3D", "Col", shape=s.subres("CylinderShape3D", {"radius": "0.3", "height": "0.9"}))
s.save(OUT + "oil_barrel.tscn")

# --- Tablero de avisos con papeles
s = Scene(); s.node("NoticeBoard", "Node3D")
blk(s, "Frame", ".", (0, 1.6, 0), (1.3, 0.9, 0.05), "wood", solid=False)
box(s, "Cork", ".", (1.2, 0.8, 0.02), smat(s, (0.5, 0.36, 0.2), 0.95), (0, 1.6, 0.03))
pap = smat(s, (0.86, 0.84, 0.74), 0.9); yel = smat(s, (0.85, 0.78, 0.4), 0.9)
for i, (x, y, w, h, r) in enumerate([(-0.4, 1.75, 0.25, 0.32, 0.05), (-0.05, 1.5, 0.3, 0.22, -0.08), (0.3, 1.72, 0.26, 0.36, 0.12), (0.4, 1.42, 0.2, 0.2, 0.0), (-0.45, 1.4, 0.22, 0.26, -0.1)]):
    box(s, "Paper%d" % i, ".", (w, h, 0.004), pap if i != 2 else yel, (x, y, 0.045), rot=(0, 0, r))
    cyl(s, "Pin%d" % i, ".", 0.012, 0.02, smat(s, (0.7, 0.1, 0.1), 0.4), (x, y + h / 2 - 0.03, 0.055), rot=(math.pi / 2, 0, 0), seg=6)
s.save(OUT + "notice_board.tscn")

# --- Extintor con soporte
s = Scene(); s.node("Extinguisher", "Node3D")
blk(s, "Bracket", ".", (0, 0.85, -0.02), (0.14, 0.04, 0.05), "metal", solid=False)
cyl(s, "Tank", ".", 0.075, 0.5, smat(s, (0.65, 0.08, 0.07), 0.4, metal=0.3), (0, 0.62, 0.05), seg=12)
cyl(s, "Neck", ".", 0.03, 0.08, smat(s, (0.1, 0.1, 0.1), 0.4, metal=0.5), (0, 0.9, 0.05), seg=8)
box(s, "Hose", ".", (0.02, 0.3, 0.02), smat(s, (0.05, 0.05, 0.05), 0.8), (0.07, 0.75, 0.1), rot=(0, 0, 0.3))
s.save(OUT + "extinguisher.tscn")

# --- Rack de tuberías en el muro (dos tubos horizontales con codos y válvula)
s = Scene(); s.node("PipeRack", "Node3D")
pipe = smat(s, (0.3, 0.32, 0.3), 0.6, metal=0.6); red = smat(s, (0.65, 0.12, 0.1), 0.5)
cyl(s, "PipeA", ".", 0.05, 3.0, pipe, (0, 2.4, 0.08), rot=(0, 0, math.pi / 2), seg=10)
cyl(s, "PipeB", ".", 0.035, 3.0, pipe, (0, 2.2, 0.07), rot=(0, 0, math.pi / 2), seg=8)
cyl(s, "Riser", ".", 0.045, 1.6, pipe, (1.4, 1.6, 0.08), seg=10)
for i, x in enumerate((-1.2, 0.0, 1.2)):
    box(s, "Clamp%d" % i, ".", (0.06, 0.28, 0.04), smat(s, (0.15, 0.15, 0.15), 0.6, metal=0.5), (x, 2.3, 0.07))
cyl(s, "ValveWheel", ".", 0.09, 0.02, red, (-0.6, 2.4, 0.16), rot=(math.pi / 2, 0, 0), seg=10)
s.save(OUT + "pipe_rack.tscn")

# --- Archivador metálico de 4 cajones
s = Scene(); s.node("FilingCabinet", "Node3D")
blk(s, "Body", ".", (0, 0.65, 0), (0.46, 1.3, 0.6), "iron_green")
dark = smat(s, (0.05, 0.06, 0.05), 0.6); metal = smat(s, (0.5, 0.52, 0.5), 0.35, metal=0.8)
for i in range(4):
    box(s, "Gap%d" % i, ".", (0.4, 0.012, 0.01), dark, (0, 0.3 + i * 0.3, 0.305)); box(s, "Pull%d" % i, ".", (0.14, 0.02, 0.03), metal, (0, 0.18 + i * 0.3, 0.32))
box(s, "OpenDrawer", ".", (0.4, 0.14, 0.3), smat(s, (0.2, 0.28, 0.2), 0.6), (0, 0.5, 0.45))
s.save(OUT + "filing_cabinet.tscn")

# --- Escritorio de oficina con lámpara, teléfono y papeles
s = Scene(); s.node("OfficeDesk", "Node3D")
blk(s, "Top", ".", (0, 0.75, 0), (1.5, 0.05, 0.75), "wood")
blk(s, "SideL", ".", (-0.7, 0.36, 0), (0.06, 0.72, 0.7), "wood"); blk(s, "SideR", ".", (0.7, 0.36, 0), (0.06, 0.72, 0.7), "wood"); blk(s, "Back", ".", (0, 0.4, -0.32), (1.4, 0.6, 0.04), "wood")
pap = smat(s, (0.86, 0.84, 0.74), 0.9); blk_m = smat(s, (0.08, 0.08, 0.08), 0.5)
box(s, "Papers", ".", (0.3, 0.02, 0.4), pap, (-0.3, 0.79, 0.05), rot=(0, 0.25, 0)); box(s, "Phone", ".", (0.2, 0.08, 0.16), blk_m, (0.4, 0.82, -0.1))
box(s, "Blotter", ".", (0.6, 0.01, 0.4), smat(s, (0.18, 0.28, 0.2), 0.9), (0.0, 0.775, 0.1))
cyl(s, "LampBase", ".", 0.07, 0.03, blk_m, (-0.6, 0.795, -0.2), seg=8); cyl(s, "LampArm", ".", 0.01, 0.35, blk_m, (-0.6, 0.97, -0.2), seg=6)
s.node("DeskLight", "OmniLight3D", ".", position=v3((-0.5, 1.2, -0.05)), light_color=col((1.0, 0.82, 0.55)), light_energy="0.55", omni_range="2.4")
s.save(OUT + "office_desk.tscn")

# --- Carrete de cable y neumático (desorden de taller)
s = Scene(); s.node("CableDrum", "Node3D")
wood = smat(s, (0.45, 0.32, 0.18), 0.9); cable = smat(s, (0.08, 0.08, 0.09), 0.5)
cyl(s, "Disc1", ".", 0.42, 0.04, wood, (0, 0.42, -0.3), rot=(math.pi / 2, 0, 0), seg=14); cyl(s, "Disc2", ".", 0.42, 0.04, wood, (0, 0.42, 0.3), rot=(math.pi / 2, 0, 0), seg=14)
cyl(s, "Core", ".", 0.28, 0.56, cable, (0, 0.42, 0), rot=(math.pi / 2, 0, 0), seg=12)
s.node("Col", "StaticBody3D", ".", position=v3((0, 0.42, 0)))
s.node("Shape", "CollisionShape3D", "Col", shape=s.subres("CylinderShape3D", {"radius": "0.42", "height": "0.84"}))
s.save(OUT + "cable_drum.tscn")

s = Scene(); s.node("Tire", "Node3D")
mesh(s, "Ring", ".", "TorusMesh", {"inner_radius": "0.16", "outer_radius": "0.34", "rings": "12", "ring_segments": "8"}, smat(s, (0.06, 0.06, 0.06), 0.9), (0, 0.17, 0))
s.node("Col", "StaticBody3D", ".", position=v3((0, 0.17, 0)))
s.node("Shape", "CollisionShape3D", "Col", shape=s.subres("CylinderShape3D", {"radius": "0.34", "height": "0.34"}))
s.save(OUT + "tire.tscn")

# --- Escalera de mano apoyada
s = Scene(); s.node("Ladder", "Node3D")
for x in (-0.22, 0.22):
    blk(s, "Rail%d" % (x > 0), ".", (x, 1.0, -0.2), (0.05, 2.1, 0.04), "wood", solid=False, rot=(0.2, 0, 0))
for i in range(7):
    blk(s, "Rung%d" % i, ".", (0, 0.25 + i * 0.28, -0.2 + (0.25 + i * 0.28) * 0.0 - 0.0), (0.44, 0.03, 0.04), "wood", solid=False, rot=(0.2, 0, 0))
s.save(OUT + "ladder.tscn")

# --- Lámpara colgante industrial (cono + bombilla que alumbra)
s = Scene(); s.node("HangingLamp", "Node3D")
cyl(s, "Cord", ".", 0.01, 0.6, smat(s, (0.05, 0.05, 0.05), 0.8), (0, -0.3, 0), seg=4)
mesh(s, "Shade", ".", "CylinderMesh", {"top_radius": "0.04", "bottom_radius": "0.22", "height": "0.18", "radial_segments": "10"}, smat(s, (0.2, 0.22, 0.2), 0.5, metal=0.6), (0, -0.66, 0))
mesh(s, "Bulb", ".", "SphereMesh", {"radius": "0.06", "height": "0.12"}, smat(s, (1, 0.9, 0.7), 0.3, emit=((1.0, 0.85, 0.6), 3.0)), (0, -0.72, 0))
s.node("Glow", "OmniLight3D", ".", position=v3((0, -0.9, 0)), light_color=col((1.0, 0.84, 0.6)), light_energy="1.1", omni_range="5.0")
s.save(OUT + "hanging_lamp.tscn")
print("props3 ok")
