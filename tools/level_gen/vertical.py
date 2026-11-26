"""Verticalidad para salas hechas con roomkit.Kit: escaleras, balcones/entrepisos, pasarelas y tabiques.
TODAS las medidas son REALES (metros), aunque la sala use el espacio normalizado de maestranza_common (se evita el escalado).

    import vertical
    vertical.stairs(k, "Stairs", x=-2.0, z=3.0, direction="+x", width=1.3, rise=2.7)        # sube hacia +X desde (x, z)
    vertical.balcony(k, "Mezzanine", -3.0, 5.0, -4.0, -1.5, y=2.7, rail_sides="SE", gap=("W", 0.0, 1.3))
    vertical.partition(k, "Wall", x0, z0, x1, z1, gap=(2.0, 3.2))                          # tabique con hueco de puerta

Isabella camina las escaleras por una rampa de colisión invisible (los escalones son solo visuales); el balcón es una losa
sólida con baranda que también tiene colisión (no se cae). Las cámaras de la sala deben cubrir también el nivel alto."""
import math
from tscn import v3

STEP_MAT = "concrete_wall"
RAIL_MAT = "metal"
RAMP_THICKNESS = 0.25


def _raw(k, what):
    return getattr(k, "raw", {}).get(what) or getattr(k, what)


def _collider(k, name, group, pos, size, rot=None):
    """Colisión INVISIBLE (StaticBody3D + caja): para rampas de escalera y barandas que no deben dibujarse como bloques."""
    k.group(group)
    props = {"position": v3(pos)}
    if rot:
        props["rotation"] = v3(rot)
    k.s.node(name, "StaticBody3D", group, **props)
    k.s.node("Shape", "CollisionShape3D", "%s/%s" % (group, name), shape=k.s.subres("BoxShape3D", {"size": v3(size)}))


def stairs(k, name, x, z, direction, width, rise, tread=0.3, mat=STEP_MAT, rails=True):
    """Escalera recta que sube en `direction` ('+x','-x','+z','-z') desde el punto (x, z) del piso hasta la altura `rise`.
    (x, z) es el centro del primer escalón por su borde inferior. Largo = escalones * huella."""
    block = _raw(k, "block")
    n = max(2, int(round(rise / 0.18)))
    rh = rise / n
    run = n * tread
    dx, dz = {"+x": (1, 0), "-x": (-1, 0), "+z": (0, 1), "-z": (0, -1)}[direction]
    along_x = dx != 0
    for i in range(n):
        c = (i + 0.5) * tread
        px, pz = x + dx * c, z + dz * c
        size = (tread, (i + 1) * rh, width) if along_x else (width, (i + 1) * rh, tread)
        block("%sStep%d" % (name, i), "Stairs", (px, (i + 1) * rh / 2, pz), size, mat, solid=False)
    # Rampa de colisión por las puntas de los escalones (un poco por debajo para no flotar sobre la huella).
    theta = math.atan2(rise, run)
    length = math.hypot(run, rise)
    cx, cz = x + dx * run / 2, z + dz * run / 2
    cy = rise / 2 + rh * 0.25 - RAMP_THICKNESS / 2 * math.cos(theta)
    rot = {"+x": (0, 0, theta), "-x": (0, 0, -theta), "+z": (-theta, 0, 0), "-z": (theta, 0, 0)}[direction]
    size = (length, RAMP_THICKNESS, width) if along_x else (width, RAMP_THICKNESS, length)
    _collider(k, "%sRamp" % name, "Stairs", (cx, cy, cz), size, rot)
    if rails:
        for side in (-1, 1):
            off = side * (width / 2 + 0.04)
            ox, oz = (0, off) if along_x else (off, 0)
            for i in range(0, n, 2):
                c = (i + 0.5) * tread
                block("%sPost%d_%d" % (name, side > 0, i), "Stairs", (x + dx * c + ox, (i + 1) * rh + 0.45, z + dz * c + oz), (0.05, 0.9, 0.05), RAIL_MAT, solid=False)
            rail_size = (length, 0.05, 0.05) if along_x else (0.05, 0.05, length)
            block("%sRail%d" % (name, side > 0), "Stairs", (cx + ox, cy + 0.95, cz + oz), rail_size, RAIL_MAT, solid=False, rot=rot)
    return run


