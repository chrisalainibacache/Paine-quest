# Brief para ChatGPT — Paine

Este documento es lo primero que lees. Claude (otro asistente) supervisa tu trabajo: revisa
tus ramas, corre las pruebas y te responde en `docs/CHATGPT_LOG.md`. El dueño del proyecto
es **Chris**, que solo tiene un teléfono Android: nunca le pidas instalar nada ni usar un PC.
Responde y escribe todo **en español**.

## 1. Qué es el juego
> **Nombres:** la protagonista es **Isabella** (antes "Cony") y su hermana **Paz** (antes
> "Javiera"). Úsalos siempre; si ves los nombres viejos en algún texto, anótalo en el registro.
> Los archivos internos conservan `cony` (no se renombran).

Survival horror 2.5D con cámaras fijas (estilo Resident Evil 3 de PS1) en **Godot 4.7.2**,
renderer *Compatibility*, para **Android en horizontal**. Isabella y su gata Leo viajan a pie por
la vía del tren desde Paine (Chile) hacia Santiago, entre infectados, buscando a la hermana de
Isabella, Paz. **Este juego es la última aventura de Leo** (Leo es en secreto la gata real de
Isabella, que murió): todo lo de Leo se escribe con ese cariño. Lee `docs/GDD.md` §2 (historia y
línea de tiempo: las notas **deben** respetarla).

Estado: capítulo 1 (estación, 6 salas), capítulo 2 (las vías, 6 salas) y capítulo 3 (Buin,
7 salas) están hechos. Siguen el capítulo 4 (La Maestranza, San Bernardo),
el 5 (Santiago / Centro de Nos) y el epílogo "Para Leo". Ver `docs/ROADMAP.md`.

## 2. Lee antes de tocar nada
`CLAUDE.md` (reglas), `docs/GDD.md`, `docs/ARCHITECTURE.md`, `docs/ART_PIPELINE.md`,
`docs/ROADMAP.md`, `update grafica.txt` (cómo se ve el juego y qué se probó) y
`tools/level_gen/README.md` (cómo se arman las salas).

## 3. Cómo trabajas (obligatorio)
1. **Nunca hagas push a `main`.** Trabaja en una rama `chatgpt/<tema-corto>` y abre un Pull
   Request. `main` publica el APK de Chris automáticamente: un error ahí le rompe el juego.
2. **Escribe el registro** en `docs/CHATGPT_LOG.md` (ver §5) **en cada entrega**, dentro del
   mismo PR. Sin registro, Claude no revisa.
3. **Una cosa por PR**, chica y probable en el teléfono. No mezcles temas.
4. Antes de cada commit corre las 3 pruebas (deben terminar en `RESULTADO: OK (0 fallas)`):
   ```
   godot --headless --path . --import
   godot --headless --path . -s res://tests/smoke_test.gd
   godot --headless --path . -s res://tests/systems_test.gd
   godot --headless --path . -s res://tests/levels_test.gd
   ```
   Si no puedes correrlas (sin Godot en tu entorno), **dilo en el registro**; no digas que pasaron.
5. Mensajes de commit en español. No pongas nombres de modelos de IA en commits ni código.
6. Si dudas, **pregunta** en la sección "Preguntas" del registro y espera la respuesta.

## 4. Reglas técnicas que no se negocian
- **GDScript tipado**, 4 espacios, comentarios breves en español; nombres por función
  (`player.gd`, no `PlayerV2.gd`); scripts de más de ~300 líneas se dividen; `class_name`
  solo en clases base reutilizables. Datos (armas, ítems, enemigos, documentos) en `data/*.tres`.
- **Las salas NO se editan a mano**: se generan con Python (`tools/level_gen/*.py`, kit
  `roomkit.Kit`). Edita el `.py` y regenera; no toques el `.tscn`.
- **No renombres** nodos de ítems/infectados de salas ya publicadas (se rompen las partidas guardadas).
- **Cámaras**: si cambias una sala o un prop grande, corre
  `godot --headless --path . -s res://tools/plan_cameras.gd -- <sala>`, regenera la sala y
  luego `godot --headless --path . -s res://tools/audit_cameras.gd` (debe dar 0 apariciones
  malas y 0 cámaras pegadas). Isabella no puede quedar fuera de cuadro ni tapada.
- **Rendimiento (Redmi 13C)**: salas pequeñas, ≤ 4 luces, pocos dibujos. Piezas repetidas
  en `MultiMesh` (ver `tools/level_gen/train_props.py`).
- **Textos**: los diálogos de Leo empiezan con `Leo: `. Las notas respetan la línea de tiempo.
- **Privacidad**: nunca compartas ni publiques originales del Drive de Chris; solo copias
  temporales. No mezcles nada de su trabajo/empresa en el proyecto.
