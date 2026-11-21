#!/usr/bin/env python3
"""Sonidos de Skull (la criatura) y de la escena del aplauso, SINTETIZADOS (sin bancos de terceros: no hay licencia
que registrar). Uso: python3 tools/audio/build_creature.py
Escribe assets/audio/sfx/{creature_step_far,creature_door_smash,creature_roar_far,applause_slow_1,hum_far_1}.ogg
(contrato de nombres de docs/AUDIO_PLAN.md). Desde el servidor no se puede oír: aprobar por oído en el teléfono."""
import os
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import shots as S

R = S.RATE
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "assets", "audio", "sfx")
rng = np.random.default_rng(1307)


def t_(sec: float) -> np.ndarray:
    return np.arange(int(R * sec)) / R


def filt(x: np.ndarray, lo: float = 0.0, hi: float = R / 2) -> np.ndarray:
    """Pasa-banda por FFT con bordes suaves."""
    X = np.fft.rfft(x)
    f = np.fft.rfftfreq(len(x), 1.0 / R)
    g = np.ones_like(f)
    if lo > 0:
        g *= 1.0 / (1.0 + (lo / np.maximum(f, 1e-3)) ** 4)
    if hi < R / 2:
        g *= 1.0 / (1.0 + (f / hi) ** 4)
    return np.fft.irfft(X * g, len(x))


def env_exp(n: int, decay: float, attack: float = 0.004) -> np.ndarray:
    t = np.arange(n) / R
    a = np.minimum(1.0, t / max(attack, 1e-4))
    return a * np.exp(-t / decay)


def place(buf: np.ndarray, x: np.ndarray, at: float, gain: float = 1.0) -> None:
    i = int(at * R)
    j = min(len(buf), i + len(x))
    if i < len(buf):
        buf[i:j] += x[: j - i] * gain


def reverb(x: np.ndarray, taps: list) -> np.ndarray:
    out = np.zeros(len(x) + int(R * max(d for d, _ in taps)) + 1)
    out[: len(x)] += x
    for d, g in taps:
        place(out, x, d, g)
    return out


def thud(freq0: float, freq1: float, sec: float, decay: float) -> np.ndarray:
    t = t_(sec)
    f = freq1 + (freq0 - freq1) * np.exp(-t / 0.05)
    ph = 2 * np.pi * np.cumsum(f) / R
    return np.sin(ph) * env_exp(len(t), decay, 0.002)


def put(name: str, x: np.ndarray, peak_db: float = -3.0, fade: float = 0.1) -> None:
    n = S.save_ogg(S.finish(x.copy(), peak_db, fade), os.path.join(OUT, name + ".ogg"))
    print("%-22s %5.2f s  %6d bytes" % (name, len(x) / R, n))


# --- Pasos de Skull a lo lejos: dos golpes graves húmedos, el segundo más suave ---
b = np.zeros(int(R * 1.6))
for at, g in ((0.05, 1.0), (0.78, 0.7)):
    n = int(R * 0.7)
    body = thud(78, 34, 0.7, 0.16)
    scuff = filt(rng.standard_normal(n), 60, 700) * env_exp(n, 0.10, 0.01) * 0.55
    place(b, body + scuff, at, g)
put("creature_step_far", filt(b, 25, 1200))

# --- Puerta rota a lo lejos: madera que cruje, golpe grave, metal que vibra ---
b = np.zeros(int(R * 2.2))
n = int(R * 0.9)
crash = filt(rng.standard_normal(n), 120, 3200) * env_exp(n, 0.16, 0.001)
place(b, crash, 0.0, 0.9)
for _ in range(14):                                    # astillas: clics de madera sueltos
    c = filt(rng.standard_normal(int(R * 0.03)), 800, 4500) * env_exp(int(R * 0.03), 0.006, 0.0005)
    place(b, c, rng.uniform(0.02, 0.55), rng.uniform(0.25, 0.7))
