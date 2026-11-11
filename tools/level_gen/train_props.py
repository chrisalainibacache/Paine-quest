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

def quad(s, name, parent, pos, size, material, rot=None):
    p = {"position": v3(pos)}
    if rot: p["rotation"] = v3(rot)
    p["mesh"] = s.subres("BoxMesh", {"size": v3(size)})
    p["material_override"] = material
    s.node(name, "MeshInstance3D", parent, **p)

def emissive(s, c, e):
    return s.subres("StandardMaterial3D", {"albedo_color": col(c), "emission_enabled": "true", "emission": col(c), "emission_energy_multiplier": fmt(e)})

# --- Vagón de pasajeros (largo en X, 14 m). Ventanas oscuras y rotas.
s = Scene(); s.node("TrainWagon", "Node3D")
L, W = 14.0, 2.9
blk(s, "Chassis", ".", (0, 0.55, 0), (L - 2, 0.5, W - 0.6), "rust")
for i, x in enumerate((-L / 2 + 2.2, L / 2 - 2.2)):
    blk(s, "Bogie%d" % i, ".", (x, 0.38, 0), (2.6, 0.62, W - 0.3), "metal")
    for j, z in enumerate((-W / 2 + 0.2, W / 2 - 0.2)):
        for k, dx in enumerate((-0.8, 0.8)):
            s.node("Wheel%d_%d_%d" % (i, j, k), "MeshInstance3D", ".", position=v3((x + dx, 0.4, z)), rotation=v3((math.pi / 2, 0, 0)),
                   mesh=s.subres("CylinderMesh", {"top_radius": "0.42", "bottom_radius": "0.42", "height": "0.12", "radial_segments": "10"}),
                   material_override=s.res(M("metal"), "Material"))
blk(s, "BodyLow", ".", (0, 1.45, 0), (L, 1.1, W), "train_blue")
blk(s, "BodyWindow", ".", (0, 2.45, 0), (L, 0.9, W), "train_cream")
blk(s, "BodyTop", ".", (0, 3.1, 0), (L, 0.4, W), "train_blue")
blk(s, "Roof", ".", (0, 3.4, 0), (L - 0.2, 0.22, W - 0.3), "metal")
glass = emissive(s, (0.05, 0.07, 0.09), 0.2)
for side, z in (("N", -W / 2 - 0.005), ("S", W / 2 + 0.005)):
    for i in range(8):
        x = -L / 2 + 1.6 + i * 1.55
        if abs(x) > L / 2 - 1.3:
            continue
        quad(s, "Win%s%d" % (side, i), ".", (x, 2.48, z), (1.15, 0.7, 0.02), glass)
    for i, x in enumerate((-L / 2 + 0.75, L / 2 - 0.75)):
        quad(s, "Door%s%d" % (side, i), ".", (x, 1.95, z), (0.8, 1.9, 0.03), s.res(M("rust"), "Material"))
s.node("Number", "Label3D", ".", position=v3((2.0, 1.55, W / 2 + 0.02)), text='"EFE  S-2214"', font_size="30", pixel_size="0.005",
       modulate=col((0.9, 0.88, 0.8)), outline_size="0")
s.save(OUT + "train_wagon.tscn")

# --- Locomotora diésel (largo en X, 12 m), cabina en +X.
s = Scene(); s.node("Locomotive", "Node3D")
L, W = 12.0, 3.0
blk(s, "Chassis", ".", (0, 0.6, 0), (L - 1, 0.6, W - 0.5), "rust")
for i, x in enumerate((-L / 2 + 2.3, L / 2 - 2.3)):
    blk(s, "Bogie%d" % i, ".", (x, 0.4, 0), (3.0, 0.65, W - 0.3), "metal")
blk(s, "Hood", ".", (-1.4, 2.0, 0), (L - 3.2, 2.2, W - 0.7), "train_red")
blk(s, "Cab", ".", (L / 2 - 1.4, 2.35, 0), (2.8, 2.9, W), "train_red")
blk(s, "CabRoof", ".", (L / 2 - 1.4, 3.85, 0), (2.9, 0.15, W + 0.1), "metal")
blk(s, "Stripe", ".", (0, 1.15, 0), (L, 0.18, W + 0.02), "train_cream", solid=False)
glass = emissive(s, (0.06, 0.08, 0.1), 0.2)
quad(s, "Windshield", ".", (L / 2 + 0.005, 2.95, 0), (0.02, 0.8, 2.2), glass)
for side, z in (("N", -W / 2 - 0.005), ("S", W / 2 + 0.005)):
    quad(s, "CabWin" + side, ".", (L / 2 - 1.4, 2.95, z), (1.6, 0.8, 0.02), glass)
    for i in range(5):
        quad(s, "Vent%s%d" % (side, i), ".", (-5.2 + i * 1.6, 2.2, z * 0.79), (0.9, 0.6, 0.02), s.res(M("metal"), "Material"))
