#!/usr/bin/env python3
"""Arma los sonidos de armas de Paine a partir de bancos CC0 de OpenGameArt.
Uso: AUDIO_RAW=/ruta/a/raw python3 tools/audio/build_weapons.py
Escribe assets/audio/sfx/<nombre>_N.ogg (contrato de docs/AUDIO_PLAN.md). Fuentes en CREDITS.md."""
import glob
import os
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import shots as S

RAW = os.environ.get("AUDIO_RAW", "raw")
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "assets", "audio", "sfx")
FIRE = os.path.join(RAW, "firearms", "Prepared SFX Library")
written = []


def put(name: str, x: np.ndarray, peak_db: float, fade: float = 0.12) -> None:
    n = S.save_ogg(S.finish(x.copy(), peak_db, fade), os.path.join(OUT, name + ".ogg"))
    written.append((name, len(x) / S.RATE, n))


def shots_of(path: str, count: int, max_len: float, floor_db: float = -52.0) -> list:
    data = S.load_mono(path)
    return [S.cut(data, o, max_len, floor_db) for o in S.find_onsets(data)[:count]]


def resample(x: np.ndarray, factor: float) -> np.ndarray:
    """Cambia el tono y la duración (factor < 1 = más grave y más lento)."""
    idx = np.arange(0, len(x) - 1, factor)
    return np.interp(idx, np.arange(len(x)), x).astype(np.float32)


def band(x: np.ndarray, lo: float, hi: float) -> np.ndarray:
    spec = np.fft.rfft(x)
    f = np.fft.rfftfreq(len(x), 1 / S.RATE)
    spec[(f < lo) | (f > hi)] = 0
    return np.fft.irfft(spec, len(x)).astype(np.float32)


def whoosh(seconds: float, lo: float, hi: float, seed: int) -> np.ndarray:
    rng = np.random.default_rng(seed)
    n = int(S.RATE * seconds)
    noise = band(rng.standard_normal(n).astype(np.float32), lo, hi)
    t = np.linspace(0, 1, n)
    return noise * (np.minimum(t * 12, 1) * np.exp(-3.2 * t)).astype(np.float32)


def mix(parts: list) -> np.ndarray:
    """Suma sonidos [(audio, retraso_s, ganancia)] alineados por el inicio."""
    end = max(int(d * S.RATE) + len(a) for a, d, g in parts)
    out = np.zeros(end, dtype=np.float32)
    for a, d, g in parts:
        s = int(d * S.RATE)
        out[s:s + len(a)] += a * g
    return out