place(b, thud(95, 38, 0.9, 0.22), 0.0, 1.0)
n = int(R * 1.8)
ring = sum(np.sin(2 * np.pi * f * t_(1.8) + rng.uniform(0, 6.28)) * g
           for f, g in ((231, 0.30), (389, 0.22), (643, 0.15), (1010, 0.08)))
place(b, ring * env_exp(n, 0.45, 0.003), 0.03, 0.25)
put("creature_door_smash", filt(reverb(b, [(0.09, 0.4), (0.21, 0.25), (0.37, 0.15)]), 35, 5500))

# --- Rugido apagado a lo lejos: voz grave rasposa, cae de tono, atenuada por la distancia ---
sec = 3.4
t = t_(sec)
f0 = 62 + 38 * np.exp(-((t - 0.5) / 0.9) ** 2) - 14 * (t / sec)
f0 = f0 * (1 + 0.012 * np.sin(2 * np.pi * 5.5 * t))   # temblor
ph = 2 * np.pi * np.cumsum(f0) / R
glot = sum(np.sin(k * ph + 0.4 * k) / k ** 0.8 for k in range(1, 22))
glot += 0.5 * filt(rng.standard_normal(len(t)), 150, 2500) * (0.5 + 0.5 * np.sin(2 * np.pi * 31 * t))   # rasposo
voice = np.tanh(1.8 * glot / np.max(np.abs(glot)))
formant = filt(voice, 90, 900) + 0.6 * filt(voice, 700, 1500)
amp = np.minimum(1.0, t / 0.35) * np.exp(-np.maximum(t - 1.4, 0) / 0.9)
put("creature_roar_far", filt(reverb(formant * amp, [(0.12, 0.4), (0.3, 0.25), (0.55, 0.15)]), 40, 1500), fade=0.25)

# --- Aplauso lento y distante: palmas sueltas, una cada ~0,9 s, con la sala devolviéndolas ---
sec = 7.0
b = np.zeros(int(R * sec))
at = 0.6
while at < 6.0:
    n = int(R * 0.05)
    clap = filt(rng.standard_normal(n), 900, 4200) * env_exp(n, 0.012, 0.0006)
    place(b, clap, at, rng.uniform(0.75, 1.0))
    at += rng.uniform(0.85, 1.05)
put("applause_slow_1", filt(reverb(b, [(0.07, 0.5), (0.16, 0.4), (0.29, 0.3), (0.47, 0.2), (0.7, 0.12)]), 250, 3800), -8.0, 0.4)

# --- Tarareo lejano por altavoz: una nana desafinada, voz de mujer, con siseo de cable ---
notes = [(392.0, 0.55), (440.0, 0.55), (392.0, 0.55), (329.6, 0.9), (349.2, 0.55), (311.1, 0.55), (293.7, 1.1)]   # la última baja medio tono: inquieta
b = np.zeros(int(R * 6.4))
at = 0.4
for fr, dur in notes:
    n = int(R * (dur + 0.15))
    t = np.arange(n) / R
    f = fr * (1 + 0.006 * np.sin(2 * np.pi * 5.2 * t)) * (1 - 0.015 * (t / (dur + 0.15)))
    ph = 2 * np.pi * np.cumsum(f) / R
    tone = sum(np.sin(k * ph) / k ** 1.2 for k in range(1, 9))
    tone = filt(tone, 200, 1400) + 0.25 * filt(rng.standard_normal(n), 400, 1800) * 0.3   # «mm» nasal con aire
    a = np.minimum(1.0, t / 0.08) * np.minimum(1.0, (dur + 0.15 - t) / 0.12)
    place(b, tone * a, at, 0.6)
    at += dur
b += 0.03 * filt(rng.standard_normal(len(b)), 2500, 7000)    # siseo del altavoz
put("hum_far_1", filt(b, 300, 3200), -9.0, 0.5)