- **No toques sin pedir permiso en el registro**: `export_presets.cfg`, `project.godot`,
  `.github/workflows/`, `tools/android/` (firma), `systems/graphics_settings.gd`, `tests/`
  (puedes *agregar* pruebas, no quitar ni debilitar).

## 5. Lecciones de la última semana (para que no se repitan)
- **El export perdió los textos** (notas, examinar, pistas de Leo, introducción) porque el
  motor convertía los recursos a binario; en el editor todo funcionaba. Está arreglado
  (`export/convert_text_resources_to_binary=false`) y el CI ahora revisa el paquete
  (`tools/export_probe.gd`). **Probar desde el editor no basta**: si agregas textos nuevos con
  `PackedStringArray` en escenas o recursos, la comprobación del CI debe seguir pasando.
- **El modo Moderno** es el predeterminado: aristas biseladas en `KitBlock`
  (`levels/kit/bevel_box.gd`), cilindros con más lados, fondos prerenderizados **solo en el
  capítulo 1** (`assets/backgrounds/`, se nombran por cámara `Cam1`…). Si cambias la geometría
  o las cámaras del capítulo 1, avisa en el registro: los fondos hay que re-renderizarlos
  (lo hace Claude; ver `update grafica.txt`).
- **Pantalla DIAG** (MOCHILA → DIAG) muestra eventos y errores en el teléfono: pídele a Chris
  una captura cuando algo "no hace nada".
- Un recurso nuevo que no se importó no aparece en el APK: corre `--import` y sube los `.import`.
- No subas `.godot/`, builds ni archivos de más de 50 MB.

## 6. Tareas
**La cola vigente está en `docs/CHATGPT_LOG.md`, sección «Cola de tareas» (tickets T1–T6 y D).**
Claude planifica y revisa; tú implementas. En cada PR corre solo el workflow «Pruebas en PR»
(3 pruebas, auditoría de cámaras, paquete exportado y `.tscn` al día): **solo cuando está en verde
puedes decir que funciona**. Las secciones de abajo son el detalle original de A–D.

### Detalle original (A–D)
Las tareas **A–C son solo diseño y texto** (sin código). **D no empieza hasta que Claude escriba
`APROBADO D` en el registro.**
- **A. Capítulo 4 "La Maestranza"** — en `docs/GDD.md` (§2 historia y §8 salas): 6 a 8 salas
  con nombre, función, conexiones, objetos, enemigos, 1 enemigo o jefe nuevo, qué se
  consigue, y el flujo de pistas de Leo. Paz trabaja ahí; el vagón del Centro de Nos
  nadie lo abre. Mantén salas pequeñas y cerradas.
- **B. Notas del capítulo 4** — redacta 5 a 8 documentos (texto, título, fecha/hora) que
  amplíen la línea de tiempo sin contradecirla; en formato de `data/documents/*.tres`
  (míralos de ejemplo) pero **solo propón el texto en el registro**, no los crees todavía.
- **C. Capítulo 5 y epílogo "Para Leo"** — esquema de salas y el texto de la despedida de
  Leo (aprobada por Chris: al amanecer, a salvo, camina unos pasos hacia la luz, se da vuelta,
  maúlla una última vez y se va; Isabella entiende; dedicatoria "Para Leo").
- **D. Implementar el capítulo 4** con `roomkit.Kit` (solo tras `APROBADO D`): una sala por PR,
  con sus pruebas, cámaras planificadas y auditadas.
- **Siempre**: si ves un error de ortografía o contradicción en textos existentes, anótalo
  en el registro (no lo arregles sin avisar).

## 7. El registro: `docs/CHATGPT_LOG.md`
Es el único canal de supervisión. Escribe **arriba** (lo más nuevo primero), una entrada por
entrega, con esta forma:
```
### AAAA-MM-DD — Título corto  (rama: chatgpt/xxx, PR: #n)
- **Qué hice:** 2 a 5 líneas.
- **Archivos tocados:** lista.
- **Pruebas:** smoke / systems / levels = OK o FALLA o "no pude correrlas" (+ auditoría de cámaras si aplica).
- **Qué debe probar Chris en el teléfono:** pasos concretos, o "nada (solo texto)".
- **Dudas / decisiones que necesito:** lista (o "ninguna").
- **Estado:** EN REVISIÓN | BLOQUEADO (por qué).
```
Claude responde en la sección "Respuestas de Claude" con `OK`, `CAMBIOS` (qué corregir) o
`APROBADO D`. No borres entradas ni respuestas anteriores.
