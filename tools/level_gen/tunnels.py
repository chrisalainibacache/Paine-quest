import math, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from tscn import *
# Túneles de tren de verdad (antes era un rectángulo plano pegado al muro):
#   - props tunnel_portal_dark / tunnel_portal_red: portal en arco de ladrillo +
#     tubo de 12 m con piso de grava, rieles y fondo oscuro o con resplandor rojo.
#   - carve(): abre el hueco en un muro y coloca el portal.
# Las medidas son del eje de la vía hacia afuera: origen = cara interior del muro,
# a la altura del riel; el tubo avanza hacia +X (se gira 180° para el muro oeste).
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
KB = "res://levels/kit/kit_block.gd"
M = lambda n: "res://levels/kit/materials/%s.tres" % n
OUT = REPO + "/levels/kit/props/"
HW = 1.6          # medio ancho libre del túnel
HS = 1.8          # altura de los muros rectos (hasta donde empieza el arco)
LENGTH = 12.0
WALL_T = 0.3


def _blk(s, name, pos, size, mat, solid=True, rot=None):
    p = {"position": v3(pos)}
    if rot: p["rotation"] = v3(rot)
    p.update({"script": s.res(KB, "Script"), "size": v3(size), "surface": s.res(M(mat), "Material")})
    if not solid: p["solid"] = "false"
    s.node(name, "StaticBody3D", ".", **p)


def _arc(s, prefix, r_in, thick, depth, x_center, n, mats, solid):
    """Arco de media vuelta (dovelas) sobre el eje X; el centro del arco está a altura HS."""
    r_mid = r_in + thick / 2
    chord = 2 * (r_in + thick) * math.sin(math.pi / (2 * n)) * 1.04
    for i in range(n):
        phi = math.pi * (i + 0.5) / n          # 0 = lado +Z, pi/2 = arriba, pi = lado -Z
        pos = (x_center, HS + r_mid * math.sin(phi), r_mid * math.cos(phi))
        _blk(s, "%s%d" % (prefix, i), pos, (depth, thick, chord), mats[i % len(mats)], solid=solid,
             rot=(math.pi / 2 - phi, 0, 0))


