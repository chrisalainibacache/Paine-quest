#!/usr/bin/env python3
"""Arma la música de Paine: recorta un tramo de cada tema de Kevin MacLeod (incompetech.com, CC BY 4.0)
y lo vuelve bucle (fundido de 4 s). Uso: AUDIO_RAW=/ruta/raw python3 tools/audio/build_music.py
Escribe assets/audio/music/<pista>.ogg (estéreo, 32 kHz). Créditos obligatorios en CREDITS.md."""
import os
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import shots as S

RAW = os.environ.get("AUDIO_RAW", "raw")
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "assets", "audio", "music")
# pista -> (archivo, largo del lazo en s, modo): calm = tramo estable y suave; intense = el tramo más fuerte
TRACKS = {
    "title": ("Ossuary_1_-_A_Beginning.mp3", 80, "calm"),
    "explore_night": ("Dark_Fog.mp3", 90, "calm"),
    "explore_day": ("Lightless_Dawn.mp3", 90, "calm"),
    "tension": ("Unseen_Horrors.mp3", 70, "intense"),
    "safe": ("Hidden_Past.mp3", 70, "calm"),
    "leo": ("Heartbreaking.mp3", 80, "calm"),
}
LEVEL_DB = -22.0


def pick_window(x: np.ndarray, length: float, mode: str, margin: float = 12.0) -> int:
    """Inicio (en muestras) del tramo: 'calm' = el de menos variación de volumen; 'intense' = el de más volumen."""
    mono = x.mean(axis=1)
    sec = S.RATE
    rms = np.array([np.sqrt(np.mean(mono[i * sec:(i + 1) * sec] ** 2)) + 1e-9 for i in range(len(mono) // sec)])
    n = int(length)
    lo, hi = int(margin), max(int(margin) + 1, len(rms) - n - int(margin))
    best, best_score = lo, None
    for s in range(lo, hi):
        w = rms[s:s + n]
        score = -float(np.mean(w)) if mode == "intense" else float(np.std(w) / (np.mean(w) + 1e-9))
        if mode == "calm" and np.mean(w) < 0.4 * np.median(rms):  # no elegir un tramo casi mudo
            continue
        if best_score is None or score < best_score:
            best, best_score = s, score
    return best * sec


total = 0
for name, (file, length, mode) in TRACKS.items():
    x = S.load_stereo(os.path.join(RAW, "music", file))
    start = pick_window(x, length, mode)
    seg = x[start: start + int(S.RATE * (length + 4))]
    loops = np.stack([S.make_loop(seg[:, c], length, 4.0) for c in range(2)], axis=1)
    loops = S.rms_norm(loops, LEVEL_DB)
    peak = float(np.max(np.abs(loops)))
    if peak > 0.85:
        loops = loops * (0.85 / peak)
    n = S.save_ogg_stereo(loops, os.path.join(OUT, name + ".ogg"), quality=2.0)
    total += n
    print("%-14s %-26s desde %5.1f s  lazo %3d s  %6.0f KB" % (name, file, start / S.RATE, length, n / 1024))
print("TOTAL: %d pistas, %.2f MB" % (len(TRACKS), total / 1048576))
