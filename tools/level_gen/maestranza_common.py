import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, "..", ".."))
if HERE not in sys.path:
    sys.path.insert(0, HERE)

from roomkit import Kit


# Las salas se DISEÑAN en un espacio normalizado de 16 x 10 (X0..X1, Z0..Z1) y se construyen del tamaño real que pida
# cada una (`size=(ancho, fondo)` en metros): cada posición de objeto se escala con SX/SZ de ESA sala. Así una sala
# puede ser un pasillo largo y angosto o un galpón alto y ancho sin reescribir sus objetos.
X0, X1, Z0, Z1 = -8.0, 8.0, -5.0, 5.0
PREV = "res://levels/maestranza/%s.tscn"
NEXT = "res://levels/maestranza/%s.tscn"
_PLACE = ("block", "prop", "pickup", "note", "infected", "examine", "door", "label", "leo_hint", "interact", "spawn", "decal", "light")
_OCCUPY = ("prop", "pickup", "note", "infected", "examine", "door", "leo_hint", "interact", "spawn")


def _squeeze(k, sx, sz):
    """Envuelve los métodos de colocación: la primera tupla de 3 números (la posición) se escala en X y Z.
    Los métodos originales quedan en k.raw (medidas reales) para escaleras y balcones (vertical.py)."""
    k._used = []
    k.raw = {}
    for name in _PLACE:
        if not hasattr(k, name):
            continue
        orig = getattr(k, name)
        k.raw[name] = orig

        def wrapped(*args, _orig=orig, _name=name, **kw):
            args = list(args)
            for i, a in enumerate(args):
                if isinstance(a, (tuple, list)) and len(a) == 3 and all(isinstance(v, (int, float)) for v in a):
                    args[i] = (a[0] * sx, a[1], a[2] * sz)
                    if _name in _OCCUPY:
                        k._used.append((a[0] * sx, a[2] * sz))
                    break
            return _orig(*args, **kw)
        setattr(k, name, wrapped)


def create_room(root_name, room_name, ambience, dark=False, final=False, theme=None, size=(12.0, 8.0), height=4.4):
    xr, zr = size[0] / 2.0, size[1] / 2.0
    sx, sz = xr / X1, zr / Z1
    k = Kit(root_name, room_name, dark=dark, ambience=ambience)
    k.theme = theme
    k.XR, k.ZR, k.H, k.SX, k.SZ = xr, zr, height, sx, sz
    k.env((0.055, 0.06, 0.07), (0.42, 0.44, 0.47), 0.9, (0.12, 0.14, 0.17), 0.018)
    k.block("Floor", "Shell", (0.0, -0.5, 0.0), (2 * xr + 0.6, 1.0, 2 * zr + 0.6), "concrete_floor")
    k.block("Ceiling", "Shell", (0.0, height + 0.05, 0.0), (2 * xr + 0.6, 0.1, 2 * zr + 0.6), "concrete_wall")
    k.block("NorthWall", "Shell", (0.0, height / 2.0, -zr - 0.15), (2 * xr + 0.3, height, 0.3), "bricks_wall")
    k.block("SouthWall", "Shell", (0.0, height / 2.0, zr + 0.15), (2 * xr + 0.3, height, 0.3), "concrete_wall")
    seg = zr - 0.9                                  # tramo de muro a cada lado de la puerta (hueco de 1,8 m)
    lintel_h = height - 2.2
    # Las paredes laterales quedan abiertas en las puertas: la llegada nunca atraviesa un muro.
    x = -xr - 0.15
    k.block("WestWallNorth", "Shell", (x, height / 2.0, -(0.9 + seg / 2)), (0.3, height, seg), "concrete_wall")
    k.block("WestWallSouth", "Shell", (x, height / 2.0, 0.9 + seg / 2), (0.3, height, seg), "concrete_wall")
    k.block("WestLintel", "Shell", (x, 2.2 + lintel_h / 2.0, 0.0), (0.3, lintel_h, 1.8), "concrete_wall")
    k.door_frame("ArrivalFrame", -xr, 0.0, "z", width=1.6, wall_side=1, panel="metal")
    k.block("WestPlug", "Shell", (-xr - 1.2, (height - 1.0) / 2.0, 0.0), (0.4, height + 1.0, 3.2), "soot")   # tapa el hueco de la puerta: ninguna cámara ve el vacío
    if final:
        k.block("EastWall", "Shell", (xr + 0.15, height / 2.0, 0.0), (0.3, height, 2 * zr), "concrete_wall")
    else:
        x = xr + 0.15
        k.block("EastWallNorth", "Shell", (x, height / 2.0, -(0.9 + seg / 2)), (0.3, height, seg), "concrete_wall")
        k.block("EastWallSouth", "Shell", (x, height / 2.0, 0.9 + seg / 2), (0.3, height, seg), "concrete_wall")
        k.block("EastLintel", "Shell", (x, 2.2 + lintel_h / 2.0, 0.0), (0.3, lintel_h, 1.8), "concrete_wall")
        k.door_frame("AdvanceFrame", xr, 0.0, "z", width=1.6, wall_side=-1, panel="metal")
        k.block("EastPlug", "Shell", (xr + 1.2, (height - 1.0) / 2.0, 0.0), (0.4, height + 1.0, 3.2), "soot")
    # Cámaras provisionales (una por mitad de la sala, dentro de ella); Claude planifica las definitivas.
    for tag, sign in (("West", -1.0), ("East", 1.0)):
        k.camera(tag, (sign * xr / 2, height / 2.0, 0.0), (xr, height, 2 * zr - 0.2),
                 (-sign * xr * 0.12, height * 0.82, -sign * zr * 0.8), (sign * xr * 0.5, 0.5, 0.0), fov=62)
    _squeeze(k, sx, sz)                             # de aquí en adelante todo se escribe en el espacio de diseño 16 x 10
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


def save_room(k, filename, **dress_kw):
    if getattr(k, "theme", None):
        import detail
        avoid = [(x, z, 0.6) for x, z in k._used] + list(dress_kw.pop("avoid", []))
        detail.dress(k, -k.XR + 0.3, k.XR - 0.3, -k.ZR + 0.3, k.ZR - 0.3, k.H, k.theme, seed=sum(map(ord, filename)),
                     sq=(k.SX, k.SZ), avoid=avoid, **dress_kw)
    output_dir = os.path.join(REPO, "levels", "maestranza")
    os.makedirs(output_dir, exist_ok=True)
    k.save(os.path.join(output_dir, filename + ".tscn"))
