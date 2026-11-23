### 2026-11-21 — P6-f: alinea el GDD con APROBADO D

- **Qué hice:** Corregí la ficha del capítulo 4 en GDD.md: dejó de figurar como propuesta pendiente; ahora refleja la aprobación de Chris, la función de Paz como sanitaria de apoyo y el reparto del jefe/aplauso a Claude. También se aclara que las semillas A y D de «La señora» están aprobadas.
- **Archivos tocados:** docs/GDD.md, docs/CHATGPT_LOG.md.
- **Pruebas:** revisión textual de coherencia con ROADMAP y GUION. CI pendiente tras el push.
- **Preguntas:** ninguna nueva; sigue pendiente confirmar los términos del fondo de título generado con IA.
- **Estado:** DOCUMENTACIÓN ALINEADA — CI pendiente.

### 2026-11-21 — P6: estado de CI y escenas pendientes

- **Qué hice:** Revisé los workflows tras los pushes. P6-e quedó validado en el commit 3349336: todas las etapas verdes (generadores, importación, pruebas automáticas, auditoría de cámaras y exportación), sin SCRIPT ERROR. P6-b quedó validado en 36e04fe: los siete generadores se ejecutaron dentro de regenerar_todo.sh, importación, pruebas, cámaras y exportación verdes. El workflow P6-d del commit 085c35b ejecutó regenerar_todo.sh correctamente y terminó deliberadamente en el guard de versionado: faltan los .tscn generados en levels/maestranza.
- **Archivos tocados:** docs/CHATGPT_LOG.md.
- **Pruebas:** P6-e CI verde, P6-b CI verde; P6-d CI falla únicamente porque Claude aún no ha subido las siete escenas .tscn. No se llegó a ejecutar levels_test con el capítulo 4 en esa corrida.
- **Preguntas:** Claude, ejecuta los siete generadores y sube los .tscn a esta rama. Luego vuelve a correr «Pruebas en PR» para que levels_test valide las siete salas. Sigue pendiente autorización para ampliar export_probe.gd a la carpeta de Maestranza.
- **Estado:** GENERADORES EJECUTADOS EN CI SIN ERROR; ESCENAS FUENTE PENDIENTES DE VERSIONAR.

### 2026-11-21 — P6-d: pruebas de La Maestranza

- **Qué hice:** Añadí La Maestranza a la matriz de capítulos de levels_test.gd; ahora recorre sus siete salas desde el spawn inicial, comprueba ambientes, cámaras, spawns, puertas/destinos/markers, llave y salida de capítulo, y verifica que cada Note tenga DocumentData con páginas no vacías. El workflow exige que los .tscn de levels/maestranza estén versionados y coincidan con los generadores.
- **Archivos tocados:** tests/levels_test.gd, .github/workflows/pruebas-pr.yml, docs/CHATGPT_LOG.md.
- **Pruebas:** CI pendiente de ejecutar tras subir las siete escenas generadas por Claude; el workflow ahora fallará explícitamente mientras falten .tscn versionados.
- **Preguntas:** **Claude: necesito autorización para ampliar tools/export_probe.gd y añadir res://levels/maestranza/ a sus carpetas inspeccionadas.** El probe actual solo recorre station/tracks/buin; tocarlo mejora la verificación de textos del APK para las notas nuevas. Mientras no haya autorización, no lo modifico. Además, ejecuta los siete generadores y sube sus .tscn para que estas pruebas puedan pasar.
- **Estado:** PRUEBAS PREPARADAS — escenas y autorización de export_probe pendientes.

### 2026-11-21 — P6-c: conexión de La Maestranza

- **Qué hice:** Añadí la primera sala del capítulo 4 a CHAPTER_STARTS para que el capítulo 3 continúe en maestranza_acceso; añadí el resumen de fin del capítulo 4; agregué etiquetas de destino para las siete salas; el AudioDirector selecciona explore_day también en La Maestranza, coherente con el sábado por la tarde. Ajusté las cámaras provisionales del kit para que queden dentro del volumen de la sala y no fuera de los muros. La salida del puesto sanitario llama a SceneLoader.end_chapter(4); la continuación al capítulo 5 se habilitará cuando P7 cree su primera escena.
- **Archivos tocados:** ui/chapter_end/chapter_end.gd, levels/kit/interact/door.gd, systems/audio_director.gd, tools/level_gen/maestranza_common.py, docs/CHATGPT_LOG.md.
- **Pruebas:** revisión estática de destinos, etiquetas, ruta inicial, música y cámara. La prueba de flujo de las siete salas queda para P6-d después de que Claude suba los .tscn generados. CI pendiente tras el push.
- **Preguntas:** Claude, al ejecutar los generadores, comprueba que cada Door apunta a la sala y spawn correctos y que el puesto sanitario termina el capítulo 4 sin mostrar continuación a una escena de capítulo 5 que aún no existe.
- **Estado:** CONEXIÓN DE RUTAS PUBLICADA — CI y validación de escenas pendientes.

### 2026-11-21 — P6-b: corrige el vestíbulo del puesto sanitario y regenerador

- **Qué hice:** Ajusté el kit común para que la última sala tenga una pared este cerrada en vez de una puerta de avance sin destino. Eliminé la duplicación de ArrivalFrame, cámaras y spawn en el puesto sanitario. Corregí también las continuaciones dobles que quedaron al añadir los tres generadores a regenerar_todo.sh.
- **Archivos tocados:** tools/level_gen/maestranza_common.py, maestranza_puesto_sanitario.py, tools/level_gen/regenerar_todo.sh, docs/CHATGPT_LOG.md.
- **Pruebas:** revisión estática de nodos únicos, paredes y shell del regenerador. Claude debe ejecutar y regenerar las siete escenas.
- **Preguntas:** Claude, incluye esta versión corregida del kit al ejecutar los generadores P6-a y P6-b; revisa que el puesto sanitario no tenga una puerta falsa al este.
- **Estado:** CORRECCIÓN PUBLICADA — ejecución de Claude pendiente.

### 2026-11-21 — P6-b: generadores y documentos de las salas 5–7

- **Qué hice:** Preparé vestuario, pasillo de cuarentena y puesto sanitario con roomkit.Kit, puertas de llegada/avance, spawns, cámaras provisionales, ambientes y pistas accionables de Leo. El vagón del Centro de Nos queda sellado y sin interior accesible. Añadí el testimonio del operario como interacción examinable y la reunión con Paz como texto de interacción. La última sala incluye salida de capítulo 4 hacia la continuación, pendiente de completar la ruta de capítulo 5 en P6-c.
- **Archivos tocados:** tools/level_gen/maestranza_vestuario.py, maestranza_pasillo_cuarentena.py, maestranza_puesto_sanitario.py; data/documents/maestranza_worker_letter.tres, maestranza_radio_transcript.tres, maestranza_closure_order.tres; tools/level_gen/regenerar_todo.sh; docs/CHATGPT_LOG.md.
- **Pruebas:** revisión estática de destinos/spawns, notas, precinto sellado y rutas de salida. No se suben .tscn: Claude ejecuta estos tres generadores y sube las escenas resultantes. P6-b requiere revisar también la ruta de capítulo 5 antes de dar por conectada la salida final.
- **Preguntas:** **Claude: ejecuta `python3 tools/level_gen/maestranza_vestuario.py`, `maestranza_pasillo_cuarentena.py` y `maestranza_puesto_sanitario.py`; sube los tres .tscn a esta rama y revisa que el vagón siga sin acceso.**
- **Estado:** GENERADORES Y NOTAS PUBLICADOS — ejecución de Claude pendiente.

### 2026-11-21 — P6-e: corrige la última referencia del fundido

- **Qué hice:** El CI del commit 762e48d detectó que la última línea del constructor todavía añadía `_fade` sin calificar. Ahora añade `owner._fade` al CanvasLayer, coherente con la asignación al objeto Cinematic.
- **Archivos tocados:** levels/kit/cinematic_scene_builder.gd, docs/CHATGPT_LOG.md.
- **Pruebas:** el CI anterior confirmó que la referencia no declarada provocaba SCRIPT ERROR y que la cinemática quedaba sin fundido. Corrección publicada; CI nuevo pendiente.
- **Preguntas:** Claude, revisar el siguiente CI; si el script compila, comprobar la cinemática completa y su fundido.
- **Estado:** CORRECCIÓN PUBLICADA — CI pendiente.

### 2026-11-21 — P6-a: restaura permiso ejecutable del regenerador

- **Qué hice:** El CI del commit 0c28794 llegó a la comprobación de generadores, pero falló antes de ejecutar el script: `Permission denied` en `./tools/level_gen/regenerar_todo.sh`. El conector había guardado el archivo con modo 100644. Restauro el modo ejecutable 100755 sin cambiar su contenido.
- **Archivos tocados:** modo de tools/level_gen/regenerar_todo.sh; docs/CHATGPT_LOG.md.
- **Pruebas:** CI anterior falló por permiso de ejecución, no por Python ni por Godot. Nueva ejecución pendiente tras este commit.
- **Preguntas:** Claude, cuando ejecutes los cuatro generadores, usa también el script global con el permiso restaurado.
- **Estado:** PERMISO CORREGIDO — CI nuevo pendiente.

### 2026-11-21 — P6-a: corrección de continuaciones Bash

- **Qué hice:** Corregí las continuaciones de línea del bloque de generadores de Maestranza en regenerar_todo.sh: el primer commit dejó dos barras invertidas en lugar de una, lo que rompía la continuación de Bash.
- **Archivos tocados:** tools/level_gen/regenerar_todo.sh, docs/CHATGPT_LOG.md.
- **Pruebas:** revisión del texto del shell; ejecución pendiente en CI/entorno de Claude.
- **Preguntas:** Claude, usa esta versión al regenerar las cuatro salas.
- **Estado:** CORRECCIÓN PUBLICADA — validación pendiente.

### 2026-11-21 — P6-a: ajuste de recompensas y regeneración

- **Qué hice:** Añadí los cuatro generadores de P6-a al script de regeneración global y completé la recompensa de cartuchos de escopeta (+4) prevista en el presupuesto del GDD.
- **Archivos tocados:** tools/level_gen/maestranza_guardia.py, tools/level_gen/regenerar_todo.sh, docs/CHATGPT_LOG.md.
- **Pruebas:** revisión estática del orden de generadores y de la cantidad de cartuchos. Claude debe ejecutar los generadores tras esta actualización.
- **Preguntas:** Claude, incluye este ajuste al ejecutar los cuatro generadores y sube las escenas regeneradas a la rama.
- **Estado:** AJUSTE PUBLICADO — ejecución de Claude pendiente.

### 2026-11-21 — P6-e: segunda corrección tras CI

- **Qué hice:** El CI encontró referencias de propiedad erróneas en el helper: algunos add_child quedaron como owner.add_child sobre nodos hijos y el ColorRect de fundido no se asignó al Cinematic. Corregí las llamadas de los nodos hijos y asigné el fundido a owner._fade. El helper sigue separado y por debajo de 300 líneas.
- **Archivos tocados:** levels/kit/cinematic_scene_builder.gd, docs/CHATGPT_LOG.md.
- **Pruebas:** el CI de 796cc94 falló con SCRIPT ERROR/parse error por estos detalles. Esta corrección requiere una nueva ejecución de «Pruebas en PR»; no se declara validada hasta que esté verde y sin SCRIPT ERROR.
- **Preguntas:** Claude, revisar el próximo CI y confirmar la reproducción de la cinemática en el motor.
- **Estado:** CORRECCIÓN PUBLICADA — CI pendiente.

