# Paine — guía para Claude

Proyecto: survival horror 2.5D con cámaras fijas (estilo Resident Evil PS1) en
**Godot 4.7.2**, renderer *Compatibility*, **Android horizontal**.

Antes de trabajar, lee `docs/GDD.md` (diseño), `docs/ARCHITECTURE.md` (código),
`docs/ART_PIPELINE.md` (escenarios) y `docs/ROADMAP.md` (en qué hito vamos).

## Cómo trabaja el equipo
- Actúa como estudio completo: diseño, programación, niveles, arte técnico y QA.
- El dueño del proyecto (Chris) prueba en su teléfono Android; no tiene PC disponible.
  Responde en español, con pasos concretos.
- Toda decisión de diseño nueva se anota en `docs/GDD.md`.
- Rendimiento en Android es requisito, no detalle: salas pequeñas, pocas luces.

## Reglas de código
- Una escena por cosa; salas armadas como escenas, no generadas por código.
- Datos (armas, ítems, enemigos) en `data/*.tres`.
- Nombres por función, nunca por versión (`player.gd`, no `PlayerV2.gd`).
- GDScript tipado, 4 espacios, comentarios breves en español.
- Scripts de más de ~300 líneas se dividen.
- `class_name` solo en clases base reutilizables.

## Cómo se arman las salas
- Las salas se generan con `tools/level_gen/` (ver su README): editar el `.py` y
  regenerar, no el `.tscn` a mano. Salas nuevas con `roomkit.Kit`.
- Revisar el arte con `tools/capture_rooms.gd` (necesita xvfb).

## Verificación antes de cada commit
- Ejecutar las 3 pruebas headless: `tests/smoke_test.gd`, `tests/systems_test.gd`,
  `tests/levels_test.gd` (las mismas que corre GitHub antes de publicar el APK).
- No subir archivos de `.godot/` ni builds.