def main() -> None:
    global written
    # --- Disparos reales (casi sin eco: Godot puede agregar reverb de sala después) ---
    for i, seg in enumerate(shots_of(f"{FIRE}/Walther PPQ/X_39P.wav", 3, 1.2), 1):
        put(f"shot_{i}", seg, -1.0)                                    # pistola 9 mm
    for i, seg in enumerate(shots_of(f"{FIRE}/1911/A_42P.wav", 2, 1.3), 1):
        put(f"mauser_{i}", seg, -1.0)                                  # pistola pesada (.45)
    shotguns = shots_of(f"{FIRE}/Mossberg/N_30P.wav", 2, 1.6) + shots_of(f"{FIRE}/Nova/O_21P.wav", 2, 1.6)
    for i, seg in enumerate(shotguns, 1):
        put(f"shotgun_{i}", seg, -1.0)
    for i, seg in enumerate(shots_of(f"{FIRE}/Mosin Nagant/M_21P.wav", 3, 2.0), 1):
        put(f"rifle_{i}", seg, -1.0)                                   # fusil de cerrojo
    for i, seg in enumerate(shots_of(f"{FIRE}/AK-47/C_29P.wav", 2, 1.8), 1):
        put(f"assault_{i}", seg, -1.0)                                 # ráfaga corta

    # --- Lanzagranadas y bazuca: disparo de escopeta grave y hueco + silbido de gas ---
    base = shotguns[2]
    launcher = band(resample(base, 0.7), 60, 2600)
    put("launcher_1", mix([(launcher, 0.0, 1.0), (whoosh(0.5, 300, 2500, 1), 0.02, 0.5)]), -2.0, 0.2)
    heavy = band(resample(shotguns[3], 0.52), 40, 2200)
    put("bazooka_1", mix([(heavy, 0.0, 1.0), (whoosh(0.95, 200, 2200, 2), 0.02, 0.6)]), -2.0, 0.25)

    # --- Explosiones: golpe seco + estallido + retumbo grave que se apaga ---
    bang = S.load_mono(f"{RAW}/25-cc0-bang-firework-sfx/25-CC0-bang-sfx_x/cannon_01.ogg")
    crack = S.load_mono(f"{RAW}/explosion-0/explosion.wav")
    rumble = S.load_mono(f"{RAW}/muffled-distant-explosion/NenadSimic - Muffled Distant Explosion.wav")
    rumble = rumble[: int(S.RATE * 3.2)]
    put("explosion_1", mix([(bang, 0.0, 1.0), (crack, 0.01, 0.8), (rumble, 0.06, 0.9)]), -0.5, 0.5)
    bang2 = S.load_mono(f"{RAW}/25-cc0-bang-firework-sfx/25-CC0-bang-sfx_x/bang_03.ogg")
    synth = S.load_mono(f"{RAW}/synthesized-explosion/synthetic_explosion_1.flac")
    put("explosion_2", mix([(bang2, 0.0, 1.0), (synth, 0.02, 0.9), (rumble[int(S.RATE * 0.4):], 0.1, 0.7)]), -0.5, 0.5)

    # --- Mecánica: gatillo vacío, recargas, cargar el arma, casquillos ---
    chamber = S.load_mono(f"{RAW}/shotgun-reload-sound-effects_x/ShotgunSounds/Shell in Chamber.mp3")
    clicks = [S.cut(chamber, o, 0.12, -40.0) for o in S.find_onsets(chamber, 0.15, 0.25)[:2]]
    for i, seg in enumerate(clicks, 1):
        put(f"click_{i}", band(seg, 800, 14000), -9.0, 0.03)
    reloads = [f"{RAW}/2-gun-reloads_x/gun_reload.2.ogg", f"{RAW}/handgun-reload-sound-effect/reload.wav",
               f"{RAW}/gun-reload-sounds/gunreload1.wav"]
    for i, p in enumerate(reloads, 1):
        x = S.load_mono(p)
        start = int(np.argmax(S.envelope(x) > 0.02 * float(np.max(np.abs(x)))))
        put(f"reload_{i}", x[max(0, start - 200):], -7.0, 0.1)
    x = S.load_mono(f"{RAW}/gun-reload-sounds/assaultriflereload1_0.wav")
    put("reload_rifle_1", x, -7.0, 0.1)
    put("weapon_equip_1", S.load_mono(f"{RAW}/gun-reload-sounds/shotguncock_0.wav"), -8.0, 0.06)
    put("shotgun_pump_1", S.load_mono(f"{RAW}/shotgun-reload-sound-effects_x/ShotgunSounds/Rack.mp3"), -6.0, 0.1)
    shells = S.load_mono(f"{RAW}/shotgun-reload-sound-effects_x/ShotgunSounds/Subsequent Shells.mp3")
    for i, o in enumerate(S.find_onsets(shells, 0.2, 0.3)[:2], 1):
        put(f"shell_drop_{i}", band(S.cut(shells, o, 0.35, -42.0), 600, 12000), -14.0, 0.08)

    total = sum(n for _, _, n in written)
    for name, dur, n in written:
        print("%-18s %5.2f s %6.1f KB" % (name, dur, n / 1024))
    print("TOTAL: %d archivos, %.2f MB" % (len(written), total / 1048576))


if __name__ == "__main__":
    main()