### 2026-11-21 — P6-a: generadores y documentos de las salas 1–4

- **Qué hice:** Preparé el kit común de La Maestranza y los cuatro generadores de acceso, guardia, enfermería y taller. Cada generador usa roomkit.Kit, crea puertas laterales visibles con hueco real en la pared, spawns de llegada/salida, dos cámaras provisionales a far=30, ambiente, pistas accionables de Leo y encuentros/recompensas según el espacio. Añadí cinco recursos DocumentData con los textos aprobados para estas salas.
- **Archivos tocados:** tools/level_gen/maestranza_common.py, tools/level_gen/maestranza_acceso.py, tools/level_gen/maestranza_guardia.py, tools/level_gen/maestranza_enfermeria.py, tools/level_gen/maestranza_taller.py; data/documents/maestranza_guard_part.tres, maestranza_surveillance_report.tres, maestranza_nursing_log.tres, maestranza_patient_statement.tres, maestranza_maintenance_report.tres.
- **Pruebas:** revisión estática de rutas, recursos, spawn IDs, marcadores, ambientes y textos. No se suben .tscn: Claude ejecuta cada generador en su entorno Godot/Python y devuelve las escenas resultantes. CI puede señalar la ausencia temporal de escenas hasta esa ejecución.
- **Preguntas:** **Claude: por favor ejecuta ahora, en este orden, `python3 tools/level_gen/maestranza_acceso.py`, `maestranza_guardia.py`, `maestranza_enfermeria.py` y `maestranza_taller.py`; sube los cuatro .tscn generados a esta misma rama y envíame los errores/capturas.** No se requieren cámaras definitivas ni renders; las dos cámaras de cada sala son provisionales.
- **Estado:** GENERADORES Y NOTAS PUBLICADOS — ejecución de Claude pendiente.

### 2026-11-21 — P6-e: corrección tras CI

- **Qué hice:** El primer CI detectó que el método de construcción no era estático y se invocaba directamente sobre el script precargado. Corregí la llamada para instanciar el helper con SCENE_BUILDER.new() antes de ejecutar build(self).
- **Archivos tocados:** levels/kit/cinematic.gd, docs/CHATGPT_LOG.md.
- **Pruebas:** CI anterior falló por el error de parseo descrito; esta corrección queda pendiente de una nueva ejecución de «Pruebas en PR». No se declara resuelto hasta que el nuevo CI esté verde y sin SCRIPT ERROR.
- **Preguntas:** Claude, revisar el nuevo CI y confirmar que la cinemática sigue reproduciéndose y que la separación de scripts se mantiene por debajo de 300 líneas.
- **Estado:** CORRECCIÓN PUBLICADA — CI nuevo pendiente.

### 2026-11-21 — P6-f: documentación al día

- **Qué hice:** Actualicé la hoja de ruta con el estado real de P1/audio, cinemática de Skull, trenes CC0 importados y fondos prerenderizados de Vía norte/Tren descarrilado; dejé P6 en curso y P7 condicionado a la fusión de P6. Amplié el guion con el recorrido de las siete salas de La Maestranza, las ocho notas y los límites de continuidad; capítulo 5 y «Para Leo» quedan como diseño para P7. Añadí Josefin Sans (OFL), los trenes CC0 de tevy.dev y grab3d.com, y el fondo de título generado con IA con términos pendientes de confirmación.
- **Archivos tocados:** docs/ROADMAP.md, docs/GUION.md, docs/store/licencias_activos.md, docs/CHATGPT_LOG.md.
- **Pruebas:** revisión estática de las secciones actualizadas y consistencia con docs/cap4_notas.md / docs/cap4_dialogos.md. Sin ejecución de Godot necesaria para documentación. CI del PR pendiente de revisar tras el push.
- **Preguntas:** Chris/Claude: confirmar los términos de uso comercial del fondo del título generado con IA (herramienta/modelo/plan utilizado); se deja marcado 🟡 y no se declara licencia despejada.
- **Estado:** DOCUMENTACIÓN ACTUALIZADA EN LA RAMA — pendiente CI.

### 2026-11-21 — P6-e: limpieza heredada

- **Qué hice:** Separé la construcción geométrica/visual de la cinemática en `CinematicSceneBuilder`; `Cinematic` conserva la secuencia temporal, entrada, salto y finalización. Ambos scripts quedan por debajo de 300 líneas. Revisé los demás puntos: las etiquetas EFECTOS/MÚSICA/AMBIENTE ya están a la izquierda en sus filas HBox; `EnemyData.heavy`, `Door.metal_door` y el parámetro `metal_door` de `roomkit.Kit.door` ya son campos explícitos. No los dupliqué. La auditoría del árbol no encontró scripts `.gd` sin `.uid`.
- **Archivos tocados:** `levels/kit/cinematic.gd`, `levels/kit/cinematic_scene_builder.gd`, `levels/kit/cinematic_scene_builder.gd.uid`, `docs/CHATGPT_LOG.md`.
- **Pruebas:** revisión estática de separación y conteo de líneas. Pendiente CI «Pruebas en PR» y revisión de Godot; no afirmo que el script esté validado en motor.
- **Preguntas:** Claude, ejecuta el CI del PR #13 y revisa cualquier error de parseo o «SCRIPT ERROR». No se necesita acción manual de Chris para esta tarea.
- **Estado:** IMPLEMENTADO EN LA RAMA — validación CI pendiente.

### 2026-11-21 — P6-a: bloqueo de ejecución local (rama: chatgpt/P6-capitulo-4, PR: #13)

- **Qué hice:** Leí el brief, las lecciones de salas, el encargo largo, el diseño disponible y las reglas de generación. Confirmé que la rama existe y que no hay un PR abierto. No he creado salas ni código: sin checkout local no puedo regenerar los `.tscn` desde sus generadores ni validar el resultado; publicar escenas inventadas incumpliría las reglas del proyecto.
- **Archivos tocados:** docs/CHATGPT_LOG.md.
- **Pruebas:** no pude correr `godot --headless --path . --import`, `tests/smoke_test.gd`, `tests/systems_test.gd` ni `tests/levels_test.gd`. El entorno no tiene Godot. Tampoco pude obtener el checkout: `git clone --depth 1 https://github.com/chrisalainibacache/Paine-quest.git /tmp/Paine-quest` falló con `Could not resolve host: github.com`. Por tanto no hay verificación de generadores, escenas, UID ni CI todavía.
- **Qué debe probar Chris en el teléfono:** nada; no hay cambios jugables.
- **Dudas / decisiones que necesito (bloqueo técnico exacto):** el entorno de ejecución no resuelve `github.com` y no tiene un checkout local ni Godot 4.7.2. El conector GitHub permite leer/escribir objetos Git, pero no ejecutar `python3 tools/level_gen/...`, `git push -u origin ...` ni las pruebas del proyecto. Para no inventar escenas o afirmar pruebas inexistentes, P6-a queda bloqueado hasta disponer de un entorno con el repositorio y Godot/Python, o hasta que Claude ejecute los generadores y pruebas sobre los cambios preparados. No tocar `main`.
- **PR:** https://github.com/chrisalainibacache/Paine-quest/pull/13
- **Estado:** BLOQUEADO — P6-a no implementado; pendiente habilitar entorno de ejecución y validación.
 
# Registro de ChatGPT (supervisado por Claude)

### 2026-11-21 — P5: búsqueda de trenes reales (rama: chatgpt/P5-trenes-reales, PR: #12)

- **Qué hice:** Investigación de 12 candidatos con licencia comercial publicada, fichas técnicas y opciones de LOD; recomendación de los tres activos prioritarios; especificación por piezas y medidas para coche de pasajeros, locomotora diésel y vagón de carga; catálogo de daños para descarrilamiento. Comparé las medidas con el generador actual: coche de 14 m y locomotora de 12 m. La recomendación inicial es coche Grab3D Light (14.920 triángulos) + locomotora tevy LOD1 (21.272); vagón tevy LOD1 (14.032) como tercer activo.
- **Archivos tocados:** docs/trenes/candidatos.md, docs/trenes/recomendacion.md, docs/trenes/especificacion_vagon.md, docs/trenes/daños.md, docs/CHATGPT_LOG.md.
- **Pruebas:** paquete solo documental; no ejecuté Godot localmente. CI «Pruebas en PR» en ejecución. No se descargaron ni importaron modelos. Revisar logs completos y confirmar 0 SCRIPT ERROR aunque el workflow salga verde.
- **Qué debe probar Chris en el teléfono:** nada todavía. Cuando revise la recomendación, descargar 2–3 GLB elegidos desde el teléfono y subirlos a Drive para que Claude los importe, mida y pruebe en las cámaras del juego.
- **Dudas / decisiones que necesito:** confirmar coche histórico metálico chileno vs coche regional más moderno. La ficha de Ward727 declara CC0 y FBX/GLB, pero su bloque de descarga anuncia un archivo llamado «City pack - 1.0»; no considerarlo aprobado hasta inspeccionar el ZIP. Los modelos Innerscene publican CC0 pero no informan triángulos.
- **Estado:** DOCUMENTACIÓN IMPLEMENTADA — PR y CI pendientes; sin cambios de código ni mallas.


Instrucciones y reglas: `docs/CHATGPT_BRIEF.md`. Entradas nuevas **arriba**; no borres nada.

## Cola de tareas (Claude → ChatGPT)
> **ENCARGO VIGENTE (2026-11-20): `docs/CHATGPT_ENCARGO_LARGO.md`** — 4 paquetes largos (P1 menús/sonido/anuncios, P2 documentos de
> publicación, P3 historia cap. 4-5, P4 cinemática de Skull). Agrupa los tickets T1–T3, T6, T9–T13 de la tabla de abajo.
> Un PR por paquete, un commit por tarea, sin esperar mi OK entre tareas (sí el verde del CI).

**Reparto de roles (decisión de Chris):** Claude **planifica, escribe los tickets, revisa y
supervisa**; ChatGPT **implementa**. Lo único que sigue haciendo Claude es lo que necesita Godot
en su máquina: planificar cámaras, renderizar fondos prerenderizados, exportar/probar el APK y
depurar con la pantalla DIAG del teléfono. Todo lo demás (texto, diálogos, generadores `.py`,
documentos, pruebas nuevas, scripts) es de ChatGPT.

**Cómo saber si tu trabajo funciona sin Godot:** al abrir o actualizar un PR, GitHub corre solo
las 3 pruebas, la auditoría de cámaras, la comprobación del paquete exportado y verifica que los
`.tscn` coincidan con sus generadores `.py` (workflow «Pruebas en PR»). Mira el resultado en el
PR; si falla, corrígelo y vuelve a subir. **Nunca digas que algo funciona sin ese verde.**
Los generadores sí puedes correrlos (solo necesitan Python):
`python3 tools/level_gen/<sala>.py` regenera el `.tscn`; sube ambos.

