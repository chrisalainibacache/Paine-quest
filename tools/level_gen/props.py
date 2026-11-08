import sys, os; sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
from tscn import *
P = REPO + "/levels/kit/props/"
KB = "res://levels/kit/kit_block.gd"
M = lambda n: "res://levels/kit/materials/%s.tres" % n

def block(s, name, parent, pos, size, mat, solid=True, rot=None):
    props = {"position": v3(pos)}
    if rot: props["rotation"] = v3(rot)
    props.update({"script": s.res(KB, "Script"), "size": v3(size), "surface": s.res(M(mat), "Material")})
    if not solid: props["solid"] = "false"
    s.node(name, "StaticBody3D", parent, **props)

# Banca de andén: asiento y respaldo de madera, patas de fierro.
s = Scene()
s.node("Bench", "Node3D")
block(s, "Seat", ".", (0, 0.45, 0), (1.6, 0.07, 0.42), "wood")
block(s, "Back", ".", (0, 0.78, 0.2), (1.6, 0.45, 0.06), "wood", rot=(-0.15, 0, 0))
for i, x in enumerate((-0.68, 0.68)):
    block(s, "Leg%d" % i, ".", (x, 0.22, 0.02), (0.06, 0.44, 0.42), "metal")
s.save(P + "bench.tscn")

# Lámpara de sodio colgante: varilla, pantalla, ampolleta y luz cálida.
s = Scene()
s.node("SodiumLamp", "Node3D")
block(s, "Rod", ".", (0, -0.25, 0), (0.04, 0.5, 0.04), "metal", solid=False)
block(s, "Shade", ".", (0, -0.55, 0), (0.5, 0.12, 0.5), "rust", solid=False)
s.node("Bulb", "MeshInstance3D", ".", position=v3((0, -0.66, 0)),
       mesh=s.subres("BoxMesh", {"size": v3((0.22, 0.08, 0.22))}),
       material_override=s.res(M("bulb"), "Material"))
s.node("Light", "OmniLight3D", ".", position=v3((0, -0.8, 0)), light_color=col((1.0, 0.68, 0.38)),
       light_energy="1.8", omni_range="8.0", omni_attenuation="1.2")
s.save(P + "sodium_lamp.tscn")

# Letrero de la estación (doble cara).
s = Scene()
s.node("StationSign", "Node3D")
block(s, "Board", ".", (0, 0, 0), (2.2, 0.5, 0.06), "metal", solid=False)
s.node("Face", "MeshInstance3D", ".", mesh=s.subres("BoxMesh", {"size": v3((2.1, 0.42, 0.07))}),
       material_override=s.res(M("sign_board"), "Material"))
for i, z in enumerate((0.04, -0.04)):
    s.node("Text%d" % i, "Label3D", ".", position=v3((0, 0, z)), rotation=v3((0, 0 if z > 0 else math.pi, 0)),
           pixel_size="0.012", text='"PAINE"', font_size="32", modulate=col((0.92, 0.9, 0.82)),
           outline_size="0", texture_filter="0")
s.save(P + "station_sign.tscn")

# Mancha en el piso.
s = Scene()
s.node("Stain", "MeshInstance3D", mesh=s.subres("PlaneMesh", {"size": "Vector2(1, 1)"}),
       material_override=s.subres("ShaderMaterial", {"render_priority": "0", "shader": s.res("res://shaders/stain.gdshader", "Shader")}),
       cast_shadow="0")
s.save(P + "stain.tscn")

# Caja de madera (para barricadas).
s = Scene()
s.node("Crate", "Node3D")
block(s, "Box", ".", (0, 0.45, 0), (0.9, 0.9, 0.9), "planks")
s.save(P + "crate.tscn")
print("props ok")
