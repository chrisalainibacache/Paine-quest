import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, "..", ".."))
if HERE not in sys.path:
    sys.path.insert(0, HERE)

from roomkit import Kit


X0, X1, Z0, Z1, HEIGHT = -8.0, 8.0, -5.0, 5.0, 3.8
PREV = "res://levels/maestranza/%s.tscn"
NEXT = "res://levels/maestranza/%s.tscn"


def create_room(root_name, room_name, ambience, dark=False, final=False):
    k = Kit(root_name, room_name, dark=dark, ambience=ambience)
    k.env((0.055, 0.06, 0.07), (0.42, 0.44, 0.47), 0.9, (0.12, 0.14, 0.17), 0.018)
    k.block("Floor", "Shell", (0.0, -0.5, 0.0), (16.6, 1.0, 10.6), "concrete_floor")
    k.block("Ceiling", "Shell", (0.0, HEIGHT + 0.05, 0.0), (16.6, 0.1, 10.6), "concrete_wall")
    k.block("NorthWall", "Shell", (0.0, HEIGHT / 2.0, Z0 - 0.15), (16.3, HEIGHT, 0.3), "bricks_wall")
    k.block("SouthWall", "Shell", (0.0, HEIGHT / 2.0, Z1 + 0.15), (16.3, HEIGHT, 0.3), "concrete_wall")
    # Las paredes laterales quedan abiertas en las puertas: la llegada nunca atraviesa un muro.
    x = X0 - 0.15
    k.block("WestWallNorth", "Shell", (x, HEIGHT / 2.0, -2.95), (0.3, HEIGHT, 4.1), "concrete_wall")
    k.block("WestWallSouth", "Shell", (x, HEIGHT / 2.0, 2.95), (0.3, HEIGHT, 4.1), "concrete_wall")
    k.block("WestLintel", "Shell", (x, 3.1, 0.0), (0.3, 1.4, 1.8), "concrete_wall")
    k.door_frame("ArrivalFrame", X0, 0.0, "z", width=1.6, wall_side=1, panel="metal")
    if final:
        k.block("EastWall", "Shell", (X1 + 0.15, HEIGHT / 2.0, 0.0), (0.3, HEIGHT, 10.0), "concrete_wall")
    else:
        x = X1 + 0.15
        k.block("EastWallNorth", "Shell", (x, HEIGHT / 2.0, -2.95), (0.3, HEIGHT, 4.1), "concrete_wall")
        k.block("EastWallSouth", "Shell", (x, HEIGHT / 2.0, 2.95), (0.3, HEIGHT, 4.1), "concrete_wall")
        k.block("EastLintel", "Shell", (x, 3.1, 0.0), (0.3, 1.4, 1.8), "concrete_wall")
        k.door_frame("AdvanceFrame", X1, 0.0, "z", width=1.6, wall_side=-1, panel="metal")
    # Cámaras provisionales; Claude planifica las definitivas.
    k.camera("West", (-4.0, 1.5, 0.0), (8.0, 3.0, 10.0), (-1.0, 4.8, 7.0), (-4.0, 0.5, 0.0), fov=62)
    k.camera("East", (4.0, 1.5, 0.0), (8.0, 3.0, 10.0), (1.0, 4.8, -7.0), (4.0, 0.5, 0.0), fov=62)
    k.spawn("from_previous", (-6.45, 0.05, 0.0), (1, 0))
    k.spawn("from_next", (6.45, 0.05, 0.0), (-1, 0))
    return k


def connect_room(k, previous_name, next_name, next_label, first=False):
    if first:
        k.spawn("start", (-6.45, 0.05, 0.0), (1, 0))
    else:
        k.door("ToPrevious", (X0 + 0.2, 0.0, 0.0), PREV % previous_name, "from_next",
               prompt="VOLVER", reach=1.4, metal_door=True)
    k.door("ToNext", (X1 - 0.2, 0.0, 0.0), NEXT % next_name, "from_previous",
           prompt="AVANZAR", reach=1.4, marker=next_label, metal_door=True)


def save_room(k, filename):
    output_dir = os.path.join(REPO, "levels", "maestranza")
    os.makedirs(output_dir, exist_ok=True)
    k.save(os.path.join(output_dir, filename + ".tscn"))