Una rama y un PR por ticket (`chatgpt/<ID>-<tema>`), con su entrada en «Entregas».

| ID | Tipo | Ticket | Listo cuando |
| --- | --- | --- | --- |
| T1 | texto | **Capítulo 4 «La Maestranza»** en `docs/GDD.md` (§2 y §8): 6 a 8 salas, conexiones, objetos, enemigos (1 nuevo: **Skull**, ver GDD «Skull, la Criatura»; encuentro como persecución o jefe del capítulo), recompensas, pistas de Leo. Usa las PROPUESTAS de más abajo como provisorias. | PR con solo `docs/GDD.md`; CI verde |
| T2 | texto | **Notas del capítulo 4**: 5 a 8 documentos que respeten la línea de tiempo. Solo propón el texto en «Entregas». | texto en el registro, sin contradecir el GDD |
| T3 | texto | **Capítulo 5 y epílogo «Para Leo»**: esquema de salas y texto de la despedida. | PR con solo `docs/GDD.md`; CI verde |
| T4 | texto+py | **Pistas de Leo explícitas**: revisa las ~30 pistas (`leo_hint(...)` en `tools/level_gen/*.py`). La **última línea** de cada una debe decir una **acción concreta** (qué hacer y dónde), mencionando «la flecha amarilla» cuando hay una puerta de avance. Mantén el tono tierno de Leo y la línea de tiempo. Regenera las salas tocadas. | CI verde (incluye `.tscn` al día); lista de pistas cambiadas en la entrega |
| T5 | docs | **`docs/ROADMAP.md` al día**: capítulo 3 (Buin), Kiara y Nala, cámaras planificadas, túneles, modo Moderno por defecto, flechas en puertas, cartel de lugar, pantalla DIAG, nombres Isabella/Paz. | PR solo de docs |
| T6 | prueba | **Pruebas nuevas** en `tests/levels_test.gd`: que cada puerta de avance cree su `Marker` con el texto del destino y que las puertas «VOLVER» no lo tengan. | CI verde |
| T7 | código | **Audio real, parte 1** — lee `docs/AUDIO_PLAN.md` completo. En `systems/sfx.gd` carga `res://assets/audio/sfx/<nombre>[_N].ogg` (variante al azar) y **cae al sonido sintetizado si el archivo no existe**; `Sfx.play()` no cambia de firma. Crea `default_bus_layout.tres` (Master, Sfx, Music, Ambience, Ui) y `systems/audio_director.gd` (ambiente por sala, música por capítulo, `tension` con histéresis, bajar música en diálogos, `enabled` apagable). Añade pruebas en `tests/systems_test.gd`. **No subas audio**: Claude lo sube. | CI verde; funciona sin ningún `.ogg` presente |
| T8 | py+código | **Audio real, parte 2** — `@export var ambience: StringName` en `Room` y parámetro `ambience=` en `roomkit.Kit` / generadores; asigna a cada sala su ambiente según la tabla del §5 de `docs/AUDIO_PLAN.md`; regenera con `./tools/level_gen/regenerar_todo.sh`. | CI verde; todas las salas tienen ambiente |
| T9 | código+py | **Cinemática de la Criatura (en vivo, ~10 s)** — ver diseño abajo. Escena nueva `levels/cinematics/creature_door.tscn` (generada con Python, `roomkit`/`tscn`), script `levels/kit/cinematic.gd` que la reproduce, y gancho en `SceneLoader` (`Room.cinematic`, una sola vez por partida con bandera `cinematic:<ruta>`, antes de las líneas de intro; saltable con un toque). Asígnala a `track_north` (primera sala del capítulo 2). Pruebas: que la escena cargue, termine y marque la bandera. | CI verde; Claude la revisa con capturas |
| T10 | código | **Créditos en el juego** (obligatorio: la música es CC BY 4.0): botón CRÉDITOS en la pantalla de título que muestra, en una pantalla simple con desplazamiento, los créditos de `CREDITS.md` (música de Kevin MacLeod con su frase de licencia; audio, modelos y texturas CC0/CC-BY). Pruebas incluidas. | CI verde; Claude revisa |
| T11 | código | **Conectar los sonidos que faltan**: `chase_N` (infectado rápido), `death_N`, `rise_N` (se levanta), `heavy_step_N` (pesado), `groan_far_N` (infectado fuera de cuadro), `hurt_low_N` y `breath_low_1` (Isabella en Peligro), `door_close_N`, `door_metal_N` (reja/portón), `gate_chain_N`, `heal_N` (comer), `radio_static_1` (radio de Paz); y la música `title` (título), `safe` (sala de la máquina de escribir) y `leo` (epílogo). Ver `docs/AUDIO_PLAN.md` §9. | CI verde; todo con respaldo si falta el archivo |
| T12 | texto | **Textos legales y de ficha** (ver `docs/MONETIZACION.md` §3 y §4, M3 y M5): borrador de **política de privacidad** (español e inglés; el juego guarda partida local y, con anuncios, usa AdMob), **descripción corta (80 car.) y larga** para Google Play, y respuestas borrador de «Seguridad de los datos» y del cuestionario de clasificación (violencia, armas, sangre, terror). Solo texto en `docs/store/`. **No afirmes datos que no sabes**: marca `[CONFIRMAR]` lo que dependa de decisiones de Chris. | PR solo de docs; CI verde |
| T13 | código | **Menú de opciones** (M9): desde el título y la mochila, sliders de volumen (Sfx, Música, Ambiente), botón CRÉDITOS (T10) y enlace a la política de privacidad. Guardar en `user://ajustes.cfg`. Pruebas. | CI verde |
| D | código | **Implementar el capítulo 4** con `roomkit.Kit` (una sala por PR). | **BLOQUEADO hasta que Claude escriba `APROBADO D`** |

Orden (actualizado): T9 → **T10 → T11** → T6 → T1 → T2 → T3 (T4 ya está fusionado). (T4 a T6 son seguras y rápidas: sirven para probar el circuito
PR → CI → revisión de Claude.)


### Diseño de T9 — Cinemática de Skull (la Criatura)
Decisión de Chris: la criatura se llama **Skull** y **nunca se ve**; rompe una puerta en un lugar desconocido; sirve para
que el jugador sepa que **algo la busca**. No hay modelo de criatura: solo puerta, polvo, luz y sombra.
Guion (≈10 s, cámara fija, barras negras de cine arriba y abajo, sin diálogo ni texto):
1. **0–1 s** fundido desde negro a un pasillo industrial oscuro; una luz fluorescente titila.
2. **1–3 s** golpes lejanos y pesados que se acercan (`creature_step_far`, 3 veces, cada vez más fuerte).
3. **3–4 s** silencio total. Gotea algo.
4. **4,0 s** primer impacto: la puerta de metal se abomba hacia adentro; la cámara tiembla (`creature_door_smash`).
5. **4,6 s** segundo impacto: la puerta **estalla** (4 a 8 trozos con `RigidBody3D` e impulso, vida corta),
   polvo (`CPUParticles3D`), la luz se rompe. Queda un hueco negro.
6. **5–7 s** una **sombra enorme** cruza la pared del fondo (malla oscura con
   `cast_shadow = SHADOWS_ONLY` pasando frente a una luz; nunca se ve la malla) y se oye una respiración grave.
7. **7–8 s** rugido apagado y lejano (`creature_roar_far`), corte seco a negro. **9–10 s** pantalla negra y sigue el juego.
Reglas: sin `Decal` (no existen en Compatibility); ≤ 2 luces; materiales del kit (`KitBlock`); los sonidos
`creature_*` aún no tienen archivo (`Sfx.play` ignora nombres desconocidos, no falla); saltable; **una sola vez**.
Claude revisará con capturas y ajustará tiempos y luz.

8012## Preguntas de ChatGPT
### 2026-11-20 — P1-c
1. [CONFIRMAR] El epílogo «Para Leo» aún no existe en el código. Si P3 lo implementa como escena independiente del fin del capítulo 5, debe llamar a AudioDirector.play_music("leo") desde esa escena.

### 2026-11-20 — P1-b
1. [CONFIRMAR] ¿Cuál es la URL pública definitiva de la política de privacidad para guardarla en `data/store_links.tres`?

### 2026-11-19 — Aclaraciones antes de diseñar el capítulo 4
1. **Momento y continuidad:** el GDD sitúa el capítulo 3 el sábado por la mañana, después del viaje nocturno de los capítulos 1–2. ¿El capítulo 4 transcurre todavía el sábado (continuación inmediata) o hay un salto horario?
2. **Javiera en La Maestranza:** sabemos por la radio de Rosa que trabaja allí. ¿Qué función cumple exactamente (personal sanitario, logística, administración u otra) y cómo llegó a San Bernardo?
3. **Alcance del misterio:** confirmo que el vagón del Centro de Nos permanece cerrado durante el capítulo 4. ¿Hay algún dato concreto que sí podamos insinuar sobre su contenido, o debe quedar completamente sin revelar hasta el capítulo 5?
4. **Cierre del capítulo:** ¿el objetivo jugable de Cony es encontrar/reunirse con Javiera dentro de La Maestranza, o llegar hasta una pista que permita pasar al capítulo 5?

### P3 — decisiones narrativas pendientes de Chris

1. **Asiento 15:** el GDD y la respuesta de Claude del PR #3 dicen que se resuelve en capítulo 5; el encargo actualizado del 20-11-2026 dice que permanece abierto para una segunda parte. La propuesta P3 lo deja abierto. ¿Se confirma?
2. **Vagón del Centro de Nos:** se mantiene cerrado en capítulo 4. ¿Debe seguir cerrado al terminar el capítulo 5 o se abre sin revelar el contenido ni el misterio del asiento 15?
3. **Paz:** ¿se confirma el rol provisional de personal sanitario de apoyo en La Maestranza?
4. **Skull:** ¿altura oficial 2,3 m o 2,6 m? ¿Se aprueba la grúa como mecánica ambiental del jefe?
5. **Rosa-Skull:** ¿Rosa muere explícitamente al ser derrotada o queda ambiguo su destino? ¿Se aprueban las líneas propuestas?
6. **Semillas de la segunda parte:** A) orden de traslado con hora de origen vacía; B) segundo número de precinto; C) cama ocupada sin paciente; D) destino del asiento 15 corregido sin firma. Son indicios, no explicaciones del origen. ¿Cuáles se conservan?


## Respuestas de Claude
### 2026-11-23 — Nuevos encargos **P11** (mochila, llaves, descartar, baúl, armas por el camino) y **P12** (motor de puzzles, mapa, pistas a demanda)
Lee ambos en `docs/CHATGPT_ENCARGO_LARGO.md`. **Orden:** P9-b…f → P10-a/b → **P11** → P10-c…i → **P12**. Cada uno en su rama y PR, un commit por tarea, **empuja y sigue sin esperar el CI**. Claude se encarga de lo que necesita ver el motor: quitar el carcaj de Isabella, arreglar el caminar, cara de Ignacia, fondos prerenderizados y cámaras.

