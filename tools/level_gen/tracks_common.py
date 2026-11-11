# Piezas comunes de las salas exteriores del capítulo 2 (la vía de noche).
import math
from roomkit import *

def night(k, fog=0.05):
    k.env((0.04, 0.045, 0.06), (0.32, 0.34, 0.42), 0.5, (0.05, 0.05, 0.065), fog)
    k.s.node("Moon", "DirectionalLight3D", ".", rotation=v3((-0.95, 0.6, 0)), light_color=col((0.55, 0.62, 0.8)), light_energy="0.28")

def track_bed(k, x0, x1, z0, z1, track_z=None, track_len=None, track_x=None, track_rot=0.0):
    W, D = x1 - x0, z1 - z0
    k.block("Ground", "Ground", ((x0 + x1) / 2, -0.5, (z0 + z1) / 2), (W + 0.6, 1, D + 0.6), "gravel")
    if track_z is not None:
        length = track_len or W
        cx = track_x if track_x is not None else (x0 + x1) / 2
        p = {"position": v3((cx, 0.0, track_z)), "script": k.s.res("res://levels/kit/rail_track.gd", "Script"),
             "length": fmt(float(length)), "sleeper_material": k.s.res(M("wood"), "Material"), "rail_material": k.s.res(M("metal"), "Material")}
        if track_rot: p["rotation"] = v3((0, track_rot, 0))
        k.s.node("Track%s" % fmt(float(cx)).replace("-", "m").replace(".", "_"), "Node3D", "Ground", **p)

def walls(k, x0, x1, z0, z1, h=5.8, north="old_bricks_wall", south="concrete_wall", west="concrete_wall", east="concrete_wall"):
    W, D = x1 - x0, z1 - z0
    cx, cz = (x0 + x1) / 2, (z0 + z1) / 2
    k.block("NorthWall", "Walls", (cx, h / 2 - 0.3, z0 - 0.15), (W + 0.6, h, 0.3), north)
    k.block("SouthWall", "Walls", (cx, h / 2 - 0.3, z1 + 0.15), (W + 0.6, h, 0.3), south)
    k.block("WestWall", "Walls", (x0 - 0.15, h / 2 - 0.3, cz), (0.3, h, D), west)
    k.block("EastWall", "Walls", (x1 + 0.15, h / 2 - 0.3, cz), (0.3, h, D), east)

def fence_top(k, x0, x1, z, y):
    n = int((x1 - x0) / 1.8) + 1
    for i in range(n):
        k.block("FencePost%d" % i, "Walls", (x0 + i * 1.8, y + 0.5, z), (0.06, 1.0, 0.06), "metal", solid=False)
    k.block("FenceRail", "Walls", ((x0 + x1) / 2, y + 0.95, z), (x1 - x0, 0.05, 0.05), "metal", solid=False)
    k.block("FenceRail2", "Walls", ((x0 + x1) / 2, y + 0.5, z), (x1 - x0, 0.04, 0.04), "metal", solid=False)

def luggage(k, name, pos, rot=0.0, size=(0.6, 0.4, 0.35), mat="planks"):
    k.block(name, "Props", (pos[0], size[1] / 2, pos[2]), size, mat, solid=False, rot=(0, rot, 0))
