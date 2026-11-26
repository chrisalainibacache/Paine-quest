"""Detalle común de la Estación: arquitectura secundaria, utilería, decals y cámaras.
Cada sala mantiene su geometría principal y su propia distribución narrativa."""
import math
from roomkit import v3


def add_station_detail(k, room_key, prop_types, labels, camera_specs, bounds):
    x0, x1, z0, z1 = bounds
    cx = (x0 + x1) / 2.0
    cz = (z0 + z1) / 2.0
    width = x1 - x0
    depth = z1 - z0

    # Vigas y cableado del techo (nodos individuales para el estándar de detalle).
    for index in range(10):
        x = x0 + 0.45 + (width - 0.9) * index / 9.0
        k.block("DetailBeam%d" % index, "DetailArchitecture", (x, 2.78, cz),
                (0.09, 0.12, depth - 0.65), "rust", solid=False)
    for index in range(8):
        z = z0 + 0.35 + (depth - 0.7) * index / 7.0
        k.block("DetailCable%d" % index, "DetailArchitecture", (cx, 2.62, z),
                (width - 0.7, 0.035, 0.035), "metal", solid=False)

    # Paneles de pared y cajas de mantenimiento, dispuestos en los perímetros.
    for index in range(12):
        side = index % 4
        step = (index // 4) * 1.15 - 1.15
        if side == 0:
            pos = (x0 + 0.12, 1.45, cz + step)
            size = (0.12, 0.85, 0.62)
        elif side == 1:
            pos = (x1 - 0.12, 1.45, cz + step)
            size = (0.12, 0.85, 0.62)
        elif side == 2:
            pos = (cx + step, 1.45, z0 + 0.12)
            size = (0.62, 0.85, 0.12)
        else:
            pos = (cx + step, 1.45, z1 - 0.12)
            size = (0.62, 0.85, 0.12)
        k.block("WallPanel%d" % index, "DetailArchitecture", pos, size,
                "tiles_wall" if index % 2 else "wood", solid=False)

    # Cajas y tablones de contexto, no colisionables para mantener los pasillos.
    for index in range(18):
        x = x0 + 0.65 + (width - 1.3) * (index % 6) / 5.0
        z = z0 + 0.55 if index < 9 else z1 - 0.55
        y = 0.18 + 0.12 * (index % 3)
        k.block("DetailCrate%d" % index, "DetailArchitecture", (x, y, z),
                (0.28 + 0.04 * (index % 3), 0.28, 0.24), "planks", solid=False)

    # Utilería instanciada: 42 piezas pequeñas, con 18 familias para evitar
    # una sala de clones. El generador principal coloca los interactuables.
    positions = []
    for z in (z0 + 0.55, z0 + 1.35, cz, z1 - 1.35, z1 - 0.55):
        for x in (x0 + 0.55, x0 + 1.35, cx, x1 - 1.35, x1 - 0.55):
            positions.append((x, 0.03, z))
    for index in range(42):
        scene_name = prop_types[index % len(prop_types)]
        pos = positions[index % len(positions)]
        # Se alterna altura para que los papeles y objetos pequeños queden en mesas.
        y = pos[1] + (0.55 if index % 4 == 0 else 0.0)
        k.prop("%sProp%02d" % (room_key, index), "DetailProps", scene_name,
               (pos[0], y, pos[2]), scale=v3((0.38, 0.38, 0.38)))

    # Rótulos de orientación y de seguridad.
    for index, text in enumerate(labels[:8]):
        x = x0 + 0.35 + (width - 0.7) * index / 7.0
        z = z0 + 0.04 if index % 2 == 0 else z1 - 0.04
        k.label("%sSign%d" % (room_key, index), "DetailSigns", (x, 2.25, z),
                text, 24, (0.78, 0.68, 0.48), rot=(0, math.pi if index % 2 else 0, 0))

    # 18 marcas de uso: sangre, humedad, grasa, huellas y daños de pared.
    decal_textures = [
        "blood_splatter_a", "blood_smear", "blood_handprint", "bullet_holes",
        "wall_hole_a", "cracks", "blood_pool", "blood_drag",
        "blood_footprints", "debris", "damp_stain", "oil_stain",
        "blood_splatter_b", "wall_hole_b", "blood_pool", "damp_stain",
        "blood_drag", "debris",
    ]
    for index, texture in enumerate(decal_textures):
        x = x0 + 0.4 + (width - 0.8) * (index % 6) / 5.0
        z = z0 + 0.4 + (depth - 0.8) * (index // 6) / 2.0
        size = 0.65 + 0.12 * (index % 5)
        k.decal("%sDecal%d" % (room_key, index), texture, (x, 0.014, z),
                size, "up", rot=0.31 * index, opacity=0.65 if index % 2 else 0.9)

    # Dos temperaturas de luz y un punto de emergencia.
    k.light("%sWarm" % room_key, "DetailLights", (x0 + 1.0, 2.45, z0 + 1.0),
            (1.0, 0.72, 0.42), 0.9, 4.0)
    k.light("%sCool" % room_key, "DetailLights", (x1 - 1.0, 2.45, z1 - 1.0),
            (0.58, 0.72, 1.0), 0.75, 4.0, flicker=True)
    k.light("%sEmergency" % room_key, "DetailLights", (cx, 2.2, cz),
            (0.65, 0.08, 0.05), 0.5, 3.0, flicker=True)

    for name, zone_center, zone_size, camera_pos, target in camera_specs:
        k.camera("%sCamera%s" % (room_key, name), zone_center, zone_size,
                 camera_pos, target, fov=62)
