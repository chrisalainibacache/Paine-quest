"""Pasada de detalle para cualquier sala hecha con roomkit.Kit: estructura (zócalo, pilastras, vigas), instalaciones
(tuberías, lámparas, extintores), suciedad (calcomanías) y mobiliario por tema. Sirve para cumplir el estándar de
docs/ESTANDAR_DETALLE.md (el andén norte es la referencia) con una sola llamada:

    import detail
    detail.dress(k, -6, 6, -4, 4, 4.4, theme="workshop", seed=3)       # medidas REALES del interior (m)
    detail.dress(k, ..., sq=(0.75, 0.8))                                  # salas de La Maestranza (se comprimen solas)

Temas: workshop, infirmary, locker, guard, corridor, office, storage, bathroom. El centro de la sala (|z| < 1.4) queda libre
para caminar y para las puertas de los muros este y oeste. `avoid` = lista de (x, z, radio) donde no poner nada."""
import math
import random

THEMES = {
    "workshop":  {"dado": "rust", "wall": "old_bricks_wall", "items": ["workbench", "shelf_unit", "oil_barrel", "oil_barrel", "oil_barrel", "cable_drum", "tire", "tire", "ladder", "crate", "crate", "workbench", "shelf_unit"]},
    "infirmary": {"dado": "tiles_wall", "wall": "plaster_wall", "items": ["cot", "cot", "cot", "cot", "shelf_unit", "filing_cabinet", "notice_board", "extinguisher", "cot", "shelf_unit"]},
    "locker":    {"dado": "olive", "wall": "concrete_wall", "items": ["locker_row", "locker_row", "locker_row", "park_bench", "park_bench", "notice_board", "shelf_unit", "extinguisher", "locker_row", "plant_pot"]},
    "guard":     {"dado": "olive", "wall": "concrete_wall", "items": ["office_desk", "filing_cabinet", "filing_cabinet", "notice_board", "sandbags", "crate", "shelf_unit", "extinguisher", "office_desk", "crate"]},
    "corridor":  {"dado": "paint_red", "wall": "concrete_wall", "items": ["shelf_unit", "oil_barrel", "oil_barrel", "extinguisher", "notice_board", "crate", "crate", "tire", "shelf_unit", "filing_cabinet"]},
    "office":    {"dado": "wood", "wall": "plaster_wall", "items": ["office_desk", "filing_cabinet", "filing_cabinet", "shelf_unit", "notice_board", "plant_pot", "extinguisher", "office_desk", "filing_cabinet"]},
    "storage":   {"dado": "rust", "wall": "bricks_wall", "items": ["shelf_unit", "shelf_unit", "crate", "crate", "crate", "oil_barrel", "oil_barrel", "cable_drum", "ladder", "shelf_unit", "crate"]},
    "bathroom": {"dado": "tiles_wall", "wall": "plaster_wall", "items": ["shelf_unit", "notice_board", "extinguisher", "plant_pot", "filing_cabinet", "locker_row", "shelf_unit", "extinguisher", "plant_pot"]},
}
WALL_DECALS = ["cracks", "wall_hole_a", "bullet_holes", "blood_splatter_a", "damp_stain", "wall_hole_b", "blood_splatter_b", "cracks"]
FLOOR_DECALS = ["oil_stain", "debris", "damp_stain", "blood_drag", "blood_footprints", "blood_smear", "debris", "blood_pool"]
CLEAR = 1.4     # franja central libre (|z| < CLEAR)


