#!/usr/bin/env python3
"""Camuflaje boscoso (256x256, repetible) para el uniforme del soldado infectado.
Uso: python3 tools/ui/build_camo.py  ->  assets/characters/infected/camo_woodland.png"""
import os
import numpy as np
from PIL import Image

N = 256
rng = np.random.default_rng(77)
y, x = np.mgrid[0:N, 0:N] / N * 2 * np.pi


def field(octaves):
    """Ruido periódico (suma de senos con fases al azar): se repite sin costuras."""
    f = np.zeros((N, N))
    for k, amp in octaves:
        for _ in range(4):
            a, b = rng.integers(1, k + 1, 2) * rng.choice([-1, 1], 2)
            f += amp * np.sin(a * x + b * y + rng.uniform(0, 6.28))
    return f


base = field([(2, 1.0), (4, 0.6)])
detail = field([(6, 0.5), (11, 0.3)])
img = np.zeros((N, N, 3))
img[:] = (0.19, 0.22, 0.13)                          # verde oliva
tan = (base + 0.25 * detail) > 0.55
brown = (field([(3, 1.0), (5, 0.5)]) + 0.2 * detail) > 0.85
black = (field([(4, 1.0), (8, 0.4)]) + 0.3 * detail) > 1.35
img[tan] = (0.37, 0.34, 0.22)
img[brown] = (0.19, 0.13, 0.08)
img[black] = (0.06, 0.06, 0.05)
img *= (0.92 + 0.08 * rng.random((N, N, 1)))          # grano de tela
out = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "assets", "characters", "infected", "camo_woodland.png")
Image.fromarray((np.clip(img, 0, 1) * 255).astype(np.uint8)).save(out)
print("camuflaje:", out)
