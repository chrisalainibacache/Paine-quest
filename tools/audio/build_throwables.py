#!/usr/bin/env python3
"""Sonidos de los objetos que lanzan los infectados, SINTETIZADOS (sin bancos de terceros).
Uso: python3 tools/audio/build_throwables.py
Escribe assets/audio/sfx/{throw_whoosh_1,glass_break_1,glass_break_2,brick_thud_1,thrown_hit_1}.ogg
(Desde el servidor no se puede oír: aprobar por oído en el teléfono.)"""
import os
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import shots as S

R = S.RATE
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "assets", "audio", "sfx")
rng = np.random.default_rng(2024)


def t_(sec):
    return np.arange(int(R * sec)) / R


def filt(x, lo=0.0, hi=R / 2):
    X = np.fft.rfft(x)
    f = np.fft.rfftfreq(len(x), 1.0 / R)
    g = np.ones_like(f)
    if lo > 0:
        g *= 1.0 / (1.0 + (lo / np.maximum(f, 1e-3)) ** 4)
    if hi < R / 2:
        g *= 1.0 / (1.0 + (f / hi) ** 4)
    return np.fft.irfft(X * g, len(x))


def env_exp(n, decay, attack=0.002):
    t = np.arange(n) / R
    return np.minimum(1.0, t / max(attack, 1e-4)) * np.exp(-t / decay)


def place(buf, x, at, gain=1.0):
    i = int(at * R)
    j = min(len(buf), i + len(x))
    if i < len(buf):
        buf[i:j] += x[: j - i] * gain


def put(name, x, peak_db=-3.0, fade=0.05):
    n = S.save_ogg(S.finish(x.copy(), peak_db, fade), os.path.join(OUT, name + ".ogg"))
    print("%-18s %5.2f s  %6d bytes" % (name, len(x) / R, n))


# Silbido corto del objeto cortando el aire: ruido filtrado cuyo tono sube y baja.
n = int(R * 0.45)
t = t_(0.45)
air = rng.standard_normal(n)
sweep = np.sin(np.pi * np.clip(t / 0.45, 0, 1)) ** 2
whoosh = filt(air, 500, 3500) * sweep * 0.9 + filt(air, 1200, 6000) * sweep ** 2 * 0.3
put("throw_whoosh_1", whoosh, -8.0, 0.06)


# Vidrio que se rompe: golpe seco inicial + lluvia de esquirlas agudas que caen y rebotan.
def glass(seed):
    g = np.random.default_rng(seed)
    b = np.zeros(int(R * 1.1))
    n0 = int(R * 0.05)
    place(b, filt(g.standard_normal(n0), 800, 7000) * env_exp(n0, 0.012), 0.0, 1.0)
    for _ in range(46):
        at = g.exponential(0.16) + 0.01
        f = g.uniform(2600, 7200)
        m = int(R * g.uniform(0.012, 0.05))
        tt = np.arange(m) / R
        shard = np.sin(2 * np.pi * f * tt + g.uniform(0, 6.28)) * env_exp(m, g.uniform(0.006, 0.02), 0.0004)
        place(b, shard, min(at, 0.9), g.uniform(0.15, 0.55))
    return filt(b, 600, 9000)


put("glass_break_1", glass(1), -3.0, 0.15)
put("glass_break_2", glass(7), -3.0, 0.15)

# Ladrillo contra el suelo/pared: golpe sordo + arenilla.
b = np.zeros(int(R * 0.6))
tt = t_(0.4)
f = 55 + 70 * np.exp(-tt / 0.03)
body = np.sin(2 * np.pi * np.cumsum(f) / R) * env_exp(len(tt), 0.09, 0.001)
grit = filt(rng.standard_normal(int(R * 0.25)), 200, 3500) * env_exp(int(R * 0.25), 0.05, 0.001)
place(b, body, 0.0, 1.0)
place(b, grit, 0.0, 0.6)
put("brick_thud_1", b, -3.0, 0.08)

# Golpe de un objeto contra el cuerpo: más "húmedo" y corto.
b = np.zeros(int(R * 0.4))
tt = t_(0.3)
body = np.sin(2 * np.pi * np.cumsum(90 + 110 * np.exp(-tt / 0.02)) / R) * env_exp(len(tt), 0.05, 0.001)
slap = filt(rng.standard_normal(int(R * 0.12)), 400, 4000) * env_exp(int(R * 0.12), 0.02, 0.0008)
place(b, body, 0.0, 0.9)
place(b, slap, 0.0, 0.8)
put("thrown_hit_1", b, -3.0, 0.06)
