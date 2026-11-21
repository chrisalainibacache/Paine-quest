# Plan de integración de trenes reales (prueba: «Tren descarrilado»)

**Decisión de Chris (2026-11-21):** planificar con la sala *Tren descarrilado* como prueba. Estado: prototipo hecho y renderizado; falta que Chris lo pruebe en el teléfono.

## 1. Idea central: cajas para jugar, trenes reales para mirar
El juego usa **fondos prerenderizados** (como RE3): la foto de cada cámara se proyecta sobre la geometría de la sala. Por eso hay **dos capas**:
| Capa | Qué es | Dónde vive |
| --- | --- | --- |
| **Proxy (juego)** | Cajas simples con el tamaño real del tren. Dan **choque** (Isabella no atraviesa) y **oclusión**. | `tools/level_gen/<sala>.py` |
| **Aspecto (render)** | Los **modelos reales** (CC0) a escala 1:1, con luces de incendio, humo y maleza. Solo se cargan al **renderizar** la foto. | `tools/prerender/<sala>_scene.py` + `render_src/` (no va al APK) |
Ventajas: el teléfono **no dibuja** 15.000 a 21.000 triángulos por vagón; los modelos no pesan en el APK; el aspecto cinematográfico (SDFGI, niebla volumétrica) sale gratis de la foto.
Límite: si una cámara no tiene foto (o se juega en modo Retro) se ven las cajas.

## 2. Modelos (todos CC0 1.0: sin obligación de crédito; se registra procedencia)
| Pieza | Fuente | Triángulos (LOD usado) | Medidas |
| --- | --- | --- | --- |
| Locomotora diésel | tevy.dev/models/diesel-locomotive | 21.272 (LOD1) | 19,9 × 3,4 × 4,7 m |
| Coche de pasajeros | grab3d.com/models/vehicles/passenger-car (Light) | 14.920 | 24 × 3,0 × 4,2 m |
| Vagón de carga cerrado | tevy.dev/models/covered-freight-wagon | 14.032 (LOD1) | 16,5 × 3,3 × 4,2 m |
Los GLB de tevy traen compresión *meshopt* y cuantización: `tools/prerender/fetch_trains.py` los baja y los convierte (necesita `gltf-transform`, de npm).

## 3. Escala: sala de 26 m
Los trenes reales son largos (24 m). Probé reducirlos (0,65 a 0,75): quedan **de juguete** al lado de Isabella (puertas de 1,3 m). Decisión: **escala 1:1 y salas más largas**, con los extremos cerrados por **túneles**
(un tren que entra a un túnel es natural; uno que atraviesa un muro, no). *Tren descarrilado* pasó de 18 a **26 m** (y de 9 a 11 m de ancho).

## 4. Diseño de la sala de prueba (hecho)
- **Oeste:** entrada desde «Vía norte» (puerta VOLVER). La vía llega recta y **se tuerce** donde descarriló el tren; quedan tramos de riel sueltos.
- **Norte:** **locomotora volcada** de costado (techo contra el muro; ruedas y bogies hacia el pasillo).
- **Sur:** **coche de pasajeros** fuera de la vía, ladeado; se sube por el costado (flecha «SUBIR AL VAGÓN»).
- **Este:** **vagón de carga** clavado en la **boca del túnel** (su cola entra al tubo): cierra el paso, así que hay que cruzar por dentro del coche.
- Entre la locomotora y el coche queda el pasillo por la vía (≈ 2,8 m). Luz: incendio (cabina y túnel) + luna fría de relleno, con humo volumétrico.
- Cámaras recalculadas con `plan_cameras.gd` (4); auditoría: 2,1 % de puntos malos, 0 spawns malos.

## 5. Resto del capítulo 2 (propuesta)
| Sala | Cambio |
| --- | --- |
| Vía norte | (hecho el render con incendio) Cambiar el vagón destrozado por una **mitad del coche real** no es posible (no se puede cortar): usar el **vagón de carga** o dejar el coche a escala 1:1 saliendo de un túnel. |
| Costado del convoy | Convoy de **2 coches reales + 1 de carga** en fila, junto a la vía (26 m). |
| Interior del vagón | Interior propio (asientos): se queda; revisar con las fotos de referencia de `especificacion_vagon.md`. |
| Paso bajo nivel / Casa de cambios | Sin trenes: solo luz y detalle. |

## 6. Cómo se rehace una sala (receta)
1. Proxies a tamaño real en `tools/level_gen/<sala>.py`; `python3 tools/level_gen/<sala>.py`; `--import`.
2. `godot --headless -s res://tools/plan_cameras.gd -- <sala>` (borrar antes la entrada de la sala en `cameras.json`) y regenerar.
3. `godot --headless -s res://tools/audit_cameras.gd -- <sala>` (≤ 4 % de puntos malos, 0 spawns malos).
4. `python3 tools/prerender/fetch_trains.py` (una vez) y `python3 tools/prerender/<sala>_scene.py`.
5. Renderizar (~3 min por cámara en CPU): ver `update grafica.txt` §4.
6. Revisar en el juego (`capture_rooms.gd`), correr las pruebas y subir los PNG.

## 7. Riesgos
- Peso: 4 PNG ≈ 6 MB por sala. Con las 6 salas del capítulo ≈ 36 MB más en el APK (hoy 80 MB). Mitigación: bajar a 1440×616 o JPEG de alta calidad.
- Una cámara sin foto muestra cajas. Mitigación: renderizar **todas** las cámaras de la sala.
- Si se mueve algo en el generador, hay que **volver a renderizar** (la foto se desincroniza).