lamp = emissive(s, (1.0, 0.85, 0.5), 1.5)
quad(s, "Headlight", ".", (L / 2 + 0.01, 3.55, 0), (0.02, 0.3, 0.3), lamp)
s.node("Number", "Label3D", ".", position=v3((L / 2 - 1.4, 1.6, W / 2 + 0.02)), text='"D-16008"', font_size="30", pixel_size="0.005",
       modulate=col((0.9, 0.88, 0.8)), outline_size="0")
s.save(OUT + "locomotive.tscn")

# --- Par de asientos enfrentados (interior del vagón), a lo largo de X.
s = Scene(); s.node("SeatPair", "Node3D")
for i, (x, dirx) in enumerate(((-0.55, 1), (0.55, -1))):
    blk(s, "Seat%d" % i, ".", (x, 0.42, 0), (0.5, 0.12, 0.95), "seat_fabric")
    blk(s, "Back%d" % i, ".", (x - dirx * 0.22, 0.85, 0), (0.1, 0.8, 0.95), "seat_fabric")
    blk(s, "Leg%d" % i, ".", (x, 0.18, 0), (0.08, 0.36, 0.7), "metal", solid=False)
s.save(OUT + "seat_pair.tscn")

# --- Fuego: escombros ardiendo, llamas, humo y luz que titila.
s = Scene(); s.node("Fire", "Node3D")
blk(s, "Debris", ".", (0, 0.15, 0), (1.0, 0.3, 0.8), "soot", solid=False, rot=(0, 0.4, 0))
dot_grad = s.subres("Gradient", {"colors": "PackedColorArray(1, 1, 1, 1, 1, 1, 1, 0)"})
dot = s.subres("GradientTexture2D", {"gradient": dot_grad, "fill": "1", "fill_from": "Vector2(0.5, 0.5)", "fill_to": "Vector2(0.5, 0)",
                                     "width": "32", "height": "32"})
glow = s.subres("StandardMaterial3D", {"shading_mode": "0", "blend_mode": "1", "transparency": "1", "billboard_mode": "1",
                                       "vertex_color_use_as_albedo": "true", "albedo_texture": dot})
grad = s.subres("Gradient", {"colors": "PackedColorArray(1, 0.75, 0.25, 1, 1, 0.25, 0.05, 0.6, 0.2, 0.05, 0.02, 0)"})
s.node("Flames", "CPUParticles3D", ".", position=v3((0, 0.3, 0)), amount="26", lifetime="0.8", direction=v3((0, 1, 0)), spread="18.0",
       gravity=v3((0, 1.6, 0)), initial_velocity_min="0.4", initial_velocity_max="1.1", scale_amount_min="0.6", scale_amount_max="1.3",
       emission_shape="3", emission_box_extents=v3((0.4, 0.05, 0.3)),
       mesh=s.subres("QuadMesh", {"size": "Vector2(0.45, 0.45)", "material": glow}), color_ramp=grad)
smoke_mat = s.subres("StandardMaterial3D", {"shading_mode": "0", "transparency": "1", "billboard_mode": "1", "albedo_color": col((0.12, 0.11, 0.1, 0.45)),
                                            "albedo_texture": dot})
s.node("Smoke", "CPUParticles3D", ".", position=v3((0, 1.0, 0)), amount="14", lifetime="2.5", direction=v3((0, 1, 0)), spread="15.0",
       gravity=v3((0.3, 0.8, 0)), initial_velocity_min="0.4", initial_velocity_max="0.8", scale_amount_min="1.0", scale_amount_max="2.2",
       mesh=s.subres("QuadMesh", {"size": "Vector2(0.9, 0.9)", "material": smoke_mat}))
s.node("Light", "OmniLight3D", ".", position=v3((0, 0.9, 0)), script=s.res("res://levels/kit/fire_light.gd", "Script"),
       light_color=col((1.0, 0.5, 0.18)), light_energy="1.8", omni_range="6.0")
s.save(OUT + "fire.tscn")
print("train props ok")
