#!/usr/bin/env python3
"""Arma los sonidos de puertas y objetos de Paine (bancos CC0 de OpenGameArt).
Uso: AUDIO_RAW=/ruta/a/raw python3 tools/audio/build_objects.py
Escribe assets/audio/sfx/<nombre>_N.ogg (contrato de docs/AUDIO_PLAN.md). Fuentes en CREDITS.md."""
import os
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import shots as S
from build_weapons import band, mix  # noqa: F401

RAW = os.environ.get("AUDIO_RAW", "raw")
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "assets", "audio", "sfx")
written = []


def put(name: str, x: np.ndarray, peak_db: float, fade: float = 0.08) -> None:
    n = S.save_ogg(S.finish(x.copy(), peak_db, fade), os.path.join(OUT, name + ".ogg"))
    written.append((name, len(x) / S.RATE, n))


def load(*parts: str) -> np.ndarray:
    return S.load_mono(os.path.join(RAW, *parts))


def tidy(x: np.ndarray, max_len: float = 1.2, floor_db: float = -48.0) -> np.ndarray:
    """Quita el silencio inicial y la cola casi muda."""
    env = S.envelope(x, 6.0)
    idx = np.where(env > 0.03 * float(env.max()))[0]
    s = max(0, int(idx[0]) - int(S.RATE * 0.01)) if len(idx) else 0
    return S.cut(x, s, max_len, floor_db, pre=0.0)


def lead(x: np.ndarray, ms: float = 10.0) -> np.ndarray:
    """Recorta el inicio para que el golpe caiga a `ms` del comienzo (respuesta inmediata)."""
    peak = int(np.argmax(S.envelope(x, 4.0)))
    return x[max(0, peak - int(S.RATE * ms / 1000)):]


SET = os.path.join("door-open-door-close-set", "_x", "qubodup-DoorSet", "ogg")
DOOR = os.path.join("door-open-door-close", "_x", "door")
MW = os.path.join("100-cc0-metal-and-wood-sfx", "_x")

# --- Puertas: abrir (madera con crujido), cerrar (golpe grave), metal (reja, portón) ---
for i, n in enumerate(["01", "05", "07", "08"], 1):
    put(f"door_{i}", tidy(load(SET, f"qubodup-DoorOpen{n}.ogg")), -4.0, 0.15)
for i, n in enumerate(["04", "07", "08"], 1):
    put(f"door_close_{i}", tidy(load(SET, f"qubodup-DoorClose{n}.ogg"), 0.9), -6.0, 0.12)
put("door_metal_1", tidy(load("iron-door", "iron_door_0.ogg")), -4.0, 0.12)
put("door_metal_2", tidy(load(MW, "metal_open_01.ogg")), -5.0, 0.12)

# --- Trabada (el picaporte no cede), llave y candado, cadena del portón ---
thud1, thud2 = tidy(load(DOOR, "door-05.flac"), 0.5), tidy(load(DOOR, "door-02.flac"), 0.6)
keys3, keys5 = tidy(load(MW, "keys_03.ogg"), 0.5), tidy(load(MW, "keys_05.ogg"), 0.6)
put("locked_1", mix([(thud1, 0.0, 1.0), (keys3, 0.05, 0.6), (keys3, 0.3, 0.45)]), -6.0, 0.1)
put("locked_2", mix([(thud2, 0.0, 1.0), (keys5, 0.04, 0.55), (keys5, 0.28, 0.4)]), -6.0, 0.1)
lock = tidy(load(MW, "lock_open_01.ogg"), 0.8)
key = tidy(load("item-pickup-key", "key-176034.mp3"), 0.6)
put("unlock_1", mix([(key, 0.0, 0.8), (lock, 0.12, 1.0)]), -5.0, 0.1)
put("unlock_2", mix([(lock, 0.0, 1.0), (key, 0.35, 0.5)]), -5.0, 0.1)
chain_dir = os.path.join("chain-winch-sounds", "_x")
put("gate_chain_1", tidy(band(load(chain_dir, "winch - Marker #2.wav"), 150, 9000), 1.6), -6.0, 0.2)
put("gate_chain_2", tidy(band(load(chain_dir, "winch - Marker #7.wav"), 150, 9000), 1.6), -6.0, 0.2)

# --- Objetos: recoger, páginas, máquina de escribir, menú, comer, radio ---
for i, n in enumerate(["misc_02", "misc_08", "misc_04"], 1):
    put(f"pickup_{i}", lead(tidy(load(MW, n + ".ogg"), 0.5), 14.0), -9.0, 0.08)
flips = [("book-flip-sounds", "_x", "BookFlip2.wav"), ("book-flip-sounds", "_x", "BookFlip6.wav"),
         ("book-flip-sounds", "_x", "BookFlip12.wav"), ("10-book-page-flips", "_x", "book_flip.8.ogg")]
for i, p in enumerate(flips, 1):
    put(f"page_{i}", lead(tidy(load(*p), 1.0), 150.0), -9.0, 0.1)
for i in range(1, 6):
    put(f"typewriter_{i}", lead(tidy(load("typewriter-sounds", f"typewriter{i}.wav"), 0.8), 12.0), -8.0, 0.08)
clicks = os.path.join("10-clicks-and-switches", "_x", "10 Clicks and Switches")
for i, n in enumerate([6, 9, 3], 1):
    put(f"menu_{i}", lead(tidy(load(clicks, f"click.{n}.ogg"), 0.3), 6.0), -12.0, 0.03)
for i, n in enumerate([4, 7], 1):
    put(f"heal_{i}", tidy(load("7-eating-crunches", "_x", f"crunch.{n}.ogg"), 0.9), -8.0, 0.12)
noise = load("static", "ScatterNoise1.mp3")
put("radio_static_1", band(noise[int(S.RATE * 1.0): int(S.RATE * 4.0)], 300, 4200), -14.0, 0.4)

total = sum(n for _, _, n in written)
for name, dur, n in written:
    print("%-16s %5.2f s %6.1f KB" % (name, dur, n / 1024))
print("TOTAL: %d archivos, %.2f MB" % (len(written), total / 1048576))