def make_portal(name, red):
    s = Scene()
    s.node(name, "Node3D")
    # Marco de ladrillo en la cara del muro (apenas sale 10 cm hacia la sala).
    depth = 0.4
    xf = 0.1 / 2 + (WALL_T - 0.1) / 2 - 0.1   # centro del marco: de x=-0.1 a x=0.3
    xf = 0.1
    ring = 0.5
    for side in (1, -1):
        _blk(s, "Jamb%s" % ("L" if side > 0 else "R"), (xf, HS / 2, side * (HW + ring / 2)), (depth, HS, ring), "old_bricks_wall")
    _arc(s, "Voussoir", HW, ring, depth, xf, 11, ["old_bricks_wall", "concrete_wall"], True)
    _blk(s, "Keystone", (xf, HS + HW + ring / 2 + 0.06, 0), (depth + 0.1, ring + 0.2, 0.4), "concrete_wall", solid=False)
    _blk(s, "Sill", (xf, -0.1, 0), (depth + 0.1, 0.2, 2 * (HW + ring) + 0.2), "concrete_wall", solid=False)
    # Tubo: piso, paredes, bóveda y fondo (todo sólido: ninguna cámara ve el vacío).
    x0, x1 = WALL_T, LENGTH
    cx, ln = (x0 + x1) / 2, x1 - x0
    _blk(s, "TubeFloor", (cx, -0.2, 0), (ln, 0.4, 2 * HW + 0.5), "gravel")
    for side in (1, -1):
        _blk(s, "TubeWall%s" % ("L" if side > 0 else "R"), (cx, HS / 2, side * (HW + 0.125)), (ln, HS, 0.25), "soot")
    _arc(s, "Vault", HW, 0.25, ln, cx, 10, ["soot"], True)
    _blk(s, "EndCap", (x1 + 0.125, 1.8, 0), (0.25, 4.6, 4.2), "soot")
    # Respaldo sólido invisible alrededor del tubo: tapa las rendijas entre dovelas
    # (ningún rayo de cámara se escapa al vacío por ahí).
    top = HS + HW + 0.25
    _blk(s, "ShellTop", (cx, top + 0.4, 0), (ln, 0.8, 2 * HW + 1.5), "soot")
    for side in (1, -1):
        _blk(s, "ShellSide%s" % ("L" if side > 0 else "R"), (cx, (top - 0.5) / 2, side * (HW + 0.25 + 0.3)), (ln, top + 0.5, 0.6), "soot")
    for n in s.nodes[-3:]:
        n[1]["visible"] = "false"
    glow = (1.0, 0.2, 0.07) if red else (0.035, 0.04, 0.055)
    mat = s.subres("StandardMaterial3D", {"albedo_color": col(glow), "emission_enabled": "true", "emission": col(glow),
                                          "emission_energy_multiplier": "1.5" if red else "1.0"})
    s.node("EndGlow", "MeshInstance3D", ".", position=v3((x1 - 0.02, 1.4, 0)), rotation=v3((0, -math.pi / 2, 0)),
           mesh=s.subres("QuadMesh", {"size": "Vector2(%s, %s)" % (fmt(2 * HW), fmt(HS + HW))}), material_override=mat)
    # Vía que sigue adentro.
    s.node("Track", "Node3D", ".", position=v3((cx, 0.0, 0.0)), script=s.res("res://levels/kit/rail_track.gd", "Script"),
           length=fmt(ln), sleeper_material=s.res(M("wood"), "Material"), rail_material=s.res(M("metal"), "Material"))
    if red:
        s.node("Glow", "OmniLight3D", ".", position=v3((3.5, 1.0, 0)), script=s.res("res://levels/kit/fire_light.gd", "Script"),
               light_color=col((1.0, 0.28, 0.1)), light_energy="1.5", omni_range="7.0")
    s.save(OUT + "tunnel_portal_%s.tscn" % ("red" if red else "dark"))


def carve(blockfn, propfn, side, x_inner, track_z, y_track, y_bottom, y_top, z0, z1, wall_mat, red=False, prefix="Tunnel", parent="Walls"):
    """Abre el hueco del túnel en un muro (side +1 = este, -1 = oeste) y pone el portal.
    El muro queda en trozos: a los lados, bajo la vía, escalones sobre el arco y el dintel."""
    xc = x_inner + side * WALL_T / 2
    zl, zr = track_z - HW, track_z + HW
    spring = y_track + HS

    def wall(name, za, zb, ya, yb):
        if zb - za > 0.02 and yb - ya > 0.02:
            blockfn(prefix + name, parent, (xc, (ya + yb) / 2, (za + zb) / 2), (WALL_T, yb - ya, zb - za), wall_mat)

    wall("WallN", z0, zl, y_bottom, y_top)
    wall("WallS", zr, z1, y_bottom, y_top)
    wall("Under", zl, zr, y_bottom, y_track)
    n = 5
    for i in range(n):
        ya = spring + i * HW / n
        yb = ya + HW / n
        w = math.sqrt(max(HW * HW - (ya - spring) ** 2, 0.0))   # ancho del arco abajo del escalón
        wall("StepL%d" % i, zl, track_z - w, ya, yb)
        wall("StepR%d" % i, track_z + w, zr, ya, yb)
    wall("Lintel", zl, zr, spring + HW, y_top)
    propfn(prefix + "Portal", "Props", "tunnel_portal_red" if red else "tunnel_portal_dark",
           (x_inner, y_track, track_z), rot=(0, 0.0 if side > 0 else math.pi, 0))


if __name__ == "__main__":
    make_portal("TunnelPortalDark", False)
    make_portal("TunnelPortalRed", True)
    print("portales de túnel ok")
