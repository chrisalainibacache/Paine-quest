# Paine

Survival horror 2.5D con cámaras fijas, al estilo de los Resident Evil clásicos,
para Android. Hecho en Godot 4.7.2.

- Diseño: [`docs/GDD.md`](docs/GDD.md)
- Arquitectura: [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)
- Assets: [`docs/ASSETS.md`](docs/ASSETS.md)
- Arte técnico: [`docs/ART_PIPELINE.md`](docs/ART_PIPELINE.md)
- Hoja de ruta: [`docs/ROADMAP.md`](docs/ROADMAP.md)

## Jugar en el teléfono

Cada cambio en `main` compila un APK nuevo (GitHub Actions) y lo publica en
**Releases → Latest**. Descarga directa (con la sesión de GitHub iniciada):

https://github.com/chrisalainibacache/Paine-quest/releases/latest/download/paine.apk

Se instala encima de la versión anterior (misma firma, ver `tools/android/README.md`).

## Desarrollo

- Pruebas: `godot --headless --path . -s res://tests/smoke_test.gd`
- Capturas: `xvfb-run godot --path . --rendering-driver opengl3 -s res://tools/capture_screenshots.gd -- <carpeta>`
- Animaciones de Cony: `godot --headless --path . -s res://tools/bake_animations.gd`

## Estado

Hito 1 — sala de prueba (andén norte de la estación de Paine). Ver `docs/ROADMAP.md`.
