# Piezas comunes del capítulo 3 (Buin, sábado en la mañana).
import math
from roomkit import *
from tracks_common import walls, fence_top, luggage, track_bed

B = "res://levels/buin/%s.tscn"


def dawn(k, fog=0.012):
    """Mañana nublada: luz difusa y un sol bajo y tibio (contraste con la noche).
    Niebla suave: más densa se come el color en el teléfono."""
    k.env((0.6, 0.62, 0.68), (0.6, 0.6, 0.64), 0.7, (0.5, 0.52, 0.58), fog)
    k.s.node("Sun", "DirectionalLight3D", ".", rotation=v3((-0.55, 2.3, 0)), light_color=col((1.0, 0.86, 0.7)), light_energy="0.95")


def sky_box(k, x0, x1, z0, z1, y_floor=-6.0, margin=5.0, top=10.0):
    """Cielo alrededor y río abajo (bloques sólidos: ninguna cámara ve el vacío)."""
    cx, cz = (x0 + x1) / 2, (z0 + z1) / 2
    W, D = x1 - x0 + margin * 2, z1 - z0 + margin * 2
    h = top - y_floor
    k.block("SkyN", "Backdrop", (cx, y_floor + h / 2, z0 - margin), (W, h, 0.5), "sky_dawn")
    k.block("SkyS", "Backdrop", (cx, y_floor + h / 2, z1 + margin), (W, h, 0.5), "sky_dawn")
    k.block("SkyW", "Backdrop", (x0 - margin, y_floor + h / 2, cz), (0.5, h, D), "sky_dawn")
    k.block("SkyE", "Backdrop", (x1 + margin, y_floor + h / 2, cz), (0.5, h, D), "sky_dawn")
    k.block("River", "Backdrop", (cx, y_floor, cz), (W, 0.4, D), "river")


