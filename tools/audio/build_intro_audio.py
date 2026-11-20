#!/usr/bin/env python3
"""Pista de sonido de la cinemática de apertura (7,5 s): viento y grillos del andén, zumbido eléctrico y
chasquidos sincronizados con las caídas de la luz de sodio. Uso: python3 tools/audio/build_intro_audio.py salida.wav"""
import os
import subprocess
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import shots as S

SECONDS = 7.5
ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..")
rate = S.RATE
n = int(rate * SECONDS)
amb = S.load_mono(os.path.join(ROOT, "assets", "audio", "ambience", "station_night.ogg"))[:n]
amb = S.rms_norm(amb, -26.0)
rng = np.random.default_rng(11)
t = np.arange(n) / rate
# Zumbido de 100 Hz (red eléctrica) que sube y baja con la luz.
hum = 0.05 * np.sin(2 * np.pi * 100 * t) + 0.025 * np.sin(2 * np.pi * 200 * t)
# Caídas de la luz: en render_cinematic.gd, int(tiempo * 4) % 7 == 3 -> cada 1,75 s durante 0,25 s.
buzz = np.zeros(n, dtype=np.float32)
for k in range(8):
    start = (3 + 7 * k) / 4.0
    if start >= SECONDS:
        break
    a, b = int(start * rate), min(n, int((start + 0.25) * rate))
    burst = rng.standard_normal(b - a).astype(np.float32)
    burst = S.rms_norm(np.convolve(burst, np.ones(3) / 3, mode="same"), -22.0)
    env = np.exp(-np.linspace(0, 6, b - a)) * (rng.random(b - a) > 0.35)
    buzz[a:b] += burst * env.astype(np.float32)
    hum[a:b] *= 0.2
fade_in = np.clip(t / 1.2, 0, 1)
fade_out = np.clip((SECONDS - t) / 1.4, 0, 1)
mix = (amb + hum + buzz * 0.8) * fade_in * fade_out
mix = S.finish(mix.astype(np.float32), -3.0, 0.0)
out = sys.argv[1]
pcm = (np.clip(mix, -1, 1) * 32767).astype("<i2").tobytes()
subprocess.run(["ffmpeg", "-v", "error", "-y", "-f", "s16le", "-ar", str(rate), "-ac", "1", "-i", "-", out], input=pcm, check=True)
print("audio listo:", out, "%.1f s" % SECONDS)