def dress(k, x0, x1, z0, z1, h, theme="workshop", seed=1, sq=(1.0, 1.0), avoid=(), doors_z=(0.0,)):
    rnd = random.Random(seed)
    sx, sz = sq
    T = THEMES[theme]
    W, D = x1 - x0, z1 - z0
    cx, cz = (x0 + x1) / 2, (z0 + z1) / 2
    P = lambda x, y, z: (x / sx, y, z / sz)           # real -> espacio de diseño (los envoltorios de Maestranza lo comprimen)
    ok = lambda x, z, r=0.9: all(math.hypot(x - ax, z - az) > r + ar for ax, az, ar in avoid) and all(abs(z - dz) > 1.3 or (x0 + 1.2 < x < x1 - 1.2) for dz in doors_z)

    # --- Estructura de muros: zócalo, moldura, pilastras y rodapié (N y S) ---
    for tag, zw, face in (("N", z0 + 0.03, 1.0), ("S", z1 - 0.03, -1.0)):
        k.block("DadoMid" + tag, "Detail", P(cx, 0.55, zw), (W - 0.1, 1.1, 0.05), T["dado"], solid=False)
        k.block("DadoCap" + tag, "Detail", P(cx, 1.12, zw + 0.02 * face), (W - 0.1, 0.06, 0.09), "wood", solid=False)
        k.block("Base" + tag, "Detail", P(cx, 0.07, zw + 0.02 * face), (W - 0.1, 0.14, 0.09), "concrete_wall", solid=False)
        for i in range(int(W // 3.0)):
            x = x0 + 1.5 + i * 3.0
            k.block("Pilaster%s%d" % (tag, i), "Detail", P(x, h / 2 - 0.2, zw + 0.015 * face), (0.3, h - 0.4, 0.06), "concrete_wall", solid=False)
    # --- Ventanas con reja y vidrio luminoso en el muro norte; costuras del piso ---
    for i, x in enumerate((x0 + W * 0.2, x0 + W * 0.55, x0 + W * 0.85)):
        if abs(x - x0 - W * 0.5) > 0.6 or i != 1:
            k.mesh("Window%d" % i, "Detail", (1.3, 1.0, 0.03), k.s.res("res://levels/kit/materials/window_glow.tres", "Material"), P(x, 2.2, z0 + 0.1))
            k.block("Sill%d" % i, "Detail", P(x, 1.65, z0 + 0.12), (1.5, 0.08, 0.16), "wood", solid=False)
            k.block("Lintel%d" % i, "Detail", P(x, 2.78, z0 + 0.12), (1.5, 0.1, 0.16), "wood", solid=False)
            for j in range(4):
                k.block("Bar%d_%d" % (i, j), "Detail", P(x - 0.45 + j * 0.3, 2.2, z0 + 0.09), (0.035, 1.0, 0.035), "metal", solid=False)
    for i in range(1, 7):
        k.block("Seam%d" % i, "Detail", P(x0 + i * W / 7.0, 0.012, cz), (0.04, 0.01, D - 0.2), "soot", solid=False)
    for i in range(1, 4):
        k.block("SeamZ%d" % i, "Detail", P(cx, 0.012, z0 + i * D / 4.0), (W - 0.2, 0.01, 0.04), "soot", solid=False)
    # --- Techo: vigas cada 1,5 m y viga maestra ---
    for i in range(int(W // 1.5)):
        x = x0 + 0.9 + i * 1.5
        k.block("Beam%d" % i, "Detail", P(x, h - 0.16, cz), (0.14, 0.22, D - 0.2), "metal", solid=False)
    k.block("Girder", "Detail", P(cx, h - 0.4, cz), (W - 0.2, 0.18, 0.2), "metal", solid=False)
    # --- Instalaciones: tubería, lámparas colgantes, extintor, aviso ---
    k.prop("PipeRack", "Detail", "pipe_rack", P(cx - 0.5, 0, z0 + 0.12), rot=(0, 0, 0))
    for i, x in enumerate((x0 + W * 0.28, x0 + W * 0.72)):
        k.prop("HangLamp%d" % i, "Detail", "hanging_lamp", P(x, h - 0.1, cz + (1.0 if i else -1.0)))
    for i, x in enumerate((x0 + W * 0.18, cx, x0 + W * 0.82)):
        k.prop("WallLantern%d" % i, "Detail", "wall_lantern", P(x, 2.35, z0 + 0.1), rot=(0, 0, 0))
    k.prop("Extinguisher", "Detail", "extinguisher", P(x0 + 0.5, 0.35, z1 - 0.2), rot=(0, math.pi, 0))
    k.prop("Clock", "Detail", "wall_clock", P(x1 - 1.6, 2.6, z0 + 0.1))
    for i in range(3):
        k.block("Conduit%d" % i, "Detail", P(x0 + 0.25 + i * 0.12, h / 2, z0 + 0.1), (0.04, h - 0.3, 0.04), "metal", solid=False)

    # --- Mobiliario por tema, en dos hileras contra los muros N y S ---
    slots = []
    for zrow, face, tag in ((z0 + 0.55, 0.0, "N"), (z1 - 0.55, math.pi, "S")):
        n = int((W - 2.4) // 1.6)
        for i in range(n):
            slots.append((x0 + 1.6 + i * 1.6 + rnd.uniform(-0.1, 0.1), zrow, face))
    rnd.shuffle(slots)
    placed = 0
    for scene in T["items"]:
        while slots:
            x, z, face = slots.pop()
            if abs(z) >= CLEAR and ok(x, z):
                k.prop("%s%d" % (scene.title().replace("_", ""), placed), "Props", scene, P(x, 0.0, z), rot=(0, face + rnd.uniform(-0.15, 0.15), 0))
                placed += 1
                break
    # Desorden de esquina: cajas apiladas y un barril caído en el rincón.
    for i, (x, z) in enumerate(((x1 - 0.7, z1 - 0.7), (x0 + 0.7, z0 + 0.7))):
        if ok(x, z, 0.6):
            k.prop("CornerCrate%d" % i, "Props", "crate", P(x, 0.0, z), rot=(0, rnd.uniform(0, 3), 0))
            k.prop("CornerCrateTop%d" % i, "Props", "crate", P(x, 0.9, z), rot=(0, rnd.uniform(0, 3), 0))

    # --- Suciedad: calcomanías en muros y piso ---
    walls = [("+z", z0 + 0.012, "N"), ("-z", z1 - 0.012, "S")]
    for i, tex in enumerate(WALL_DECALS):
        normal, zw, tag = walls[i % 2]
        x = x0 + 1.0 + rnd.random() * (W - 2.0)
        y = 0.9 + rnd.random() * 2.0
        k.decal("WallDirt%d" % i, tex, P(x, y, zw), rnd.uniform(0.9, 1.5), normal, rot=rnd.uniform(-0.3, 0.3), wear=0.3)
    for i, tex in enumerate(FLOOR_DECALS):
        x = x0 + 1.0 + rnd.random() * (W - 2.0)
        z = z0 + 0.8 + rnd.random() * (D - 1.6)
        k.decal("FloorDirt%d" % i, tex, P(x, 0.016, z), (rnd.uniform(1.0, 2.0), rnd.uniform(0.8, 1.4)), "up", rot=rnd.uniform(0, 3.1))
    # Rótulos en los muros (texto del mundo).
    k.label("StencilN", "Details", P(x0 + W * 0.7, 2.7, z0 + 0.08), "ÁREA RESTRINGIDA" if theme in ("storage", "corridor") else "SECTOR " + theme[:3].upper(), 26, (0.82, 0.78, 0.66))
    k.label("StencilS", "Details", P(x0 + W * 0.3, 2.5, z1 - 0.08), "PROHIBIDO FUMAR", 22, (0.8, 0.3, 0.25), rot=(0, math.pi, 0))