def open_field(k, x0, x1, z0, z1, gates=(("W", 0.0), ("E", 0.0)), fence_edges="NSWE", seed=3, reach=24.0):
    """Campo abierto en vez de un recinto de muros: cerco bajo de palos, portones por donde se entra y se sale, camino
    que sigue afuera, el campo que continúa, álamos, cerros y cielo. Los muros invisibles solo detienen a Isabella."""
    import random
    rng = random.Random(seed)
    cx, cz = (x0 + x1) / 2, (z0 + z1) / 2
    W, D = x1 - x0, z1 - z0
    for g in ("Props", "Fence", "Backdrop", "Boundary"):
        k.group(g)
    # El suelo sigue más allá del cerco (apenas más bajo para no pelear con el de la sala).
    k.block("OuterGround", "Ground", (cx, -0.54, cz), (W + reach * 2, 1, D + reach * 2), "dirt")
    # Límites invisibles (colisión).
    for name, pos, size in (("N", (cx, 1.5, z0 - 0.15), (W + 0.6, 3.0, 0.3)), ("S", (cx, 1.5, z1 + 0.15), (W + 0.6, 3.0, 0.3)),
                            ("W", (x0 - 0.15, 1.5, cz), (0.3, 3.0, D)), ("E", (x1 + 0.15, 1.5, cz), (0.3, 3.0, D))):
        k.s.node("Limit" + name, "StaticBody3D", "Boundary", position=v3(pos))
        k.s.node("Shape", "CollisionShape3D", "Boundary/Limit" + name, shape=k.s.subres("BoxShape3D", {"size": v3(size)}))
    gate_z = {e: z for e, z in gates}
    # Cerco: postes cada 2 m y dos hilos de alambre/riel; se interrumpe en los portones.
    def skip_ew(edge, z):
        return edge in gate_z and abs(z - gate_z[edge]) < 1.5
    n = 0
    for edge in fence_edges:
        if edge in "NS":
            z = z0 + 0.12 if edge == "N" else z1 - 0.12
            xs = [x0 + i * 2.0 for i in range(int(W / 2.0) + 1)]
            for x in xs:
                k.block("Post%d" % n, "Fence", (x, 0.55, z), (0.12, 1.1, 0.12), "wood", solid=False); n += 1
            for j, y in enumerate((0.45, 0.95)):
                k.block("Wire%s%d" % (edge, j), "Fence", (cx, y, z), (W, 0.04, 0.04), "metal", solid=False)
        else:
            x = x0 + 0.12 if edge == "W" else x1 - 0.12
            zs = [z0 + i * 2.0 for i in range(int(D / 2.0) + 1)]
            for z in zs:
                if skip_ew(edge, z):
                    continue
                k.block("Post%d" % n, "Fence", (x, 0.55, z), (0.12, 1.1, 0.12), "wood", solid=False); n += 1
            gz = gate_z.get(edge)
            segs = [(z0, D)] if gz is None else [((z0 + gz - 1.5) / 2, gz - 1.5 - z0), ((gz + 1.5 + z1) / 2, z1 - gz - 1.5)]
            for si, (zc, ln) in enumerate(segs):
                for j, y in enumerate((0.45, 0.95)):
                    k.block("Wire%s%d_%d" % (edge, si, j), "Fence", (x, y, zc), (0.04, 0.04, max(ln, 0.1)), "metal", solid=False)
    # Portones abiertos, con su camino que sigue afuera.
    for edge, gz in gates:
        sgn = -1 if edge == "W" else 1
        x = (x0 if edge == "W" else x1) - 0.0
        for s, zz in enumerate((gz - 1.35, gz + 1.35)):
            k.block("GatePost%s%d" % (edge, s), "Fence", (x + (-0.12 * sgn), 0.95, zz), (0.22, 1.9, 0.22), "wood", solid=False)
        k.block("GateBar%s" % edge, "Fence", (x + (-0.12 * sgn), 1.85, gz), (0.18, 0.14, 2.9), "wood", solid=False)
        k.block("GateLeaf%s" % edge, "Fence", (x + (-0.12 * sgn) + sgn * -0.62, 0.7, gz - 1.0), (1.3, 1.1, 0.07), "planks", solid=False,
                rot=(0, 1.15 * sgn, 0))
        k.block("Road%s" % edge, "Ground", (x + sgn * (reach / 2 - 0.2), 0.012, gz), (reach, 0.03, 2.8), "gravel", solid=False)
    # Hileras de álamos y arbustos más allá del cerco, y cerros al fondo.
    crown = k.s.subres("CylinderMesh", {"top_radius": "0.0", "bottom_radius": "1.1", "height": "7.0", "radial_segments": "6"})
    trunk = k.s.subres("CylinderMesh", {"top_radius": "0.14", "bottom_radius": "0.22", "height": "3.0", "radial_segments": "5"})
    foliage = k.s.subres("StandardMaterial3D", {"albedo_color": col((0.13, 0.22, 0.12)), "roughness": "1.0"})
    hills = k.s.subres("StandardMaterial3D", {"albedo_color": col((0.22, 0.3, 0.24)), "roughness": "1.0"})
    bark = k.s.res(M("wood"), "Material")
    t = 0
    for side in (-1, 1):
        for i in range(16):
            x = x0 - 4 + i * ((W + 8) / 15) + rng.uniform(-0.8, 0.8)
            z = (z0 - 5.5 - rng.uniform(0, 3.5)) if side < 0 else (z1 + 5.5 + rng.uniform(0, 3.5))
            s = rng.uniform(0.85, 1.35)
            k.s.node("Trunk%d" % t, "MeshInstance3D", "Props", position=v3((x, 1.5 * s, z)), scale=v3((s, s, s)), mesh=trunk, material_override=bark)
            k.s.node("Crown%d" % t, "MeshInstance3D", "Props", position=v3((x, 3.4 * s + 3.0, z)), scale=v3((s, s, s)), mesh=crown, material_override=foliage)
            t += 1
    for name, z, ln in (("HillN", z0 - 12.5, W + 40), ("HillS", z1 + 12.5, W + 40)):
        k.s.node(name, "MeshInstance3D", "Backdrop", position=v3((cx, 2.5, z)), mesh=k.s.subres("BoxMesh", {"size": v3((ln, 7.0, 6.0))}), material_override=hills)
    SKY_M = 16.0
    sky_w, sky_d = W + 2 * SKY_M, D + 2 * SKY_M
    for name, pos, size in (("SkyN", (cx, 8.0, z0 - SKY_M), (sky_w, 24.0, 0.5)), ("SkyS", (cx, 8.0, z1 + SKY_M), (sky_w, 24.0, 0.5)),
                            ("SkyW", (x0 - SKY_M, 8.0, cz), (0.5, 24.0, sky_d)), ("SkyE", (x1 + SKY_M, 8.0, cz), (0.5, 24.0, sky_d))):
        k.block(name, "Backdrop", pos, size, "sky_dawn")
    k.block("SkyTop", "Backdrop", (cx, 15.0, cz), (sky_w, 0.5, sky_d), "sky_dawn")
