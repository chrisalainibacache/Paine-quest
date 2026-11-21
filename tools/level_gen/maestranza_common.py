import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, "..", ".."))
if HERE not in sys.path:
    sys.path.insert(0, HERE)

from roomkit import Kit


# Las salas se DISEÑAN en un espacio de 16 x 10 m (X0..X1, Z0..Z1) y se construyen más chicas (12 x 8 m): cada
# posición de objeto se comprime con SX/SZ. Salas pequeñas = mejores cámaras y menos carga en el teléfono.
X0, X1, Z0, Z1 = -8.0, 8.0, -5.0, 5.0
SX, SZ = 0.75, 0.8
XR, ZR, HEIGHT = X1 * SX, Z1 * SZ, 4.4          # medidas reales: 12 x 8 m, techo a 4,4 m
PREV = "res://levels/maestranza/%s.tscn"
NEXT = "res://levels/maestranza/%s.tscn"
_PLACE = ("block", "prop", "pickup", "note", "infected", "examine", "door", "label", "leo_hint", "interact", "spawn", "decal", "light")


def _squeeze(k):
    """Envuelve los métodos de colocación: la primera tupla de 3 números (la posición) se comprime en X y Z."""
    for name in _PLACE:
        if not hasattr(k, name):
            continue
        orig = getattr(k, name)

        def wrapped(*args, _orig=orig, **kw):
            args = list(args)
            for i, a in enumerate(args):
                if isinstance(a, (tuple, list)) and len(a) == 3 and all(isinstance(v, (int, float)) for v in a):
                    args[i] = (a[0] * SX, a[1], a[2] * SZ)
                    break
            return _orig(*args, **kw)
        setattr(k, name, wrapped)


def create_room(root_name, room_name, ambience, dark=False, final=False):
    k = Kit(root_name, room_name, dark=dark, ambience=ambience)
    k.env((0.055, 0.06, 0.07), (0.42, 0.44, 0.47), 0.9, (0.12, 0.14, 0.17), 0.018)
    k.block("Floor", "Shell", (0.0, -0.5, 0.0), (2 * XR + 0.6, 1.0, 2 * ZR + 0.6), "concrete_floor")
    k.block("Ceiling", "Shell", (0.0, HEIGHT + 0.05, 0.0), (2 * XR + 0.6, 0.1, 2 * ZR + 0.6), "concrete_wall")
    k.block("NorthWall", "Shell", (0.0, HEIGHT / 2.0, -ZR - 0.15), (2 * XR + 0.3, HEIGHT, 0.3), "bricks_wall")
    k.block("SouthWall", "Shell", (0.0, HEIGHT / 2.0, ZR + 0.15), (2 * XR + 0.3, HEIGHT, 0.3), "concrete_wall")
    seg = ZR - 0.9                                  # tramo de muro a cada lado de la puerta (hueco de 1,8 m)
    lintel_h = HEIGHT - 2.2
    # Las paredes laterales quedan abiertas en las puertas: la llegada nunca atraviesa un muro.
    x = -XR - 0.15
    k.block("WestWallNorth", "Shell", (x, HEIGHT / 2.0, -(0.9 + seg / 2)), (0.3, HEIGHT, seg), "concrete_wall")
    k.block("WestWallSouth", "Shell", (x, HEIGHT / 2.0, 0.9 + seg / 2), (0.3, HEIGHT, seg), "concrete_wall")
    k.block("WestLintel", "Shell", (x, 2.2 + lintel_h / 2.0, 0.0), (0.3, lintel_h, 1.8), "concrete_wall")
    k.door_frame("ArrivalFrame", -XR, 0.0, "z", width=1.6, wall_side=1, panel="metal")
    k.block("WestPlug", "Shell", (-XR - 1.2, (HEIGHT - 1.0) / 2.0, 0.0), (0.4, HEIGHT + 1.0, 3.2), "soot")   # tapa el hueco de la puerta: ninguna cámara ve el vacío
    if final:
        k.block("EastWall", "Shell", (XR + 0.15, HEIGHT / 2.0, 0.0), (0.3, HEIGHT, 2 * ZR), "concrete_wall")
    else:
        x = XR + 0.15
        k.block("EastWallNorth", "Shell", (x, HEIGHT / 2.0, -(0.9 + seg / 2)), (0.3, HEIGHT, seg), "concrete_wall")
        k.block("EastWallSouth", "Shell", (x, HEIGHT / 2.0, 0.9 + seg / 2), (0.3, HEIGHT, seg), "concrete_wall")
        k.block("EastLintel", "Shell", (x, 2.2 + lintel_h / 2.0, 0.0), (0.3, lintel_h, 1.8), "concrete_wall")
        k.door_frame("AdvanceFrame", XR, 0.0, "z", width=1.6, wall_side=-1, panel="metal")
        k.block("EastPlug", "Shell", (XR + 1.2, (HEIGHT - 1.0) / 2.0, 0.0), (0.4, HEIGHT + 1.0, 3.2), "soot")
    # Cámaras provisionales; Claude planifica las definitivas (en medidas reales).
    k.camera("West", (-3.0, 1.5, 0.0), (6.0, 3.0, 8.0), (-1.0, 3.6, 3.5), (-3.0, 0.5, 0.0), fov=62)
    k.camera("East", (3.0, 1.5, 0.0), (6.0, 3.0, 8.0), (1.0, 3.6, -3.5), (3.0, 0.5, 0.0), fov=62)
    _squeeze(k)                                     # de aquí en adelante todo se escribe en el espacio de diseño 16 x 10
    k.spawn("from_previous", (-6.45, 0.05, 0.0), (1, 0))
    if not final:
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