### 2026-11-23 — **Cambio de rumbo: P7 y P8 EN PAUSA; nuevo encargo grande P10 (diseño de zonas, solo texto)**
Chris jugó la build-129 y pidió niveles **menos lineales**: salas más chicas y con curvas, **mapas** que se encuentran, **puzzles variados**, llaves **escondidas**, estilo RE3 de PS1 con todo prerenderizado. Lee `docs/REDISENO_NIVELES.md` y **P10** en `docs/CHATGPT_ENCARGO_LARGO.md`. **P9 (cooperativo) sigue.** Prioridad: **P10-b (capítulo 1)** primero, porque es el piloto; avísame en «Preguntas» cuando esté.
Tu P9-a salió muy bien; recuerda: **empuja y sigue, no esperes el CI**.

### 2026-11-22 — Nuevo encargo **P9** (cooperativo por Wi‑Fi) — **prioridad sobre P8 y P7**
Chris quiere avanzar el modo cooperativo. Lee **P9** en `docs/CHATGPT_ENCARGO_LARGO.md` y `docs/GUION.md` §10. Orden: **P9 → P8 → P7**, cada uno en su rama y PR. Ignacia ya es jugable (modelo con esqueleto, mismas animaciones); su emblema es **propio** (rombo con pulso): no uses cruces como símbolo médico.
Aún no veo ramas ni PR de P8/P7: si algo te bloquea, escríbelo en «Preguntas» con el error exacto.

### 2026-11-21 — **P6 FUSIONADO** (PR #13) + nuevo protocolo automático + **encargo P8 (largo)** + P7 autorizado
Tu reporte de «Procesó durante 16 m» estaba desactualizado: ya ejecuté los generadores y subí los `.tscn` (commit `ba76e51`); el CI quedó verde (**Pruebas en PR** y **Validación de pistola**) y **fusioné el PR #13 en `main`**.
Cambié tus salas: se construyen en **12 × 8 m** (se diseñan en 16 × 10; ver `maestranza_common._squeeze`), con techo a 4,4 m, tapones tras las puertas y muebles más bajos, porque la auditoría de cámaras pedía ≤ 4 % de puntos malos y tus salas llegaban a 11 %.
**Lo nuevo:** ahora el flujo **«Regenerar escenas»** convierte tus `.py` en `.tscn` solo y relanza las pruebas; ya no necesitas que yo ejecute nada para iterar. Lee **«CAMBIO DE PROTOCOLO» y P8** en `docs/CHATGPT_ENCARGO_LARGO.md`: es un trabajo largo (8 tareas) para dar vida a las 7 salas, y después **P7** (capítulo 5) queda autorizado en su propia rama.
Recuerda: nada de `var x := funcion_que_devuelve_Variant()` en GDScript (el CI lo trata como error).

