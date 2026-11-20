#!/usr/bin/env python3
"""Arma los sonidos de infectados e Isabella a partir de bancos CC0 de OpenGameArt.
Uso: AUDIO_RAW=/ruta/a/raw python3 tools/audio/build_infected.py
Escribe assets/audio/sfx/<nombre>_N.ogg (contrato de docs/AUDIO_PLAN.md). Fuentes en CREDITS.md."""
import glob
import os
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import shots as S
from build_weapons import band, mix, resample  # noqa: F401  (mismas utilidades)

RAW = os.environ.get("AUDIO_RAW", "raw")
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "assets", "audio", "sfx")
written = []


def put(name: str, x: np.ndarray, peak_db: float, fade: float = 0.08) -> None:
    n = S.save_ogg(S.finish(x.copy(), peak_db, fade), os.path.join(OUT, name + ".ogg"))
    written.append((name, len(x) / S.RATE, n))


def load(*parts: str) -> np.ndarray:
    return S.load_mono(os.path.join(RAW, *parts))


def head_trim(x: np.ndarray, rel: float = 0.03, keep: float = 0.02) -> np.ndarray:
    """Quita el silencio del inicio."""
    env = S.envelope(x, 6.0)
    idx = np.where(env > rel * float(env.max()))[0]
    s = max(0, int(idx[0]) - int(S.RATE * keep)) if len(idx) else 0
    return x[s:]


def lead(x: np.ndarray, ms: float = 8.0) -> np.ndarray:
    """Recorta el inicio para que el pico del golpe caiga a `ms` del comienzo (impacto inmediato)."""
    peak = int(np.argmax(S.envelope(x, 4.0)))
    return x[max(0, peak - int(S.RATE * ms / 1000)):]


def clip(x: np.ndarray, seconds: float) -> np.ndarray:
    return x[: int(S.RATE * seconds)]


def echo(x: np.ndarray, taps: list) -> np.ndarray:
    """Eco simple [(retraso_s, ganancia)] para dar sensación de lejanía."""
    return mix([(x, 0.0, 1.0)] + [(x, d, g) for d, g in taps])


ZOMBIES = os.path.join("zombies-sound-pack", "_x", "zombies")
MOANS = os.path.join("zombie-moans-01-by-emopreben", "_x")
VOICE = os.path.join("zombie-skeleton-monster-voice-effects", "_x", "Voice Effects Zombie-Skeleton-Monster Human Male")
CREAT = os.path.join("80-cc0-creature-sfx", "_x")
IMPACT = os.path.join("impact", "_x", "qubodupImpact")
SPLAT = os.path.join("8-wet-squish-slurp-impacts", "_x", "impsplat")

# --- Infectados: gruñidos largos y cortos (graves, húmedos) ---
for i, p in enumerate([(MOANS, "ZombieMoans - Track 5 - ZombieMoan1.wav"), (MOANS, "ZombieMoans - Track 7 - ZombieMoan3.wav"),
                       (ZOMBIES, "zombie-17.wav"), (ZOMBIES, "zombie-16.wav")], 1):
    put(f"groan_{i}", head_trim(load(*p)), -3.0, 0.15)
for i, n in enumerate(["zombie-1.wav", "zombie-3.wav", "zombie-4.wav", "zombie-7.wav"], 1):
    put(f"groan_short_{i}", head_trim(load(ZOMBIES, n)), -3.0, 0.08)
# Gruñido lejano: filtrado, bajo y con eco (se oye "al otro lado de la pared").
for i, p in enumerate([(MOANS, "ZombieMoans - Track 6 - ZombieMoan2.wav"), (ZOMBIES, "zombie-18.wav")], 1):
    far = band(head_trim(load(*p)), 60, 750)
    put(f"groan_far_{i}", echo(far, [(0.16, 0.45), (0.34, 0.22)]), -14.0, 0.3)
# Infectado rápido: gritos secos y graves al correr.
for i, n in enumerate(["zombieYell8.wav", "zombieYell2.wav", "zombieYell7.wav"], 1):
    put(f"chase_{i}", head_trim(load(VOICE, n)), -2.0, 0.06)
for i, n in enumerate(["zombieDeath3.wav", "zombieDeath1.wav", "zombieDeath4.wav"], 1):
    put(f"death_{i}", head_trim(load(VOICE, n)), -3.0, 0.1)
# Se levanta del suelo: gorgoteo grave (del "hambriento") recortado.
ghoul = load("hungry-ghoul", "hungry-ghoul_0.ogg")
for i, o in enumerate(S.find_onsets(ghoul, 0.5)[3:5], 1):
    put(f"rise_{i}", band(clip(S.cut(ghoul, o, 1.6), 1.4), 40, 2500), -5.0, 0.2)

# --- Cuerpos: mordida (carne que se desgarra), balazo, caídas y pasos del pesado ---
ripping = load("ripping-into-meat", "rippingintomeat_0.mp3")
ons = S.find_onsets(ripping, 0.5)
meat1, meat2 = head_trim(load(IMPACT, "qubodupImpactMeat01.ogg"), 0.1, 0.004), head_trim(load(IMPACT, "qubodupImpactMeat02.ogg"), 0.1, 0.004)
splat = [head_trim(load(SPLAT, f"impactsplat0{k}.mp3.flac"), 0.1, 0.004) for k in range(1, 9)]
for i, (o, sp) in enumerate(zip(ons[:3], [splat[6], splat[2], splat[3]]), 1):
    rip = clip(S.cut(ripping, o, 0.6), 0.5)
    put(f"bite_{i}", mix([(rip, 0.0, 1.0), (clip(sp, 0.4), 0.02, 0.8)]), -3.0, 0.12)
for i, (m, sp) in enumerate([(meat1, splat[2]), (meat2, splat[3]), (meat2, splat[4]), (meat1, splat[5])], 1):
    put(f"hit_{i}", mix([(clip(lead(m), 0.3), 0.0, 1.0), (clip(lead(sp), 0.3), 0.0, 0.6)]), -4.0, 0.1)
for i, (rate, sp) in enumerate([(0.62, splat[2]), (0.55, splat[3]), (0.7, splat[4])], 1):
    body = lead(band(resample(meat2, rate), 40, 1400), 10.0)
    put(f"fall_{i}", mix([(body, 0.0, 1.0), (clip(lead(sp, 30.0), 0.5), 0.03, 0.55)]), -4.0, 0.15)
for i, rate in enumerate([0.42, 0.5], 1):
    put(f"heavy_step_{i}", clip(band(resample(meat2, rate), 35, 900), 0.55), -5.0, 0.2)

# --- Isabella: quejidos al recibir daño y respiración cansada ---
female = load("female-hurt-grunts-groans", "female_hurt_grunts_groans_1.ogg")
fon = S.find_onsets(female, 0.6)
for i, k in enumerate([0, 2, 4], 1):
    put(f"hurt_{i}", clip(S.cut(female, fon[k], 1.2), 0.85), -4.0, 0.15)
for i, k in enumerate([1, 5], 1):
    put(f"hurt_low_{i}", band(clip(S.cut(female, fon[k], 1.8), 1.4), 80, 3000), -8.0, 0.3)
breath = head_trim(load(CREAT, "breath.ogg"))
put("breath_low_1", mix([(breath, 0.0, 1.0), (breath, 0.9, 0.9), (breath, 1.8, 0.8)]), -10.0, 0.25)

total = sum(n for _, _, n in written)
for name, dur, n in written:
    print("%-16s %5.2f s %6.1f KB" % (name, dur, n / 1024))
print("TOTAL: %d archivos, %.2f MB" % (len(written), total / 1048576))
