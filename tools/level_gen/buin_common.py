# Piezas comunes del capítulo 3 (Buin, sábado en la mañana).
import math
from roomkit import *
from tracks_common import walls, fence_top, luggage, track_bed

B = "res://levels/buin/%s.tscn"


def dawn(k, fog=0.012):
    """Mañana nublada: luz difusa y un sol bajo y tibio (contraste con la noche).
    Niebla suave: más densa se come el color en el teléfono."""
    k.env((0.6, 0.62, 0.68), (0.6, 0.6, 0.64), 0.9, (0.56, 0.58, 0.64), fog)
    k.s.node("Sun", "DirectionalLight3D", ".", rotation=v3((-0.55, 2.3, 0)), light_color=col((1.0, 0.86, 0.7)), light_energy="1.15")


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