def balcony(k, name, x0, x1, z0, z1, y, rail_sides="NSEW", gap=None, mat="planks", floor_thickness=0.22, columns=True):
    """Entrepiso / balcón: losa sólida de (x0..x1, z0..z1) con su cara superior a altura `y`. Baranda con colisión en los lados
    de `rail_sides` (N=z0, S=z1, W=x0, E=x1). `gap=(lado, desde, hasta)` deja el hueco para la escalera (coordenadas a lo largo del lado)."""
    block = _raw(k, "block")
    w, d = x1 - x0, z1 - z0
    cx, cz = (x0 + x1) / 2, (z0 + z1) / 2
    block(name + "Slab", "Balcony", (cx, y - floor_thickness / 2, cz), (w, floor_thickness, d), mat)
    block(name + "Beam", "Balcony", (cx, y - floor_thickness - 0.1, cz), (w, 0.2, 0.25), "metal", solid=False)
    if columns:
        for i, (px, pz) in enumerate(((x0 + 0.15, z0 + 0.15), (x1 - 0.15, z0 + 0.15), (x0 + 0.15, z1 - 0.15), (x1 - 0.15, z1 - 0.15))):
            block("%sColumn%d" % (name, i), "Balcony", (px, (y - floor_thickness) / 2, pz), (0.22, y - floor_thickness, 0.22), "metal")
    sides = {"N": (x0, x1, z0, True), "S": (x0, x1, z1, True), "W": (z0, z1, x0, False), "E": (z0, z1, x1, False)}
    for side in rail_sides:
        a0, a1, fixed, along_x = sides[side]
        spans = [(a0, a1)]
        if gap and gap[0] == side:
            spans = [(a0, gap[1]), (gap[2], a1)]
        for j, (s0, s1) in enumerate(spans):
            if s1 - s0 < 0.2:
                continue
            mid, length = (s0 + s1) / 2, s1 - s0
            px, pz = (mid, fixed) if along_x else (fixed, mid)
            size = (length, 1.0, 0.06) if along_x else (0.06, 1.0, length)
            # Colisión invisible de la baranda + barandal y postes visibles.
            _collider(k, "%sRailWall%s%d" % (name, side, j), "Balcony", (px, y + 0.5, pz), size)
            top = (length, 0.06, 0.07) if along_x else (0.07, 0.06, length)
            block("%sRailTop%s%d" % (name, side, j), "Balcony", (px, y + 1.05, pz), top, RAIL_MAT, solid=False)
            count = max(2, int(length // 1.1) + 1)
            for q in range(count):
                t = s0 + (s1 - s0) * q / (count - 1)
                qx, qz = (t, fixed) if along_x else (fixed, t)
                block("%sPost%s%d_%d" % (name, side, j, q), "Balcony", (qx, y + 0.52, qz), (0.06, 1.04, 0.06), RAIL_MAT, solid=False)


def partition(k, name, x0, z0, x1, z1, gap=None, h=None, mat="concrete_wall", thickness=0.25):
    """Tabique recto de (x0,z0) a (x1,z1) (alineado a un eje), con un hueco opcional `gap=(desde, hasta)` medido a lo largo del tabique."""
    block = _raw(k, "block")
    h = h or getattr(k, "H", 4.4)
    along_x = abs(x1 - x0) >= abs(z1 - z0)
    a0, a1 = (x0, x1) if along_x else (z0, z1)
    if a0 > a1:
        a0, a1 = a1, a0
    fixed = z0 if along_x else x0
    spans = [(a0, a1)] if not gap else [(a0, a0 + gap[0]), (a0 + gap[1], a1)]
    for j, (s0, s1) in enumerate(spans):
        if s1 - s0 < 0.1:
            continue
        mid, length = (s0 + s1) / 2, s1 - s0
        px, pz = (mid, fixed) if along_x else (fixed, mid)
        size = (length, h, thickness) if along_x else (thickness, h, length)
        block("%s%d" % (name, j), "Partitions", (px, h / 2, pz), size, mat)
    if gap:
        mid = a0 + (gap[0] + gap[1]) / 2
        px, pz = (mid, fixed) if along_x else (fixed, mid)
        lintel = (gap[1] - gap[0], h - 2.3, thickness) if along_x else (thickness, h - 2.3, gap[1] - gap[0])
        block(name + "Lintel", "Partitions", (px, 2.3 + (h - 2.3) / 2, pz), lintel, mat)


def block_corner(k, name, x0, x1, z0, z1, h=None, mat="bricks_wall"):
    """Volumen macizo (un cuarto cerrado, un tanque, un ducto) que recorta la planta y hace la sala en L."""
    block = _raw(k, "block")
    h = h or getattr(k, "H", 4.4)
    block(name, "Partitions", ((x0 + x1) / 2, h / 2, (z0 + z1) / 2), (x1 - x0, h, z1 - z0), mat)
