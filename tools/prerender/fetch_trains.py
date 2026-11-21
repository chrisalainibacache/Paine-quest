#!/usr/bin/env python3
"""Baja los trenes reales (CC0) para los fondos prerenderizados y los deja listos para Godot.
Modelos (todos CC0 1.0, uso comercial libre):
  - Locomotora diésel   — tevy.dev/models/diesel-locomotive (LOD1, ~21.000 triángulos)
  - Vagón cerrado       — tevy.dev/models/covered-freight-wagon (LOD1, ~14.000)
  - Coche de pasajeros  — grab3d.com/models/vehicles/passenger-car (variante Light, ~14.900)
Los GLB de tevy vienen con compresión meshopt y cuantización, que Godot no lee: se convierten con
`gltf-transform` (npm). Resultado en render_src/trains/ (carpeta ignorada por git: solo sirve para renderizar).
Uso: python3 tools/prerender/fetch_trains.py
"""
import os, subprocess, sys, urllib.request
ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
OUT = ROOT + "/render_src/trains"
MODELS = {
    "locomotive": "https://tevy.dev/models/diesel-locomotive/v1/lod1.glb",
    "freight_wagon": "https://tevy.dev/models/covered-freight-wagon/v1/lod1.glb",
    "passenger_car": "https://grab3d.com/dl/passenger-car/passenger-car-light.glb",
}
os.makedirs(OUT, exist_ok=True)
GT = os.environ.get("GLTF_TRANSFORM", "gltf-transform")
for name, url in MODELS.items():
    raw = "/tmp/_%s_raw.glb" % name
    mid = "/tmp/_%s_mid.glb" % name
    print("bajando", name)
    urllib.request.urlretrieve(url, raw)
    subprocess.run([GT, "copy", raw, mid], check=True)
    subprocess.run([GT, "dequantize", mid, "%s/%s.glb" % (OUT, name)], check=True)
print("listo en", OUT)
