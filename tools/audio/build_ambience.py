#!/usr/bin/env python3
"""Arma los ambientes en bucle de Paine (uno por sala; docs/AUDIO_PLAN.md §5) mezclando capas CC0
de OpenGameArt. Uso: AUDIO_RAW=/ruta/raw python3 tools/audio/build_ambience.py
Escribe assets/audio/ambience/<ambiente>.ogg (mono, 32 kHz, lazo de 24 s sin corte)."""
import os
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import shots as S
from build_weapons import band  # noqa: F401

RAW = os.environ.get("AUDIO_RAW", "raw")
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "assets", "audio", "ambience")
LENGTH = 24.0

SRC = {
    "wind": "wind1/wind1.wav", "wind_soft": "wind/_x/wind/Wind.ogg", "crickets": "crickets-ambient-noise-loopable/crickets_1.mp3",
    "drone1": "the-shop/_x/TheShopCollection_convenience_store_drinks_fridge_drone.wav",
    "drone2": "the-shop/_x/TheShopCollection_convenience_store_drinks_fridge_drone_2.wav",
    "dungeon": "loopable-dungeon-ambience/dungeon_ambient_1_0.ogg", "drip": "dripping-water-loop/atmosbasement.mp3_.flac",
    "eerie1": "4-atmospheric-ghostly-loops/_x/atmosmoody/atmoseerie01.mp3.flac",
    "eerie2": "4-atmospheric-ghostly-loops/_x/atmosmoody/atmoseerie02.mp3.flac",
    "eerie3": "4-atmospheric-ghostly-loops/_x/atmosmoody/atmoseerie03.mp3.flac",
    "eerie4": "4-atmospheric-ghostly-loops/_x/atmosmoody/atmoseerie04.mp3.flac",
    "fire": "fireplace-sound-loop/fire.wav", "birds": "ambient-bird-sounds/birds-isaiah658_0.ogg",
    "river": "sea-and-river-wave-sounds/VistulaShort_0.mp3", "hum": "ghostly-humming/ghostly_humming.ogg",
    "static": "static/ScatterNoise1.mp3",
}
_cache = {}


def layer(name: str, gain: float, lo: float = 20.0, hi: float = 14000.0, start: float = 0.0) -> np.ndarray:
    """Una capa: se lee, se filtra, se nivela y se vuelve bucle de LENGTH segundos."""
    if name not in _cache:
        _cache[name] = S.load_mono(os.path.join(RAW, SRC[name]))
    x = _cache[name][int(S.RATE * start):]
    x = band(x[: int(S.RATE * (LENGTH + 6))], lo, hi) if len(x) > 0 else x
    loop = S.make_loop(x, LENGTH, 2.5)
    return S.rms_norm(loop, -30.0) * gain


RECIPES = {
    "station_night": [("wind", 1.0, 80, 2500), ("crickets", 0.35, 2000, 9000), ("drone1", 0.15, 40, 300)],
    "waiting_room": [("drone2", 0.5, 40, 1200), ("wind", 0.15, 60, 600)],
    "office": [("drone1", 0.3, 40, 500), ("eerie4", 0.25, 40, 400)],
    "service_corridor": [("eerie3", 0.35, 100, 1500), ("drip", 0.35, 300, 6000), ("drone2", 0.25, 40, 400)],
    "storeroom": [("dungeon", 0.8, 30, 1200), ("drip", 0.25, 300, 6000)],
    "tracks_night": [("wind", 1.1, 80, 3000), ("crickets", 0.5, 2000, 9000)],
    "fire_wreck": [("fire", 1.0, 40, 6000), ("wind", 0.35, 60, 1200), ("eerie2", 0.25, 30, 300)],
    "train_interior": [("hum", 0.35, 60, 800), ("eerie1", 0.3, 30, 300)],
    "underpass": [("drip", 0.7, 300, 6000), ("dungeon", 0.5, 30, 800), ("eerie2", 0.2, 30, 300)],
    "switch_house": [("birds", 0.45, 800, 9000), ("wind_soft", 0.25, 60, 1500), ("drone1", 0.12, 40, 300)],
    "day_fields": [("wind", 0.9, 80, 3500), ("birds", 0.55, 800, 9000)],
    "bridge_river": [("river", 1.0, 60, 9000), ("wind", 0.35, 80, 2500)],
    "military": [("wind", 0.7, 80, 2500), ("static", 0.12, 400, 3500), ("drone2", 0.15, 40, 400)],
    "barn": [("dungeon", 0.3, 60, 1500), ("birds", 0.15, 800, 9000), ("wind", 0.25, 60, 1500)],
}

# Nivel de cada ambiente (RMS en dBFS): todos parecidos, con las salas más tensas un poco más bajas.
LEVEL = {"underpass": -28.0, "service_corridor": -27.0, "storeroom": -26.0, "office": -26.0, "waiting_room": -25.0}
DEFAULT_LEVEL = -24.0

total = 0
for name, layers in RECIPES.items():
    mixed = S.rms_norm(sum(layer(*args) for args in layers).astype(np.float32), LEVEL.get(name, DEFAULT_LEVEL))
    peak = float(np.max(np.abs(mixed)))
    if peak > 0.8:  # que ningún pico se acerque a saturar
        mixed = mixed * (0.8 / peak)
    n = S.save_ogg(mixed, os.path.join(OUT, name + ".ogg"), quality=1.0)
    total += n
    print("%-18s %5.1f s %7.1f KB" % (name, len(mixed) / S.RATE, n / 1024))
print("TOTAL: %d ambientes, %.2f MB" % (len(RECIPES), total / 1048576))