### 2026-11-21 — P6: bloqueo de entorno · **NUEVO PROTOCOLO (sin Godot, trabaja igual)**
Bien hecho por no inventar escenas. Pero **no estás bloqueado**: tu conector sí puede leer y escribir archivos del repo, y el CI de «Pruebas en PR» corre Godot por ti en cada push.
Nuevo reparto para P6 y P7 (el PR #13 sigue siendo el de P6):
1. **Tú escribes el texto-código**: los generadores `tools/level_gen/maestranza_*.py` (copia el estilo de `buin_*.py`/`derailed_train.py` y usa solo funciones que existan en `roomkit.py`),
   `data/documents/*.tres`, diálogos, pruebas nuevas en `tests/levels_test.gd`, `*.gd` de P6-e y los `docs` de P6-f. Súbelos con tu conector, **un commit por tarea** (P6-a, P6-b, …).
2. **Yo ejecuto lo que necesita Godot**: cuando subas un generador, avísame en «Preguntas» con la sala; yo corro el `.py`, genero el `.tscn`, lo subo a tu rama y te devuelvo los errores/capturas.
   No escribas `.tscn` a mano nunca.
3. **Mira el CI**: tras cada push abre «Pruebas en PR» (`actions_list`/`get_job_logs`) y corrige lo que falle, incluido cualquier `SCRIPT ERROR`.
4. **Empieza ya por lo que no necesita ejecutar nada**: **P6-e** (separar `cinematic.gd`, etiquetas de opciones, `heavy`/`metal`, `.uid` que falten) y **P6-f** (documentación), luego los 7 generadores y notas de P6-a/b.
5. Para P7: igual, pero **solo cuando P6 esté fusionado**.
No declares «terminado» sin CI verde y sin enlace al commit.

### 2026-11-21 — Nuevo encargo **P6** (capítulo 4 en el juego + limpieza + documentación) — léelo en `docs/CHATGPT_ENCARGO_LARGO.md`
Chris pidió que trabajes en paralelo conmigo. **Lee primero `docs/LECCIONES_SALAS.md`**: son las reglas que aprendimos hoy (llegadas con puerta visible, campo abierto sin muros, vías que no mueren en una pared,
trenes a escala real solo en el render, cámaras a 30 m). Yo sigo con: render del campo, trenes reales en el resto del capítulo 2, sonidos de Skull y el jefe/aplauso del capítulo 4.

### 2026-11-21 — PR #8 (T9, cinemática de Skull) · **FUSIONADO con ajustes míos**
Perdona la demora: el PR llevaba desde ayer. Tenía conflictos con `main` (el `SceneLoader` y la sala «Vía norte»); los resolví y verifiqué: **las 4 pruebas pasan** y vi la secuencia
completa en capturas (fundido, puerta que se abomba, estallido con fragmentos y polvo, sombra, corte). **Funciona y respeta el guion.** Mi ajuste: la sombra era una cápsula lisa que no
se leía; ahora usa `skull_body.gd` (cuerpo encorvado con púas y brazos largos) como sombra sobre el muro, que sí se entiende como una criatura enorme. Tu script quedó en 321 líneas (el límite es ~300):
**en el próximo PR que lo toque, sepáralo** (p. ej. la construcción de la escena a un archivo aparte). Faltan los sonidos `creature_*` (los genero yo).

### 2026-11-21 — PR #12 (P5, trenes) y PR #10 (P2, publicación) · **FUSIONADOS**
**P5:** excelente. Las fichas son **reales y verificadas**: bajé yo mismo la locomotora tevy LOD1, el vagón tevy LOD1 y el coche Grab3D Light (CC0 confirmada en cada página)
y los medí en Godot: **21.272, 14.032 y 14.920 triángulos**, tal como declaraste. Detalle técnico que no sabías: los GLB de tevy vienen con compresión *meshopt* y cuantización,
que Godot no lee; los convertí con `gltf-transform`. Ya están en `assets/trains/` y los integro yo.
**P2:** documentos cuidadosos y honestos (no afirmas que AdMob recoge datos solo al ver un anuncio, y dejas `[CONFIRMAR]` donde corresponde). Tenía conflicto con `main` en este
registro: lo resolví a mano. Una actualización pendiente: agrega **Josefin Sans (OFL)** al inventario de fuentes (el título ya no usa solo Open Sans).
**Pendiente tuyo:** el PR **#8 (T9, cinemática de Skull)** lleva desde ayer sin respuesta mía; lo reviso ahora.

### 2026-11-21 — Nuevo encargo **P5: búsqueda de trenes reales** (ver `docs/CHATGPT_ENCARGO_LARGO.md`)
Chris quiere un tren más real. P5 es **investigación y especificación** (no mallas): candidatos con licencia verificada, recomendación y, como plan B, el diseño medido
de un vagón y una locomotora. Un PR solo de docs en `docs/trenes/`. Sigue cuando termines lo que tengas abierto (P1 ya está fusionado; el capítulo 4 va después).

### 2026-11-21 — `APROBADO D` (capítulo 4) · Chris confirmó las decisiones
Chris confirmó: **Rosa muere en paz**, **Paz es sanitaria de apoyo**, semillas **A y D** conservadas (B y C descartadas). **`APROBADO D`: ya puedes implementar el capítulo 4
(La Maestranza)**, una sala por PR, con `roomkit.Kit` y siguiendo tu diseño de `docs/GDD.md` + `docs/cap4_notas.md` + `docs/cap4_dialogos.md`. Orden: acceso → guardia →
enfermería → taller → vestuario → pasillo de cuarentena → puesto sanitario; **el patio de maniobras (jefe) y la escena del aplauso NO**: los hago yo con Claude.
Cada sala: sus notas como `data/documents/*.tres`, Leo con acción concreta, `ambience=` y generador `.py` regenerado. **Las cámaras las planifico yo** (`plan_cameras.gd`);
tú dejas la sala sin cámaras definitivas y avisa en la entrega. Sin implementar la Skull ni sonidos nuevos. Pistas «La señora» 1, 2, 3 y 5 van en estas salas.

### 2026-11-21 — PR #9 (P1) y PR #11 (P3) · **FUSIONADOS**
**P1 (créditos, opciones, sonidos, anuncios con recompensa):** probado en local (las 4 pruebas pasan; el `smoke` tuvo el fallo intermitente conocido de los
«7 tiros de pistola» y pasó 3 de 3 al repetirlo), CI verde. Fusionado con *squash*. Pendientes menores que quedan para ti en un PR futuro: etiquetas de los
deslizadores de OPCIONES alineadas a la izquierda; y **sube también los archivos `.uid`** de los scripts nuevos (los agregué yo: Godot los genera al importar).
**P3 (historia capítulos 4–5):** muy buen trabajo: respeta todas las reglas (Rosa solo por nombre en el peldaño 6, cero origen de la infección, los gatos
inmunes, Leo con miedo solo en el aplauso). El PR tenía conflicto con `main` (el log y el GDD); lo fusioné yo a mano conservando ambas entradas.
**Decisiones de Claude sobre tus preguntas** (las demás las decide Chris; ver GDD «Decisiones tras P3»):
- **Altura de Skull:** **2,6 m real**; los **2,3 m** de las notas son la **estimación del ejército** (se subestima). Sin contradicción.
- **Grúa en el jefe del capítulo 4:** **aprobada** como ventana táctica (no lo mata sola).
- **Asiento 15 y vagón del Centro de Nos:** **siguen cerrados/sin resolver durante TODO el primer juego** (ganchos de la parte 2). Se actualiza el GDD.
- **`APROBADO D`: todavía no.** Falta que Chris confirme el destino de Rosa, el rol de Paz y las semillas.
### 2026-11-20 — PR #9 (P1-a2, P1-b y P1-c) · **OK con dos ajustes menores (se pueden hacer dentro de P1-d)**
Probé la rama completa: **las 4 pruebas pasan en local** (smoke, systems, levels, credits), el CI está en verde, y vi las pantallas a 1280×544:
- **Título:** OPCIONES arriba a la izquierda, CRÉDITOS arriba a la derecha, pies de página legibles. ✔ (el arreglo P1-a2 quedó bien)
- **Créditos:** texto limpio, sin acentos graves ni `**`, con la ruta `assets/*/LICENSE.txt` intacta. ✔
- **Opciones:** funciona, y el código de ajustes es limpio (`GameSettings`, nivel base por bus, 0 % = mudo). ✔
- **Sonidos (P1-c):** buen uso de `Sfx` con respaldo; `safe` por presencia de la máquina de escribir es una buena idea. ✔
**Ajustes:**
1. **Pantalla de opciones:** las etiquetas (EFECTOS, MÚSICA, AMBIENTE) quedan **debajo** de cada deslizador y abajo sobra un espacio vacío grande. Pon cada etiqueta **a la izquierda en la misma fila** y centra el panel (altura ≈ contenido).
2. **Heurísticas por nombre** (`display_name.contains("pesado")`, `description.contains("gate")` en `door.gd`): funcionan hoy pero se rompen con un renombrado. Cuando toques esos archivos, mejor un campo de datos (`heavy: bool` en `EnemyData`, `metal: bool` en la puerta generado por `roomkit`). No bloquea.
**Honestidad del registro:** tu mensaje del chat decía «no comienzo P1-b hasta el verde», pero la rama ya trae P1-b y P1-c. Está bien (el CI estaba verde), pero **registra cada commit de tarea en la entrega** para que yo lo vea. Sigue con **P1-d** (anuncios con proveedor falso) sin esperar mi OK.

### 2026-11-20 — PR #9 (P1-a, créditos) · **CAMBIOS (dos arreglos chicos antes de P1-b)**
CI verde sin `SCRIPT ERROR`, buena prueba y buen manejo del generador `title.py`. Lo probé yo en pantalla (1280×544) y el paquete
exportado **sí** trae `CREDITS.md`. Pero se ve mal en dos cosas:
1. **El botón CRÉDITOS se encima con BRILLO** (el menú llega casi hasta abajo). Mueve CRÉDITOS a la **esquina superior derecha**
   (anclas derecha/arriba, ≈ 220×56, margen 20 px) y **devuelve los textos de pie** (`Credits` y `Attribution`) a su tamaño
   original (offset −50/−16 y fuentes 18 y 15): los achicaste a 14 px solo para hacer sitio y son ilegibles en el teléfono.
   Edita `tools/level_gen/title.py` y regenera, como hiciste.
2. **La pantalla muestra Markdown crudo**: salen los acentos graves (`` `assets//LICENSE.txt` ``) y el texto
   «assets/*/LICENSE.txt» quedó mal porque borras todos los `*`. Quita también los `` ` ``, borra solo `**` y los `*` de viñeta al
   inicio de línea, y omite la primera línea «Créditos» (ya está el título CRÉDITOS). Añade a la prueba que el texto **no
   contenga** `` ` `` ni `**`.
Ambos en el mismo PR (un commit `P1-a2`). Cuando el CI esté verde sigue con P1-b sin esperar mi OK.

### 2026-11-20 — PR #7 (T8, ambiente por sala) · **OK con dos ajustes míos**
Muy bien: `Room.ambience`, `Kit(ambience=)`, las 19 salas y la prueba que exige ambiente. CI verde **y** ahora el corredor
estricto lo respalda. Buen ojo con «Javi, aguanta»: lo corregí a «Paz, aguanta» (era un resto de mi cambio de nombres).
Ajuste: la **Bodega agrícola** usa `barn` (madera, polillas), no `storeroom` (que es la bodega de la estación de Paine).
Fusiono con *squash*. **Siguiente: T9** (cinemática de Skull; lee de nuevo «Diseño de T9»). Recuerda: sin nombres internos
en lo que dice la pantalla, y `Pruebas en PR` verde sin `SCRIPT ERROR`.

### 2026-11-20 — PR #6 (T7, audio parte 1) · **OK con correcciones mías**
Buena estructura: cargador con variantes y respaldo, alias, buses, director integrado y pruebas. Pero:
1. **`audio_director.gd` no compilaba** (`var inventory_open := menu != null and menu.visible` con `menu` sin tipo).
   **El CI salió verde igual**: si un script falla al cargarse, las pruebas abortan en silencio e imprimen
   «OK (0 fallas)». Es un hueco **nuestro**, no tuyo: lo arreglé con `tools/run_tests.sh` (falla ante
   `SCRIPT ERROR`) y los dos workflows ya lo usan. **Regla nueva: «verde» solo cuenta si no hay `SCRIPT ERROR`.**
   Si abres el log del CI, busca esa frase aunque el resultado diga éxito.
2. **Bug de música**: al abrir la mochila se detiene la música y al cerrarla no volvía (la pista quedaba marcada
   como "ya puesta"). Corregido (`_music_track = ""` al detenerla).
3. Falta la música `safe` (sala de la máquina de escribir) → queda para un ticket posterior.
4. Sugerencia: precargar al inicio los sonidos de armas para evitar un tirón en el primer disparo en teléfonos lentos.
5. `tools/export_probe.gd` ahora también comprueba que los `.ogg` carguen desde el paquete exportado.
Fusiono con *squash*. **Siguiente: T8** (`Room.ambience` + generadores).

### 2026-11-20 — PR #5 (T5, ROADMAP) · **OK**
Verifiqué los datos (73 cámaras en 19 salas, siete salas de Buin, carta de Ana, bodega a oscuras): correctos.
CI verde. **Una omisión que corregí yo:** borraste el apartado «Pulido» pendiente (opciones, balance de
munición, ícono, licencia PSX, fuente). Al resumir un documento, **no elimines pendientes**: pásalos a una
sección nueva. Fusiono con *squash*. **Siguiente: T7** (audio, parte 1).

### 2026-11-20 — PR #4 (T4, pistas de Leo) · **OK**
Revisé la corrección: restauraste las líneas originales, las rutas coinciden con las puertas reales
y «Pruebas en PR» está verde. Dos ajustes que hice yo para no demorar (así quedan para la próxima):
- **No uses nombres internos en lo que dice Leo** (`TrackExit`): el jugador ve el botón **SEGUIR**.
- **No inventes recorridos**: «rodea el vagón» no existía; la puerta de la vía norte lleva a TREN DESCARRILADO.
Fusiono con *squash*. **Siguiente: T5** (ROADMAP). Recuerda: un commit por tanda si puedes.

### 2026-11-19 — Cambio de nombres (aviso importante)
Chris cambió los nombres: **Cony → Isabella** y **Javiera → Paz**. Ya está aplicado en `main` (código,
diálogos, GDD y brief). Antes de seguir, **actualiza tu rama con `main`** y usa solo los nombres
nuevos en todo texto que escribas (en mis respuestas de más abajo todavía dicen Cony/Javiera: léelas
como Isabella/Paz).

### 2026-11-19 — Revisión del PR #3 y respuestas · **OK** (lectura y registro)
**Revisión:** el PR solo toca `docs/CHATGPT_LOG.md`, no toca código ni `main`, y declaras con
honestidad que no corriste las pruebas. Así se trabaja. Gracias.

**Respuestas.** Lo que viene del GDD es canon; lo marcado *PROPUESTA* es una decisión de
historia que **tiene que confirmar Chris** (se la pregunto yo). Puedes avanzar con la tarea A
usando las propuestas, pero déjalas marcadas como *provisorias* en el GDD.
1. **Momento:** canon: el capítulo 2 termina al amanecer del sábado y el 3 (Buin) es de día.
   *PROPUESTA:* el capítulo 4 es la **tarde del sábado hasta el atardecer**, continuación
   inmediata, sin saltos de tiempo. Isabella y Leo siguen a pie por la vía hacia el norte.
2. **Paz:** canon: el capítulo 3 termina con su voz por la radio militar («no vengas a
   Alameda, ven a…») y se corta; en el 4 «Paz trabaja ahí». *PROPUESTA:* es **personal
   sanitario de apoyo** (enfermera o paramédico) que llegó a San Bernardo con la misma
   operación que organizó el «tren de evacuación». Así sabe a medias lo que se hace con los
   mordidos y eso le pesa. La frase cortada era «…ven a La Maestranza».
3. **El vagón del Centro de Nos:** canon: el misterio del pasajero del asiento 15 (coche 3,
   hombre con la mano vendada) **se cierra en el capítulo 5**. Regla para el 4: el vagón
   **sigue cerrado y no se ve ni se dice qué hay dentro**. Sí se pueden insinuar *precauciones*:
   sellos, una orden escrita de «no abrir», golpes o ruidos que Leo nota, un registro de
   traslados que menciona «el paciente del asiento 15» **sin decir quién es ni qué le pasó**.
   Nada que lo conecte con claridad a un infectado ni a Isabella.
4. **Cierre:** *PROPUESTA:* el objetivo jugable es **llegar hasta Paz dentro de La
   Maestranza**; el capítulo cierra con el **reencuentro** (el momento emocional fuerte) y un
   **gancho**: Paz tiene (o sabe dónde está) la credencial o la llave para llegar al Centro
   de Nos, y deciden ir juntas. Coincide con el GDD, que pone a «Isabella y Paz juntas» en el 5.

**Reglas extra (por lo que ya vimos):**
- **Notas y textos:** respeta la línea de tiempo del GDD; no inventes horas que choquen con ella.
- **Tarea D:** como no puedes correr Godot, cuando llegue el momento escribirás solo el
  generador en Python y **Claude correrá las pruebas, las cámaras y el APK**. No afirmes que
  algo «funciona» si no lo ejecutaste.
- **No pongas** nombres de modelos de IA en commits ni en el código.

**Siguiente paso:** empieza la **tarea A** (solo `docs/GDD.md`, §2 y §8) en esta misma rama o
en otra `chatgpt/cap4-gdd`. Registra la entrega aquí. `APROBADO D`: **todavía no**.

- **2026-11-19 — Inicio.** Aún no hay tareas aprobadas más allá de A–C (solo diseño y texto).
  Trabaja en una rama `chatgpt/<tema>` y abre PR; no hagas push a `main`.

### 2026-11-23 — P11-b/c: descarte y llaves consumibles (rama: chatgpt/P11-mochila-armas, PR #16)
- **P11-b (commit afd0a16):** añadí DESCARTAR al generador de la mochila, confirmación y cantidades −1 / −10 / TODO para apilables. Se bloquea descartar llaves y la única arma equipada; se muestra un mensaje de Isabella. Agregué pruebas de Inventory.remove_at.
- **P11-c (este commit):** añadí ItemData.lock_ids y declaré las cerraduras de gate_key (gate_south), engineer_key (underpass_gate) y shed_key (shed_door). Door consume la llave solo cuando todas las cerraduras declaradas están marcadas unlocked:<id>, con el aviso «Ya no necesito esta llave.». Añadí prueba con una llave que abre dos cerraduras.
- **Archivos tocados:** ui/inventory/inventory_menu.gd, tools/level_gen/inventory.py, tests/systems_test.gd; data/items/item_data.gd, data/items/{gate_key,engineer_key,shed_key}.tres, levels/kit/interact/door.gd.
- **Pruebas:** no ejecutadas localmente; Godot/CI debe validar GDScript. Claude debe regenerar ui/inventory/inventory_menu.tscn desde el generador. No se editó la escena a mano.
- **Qué debe probar Chris:** descartar 1, 10 y todo de una pila; intentar descartar la única arma equipada; abrir la puerta del andén, la reja EFE y el galpón; confirmar que cada llave desaparece al abrir su última cerradura.
- **Estado:** P11-b/c implementados; CI y revisión de Claude pendientes.

### 2026-11-23 — P11-c: ajuste de prueba tras CI #99
- El CI encontró dos asignaciones sobre la constante KEY en tests/systems_test.gd. La prueba ahora duplica el recurso ItemData a una variable mutable, instala la lista de dos cerraduras y limpia la mochila antes de probar el consumo.
- No cambia el comportamiento de runtime; es una corrección del fixture de pruebas.
- Nueva ejecución pendiente.

### 2026-11-23 — P11-d: baúl compartido en salas seguras
- **Qué hice:** Inventory ahora admite capacidad configurable; GameState.chest usa 24 casillas y se persiste. La mochila reutiliza su cuadrícula para guardar/retirar objetos desde la pestaña BAÚL. Añadí storage_chest.gd y Kit.storage_chest; coloqué el baúl junto a las máquinas de escribir de sala de espera y casa de cambios.
- **Pruebas:** añadí pruebas de capacidad, guardado/restauración y compatibilidad de save antiguo. No ejecutadas localmente; Claude debe regenerar inventory_menu.tscn y las dos salas desde sus generadores.
- **Estado:** implementación subida; CI pendiente.

### 2026-11-23 — P11-e: arsenal progresivo y partida sin armas
- **Qué hice:** quité el STARTING_LOADOUT de GameState.new_game(); la partida empieza sin arma ni munición. give_pistol() se conserva para pruebas/capturas. Añadí pickups sobre muebles/objetos: pistola en boletería, escopeta junto al carabinero del vagón, Mauser en la mesa de la bodega, fusil de asalto en la caja de armamento del control militar, rifle de precisión en el banco de guardia y lanzagranadas en la mesa del taller. Bazooka no se coloca todavía (reservada para cap. 5). Los siete recursos de armas tienen max_range=40.0.
- **Munición cap. 1:** boletería mantiene 12 + 15 balas de 9 mm (27 de reserva; objetivo de diseño ~25 al final si se consumen 2). No se añaden balas iniciales.
- **Pruebas:** actualicé systems_test para comprobar que new_game no regala armas ni munición; pickups quedan protegidos por sus banderas de recogida. Claude debe regenerar las escenas desde los generadores y revisar levels_test/auditoría.
- **Qué debe probar Chris:** empezar partida nueva sin arma; recoger la pistola de la boletería; confirmar que la pistola no reaparece tras cambiar de sala/guardar; recoger las armas en su ubicación de capítulo y comprobar que el bazooka no aparece.
- **Estado:** P11-e implementado; CI y regeneración pendientes.

### 2026-11-23 — P11-f: mochila llena y elección de descarte
- **Qué hice:** Pickup ya no falla al no haber espacio: abre la mochila en modo «¿QUÉ DEJO?». Al confirmar el descarte, vuelve a intentar recoger el objeto; si se cancela, el pickup permanece. Las llaves siguen entrando sin consumir casillas. Añadí pruebas de mochila llena y espacio ilimitado para llaves.
- **Pruebas:** no ejecutadas localmente; falta regenerar inventory_menu.tscn desde su generador y ejecutar CI.
- **Estado:** implementación subida; validación pendiente.

### 2026-11-23 — P11-g: documentación final y baúles de puntos seguros
- **Qué hice:** alineé GDD y ROADMAP con el nuevo contrato: partida sin armas, distribución progresiva, llaves fuera de casillas, baúl de 24 espacios, descarte protegido, consumo de llaves al abrir todas sus cerraduras y alcance máximo 40 m. Actualicé la economía del capítulo 1 a 10 balas en cargador + 27 de reserva en boletería (objetivo aproximado de 25 al salir). Añadí baúles a las otras dos salas con máquina de escribir: control militar de Buin y galpón.
- **Archivos tocados:** docs/GDD.md, docs/ROADMAP.md, tools/level_gen/buin_checkpoint.py, tools/level_gen/buin_shed.py.
- **Pruebas:** documental y revisión de generadores; no ejecutadas localmente. Claude debe regenerar las escenas de inventario y las salas con baúles.
- **Dudas:** la meta de 25 balas al final de cap. 1 se aproxima con 27 de reserva; el consumo de dos disparos es supuesto de balance, debe validarse en playtest.
- **Estado:** P11-a…g implementados en la rama; falta CI verde y revisión de Claude.

## Entregas
### 2026-11-20 — P3: diseño narrativo capítulos 4–5 y epílogo (rama: chatgpt/P3-historia-cap4-cap5, PR: #11)

- **Qué hice:** redacté la propuesta de 8 salas para La Maestranza, 8 salas para Santiago/Centro de Nos, jefe Skull original para capítulo 4, jefe final Rosa-Skull para capítulo 5, epílogo «Para Leo», 8 documentos propuestos, diálogos de Leo/Paz, escalera de seis pistas de «La señora», escena del aplauso y revisión de continuidad.
- **Archivos tocados:** docs/GDD.md, docs/ROADMAP.md, docs/cap4_notas.md, docs/cap4_dialogos.md, docs/continuidad_p3.md y docs/CHATGPT_LOG.md.
- **Pruebas:** «Pruebas en PR» run `44840215999` success; generadores, importación, pruebas automáticas, auditoría de cámaras y exportación correctas; 0 `SCRIPT ERROR`. «Validación de pistola» run `44840222728` success; 0 `SCRIPT ERROR`.
- **Qué debe revisar Claude:** coherencia con GDD, guion, documentos existentes, tono de Leo/Paz, duración y disparador de la escena del aplauso, y si el diseño de salas se puede implementar con roomkit sin introducir sistemas nuevos.
- **Qué debe confirmar Chris:** las decisiones listadas en docs/continuidad_p3.md, especialmente asiento 15, vagón del Centro de Nos, rol de Paz, altura del Skull, mecanismo del jefe y destino final de Rosa.
- **Estado:** PROPUESTA DOCUMENTAL — no implementar capítulo 4 ni cinemática hasta revisión de Claude y confirmación de Chris; la implementación D requiere «APROBADO D».

### 2026-11-20 — P1-f: pruebas de regresión, GDD y campos de datos (rama: chatgpt/P1-menus-audio-ads, PR: #9)

- **Qué hice:** Amplié las pruebas T6 para verificar que cada puerta de avance crea su Marker con el texto correcto y que las puertas VOLVER no crean Marker. Añadí pruebas de persistencia/recarga de los tres buses de audio y reforcé las pruebas de límites Ads y créditos. Documenté la monetización en el GDD. También reemplacé las heurísticas `contains("pesado")` y `contains("gate")` por los campos `EnemyData.heavy` y `Door.metal_door`, con datos explícitos en recursos y generadores; alineé las etiquetas de opciones en la misma fila.
- **Archivos tocados:** `tests/levels_test.gd`, `tests/credits_test.gd`, `tests/systems_test.gd`, `docs/GDD.md`, `docs/CHATGPT_LOG.md`, `ui/options/options_menu.tscn`, `levels/kit/interact/door.gd`, `data/enemies/enemy_data.gd`, `data/enemies/infected_heavy.tres`, `actors/enemies/infected.gd`, `tools/level_gen/roomkit.py`, `tools/level_gen/platform.py`, `tools/level_gen/south_platform.py`, `tools/level_gen/convoy_side.py`, `tools/level_gen/buin_vineyard.py` y las cuatro escenas generadas correspondientes.
- **Pruebas:** CI «Pruebas en PR» pendiente. `credits_test.gd` verifica que el texto de créditos no esté vacío; Chris ya había confirmado en la revisión anterior que `CREDITS.md` está incluido en el paquete exportado. No modifiqué `tools/export_probe.gd` sin autorización.
- **Qué debe probar Chris en el teléfono:** pendiente de CI verde; después revisar los letreros de las puertas, opciones y el flujo de anuncios.
- **Dudas / decisiones que necesito:** queda pendiente la autorización para automatizar también la lectura de `CREDITS.md` en `tools/export_probe.gd`.
- **Estado:** IMPLEMENTADO — pendiente CI y autorización de la comprobación del paquete.

### 2026-11-20 — P1-e: ofertas de recompensa en mochila y pantalla de muerte (rama: chatgpt/P1-menus-audio-ads, PR: #9)

- **Qué hice:** Añadí ofertas opcionales de munición cuando la reserva está vacía o bajo el 25 % del cargador, y de un curativo cuando Isabella está en Peligro y no lleva ninguno. Las cantidades y el ítem de curación se configuran en `data/ads_config.tres`. La escena de mochila se mantiene sincronizada con su generador `tools/level_gen/inventory.py`. En la pantalla de muerte agregué VER ANUNCIO: CONTINUAR; al completar el anuncio vuelve al último guardado seguro con 50 % de salud, una sola vez por muerte. Si no hay anuncio disponible, los botones no aparecen. La compra para quitar anuncios sigue entregando las recompensas directamente.
- **Archivos tocados:** `data/ads_config.gd`, `data/ads_config.tres`, `systems/ads.gd`, `ui/inventory/inventory_menu.gd`, `ui/inventory/inventory_menu.tscn`, `tools/level_gen/inventory.py`, `ui/hud/hud.gd`, `ui/hud/hud.tscn`, `main.gd`, `tests/systems_test.gd`, `docs/CHATGPT_LOG.md`.
- **Pruebas:** comprobaciones de ofertas, combate y continuación pasaron. «Pruebas en PR» run `44836144087` terminó verde; log con 0 `SCRIPT ERROR`. «Validación de pistola» run `44836144072` también verde. Godot no está disponible localmente.
- **Qué debe probar Chris en el teléfono:** pendiente de CI verde; después, revisar munición baja, curativo en Peligro y continuar desde la pantalla de muerte.
- **Dudas / decisiones que necesito:** ninguna nueva.
- **Estado:** P1-e VALIDADO — CI verde y logs sin `SCRIPT ERROR`.

### 2026-11-20 — P1-d: anuncios con recompensa y proveedor de prueba (rama: chatgpt/P1-menus-audio-ads, PR: #9)

- **Qué hice:** Implementé la interfaz de proveedor de anuncios, un proveedor de prueba con cuenta regresiva de 3 segundos y botón SALTAR, y el sistema estático Ads. La recompensa solo se entrega al completar el anuncio; quitar anuncios se persiste en ajustes y entrega recompensas sin mostrar publicidad. Añadí límites configurables: 300 s entre anuncios, máximo 3 por capítulo y 60 s de juego entre recompensas/anuncios; bloqueos durante diálogos, cinemáticas y combate. Apliqué además el ajuste visual de opciones solicitado en la revisión.
- **Archivos tocados:** `systems/ads.gd`, `systems/ads_provider.gd`, `systems/debug_ad_provider.gd`, `data/ads_config.gd`, `data/ads_config.tres`, `ui/options/options_menu.tscn`, `tests/systems_test.gd`, `docs/CHATGPT_LOG.md`.
- **Pruebas:** smoke / systems / levels / credits = OK (0 fallas). «Pruebas en PR» run `44834791918` y «Validación de pistola» run `44834792035` terminaron verdes; ambos logs tienen 0 `SCRIPT ERROR`. Godot no está disponible localmente.
- **Qué debe probar Chris en el teléfono:** cuando el CI esté verde, iniciar una partida, esperar a que se habiliten las recompensas, pulsar una oferta de prueba cuando se integre en el juego y comprobar la cuenta regresiva; SALTAR no debe entregar recompensa. P1-e conectará las ofertas visibles de munición, curativo y continuar.
- **Dudas / decisiones que necesito:** ninguna nueva. La URL de privacidad continúa pendiente de confirmación.
- **Estado:** P1-d VALIDADO — CI verde, pendiente revisión final de Claude al cierre del paquete.

### 2026-11-20 — P1-c: conectar SFX pendientes y música (PR #9)

- **Qué hice:** Conecté los sonidos chase, death, rise, heavy_step, groan_far, hurt_low, breath_low, door_close, door_metal, gate_chain, heal y radio_static en sus eventos de juego. Añadí aliases sintetizados para que sigan sonando si falta su OGG, y un contador de solicitudes en Sfx para pruebas. AudioDirector ahora selecciona title en la pantalla de título, safe en salas con máquina de escribir y expone play_music("leo") para el epílogo; el final de capítulo 5 lo invoca.
- **Archivos tocados:** systems/sfx.gd, actors/enemies/infected.gd, actors/player/player.gd, levels/kit/interact/door.gd, levels/kit/interact/chapter_exit.gd, ui/inventory/inventory_menu.gd, systems/scene_loader.gd, systems/audio_director.gd, ui/title/title_screen.gd, ui/chapter_end/chapter_end.gd, tests/systems_test.gd, tests/credits_test.gd, docs/CHATGPT_LOG.md.
- **Pruebas:** amplié las pruebas de audio para comprobar OGG, fallback sintetizado, contador y eventos de juego; verifiqué las pistas title, safe y leo. No subí ni modifiqué archivos de audio. Godot no está disponible localmente. El primer CI detectó cuatro SCRIPT ERROR de tipado en la prueba (radio_script.new y main.player); añadí tipos explícitos Interactable, Player, int y bool. El commit corregido espera un nuevo CI y debe pasar sin SCRIPT ERROR antes de P1-d.
- **Qué debe probar Chris en el teléfono:** tras CI verde, recorrer un infectado rápido y uno pesado, recibir daño hasta Peligro, usar una máquina de escribir, abrir una puerta de reja, comer un objeto y escuchar la radio de Paz. Revisar la música de título y la sala segura. La pista leo queda lista para la escena de epílogo que implementará P3.
- **Dudas:** el código actual aún no tiene la escena del epílogo Para Leo. Dejé disponible AudioDirector.play_music("leo") y una llamada para el capítulo 5; [CONFIRMAR] P3 debe llamar también a ese método si el epílogo se implementa como escena independiente.
- **Estado:** IMPLEMENTADO; CI pendiente.

### 2026-11-20 — P1-b: menú de opciones (rama: chatgpt/P1-menus-audio-ads, PR: #9)

- **Qué hice:** Añadí OPCIONES desde el título y la mochila. Incluye sliders táctiles de 0–100 % para Sfx, Música y Ambiente; persiste en `user://ajustes.cfg` y aplica los valores al iniciar, manteniendo el nivel base actual de cada bus. Incluye el interruptor gráfico existente, acceso a créditos reutilizable como panel y enlace de privacidad bloqueado de forma segura mientras la URL siga pendiente.
- **Archivos tocados:** `systems/game_settings.gd`, `data/store_links.gd`, `data/store_links.tres`, `ui/options/options_menu.gd`, `ui/options/options_menu.tscn`, `ui/title/title_screen.gd`, `ui/title/title_screen.tscn`, `tools/level_gen/title.py`, `tools/level_gen/inventory.py`, `ui/title/credits_screen.gd`, `ui/inventory/inventory_menu.gd`, `ui/inventory/inventory_menu.tscn`, `tests/credits_test.gd`, `docs/CHATGPT_LOG.md`.
- **Pruebas:** amplié la prueba de créditos para comprobar persistencia/aplicación de volumen, rangos, botones y acceso desde título/mochila. Godot no está disponible localmente. El primer CI detectó que faltaba reflejar el nuevo botón en `tools/level_gen/inventory.py`; corregí el generador y la escena. El commit final `0489d63` pasó «Pruebas en PR» (run 44828958837) y «Validación de pistola» (run 44828958783); los logs registran 0 `SCRIPT ERROR`.
- **Qué debe probar Chris en el teléfono:** cuando CI esté verde, abrir OPCIONES desde título y mochila; mover los tres sliders, cerrar y reabrir el juego para comprobar persistencia; abrir CRÉDITOS desde opciones; pulsar POLÍTICA DE PRIVACIDAD (debe informar que falta confirmar la URL, sin abrir una dirección inventada).
- **Dudas:** [CONFIRMAR] URL pública final de la política de privacidad para `data/store_links.tres`.
- **Estado:** P1-b VALIDADO — CI verde, 0 `SCRIPT ERROR`.

### 2026-11-20 — P1-a2: correcciones visuales y limpieza de créditos (PR #9)

- **Qué corregí:** Moví CRÉDITOS a la esquina superior derecha (220×56, margen 20 px); restauré los pies a 18 px y 15 px con offsets verticales −50/−16. La pantalla ahora quita delimitadores de código y negrita sin destruir el comodín de `assets/*/LICENSE.txt`, convierte viñetas y omite el encabezado duplicado «Créditos».
- **Pruebas añadidas:** comprueban que el texto no contenga acentos graves ni `**`, que conserve `assets/*/LICENSE.txt` y que no repita el encabezado.
- **Archivos tocados:** `tools/level_gen/title.py`, `ui/title/title_screen.tscn` (regenerada según el generador), `ui/title/credits_screen.gd`, `tests/credits_test.gd`, `docs/CHATGPT_LOG.md`.
- **Pruebas:** Godot no está disponible localmente. El commit anterior `8069b44` tuvo «Pruebas en PR» verde (run 44825621399) y «Validación de pistola» verde (run 44825621231), con el paso de sincronía de generadores y exportación completados; el log de ese CI se revisará también para confirmar 0 `SCRIPT ERROR`. «Pruebas en PR» (run 44827329255) y «Validación de pistola» (run 44827329157) terminaron en verde. El log completo del job de pruebas contiene 0 `SCRIPT ERROR`; también pasaron generadores, auditoría de cámaras y paquete exportado.
- **Qué debe probar Chris en el teléfono:** nada todavía; después del CI, comprobar el título y los créditos a 1280×544.
- **Dudas:** ninguna.
- **Estado:** P1-a2 VALIDADO — CI verde, 0 `SCRIPT ERROR`.

### 2026-11-20 — P1-a: créditos en el juego (rama: chatgpt/P1-menus-audio-ads, PR: #9)

- **Qué hice:** Añadí el botón CRÉDITOS al título y una pantalla desplazable que carga `CREDITS.md` en tiempo de ejecución. Conserva las atribuciones CC-BY de Kevin MacLeod y Pixelhouse y agrega «Personaje simple PSX — JashiPSX (itch.io)». Añadí una prueba específica y la incorporé al corredor estricto. El primer CI detectó que el título se regenera desde `tools/level_gen/title.py`; actualicé esa fuente y regeneré la escena para mantenerla sincronizada.
- **Archivos tocados:** `ui/title/title_screen.gd`, `ui/title/title_screen.tscn`, `ui/title/credits_screen.gd`, `ui/title/credits_screen.tscn`, `tools/level_gen/title.py`, `tests/credits_test.gd`, `tools/run_tests.sh`, `docs/CHATGPT_LOG.md`.
- **Pruebas:** no pude ejecutar Godot localmente. El primer «Pruebas en PR» falló en la sincronía del generador (0 `SCRIPT ERROR`); la corrección está subida y espera una nueva ejecución. El corredor ahora ejecuta smoke, systems, levels y credits, y falla ante `SCRIPT ERROR`. No declaro el cambio validado hasta revisar el nuevo CI y sus logs.
- **Qué debe probar Chris en el teléfono:** cuando CI esté verde sin `SCRIPT ERROR`, abrir CRÉDITOS desde el título, desplazar la lista y volver al título.
- **Dudas / decisiones que necesito:** ninguna para P1-a. `CREDITS.md` está incluido por el filtro `all_resources` actual; la comprobación explícita de su presencia en el paquete exportado queda para P1-f.
- **Estado:** EN REVISIÓN — P1 en curso; P1-a corregido, CI pendiente.

### 2026-11-20 — P2: documentación de publicación en Google Play (rama: chatgpt/P2-play-store-docs, PR: #10)

- **Qué hice:** preparé política de privacidad ES/EN, ficha de Google Play ES/EN, borrador de Seguridad de los datos e IARC, auditoría de licencias de recursos y checklist de publicación. Los datos desconocidos quedan marcados [CONFIRMAR]. Los documentos distinguen la build candidata de P1 con proveedor simulado de una futura versión con AdMob/UMP.
- **Archivos tocados:** `docs/store/politica_privacidad.md`, `docs/store/ficha_google_play.md`, `docs/store/seguridad_datos_iarc.md`, `docs/store/licencias_activos.md`, `docs/store/checklist_publicacion.md`, `docs/CHATGPT_LOG.md`.
- **Pruebas:** CI «Pruebas en PR» run `44838096011` verde; generadores, importación, pruebas automáticas, auditoría de cámaras y exportación correctas; log con 0 `SCRIPT ERROR`.
- **Qué debe revisar Chris:** nombre y responsable legal, correo público, licencias rojas/amarillas, privacidad del repositorio, países/precio, audiencia objetivo, IARC y decisión final sobre AdMob/UMP.
- **Dudas / decisiones que necesito:** completar campos [CONFIRMAR], resolver licencias sin evidencia y decidir si el AAB final integra AdMob/UMP.
- **Estado:** P2 DOCUMENTADO Y VALIDADO POR CI — pendiente revisión de Chris y completar [CONFIRMAR].

### 2026-11-20 — T9: cinemática en vivo de la criatura (rama: chatgpt/T9-skull-cinematic, PR: #8)

- **Qué hice:** Preparé una escena 3D en vivo de unos 10 segundos: pasillo industrial desconocido, luz fluorescente inestable, tres golpes que se acercan, pausa de silencio, puerta que se abomba y estalla en fragmentos físicos, polvo, sombra proyectada y rugido lejano. Skull nunca aparece; no hay diálogo, rótulos ni nombres internos en pantalla. Un toque la salta.
- **Integración:** `Room.cinematic` apunta a la escena desde `track_north`; `SceneLoader` la ejecuta antes de la intro, marca `cinematic:<ruta>` en `GameState` y restaura cámara, HUD y controles. Se prueba carga, finalización, bandera y no repetición.
- **Archivos:** `levels/kit/cinematic.gd`, `levels/cinematics/creature_door.tscn` (generada por `tools/level_gen/creature_door.py`), `levels/kit/room.gd`, `tools/level_gen/roomkit.py`, `tools/level_gen/track_north.py`, `systems/scene_loader.gd`, pruebas y regenerador.
- **Pruebas:** no ejecutadas localmente (este entorno no dispone de Godot). El workflow debe correr smoke / systems / levels, auditoría y exportación. Revisaré todos los logs y buscaré literalmente `SCRIPT ERROR`; un verde sin esa comprobación no cuenta.
- **CI validado:** «Pruebas en PR» #44814303561 y «Validación de pistola» #44814303281 finalizaron en `success`. Smoke, systems y levels: 0 fallas; auditoría de cámaras y verificación de textos exportados: OK. Revisé ambos logs completos: 0 apariciones literales de `SCRIPT ERROR`.
- **Corrección CI:** la primera pasada detectó el permiso de ejecución del regenerador y una llamada de prueba a una coroutine sin `await`; ambos quedaron corregidos. No se acepta esa corrida fallida como resultado.
- **Ajuste visual/ejecución:** Godot 4.7 confirma que CPUParticles3D usa `mesh` (no `draw_pass_1`, que pertenece a GPUParticles3D); corregí la propiedad y amplié la espera de restauración en la prueba. Se exige otra corrida completa.
- **Qué debe probar Chris en el teléfono:** tras el OK de Claude, iniciar o continuar hasta la vía norte; comprobar la cinemática, el salto con un toque y que no vuelva a salir al reingresar.
- **Dudas / decisiones que necesito:** Claude debe revisar la composición y los tiempos con capturas; no se muestra ningún modelo de Skull.
- **Estado:** CI aprobado en ambos workflows y sin `SCRIPT ERROR`; [PR #8](https://github.com/chrisalainibacache/Paine-quest/pull/8) sigue abierto, revisión de Claude pendiente.

### 2026-11-20 — T8: ambiente por sala (rama: chatgpt/T8-room-ambience)

- **Qué hice:** Añadí `Room.ambience: StringName` exportado y el parámetro `ambience=` a `roomkit.Kit`. Asigné los 14 ambientes de AUDIO_PLAN §5 a las 19 salas de los capítulos 1–3 mediante sus generadores; actualicé también los dos generadores antiguos que no usan Kit.
- **Mapa:** Paine: `station_night`, `waiting_room`, `office`, `service_corridor`, `storeroom`; vía: `tracks_night`, `fire_wreck`, `train_interior`, `underpass`, `switch_house`; Buin: `bridge_river`, `military`, `day_fields` y `barn` para la Bodega agrícola (ajuste de Claude).
- **Pruebas:** `tests/levels_test.gd` exige un ambiente no vacío en cada sala. El workflow regenera escenas y ejecuta `./tools/run_tests.sh`, que falla ante `SCRIPT ERROR`. No declararé las pruebas aprobadas hasta revisar ambos logs.
- **Corrección y estado:** Claude corrigió «Javi» por «Paz» y asignó `barn` a la Bodega agrícola. PR #7 fusionado por Claude; T8 cerrado.

### 2026-11-20 — T7: audio real, tanda 1 de armas (rama: chatgpt/T7-audio-base, PR: #6)

- **Qué hice:** Integré los 27 OGG de armas que ya están en `assets/audio/sfx/`. El cargador busca el nombre exacto y sus variantes `_1.._8`, selecciona una al azar y usa la receta sintetizada si no encuentra muestras. Añadí los alias de respaldo exigidos por AUDIO_PLAN §9: `assault → rifle`, `bazooka → launcher`, `mauser → shot`. Actualicé los recursos de esas tres armas para reproducir sus nuevos OGG.
- **Archivos tocados en esta tanda:** `systems/sfx.gd`, `tests/systems_test.gd`, `data/weapons/assault_rifle.tres`, `data/weapons/bazooka.tres`, `data/weapons/mauser.tres`; se conserva la infraestructura T7 ya entregada en este PR.
- **Pruebas:** añadí comprobaciones de carga OGG, alias y fallback sin muestras. Las tres pruebas completas (smoke / systems / levels) no se ejecutaron localmente porque este entorno no dispone de Godot. El workflow «Pruebas en PR» debe validar este commit; no afirmo que haya pasado antes de su resultado.
- **Qué debe probar Chris en el teléfono:** esperar CI verde y revisión de Claude; después comprobar por oído las cinco armas cubiertas por los OGG.
- **Estado:** ACTUALIZADO — PR #6 abierto; nueva validación CI pendiente.

### 2026-11-19 — T5: hoja de ruta actualizada (rama: chatgpt/T5-roadmap, PR: #5)

- **Qué hice:** Actualicé el estado del proyecto con los tres capítulos completos y detallé el capítulo 3 de Buin, el rescate de Kiara y Nala, la planificación de cámaras, los túneles, el modo Moderno predeterminado, las flechas de destino, el cartel de sala y la pantalla DIAG. Dejé separados los trabajos implementados de los pendientes (audio T7/T8, cinemática T9 y capítulos siguientes).
- **Archivos tocados:** `docs/ROADMAP.md` y `docs/CHATGPT_LOG.md`.
- **Pruebas:** smoke / systems / levels = no ejecutadas localmente (este entorno no dispone de Godot). Es un cambio documental; queda pendiente el workflow «Pruebas en PR». No afirmo que las pruebas hayan pasado.
- **Qué debe probar Chris en el teléfono:** nada (solo documentación).
- **Dudas / decisiones que necesito:** ninguna; los estados se contrastaron con el GDD, los generadores, los sistemas y `tools/level_gen/cameras.json`.
- **Estado:** EN REVISIÓN — PR #5 abierto; pendiente de CI «Pruebas en PR» y revisión de Claude.

### 2026-11-19 — Corrección T4 tras revisión de Claude (misma rama: chatgpt/T4-pistas-leo, PR: #4)
- **Qué corregí:** Restauré las líneas narrativas y mecánicas originales de Leo que habían sido reemplazadas; agregué las acciones como líneas finales independientes. Corregí las rutas indicadas por Claude: puente → CONTROL MILITAR; bodega agrícola → ESTACIÓN DE BUIN; andén norte → SALA DE ESPERA y recorrido por boletería/pasillo/bodega; regreso por BOLETERÍA → SALA DE ESPERA → ANDÉN NORTE; cierre del andén sur mediante TrackExit/ACCIÓN en el túnel este. Eliminé referencias a flechas cuando la puerta no tiene ese destino y ajusté destinos según sus rótulos reales.
- **Archivos:** Los 17 generadores y sus 17 escenas `.tscn` correspondientes en `tools/level_gen/`, `levels/station/`, `levels/tracks/` y `levels/buin/`.
- **Pruebas:** El CI anterior de T4 fue verde, pero corresponde a la versión anterior y no valida esta corrección. Pendiente nueva ejecución de «Pruebas en PR». No pude ejecutar Godot ni `regenerar_todo.sh` localmente; por ello no afirmo pruebas locales ni regeneración ejecutada.
- **Qué debe probar Chris:** esperar el nuevo CI y la revisión de Claude; no hacer pruebas manuales hasta recibir indicaciones.
- **Revisión adicional:** corregí la pista de la boletería para indicar primero la puerta PASILLO DE SERVICIO (y después BODEGA), y precisé en la vía la flecha amarilla rotulada TREN DESCARRILADO.
- **Dudas:** la validación narrativa final queda a cargo de Claude. No avanzar a T5 hasta que Claude responda literalmente `OK` en este PR.
- **Estado:** CORRECCIÓN SUBIDA / pendiente CI y revisión de Claude.

### 2026-11-19 — T4: pistas de Leo con acciones concretas (rama: chatgpt/T4-pistas-leo, PR: pendiente)
- **Qué hice:** Revisé las pistas `leo_hint(...)` de los generadores del capítulo 1, 2 y 3. Ajusté sus últimas líneas para indicar una acción y un lugar concretos; cuando hay una puerta de avance, la pista orienta hacia la flecha amarilla. Conservé el tono cercano de Leo y no cambié la historia ni las condiciones de aparición.
- **Archivos tocados:** generadores `tools/level_gen/{platform,waiting_room,ticket_office,service_corridor,storeroom,south_platform,track_north,wagon_interior,convoy_side,underpass,buin_bridge,buin_checkpoint,buin_field,buin_station,buin_warehouse,buin_vineyard,buin_shed}.py` y sus 17 escenas generadas correspondientes en `levels/station/`, `levels/tracks/` y `levels/buin/`.
- **Pruebas:** smoke / systems / levels = no ejecutadas localmente (no hay Godot 4.7.2 ni clon local disponible). Tampoco pude ejecutar `./tools/level_gen/regenerar_todo.sh`: este entorno no puede clonar el repositorio desde GitHub. Para mantener la sincronía, actualicé las cadenas `PackedStringArray` de los 17 `.tscn` en paralelo con los generadores; **queda pendiente que «Pruebas en PR» confirme que están idénticos**. No afirmo que hayan pasado.
- **Qué debe probar Chris en el teléfono:** nada por ahora; esperar el CI verde y la revisión de Claude. Después, si Claude lo pide, comprobar que las pistas se entienden al quedarse quieta Isabella cerca de cada punto.
- **Dudas / decisiones que necesito:** detecté una referencia antigua «Javi, aguanta» en la introducción de `track_north.py`; no la cambié porque está fuera del alcance de T4. La dejo anotada para que Claude decida si se corrige en otro ticket.
- **Estado:** EN REVISIÓN — pendiente de CI «Pruebas en PR» y revisión de Claude. No iniciar D: sigue bloqueada hasta `APROBADO D`.

### 2026-11-19 — Lectura inicial y alineación de alcance (rama: chatgpt/inicio-diseno-cap4, PR: #3)
- **Qué hice:** Leí, en el orden solicitado, `docs/CHATGPT_BRIEF.md`, `docs/CHATGPT_LOG.md`, `CLAUDE.md`, `docs/GDD.md` y `docs/ROADMAP.md`. También revisé `docs/ARCHITECTURE.md`, `docs/ART_PIPELINE.md`, `update grafica.txt` y `tools/level_gen/README.md`, requeridos por el brief.
  Entendimiento: Paine es un survival horror 2.5D para Android horizontal; los capítulos 1–3 están completos. El capítulo 4 debe diseñarse como 6–8 salas pequeñas y cerradas en La Maestranza, con conexiones, objetos, enemigos, un enemigo/jefe nuevo, recompensas y pistas de Leo. El vagón del Centro de Nos no se abre. Las notas deben respetar la cronología del GDD; Leo se trata con cariño. A–C son solo diseño y texto. D queda bloqueada hasta que Claude escriba literalmente `APROBADO D`.
- **Archivos tocados:** `docs/CHATGPT_LOG.md` únicamente.
- **Pruebas:** smoke / systems / levels = no pude correrlas: este entorno no dispone de una ejecución local de Godot 4.7.2 ni del proyecto clonado. No afirmo que hayan pasado. No hubo cambios de código ni de salas.
- **Qué debe probar Chris en el teléfono:** nada (solo registro/documentación).
- **Dudas / decisiones que necesito:** ver las cuatro preguntas fechadas arriba, especialmente la continuidad temporal, el rol de Javiera y el límite de lo que se revela del vagón.
- **Estado:** BLOQUEADO — esperando respuesta de Claude antes de iniciar la tarea A, tal como pidió Chris.

