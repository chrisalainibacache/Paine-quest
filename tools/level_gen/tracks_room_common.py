"""Helpers for the four P16 interiors, using the shared Maestranza room pipeline."""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, "..", ".."))
if HERE not in sys.path:
    sys.path.insert(0, HERE)

from maestranza_common import create_room


def add_north_door(k, width=1.8, wall="old_bricks_wall"):
    """Replace the north wall with two real wall segments and a walkable door gap."""
    k.s.nodes = [(header, props) for header, props in k.s.nodes
                 if not header.startswith('[node name="NorthWall"')]
    block = k.raw["block"]
    xr, zr, h = k.XR, k.ZR, k.H
    half = width / 2.0
    left = xr - half
    if left > 0.2:
        block("NorthWallLeft", "Shell", ((-xr - half) / 2.0, h / 2.0, -zr - 0.15),
              (left, h, 0.3), wall)
        block("NorthWallRight", "Shell", ((xr + half) / 2.0, h / 2.0, -zr - 0.15),
              (left, h, 0.3), wall)
    block("NorthDoorLintel", "Shell", (0.0, 2.3 + max(0.1, h - 2.3) / 2.0, -zr - 0.15),
          (width, max(0.1, h - 2.3), 0.3), wall)
    k.door_frame("NorthServiceFrame", 0.0, -zr, "x", width=width - 0.2, wall_side=1, panel="metal")


def add_detail_props(k, prefix):
    """Story clutter distributed along both long walls; detail.dress adds the base pass."""
    scenes = [
        "oil_barrel", "workbench", "shelf_unit", "cable_drum", "tire", "ladder", "crate", "filing_cabinet", "notice_board",
        "extinguisher", "office_desk", "locker_row", "wall_lantern", "hanging_lamp", "pipe_rack", "plant_pot", "park_bench", "shelf_unit"
    ]
    for index, scene in enumerate(scenes):
        row, column = divmod(index, 9)
        x = -7.1 + column * 1.775
        z = -4.0 if row == 0 else 4.0
        y = 1.55 if scene in ("notice_board", "wall_lantern", "hanging_lamp", "pipe_rack", "extinguisher") else 0.0
        k.prop("%sProp%02d" % (prefix, index), "Props", scene, (x, y, z),
               rot=(0.0, (index % 4) * 0.22, 0.0))


def finish_tracks_room(k, filename, seed, extra_avoid=(), avoid_rects=()):
    import detail
    avoid = [(x, z, 0.65) for x, z in getattr(k, "_used", [])]
    avoid.extend(extra_avoid)
    detail.dress(k, -k.XR + 0.3, k.XR - 0.3, -k.ZR + 0.3, k.ZR - 0.3,
                 k.H, k.theme or "storage", seed=seed, sq=(k.SX, k.SZ),
                 avoid=avoid, avoid_rects=avoid_rects)
    output = os.path.join(REPO, "levels", "tracks", filename + ".tscn")
    os.makedirs(os.path.dirname(output), exist_ok=True)
    k.s.save(output)
    print(filename + ": generador listo")
