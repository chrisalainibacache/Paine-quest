#!/usr/bin/env python3
"""Herramientas de audio de Paine (corren en el servidor, no en el teléfono).

Parte un archivo largo de disparos en disparos sueltos, recorta, normaliza y exporta
.ogg mono (Godot 4 solo lee Ogg Vorbis) siguiendo el contrato de nombres de docs/AUDIO_PLAN.md.
Uso (ver tools/audio/README.md): python3 tools/audio/shots.py <comando> ...
"""
import os
import subprocess
import sys

import numpy as np

RATE = 32000


def load_mono(path: str, rate: int = RATE) -> np.ndarray:
    """Lee cualquier audio como mono float32 a `rate` Hz (usa ffmpeg)."""
    out = subprocess.run(["ffmpeg", "-v", "error", "-i", path, "-ac", "1", "-ar", str(rate), "-f", "f32le", "-"],
                         capture_output=True, check=True).stdout
    return np.frombuffer(out, dtype=np.float32).copy()


def envelope(x: np.ndarray, ms: float = 4.0) -> np.ndarray:
    n = max(1, int(RATE * ms / 1000))
    return np.convolve(np.abs(x), np.ones(n) / n, mode="same")


def find_onsets(x: np.ndarray, min_gap: float = 0.7, rel: float = 0.12) -> list:
    """Inicios de cada disparo: sube sobre `rel` × el pico y antes hubo `min_gap` s de calma."""
    env = envelope(x)
    thr = float(env.max()) * rel
    quiet_need = int(RATE * min_gap)
    onsets = []
    last_loud = -10**9
    i = 0
    while i < len(env):
        if env[i] > thr:
            if i - last_loud > quiet_need:
                onsets.append(i)
            last_loud = i
        i += 1
    return onsets


def cut(x: np.ndarray, start: int, max_len: float, floor_db: float = -52.0, pre: float = 0.006) -> np.ndarray:
    """Recorta desde `start` hasta que la cola baja de `floor_db` (o `max_len` s)."""
    s = max(0, start - int(RATE * pre))
    end = min(len(x), s + int(RATE * max_len))
    seg = x[s:end]
    peak = float(np.max(np.abs(seg))) or 1.0
    env = envelope(seg, 20.0) / peak
    floor = 10 ** (floor_db / 20)
    above = np.where(env > floor)[0]
    stop = int(above[-1]) + int(RATE * 0.05) if len(above) else len(seg)
    return seg[:min(stop, len(seg))]


def finish(seg: np.ndarray, peak_db: float = -1.0, fade: float = 0.12) -> np.ndarray:
    """Normaliza el pico y suaviza el final (evita chasquidos)."""
    peak = float(np.max(np.abs(seg))) or 1.0
    seg = seg * (10 ** (peak_db / 20) / peak)
    n = min(len(seg), int(RATE * fade))
    if n > 0:
        seg[-n:] *= np.linspace(1.0, 0.0, n)
    return seg


def save_ogg(x: np.ndarray, path: str, quality: float = 3.0) -> int:
    """Escribe un .ogg mono (Vorbis, con oggenc) y devuelve su tamaño en bytes.
    Requiere `oggenc` (paquete vorbis-tools); el codificador interno de ffmpeg solo hace estéreo."""
    os.makedirs(os.path.dirname(path), exist_ok=True)
    pcm = (np.clip(x, -1, 1) * 32767).astype("<i2").tobytes()
    subprocess.run(["oggenc", "-Q", "-q", str(quality), "--raw", "--raw-bits=16", "--raw-chan=1",
                    "--raw-rate=%d" % RATE, "-o", path, "-"], input=pcm, check=True)
    return os.path.getsize(path)


def report(x: np.ndarray, label: str) -> str:
    env = envelope(x, 10.0)
    rms = float(np.sqrt(np.mean(x ** 2))) + 1e-9
    # Centroide espectral (brillo): bajo = grave/pesado, alto = seco/agudo.
    spec = np.abs(np.fft.rfft(x[:RATE])) if len(x) else np.array([0.0])
    freqs = np.fft.rfftfreq(min(len(x), RATE) or 1, 1 / RATE)
    centroid = float((freqs * spec).sum() / (spec.sum() + 1e-9)) if len(spec) == len(freqs) else 0.0
    return "%-28s %5.2f s  pico %5.1f dBFS  rms %6.1f dB  brillo %5.0f Hz" % (
        label, len(x) / RATE, 20 * np.log10(float(np.max(np.abs(x))) + 1e-9), 20 * np.log10(rms), centroid)


if __name__ == "__main__":
    # Modo exploración: python3 shots.py explore archivo.wav
    if len(sys.argv) >= 3 and sys.argv[1] == "explore":
        data = load_mono(sys.argv[2])
        marks = find_onsets(data)
        print("%s: %.1f s, %d disparos" % (os.path.basename(sys.argv[2]), len(data) / RATE, len(marks)))
        for k, o in enumerate(marks):
            seg = cut(data, o, 3.0)
            print("  #%d en %.2f s -> %s" % (k + 1, o / RATE, report(seg, "")))
