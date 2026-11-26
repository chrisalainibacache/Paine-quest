# Encargo largo para ChatGPT — 4 paquetes (supervisa Claude)

Decisión de Chris (2026-11-20): **tareas largas, no de a una línea.** Cada paquete agrupa varios tickets de la cola
(`docs/CHATGPT_LOG.md`). Reglas de trabajo de siempre (`docs/CHATGPT_BRIEF.md`): rama `chatgpt/<paquete>`, nunca push a `main`,
registro en `docs/CHATGPT_LOG.md` (arriba), «verde» solo si «Pruebas en PR» pasa **sin `SCRIPT ERROR`**, nada de nombres
internos en textos visibles, no borrar pendientes ni líneas ajenas, no inventar rutas del juego.

## Cómo se trabaja un paquete (distinto a antes)
- **Un PR por paquete**, con **un commit por tarea** (`P1-a`, `P1-b`…). Abre el PR (borrador) tras el primer commit para que
  el CI corra en cada push.
- **No esperes mi OK entre tareas del mismo paquete.** Sí espera el **verde del CI** antes de empezar la siguiente: si un
  commit rompe el CI, arréglalo antes de seguir.
- Claude revisa **al final del paquete** (o antes si pides ayuda en «Preguntas»). Al cerrar, deja en el registro una sola
  entrega por paquete con: qué hiciste por tarea, archivos, pruebas, qué probar en el teléfono, dudas.
- Orden de paquetes: **P1 → P2 → P3 → P4**. P2 y P3 son texto y pueden hacerse mientras esperas CI de P1.
- Si algo del encargo choca con el código real, **pregunta** (no inventes). Marca `[CONFIRMAR]` lo que dependa de Chris.

---

## P1 — Menús, créditos, sonido y anuncios con recompensa (código, ~6 tareas)
Contexto: el juego se publicará en Google Play gratis con **anuncios con recompensa opcionales** (decisión de Chris;
`docs/MONETIZACION.md`). Claude integrará después el SDK real (AdMob); tú dejas **todo el juego listo** con un proveedor falso.

**P1-a · Créditos (T10).** Botón CRÉDITOS en el título (`ui/title/`) → pantalla con desplazamiento que muestra el contenido de
`CREDITS.md` (léelo en tiempo de ejecución desde `res://CREDITS.md` si se exporta; si no, cópialo a `data/credits.txt` y
añade esa extensión al filtro de exportación **pidiéndolo en «Preguntas»**, porque no puedes tocar `export_presets.cfg`).
Debe incluir la frase de licencia CC BY 4.0 de la música de Kevin MacLeod y los créditos de modelos CC-BY (Pixelhouse).
Añade además «Personaje simple PSX — JashiPSX (itch.io)» (crédito agradecido, no obligatorio). Salir con un toque o botón VOLVER.

**P1-b · Menú de opciones (T13).** Pantalla accesible desde el título y desde la mochila: sliders **Sfx, Música, Ambiente**
(buses del `default_bus_layout.tres`; 0–100 %), botón CRÉDITOS, botón **POLÍTICA DE PRIVACIDAD** (abre la URL guardada en
`data/store_links.tres` con un valor `[CONFIRMAR]`, usando `OS.shell_open`), y el interruptor de gráficos ya existente si
corresponde (**no** modifiques `systems/graphics_settings.gd`). Guarda en `user://ajustes.cfg` (`ConfigFile`) y aplícalo al
iniciar. Botones táctiles grandes (≥ 64 px de alto), apto para pantalla 1280×544 con notch.

**P1-c · Sonidos que faltan (T11).** Conecta con respaldo (`Sfx.play` ya cae al sintetizado si falta el archivo):
`chase_N` (infectado rápido persiguiendo), `death_N`, `rise_N` (se levanta), `heavy_step_N` (pesado), `groan_far_N` (infectado
fuera de cuadro), `hurt_low_N` y `breath_low_1` (Isabella en Peligro), `door_close_N`, `door_metal_N` (reja/portón),
`gate_chain_N`, `heal_N` (comer/curarse), `radio_static_1` (radio de Paz); música `title` (título), `safe` (sala de la
máquina de escribir) y `leo` (epílogo) vía `AudioDirector`. Ver `docs/AUDIO_PLAN.md` §9. **No subas audio** (lo sube Claude).
Pruebas: que cada nombre se pida donde corresponde (usa un espía/contador en `Sfx` para tests) y que no falle sin archivo.

**P1-d · Anuncios con recompensa (sistema, sin SDK).** Clase `Ads` (`systems/ads.gd`, `class_name Ads`, estática) con:
`Ads.available() -> bool`, `Ads.show_rewarded(placement: StringName, on_done: Callable)` (`on_done(rewarded: bool)`),
`Ads.removed` (bool persistido en `user://ajustes.cfg`; si es verdadero, todas las recompensas se entregan **sin anuncio**).
Un `AdProvider` base (`systems/ads_provider.gd`) con métodos `is_ready()`, `show(placement, on_done)`, y un
`DebugAdProvider` que muestra un panel «ANUNCIO DE PRUEBA» con cuenta regresiva de 3 s y botón SALTAR (rewarded = verdadero
al terminar la cuenta). Claude añadirá `AdMobProvider`. **Nunca** muestres anuncios sin que el jugador pulse un botón.
Reglas anti-abuso en `Ads` (datos en `data/ads_config.tres`, `Resource` tipado): enfriamiento 300 s entre anuncios, máximo
3 por capítulo, mínimo 60 s de partida desde el último anuncio, y nada de anuncios durante diálogo/cinemática/combate.

**P1-e · Ofertas de recompensa en el juego.** Tres puntos, todos opcionales y con botón claro:
1. **MOCHILA**: si la munición de reserva del arma equipada es 0 (o < 25 % del cargador) aparece «VER ANUNCIO: +MUNICIÓN»
   (cantidad en `ads_config`: 12 pistola / 6 escopeta / etc. por tipo; consulta `data/weapons/*.tres`).
2. **MOCHILA**: si la salud está en Peligro y no hay curativos: «VER ANUNCIO: +1 CURATIVO».
3. **PANTALLA DE MUERTE**: «VER ANUNCIO: CONTINUAR» → reaparece en la última sala segura con 50 % de salud **una vez por
   muerte** (y respeta el máximo de 3 por capítulo). Si no hay anuncio disponible, el botón no aparece.
Textos en español, sin nombres internos. No cambies el balance base del juego. Registra la decisión en `docs/GDD.md`
(nueva subsección «Monetización y anuncios»).

**P1-f · Pruebas (T6 + nuevas).** En `tests/` (solo **agregar**): (1) cada puerta de avance crea su `Marker` con el texto del
destino y las puertas «VOLVER» no lo tienen (T6); (2) `Ads` respeta enfriamiento, máximo por capítulo y `removed`;
(3) el menú de opciones guarda y recarga volúmenes; (4) créditos cargan texto no vacío **en el paquete exportado**
(si hace falta, añade la comprobación a `tools/export_probe.gd`: pregunta antes de tocar `tools/`). Todo con CI verde.

**Hecho cuando:** CI verde en el PR; el juego se juega igual que antes con el proveedor falso; Claude revisa y prueba en el
teléfono (créditos, opciones, anuncio de prueba, continuar).

---

## P2 — Documentos de publicación (texto, ~5 entregables) · carpeta `docs/store/`
No afirmes datos que no conoces; marca `[CONFIRMAR]`. Todo en español, y **versión en inglés** donde se indica.
- **P2-a `politica_privacidad.md` (ES + EN):** datos que trata el juego: partida guardada local, ajustes, **identificador
  publicitario y datos de dispositivo por AdMob** (solo si el jugador ve anuncios), consentimiento (UMP) en regiones que lo
  exigen, sin cuentas ni compras con datos personales por parte nuestra, contacto `[CONFIRMAR correo de contacto]`,
  derechos del usuario, menores (el juego es para **mayores de edad**: violencia/terror), cambios de la política.
- **P2-b `ficha_google_play.md` (ES + EN):** título, descripción corta (≤ 80 car.), larga (≤ 4000 car., sin promesas falsas ni
  palabras prohibidas de reseñas/ranking), lista de capturas sugeridas (qué sala y qué momento mostrar, 2 a 8), texto de
  «novedades», categoría, etiquetas. Tono: survival horror chileno, cámaras fijas, Isabella y Leo.
- **P2-c `seguridad_de_datos_y_clasificacion.md`:** respuestas borrador, pregunta por pregunta, de «Seguridad de los datos»
  y del cuestionario IARC (violencia, sangre, armas, miedo, lenguaje) y de la declaración de anuncios. Cita la política.
- **P2-d `licencias_activos.md`:** tabla viva de **todos** los recursos de terceros (usa `docs/MONETIZACION.md` §1,
  `CREDITS.md` y los `LICENSE.txt` de `assets/**`): archivo, autor, fuente (itch.io/OpenGameArt/Poly Haven…), licencia,
  condición (crédito, no redistribuir), dónde se usa, estado (🟢🟡🔴). **No cambies licencias de lo que no sabes**; lo
  desconocido queda 🔴 `[CONFIRMAR]`.
- **P2-e `checklist_publicacion.md`:** lista numerada, con casillas, de todo lo necesario para publicar (cuenta, firma,
  AAB, política, formularios, ícono 512, gráfico 1024×500, capturas, prueba cerrada con testers, consentimiento UMP,
  país/precio, fiscal). Para cada ítem: quién lo hace (Chris / Claude / ChatGPT) y dependencias.
**Hecho cuando:** PR solo de docs, CI verde; Claude revisa coherencia con el juego real.

---

## P3 — Historia larga: capítulo 4, notas, capítulo 5 y epílogo (texto, ~5 entregables)
Incluye T1, T2 y T3. **Regla de oro (decisión de Chris, 2026-11-20):** el **origen de la infección NO se revela en este juego**: se reserva para una
**segunda parte**. Ni los capítulos 4 y 5 ni el epílogo lo explican. Sí pueden **sembrar preguntas** para la parte 2 (rumores,
registros incompletos, cosas que nadie sabe explicar), siempre sin dar respuestas ni contradecir el GDD. Lista esas semillas
en «Preguntas» para que Chris elija cuáles conservar. Respeta la línea de tiempo del GDD y lo canon descrito en «Respuestas de
Claude» (2026-11-19, PR #3): ch.4 = tarde del sábado en La Maestranza; Paz es personal sanitario de apoyo (**PROPUESTA
provisoria**); el vagón del Centro de Nos sigue cerrado hasta el capítulo 5.
**Decisiones nuevas de Chris (2026-11-20), obligatorias en P3:** (1) **Skull aparece en las notas** del camino como un infectado más grande y aterrador
(más alto que un hombre, cara pelada «como una calavera», resiste el fuego, no corre: espera y busca), **sin nombrarlo ni verlo**: todas las
notas del capítulo 4 y 5 pueden mencionarlo (ver GDD «Rosa y Skull en las notas»). (2) **Rosa** quedó sospechosa (cómo cruzó hasta Buin no se
explica; Leo cree que es un infectado distinto): no la resuelvas, puedes dejar ecos. (3) La radio de Paz pregunta por **sobrevivientes**.
(4) El capítulo 2 no es el final del juego. (6) **APROBADO: Rosa es Skull** (lee GDD «APROBADO por Chris: Rosa se transforma en Skull»). El **Skull original** es el jefe del capítulo 4 y
**muere** ahí; **Rosa**, mordida por él, los **sigue** y es el **jefe final del capítulo 5** (transformación a la vista). Escribe en P3: el eco de la
puerta del galpón arrancada desde dentro, 2 o 3 indicios en notas **sin decir que son lo mismo**, y el diseño de la pelea final (fases, entorno, qué
pasa con Rosa, frases suyas durante la pelea, el final emocional). (5) **Los gatos son inmunes a los infectados** (no se contagian, ni Skull los ataca): regla del mundo, sin explicar el porqué; puedes sembrarla en notas, pero Leo no la dice en voz alta.
- **P3-a Capítulo 4 «La Maestranza»** en `docs/GDD.md` §2 y §8: 6 a 8 salas pequeñas y cerradas (nombre, función, conexiones,
  objetos, enemigos, recompensas, **qué cámara/ángulo conviene** y rutas de Leo). Un enemigo nuevo: **Skull** (nunca se ve
  completo; ver GDD «Skull, la Criatura» y su cinemática P4) como persecución/jefe. Equilibrio de munición del capítulo.
- **P3-b Notas del capítulo 4:** 6 a 8 documentos (título, hora, texto) en el formato de `data/documents/*.tres`, **solo como
  texto en el registro o `docs/cap4_notas.md`** (no crees `.tres` todavía). Voces distintas (enfermera, guardia, cartas).
- **P3-c Capítulo 5 y epílogo «Para Leo»**: salas, enemigos, final; despedida de Leo según `docs/CHATGPT_BRIEF.md` §6-C.
- **P3-d2 «La señora» (ver GDD «La señora: escalera de pistas hacia Rosa»):** escribe los **seis peldaños** completos: quién habla, en qué sala del
  capítulo 4 o 5, el texto exacto (diálogo o nota) y la reacción de Leo. Cada uno 3 a 6 líneas, voces distintas (paciente, enfermera, soldado, Paz, grabación).
  Respeta las reglas del GDD: los peldaños 1 a 5 **no nombran** a Rosa; ninguno explica el origen. Entrega una **tabla** con sala, texto y condición.
- **P3-d3 Escena viva «el aplauso» (peldaño 4):** escribe en el GDD, dentro de P3, el **guion de la escena** (planos, tiempos, luz, sonidos, líneas) según el
  GDD «La señora» (decisión de Claude: es escena en vivo). La implementación en código irá en un paquete posterior; **no** implementes nada ahora.
- **P3-d Diálogos de Leo y de Paz** (Leo empieza con `Leo: `): lista por sala para cap. 4 y 5, tono tierno, **cada pista
  termina en una acción concreta** (como T4).
- **P3-e Revisión de continuidad:** anota (no corrijas) contradicciones o errores de ortografía en textos existentes.
**Hecho cuando:** PR solo de docs, CI verde; Claude revisa contra el GDD; Chris confirma las PROPUESTAS.

---

## P4 — Cinemática de Skull en vivo (T9) y pruebas finales (código+py, ~4 tareas)
Sigue el «Diseño de T9» del registro al pie de la letra (puerta que estalla, sombra, 10 s, saltable, una vez por partida).
- **Nota de arte:** **no pidas imágenes ni dibujos de Skull** (no se pudo y no hace falta). Para la **sombra** usa el cuerpo ya armado:
  `preload("res://levels/kit/skull_body.gd").build()` devuelve un `Node3D`; ponle `cast_shadow = SHADOWS_ONLY` a todas sus `MeshInstance3D`
  (nunca se ve la malla). Capturas de referencia en `docs/arte/skull_sombra.png`.
- **P4-a** escena generada `levels/cinematics/creature_door.tscn` con Python (`roomkit`/`tscn`).
- **P4-b** `levels/kit/cinematic.gd` (≤ 300 líneas) + gancho en `SceneLoader` (`Room.cinematic`, bandera `cinematic:<ruta>`,
  antes de las líneas de intro, saltable con un toque; coordina con `_play_opening` ya existente). Asígnala a `track_north`.
- **P4-c** pruebas (carga, termina, marca la bandera, saltable) y **modo sin sonido** si faltan los `.ogg`.
- **P4-d** deja en el registro una **lista de los archivos de sonido** `creature_*` que Claude debe generar.
**Hecho cuando:** CI verde; Claude revisa con capturas y ajusta tiempos/luz.

---

## Al terminar todo
Escribe una entrega final «Estado de los 4 paquetes» y deja **lista la cola siguiente** (tareas que propones). No avances a
`D` (capítulo 4 implementado) sin que Claude escriba `APROBADO D`.

---

## P5 — Búsqueda de trenes reales (investigación + diseño; ~4 entregables) · decisión de Chris (2026-11-21)
Los vagones y la locomotora que armamos con cajas se ven irreales. Hace falta **modelos 3D de verdad** (CC0 o CC-BY, uso comercial permitido) o,
si no hay, un **diseño detallado** para mejorar los nuestros. **No puedes modelar mallas ni verlas**; tu trabajo aquí es investigar, verificar licencias
y escribir especificaciones. Todo en `docs/trenes/` (solo texto).
- **P5-a `candidatos.md`:** 8 a 12 modelos descargables de **locomotora diésel**, **vagón de pasajeros** (tipo chileno/EFE: caja de metal, ventanas corridas,
  bogies, escalones, puertas laterales) y **vagón de carga**, buscando en: Sketchfab (filtro *Downloadable* + licencia *CC0 / CC-BY*), Poly Pizza, OpenGameArt
  (p. ej. «locomotive 1» de 32kda), itch.io (p. ej. «Train Pack» de Ward727), Kenney (Train Kit), BlenderKit y Free3D. Por cada uno: **enlace directo, autor, licencia
  literal (cópiala de la página), triángulos, formato (GLB/FBX/OBJ), texturas, estilo (realista/low poly) y qué hay que hacer para bajarlo** (¿exige cuenta?). Descarta todo lo
  **NC (no comercial)**, «solo educativo» o sin licencia visible. Máximo ~25.000 triángulos por vagón (corre en un Redmi 13C).
- **P5-b `recomendacion.md`:** tu ranking (mejor 3 + por qué), qué licencia obliga a **dar crédito** (para `CREDITS.md`) y cómo se vería con nuestro estilo (cámaras fijas desde arriba).
- **P5-c `especificacion_vagon.md` (plan B si nada sirve):** descripción **medida y por piezas** de un vagón de pasajeros y una locomotora diésel reales (dimensiones, bogies,
  ventanas, puertas, enganches, topes, techo, equipos de bajos), con **lista de piezas y medidas en metros** que yo pueda construir en el generador (`tools/level_gen/train_props.py`),
  y **referencias fotográficas con enlace** (solo páginas con licencia clara o que sean únicamente para mirar).
- **P5-d `daños.md`:** catálogo de **daños realistas de un descarrilamiento** (vagón ladeado, bogies salidos, techo rasgado, ventanas rotas, quemaduras, tapas de tope) para cada pieza.
**Hecho cuando:** PR solo de docs, CI verde. Chris descarga los 2–3 elegidos desde el teléfono y los sube a su Drive; Claude los convierte y los integra.

---

## P6 — Capítulo 4 en el juego y limpieza (código + texto, ~6 tareas) · pedido de Chris (2026-11-21): «ponlo a trabajar también»
**Antes de empezar lee `docs/LECCIONES_SALAS.md`** (reglas obligatorias aprendidas hoy) y tu propio diseño en `docs/GDD.md`, `docs/cap4_notas.md` y `docs/cap4_dialogos.md`.
`APROBADO D` ya está escrito: puedes implementar **La Maestranza**. Un PR para el paquete, **un commit por tarea**, sin esperar mi OK entre tareas (sí el verde del CI).
- **P6-a Salas 1 a 4** del capítulo 4 (`maestranza_acceso`, `maestranza_guardia`, `maestranza_enfermeria`, `maestranza_taller`): carpeta `levels/maestranza/`,
  generadores `tools/level_gen/maestranza_*.py` con `roomkit.Kit`, **llegadas con puerta visible**, `ambience=` (usa los ambientes de `docs/AUDIO_PLAN.md`), notas como
  `data/documents/*.tres` (textos de `docs/cap4_notas.md`), pistas de Leo con acción concreta, enemigos y recompensas de tu tabla del GDD. Cámaras provisorias (Claude las planifica).
- **P6-b Salas 5 a 7** (`vestuario`, `pasillo_cuarentena`, `puesto_sanitario`): igual que arriba. **No** hagas `patio_maniobras` (el jefe) ni la escena del aplauso: los hago yo.
- **P6-c Conexión**: puertas entre las 7 salas, `SceneLoader`/`chapter_end` (el capítulo 3 ya apunta al 4: `ui/chapter_end/chapter_end.gd`), `AudioDirector` (música del capítulo), y el
  `Room.cinematic`/banderas que correspondan. Sin tocar el 1–3.
- **P6-d Pruebas**: en `tests/levels_test.gd` (solo **agregar**): cada sala nueva carga, tiene ambiente, spawns válidos, puertas de avance con su `Marker`, notas con texto no vacío, y
  `tools/export_probe.gd` sigue verde (pide permiso en «Preguntas» si hay que tocarlo).
- **P6-e Limpieza heredada**: (1) separar `levels/kit/cinematic.gd` (321 líneas) en dos archivos < 300; (2) en `ui/options/options_menu.tscn` poner cada etiqueta de volumen **a la izquierda en la misma fila**
  que su deslizador; (3) campos de datos en vez de comprobaciones por nombre (`heavy: bool` en `EnemyData`, `metal: bool` en las puertas); (4) subir los `.uid` que falten.
- **P6-f Documentación al día**: `docs/ROADMAP.md` (hitos 9 a 12 y estado real: P1, trenes reales, Vía norte y Tren descarrilado renderizados, campo abierto), `docs/GUION.md` (agrega capítulo 4
  según tu diseño), `docs/store/licencias_activos.md` (agrega **Josefin Sans (OFL)**, los **trenes CC0 de tevy.dev y grab3d.com**, el **fondo del título generado con IA, términos por confirmar**).
**Hecho cuando:** CI verde en el PR, sin `SCRIPT ERROR`; Claude revisa con capturas y planifica cámaras/renders. **No avances al capítulo 5.**

---

## P7 — Capítulo 5 y epílogo en el juego (código + texto, ~5 tareas) · después de P6
Mismas reglas que P6 y **`docs/LECCIONES_SALAS.md`**. Un PR aparte (`chatgpt/P7-capitulo-5`), un commit por tarea. Usa tu diseño de `docs/GDD.md` (capítulo 5 y epílogo) y `docs/cap4_dialogos.md`.
- **P7-a** Salas 1 a 4 de **Santiago / Centro de Nos** (`santiago_via_norte`, `centro_nos_acceso`, `centro_nos_recepcion`, `centro_nos_archivo`): carpeta `levels/centro_nos/`, generadores `tools/level_gen/centro_nos_*.py`, notas en `data/documents/*.tres`, pistas de Leo, enemigos y recompensas de tu tabla.
- **P7-b** Salas 5 a 7 (`enfermeria`, `pasillo_transferencia`, `preaislamiento`). La del jefe final (`sala_aislamiento`, Rosa-Skull) **no**: la hago yo.
- **P7-c** Peldaño 6 de «La señora» (grabación de Rosa C. en preaislamiento) y el resto de las pistas del capítulo 5, con los textos exactos de `docs/cap4_dialogos.md`.
- **P7-d** Epílogo «Para Leo» (`epilogo_amanecer`): sala sin enemigos, la despedida aprobada (Leo camina hacia la luz, se gira, maúlla una vez y se va; dedicatoria **«Para Leo»**), pantalla final y vuelta al título. Música `leo` ya está en `AudioDirector`.
- **P7-e** Pruebas en `tests/levels_test.gd` (solo agregar) y entrega en el registro. **No** implementes el jefe final.

## Reglas de entrega para P6 y P7 (la vez pasada no llegó nada a GitHub)
1. Crea la rama, haz el **primer commit** y **empuja** (`git push -u origin chatgpt/P6-capitulo-4`); abre el PR **en borrador** de inmediato y deja el enlace en el registro.
2. Cada tarea = un commit **empujado** (no acumules local). Si no puedes empujar, di **exactamente** qué falló en «Preguntas»; no digas «terminé» sin enlace al PR.
3. Al terminar, escribe la entrega en `docs/CHATGPT_LOG.md` (qué hiciste por tarea, archivos, pruebas, qué debe revisar Claude) y quita el borrador del PR.

---

## ⚡ CAMBIO DE PROTOCOLO (2026-11-21, léelo antes de P8 y P7) — ya no necesitas Godot
**P6 está FUSIONADO en `main`** (PR #13): las 7 salas de La Maestranza ya existen en `levels/maestranza/`. Dos cosas nuevas que te destraban:
1. **Regeneración automática.** Edita SOLO los `.py` de `tools/level_gen/`. Al hacer push a una rama `chatgpt/**`, el flujo **«Regenerar escenas»** corre `regenerar_todo.sh`, sube los `.tscn`
   resultantes a tu rama (commit «Regenerar escenas… (automático)») y lanza **«Pruebas en PR»**. Mira ese resultado (`actions_list` / `get_job_logs`), no esperes a Claude para cada cambio.
   Si agregas un generador nuevo, **ponlo en la lista de `tools/level_gen/regenerar_todo.sh`**. Si algo falla, lee el log y corrige; no digas «bloqueado» sin haber leído el log.
2. **Las salas se diseñan en 16 × 10 m** (`X -8..8`, `Z -5..5`) y `maestranza_common._squeeze` las construye en 12 × 8 m. Escribe las posiciones en el espacio de diseño. Alto del techo útil: 4,4 m.
   **Reglas de cámara** (Claude las replanifica al final, tú no puedes): nada sólido más alto de **1,3 m** en la franja central de la sala (|Z| < 2,5) ni pegado a las puertas (|X| > 6,5);
   lo alto va **contra los muros norte/oeste/este**; deja siempre 1,2 m libres frente a cada puerta; sin cajas sólidas grandes en el eje puerta-puerta.
**Materiales** (`block(..., "mat")`): asphalt barrel_wood bricks_wall bulb canvas concrete_floor concrete_wall dirt gravel iron_green metal old_bricks_wall olive paint_red paving_floor planks plaster_wall river roof rust safety_yellow sandbag seat_fabric sign_board soot tiles_wall train_blue train_cream train_red window_glow wood.
**Decales** (`k.decal(nombre, tex, pos, tamaño, normal)`): blood_drag blood_footprints blood_handprint blood_pool blood_smear blood_splatter_a/b/c bullet_holes cracks damp_stain debris graffiti_* oil_stain wall_hole_a/b.
**Props existentes** (`k.prop(nombre, "Props", "<escena>", pos, rot=)`): army_tent army_truck barrier bench crate field_radio fire iron_column park_bench plant_pot sandbags seat_pair sodium_lamp station_sign tractor typewriter_desk vending_machine wall_clock wall_lantern window_arch wine_barrel…
Mira `tools/level_gen/*.py` (p. ej. `buin_*.py`, `derailed_train.py`) para ver cómo los usan; **copia patrones, no inventes funciones** que no estén en `roomkit.py`.

## P8 — Vida y detalle de La Maestranza (código + texto, ~8 tareas, trabajo LARGO) · rama `chatgpt/P8-detalle-maestranza`, PR aparte, un commit por tarea
Hoy las 7 salas son cajas casi vacías (una radio, tres camillas…). Hay que convertirlas en lugares que cuenten una historia. Haz **todas** las tareas; no pidas OK entre ellas, sí el verde del CI en cada una.
- **P8-a Biblia de arte** `docs/cap4_arte.md`: por sala (acceso, guardia, enfermería, taller, vestuario, cuarentena, puesto sanitario): propósito dramático, paleta (3 colores), luz (fuente, color, si parpadea),
  lista de objetos que **cuentan lo ocurrido** (evidencia: barricada, camilla volcada, huellas, tazas, mapa en la pared…), y **2 puntos de interés** (algo para examinar) por sala. Coherente con `docs/cap4_notas.md`, `docs/cap4_dialogos.md` y el GDD.
- **P8-b Piezas nuevas** `tools/level_gen/maestranza_props.py` (nuevo; añádelo a `regenerar_todo.sh`): genera escenas `levels/kit/props/*.tscn` armadas con bloques (mira `train_props.py`/`station_props.py` para el patrón):
  camilla con sábana (baja, ≤ 0.9 m), carrito médico, biombo/cortina de hospital, soporte de suero, estante metálico, archivador, mesa de taller con tornillo de banco, caja de herramientas, cinta de peligro, barricada de sacos y tablas, silla volcada, casillero abierto.
  Una función por pieza, tamaños reales, materiales de la lista, **sin colisión sólida** salvo la base.
- **P8-c Detalle salas 1–3** (`maestranza_acceso/guardia/enfermeria.py`): según tu biblioteca de arte, **≥ 12 elementos por sala** entre props, decales, rótulos y luces (`k.light(..., flicker=True)` en 1 por sala), más los 2 puntos de interés como `k.examine(...)` con texto nuevo (3 líneas, tono Isabella, sin nombres internos).
- **P8-d Detalle salas 4–7** (`taller/vestuario/pasillo_cuarentena/puesto_sanitario`): igual. En cuarentena: precinto, cinta, luz roja de emergencia; en el puesto sanitario: sensación de refugio (luz cálida, mantas, comida, radio).
- **P8-e Combate y recursos**: en `docs/cap4_balance.md` tabla por sala de enemigos (tipo, cantidad, vida) y munición/curas disponibles; ajusta `k.infected`/`k.pickup` para que un jugador cuidadoso llegue con ~5 balas de reserva y 1 cura, y uno descuidado sufra. Máx. **1 infectado pesado** en todo el capítulo y **2 rápidos**. Mira `data/` y `docs/GDD.md` para las vidas.
- **P8-f Texto y voz**: revisa pistas de Leo (3 niveles: pista, ayuda, solución concreta con la flecha amarilla) y notas; ninguna debe mencionar nombres de archivo ni términos de programación. Agrega **2 diálogos ambientales** cortos (radio/altavoz que se oye al entrar a guardia y cuarentena) con el patrón de `k.examine`/`room.intro` que ya exista.
- **P8-g Pruebas** (solo **agregar** a `tests/levels_test.gd`; recuerda que `var x := f()` que devuelve Variant **no compila**: tipa `var x: Tipo = f()`): cada sala de Maestranza tiene ≥ 12 hijos en `Props`/`Details`, ≥ 1 `LeoHint`, ≥ 2 `examine`, ningún sólido de > 1,3 m en la franja central, y un recorrido puerta→puerta posible (ya hay auditoría de spawns).
- **P8-h Diseño del jefe** `docs/cap4_jefe.md` (yo lo implemento): patio de maniobras de 26 × 16 m con grúa, vagón de la cuarentena y Skull (diseño original aprobado en el GDD). Fases, reglas de la arena (dónde está el cobertor, qué hace Leo), cámaras (descríbelas por zona), tabla de sonidos que haga falta, recompensa, cinemática final del capítulo y puente al capítulo 5. **Sin implementar.**
**Hecho cuando:** CI verde (sin `SCRIPT ERROR`), `docs/CHATGPT_LOG.md` con la entrega, PR fuera de borrador. Después de mi replanificación de cámaras y mi revisión con capturas, se fusiona.

## P7 (capítulo 5) — ya puedes empezar tras P8-c
P6 ya está fusionado, así que **P7 queda autorizado**. Sigue el texto de P7 más arriba en una rama y PR separados (`chatgpt/P7-capitulo-5`), con el protocolo nuevo (solo `.py`, regeneración automática, reglas de cámara de arriba).
**Agrega a P7:** (a) `ui/chapter_end/chapter_end.gd`: el final del capítulo 4 («CONTINUAR» en el puesto sanitario) debe llevar a `santiago_via_norte`; (b) todas las salas con **detalle desde el inicio** (≥ 12 elementos, 2 puntos de interés, usando las piezas de P8-b). Orden: P8-a, P8-b, P8-c → empiezas P7 en paralelo (otro PR) → terminas P8.

---

## P9 — Cooperativo por Wi‑Fi: base de red, menú de prueba y textos de Ignacia (código + texto, ~6 tareas, trabajo LARGO) · rama `chatgpt/P9-cooperativo`, PR aparte, un commit por tarea
**Contexto (decisión de Chris, 2026-11-21):** el juego tendrá un modo **cooperativo de dos jugadores, cada uno en su teléfono por la misma Wi‑Fi**, misma APK. El anfitrión juega **Isabella** y el invitado **Ignacia** (jugadora 2, ya existe su modelo jugable). **Lee antes:** `docs/GUION.md` §10 (guion cooperativo aprobado), `docs/DISENO_IGNACIA.md`, `docs/ARCHITECTURE.md`, `systems/game_state.gd`, `systems/scene_loader.gd`, `actors/player/player.gd`.
Reglas de siempre: protocolo nuevo (CI + regeneración automática), GDScript tipado (**nada de `var x := f()` que devuelva Variant**), 4 espacios, comentarios breves en español, scripts < 300 líneas, textos sin nombres internos. **No toques** `levels/**` ni generadores de salas. Nada de cruces como símbolo médico.
- **P9-a Diseño de red** `docs/COOP_DISENO.md`: anfitrión **autoritativo** (infectados, daño, puertas, banderas, guardado); invitado envía entrada/posición. Tabla de **qué se sincroniza** (posición/animación de los dos personajes a ~15 Hz con interpolación, disparos y daño, infectados, objetos recogidos, puertas, cinemáticas, diálogos, inventario compartido), **mensajes** (nombre, campos, fiable/no fiable), **transición de sala** (los dos siempre en la misma sala), desconexión/reconexión, y una **lista de los singletons y scripts de un solo jugador** que habrá que adaptar (`GameState`, `SceneLoader`, `Player`, `Infected`, `Leo`…) con el cambio mínimo en cada uno y un **orden de implementación en hitos** (cada hito jugable y con prueba). Sé concreto: archivos y funciones reales; marca como «hipótesis» lo que no hayas verificado.
- **P9-b Capa de red** `systems/net/` (archivos nuevos, sin tocar el juego): `net_session.gd` (anfitrión/invitado con `ENetMultiplayerPeer`, puerto 7777, señales `peer_joined`, `peer_left`, `connection_failed`), `lan_discovery.gd` (anfitrión que **anuncia por UDP broadcast** su partida y el invitado que **lista las partidas de su Wi‑Fi**; si no hay broadcast, entrada manual de IP) y `net_messages.gd` (codificación/decodificación de mensajes **puros**, testeables). Que compile bajo Godot 4.7 y que no rompa ninguna prueba existente.
- **P9-c Menú «Cooperativo (prueba)»** `ui/coop/coop_menu.tscn` + `coop_menu.gd`: «CREAR PARTIDA» (muestra «Esperando a Ignacia… tu IP: x.x.x.x»), «UNIRSE» (lista de partidas encontradas + campo de IP), «VOLVER». Al conectar, una pantalla **«Prueba de conexión»**: nombres de los dos jugadores, **ping en ms** actualizado cada segundo (RPC ping/pong) y un **botón «ENVIAR SEÑAL»** que hace sonar un tono en el otro teléfono. Añade el botón **«COOPERATIVO (PRUEBA)»** al menú del título editando **`tools/level_gen/title.py`** (no el `.tscn`). Textos en español, botones grandes para teléfono horizontal.
- **P9-d Pruebas** (solo **agregar**, `tests/`): codificación/decodificación de mensajes, validación de IP/puerto, que el menú carga sin errores, y —si es viable en CI— un **bucle local** anfitrión+invitado en el mismo proceso (si no lo es, di por qué y prueba solo las partes puras). Cuida que el CI no se cuelgue (tiempos máximos).
- **P9-e Textos de Ignacia como datos** `data/coop/ignacia_lines.tres` + `systems/coop_lines.gd` (`class_name` solo si hace falta): pasa a datos **todas** las líneas de `docs/GUION.md` §10.3–§10.5 con su sala y su disparador, y una función `lines_for(room: String, event: String) -> PackedStringArray` que **devuelve vacío si la partida no es cooperativa** (bandera de `GameState`; agrégala con valor por defecto falso). **No conectes** estas líneas a las salas todavía. Pruebas: en un jugador nunca devuelve líneas; en cooperativo devuelve las del guion; ningún texto contiene nombres internos ni la palabra «Skull».
- **P9-f Documentación**: `docs/ROADMAP.md` (Hito 13 al día), `docs/GDD.md` (sección cooperativo) y la entrega en `docs/CHATGPT_LOG.md` (qué hiciste por tarea, archivos, pruebas, **qué debe probar Chris en dos teléfonos reales**).
**Hecho cuando:** CI verde sin `SCRIPT ERROR`, PR fuera de borrador y el log al día. **Claude** revisa, integra con el juego y hace la prueba con Chris en dos teléfonos. **Orden de trabajo sugerido para ChatGPT:** P9 completo → P8 → P7.

---

## ⚠️ P7 y P8 EN PAUSA (2026-11-23) — cambia el modelo de niveles
Chris probó la build-129: «demasiado lineal, puzzles muy básicos, llaves en el piso». Se rediseñan los niveles al estilo RE3 de PS1 (`docs/REDISENO_NIVELES.md`: zonas con bucles, mapas, puzzles variados, pistas a demanda). **No avances P7 ni P8** (si ya hay trabajo, déjalo en su rama sin fusionar: se reaprovecha como material). **P9 (cooperativo) sigue igual.** Lo nuevo es **P10**.

## P10 — Diseño de zonas de los 5 capítulos (SOLO TEXTO, trabajo LARGO, ~12 entregas) · rama `chatgpt/P10-zonas`, un PR, un commit por documento
**Lee primero:** `docs/REDISENO_NIVELES.md` (el modelo), `docs/GUION.md` (canon y línea de tiempo), `docs/GDD.md`, `docs/LECCIONES_SALAS.md`, `docs/cap4_notas.md`, `docs/cap4_dialogos.md`, `docs/CHATGPT_BRIEF.md`. **No escribas código ni toques `levels/**`**: entregas **documentos** que Claude implementa. Empuja cada documento apenas lo termines y **pasa al siguiente sin esperar el CI**.
**Qué debe contener CADA documento de zona** (`docs/zonas/capN_<nombre>.md`), con estos apartados numerados:
1. **Resumen de la zona** (3 líneas: dónde, cuándo, qué siente el jugador, objetivo de salida).
2. **Grafo de salas**: tabla con `id` (snake_case, nombres nuevos y los actuales cuando se reaprovechen), nombre visible, **tamaño en metros (6–10 de lado; algunas L/U/curvas, con la forma descrita)**, función, enemigos. Más un **mapa ASCII** de la zona. **8–12 salas.** Cada sala con **≥ 2 puertas** salvo un máximo de 2 rincones sin salida.
3. **Conexiones**: tabla `puerta_id`, de→a, estado inicial (abierta / cerrada con X / **solo se abre desde un lado** / oculta), qué la abre. Marca los **bucles** (≥ 2 caminos hacia cada objetivo) y **≥ 2 atajos** que se abren desde el otro lado.
4. **Objetos y llaves**: tabla de cada objeto clave: dónde está (**nunca a la vista y tirado: dentro de un contenedor, en un infectado, tras un puzzle, tras un cuadro…**), cómo se obtiene, para qué sirve, **qué puerta/puzzle desbloquea**. Comprobación obligatoria: **ninguna cadena imposible** (todo objeto es alcanzable antes de necesitarlo) y **el orden de resolución tiene al menos 2 caminos válidos**.
5. **Puzzles** (**mínimo 6 por zona, de ≥ 4 tipos distintos** del catálogo de `REDISENO_NIVELES.md` §4, más los que inventes): para cada uno: nombre, tipo, sala, **pasos**, **≥ 2 pistas con su ubicación exacta** (nota, objeto, entorno), **solución exacta**, recompensa, qué pasa si se falla, y su **variante cooperativa** con Ignacia (solo si aplica).
6. **Pistas de Leo por puzzle** en 3 niveles: **N1** hacia dónde mira/maúlla (sin palabras), **N2** una frase vaga (≤ 12 palabras), **N3** solución explícita (solo «AYUDA»). Sin nombres internos.
7. **Mapa de la zona** (objeto): dónde se encuentra, si es completo o en dos mitades, y **qué salas revela**.
8. **Enemigos y recursos por sala**: tipo, cantidad, comportamiento (dormido, patrulla, se hace el muerto…), munición y curas. Límites del GDD (máx. 1 pesado por capítulo y 2 rápidos, salvo que lo justifiques). Meta: **un jugador cuidadoso termina con ~5 balas y 1 cura; uno descuidado sufre**.
9. **Notas y documentos nuevos** con el **texto exacto** (≤ 120 palabras cada una; coherentes con la línea de tiempo; algunas **sirven de pista de puzzle**). Respeta las reglas narrativas del GUION (sin origen de la infección, nadie dice «Skull», Rosa/Skull, gatos inmunes, vagón del Centro de Nos sellado en el cap. 4…).
10. **Cámaras y aspecto por sala**: 2–4 posiciones descritas (esquina, altura, qué se ve), paleta de 3 colores, fuente de luz (**máx. 4 luces**), 1 detalle memorable. Es para el render; piensa en cámaras **que no pierdan a Isabella** y en **esquinas y curvas** (RE3).
11. **Variante cooperativa** (solo si Ignacia cambia algo): líneas de `docs/GUION.md` §10 que se disparan aquí y puzzles de dos jugadores.
12. **Lista de comprobación final** (marcada ✔): grafo conexo; sin cadenas imposibles; ≥ 2 caminos; puzzles con pistas; todo objeto con dueño; textos sin nombres internos; **ninguna cruz roja/blanca como símbolo médico** (usa el rombo con pulso o diseño propio).
**Entregas, en este orden** (cada una un commit):
- **P10-a** `docs/zonas/README.md` + **catálogo de puzzles** `docs/zonas/catalogo_puzzles.md`: ≥ 30 puzzles de plantilla (tipo, ingredientes, variantes, dificultad) para reutilizar; y las **reglas de cerraduras/códigos** que necesita el motor (qué datos guarda cada puzzle: estado, código, objetos puestos).
- **P10-b ★ PRIORIDAD ★** `docs/zonas/cap1_estacion.md` — **capítulo 1 (estación de Paine)**: reaprovecha las salas actuales (andén norte, sala de espera, boletería, pasillo de servicio, bodega, andén sur) y **agrega 3–5 nuevas** (p. ej. oficina del jefe de estación con el mapa, baños, sala de fusibles/máquinas, cabina de señales, escalera al puente peatonal). **Incluye** la caja fuerte de la boletería con el código **0712** (reloj parado de la sala de espera a las 7:12 con el balazo), fusibles, y una llave oculta en un casillero. **Avísame en «Preguntas» apenas esté**: es el piloto y lo implemento de inmediato.
- **P10-c** `cap2_vias.md`, **P10-d** `cap3_buin.md`, **P10-e** `cap4_maestranza.md` (incluye el **jefe del patio de maniobras** que antes era P8-h: patio de 26 × 16 m con grúa, fases, reglas de la arena, sonidos), **P10-f** `cap5_centro_nos.md` (incluye la sala final de **Rosa convertida en Skull**, sin implementar) y **P10-g** `epilogo.md`.
- **P10-h** `docs/zonas/guia_de_jugada.md`: recorrido completo posible de todo el juego (orden de resolución, tiempo estimado por zona, dónde se guarda) y **tabla de munición/curas global**.
- **P10-i** `docs/zonas/notas_nuevas_indice.md`: índice de **todas** las notas nuevas (id, zona, sala, título, pista que da).
**Hecho cuando:** todos los documentos empujados con su lista de comprobación en ✔, el CI verde, el log al día y el PR fuera de borrador. Claude los revisa, implementa por zonas y pide correcciones en el PR. **Tu turno es corto: un documento por turno está bien; no esperes el CI.**

---

## P11 — Mochila, llaves, descartar, baúl y armas por el camino (código + datos, ~7 tareas) · rama `chatgpt/P11-mochila-armas`, PR aparte, un commit por tarea
**Pedido de Chris (2026-11-23):** con la mochila llena no puede recoger llaves; hay que poder **eliminar objetos**; las **llaves ya usadas** deben desaparecer; y las **armas deben estar repartidas por el camino**, no regaladas al empezar (el alcance no importa).
**Análisis previo (de Claude, verificado en el código):** `systems/inventory.gd` tiene 16 casillas (`SIZE`) y cada ítem distinto ocupa una; la partida nueva (`GameState.STARTING_LOADOUT`, `systems/game_state.gd`) ya llena 12 casillas (7 armas + 5 municiones); `levels/kit/interact/pickup.gd` solo dice «No me cabe nada más en la mochila»; `ui/inventory/inventory_menu.gd` solo tiene USAR y EXAMINAR. **Lee esos 4 archivos antes de empezar.** Reglas: protocolo nuevo (empuja y sigue, CI cada 2 tareas), GDScript tipado (**`var x := f()` que devuelva Variant no compila**), nada de editar `.tscn` a mano (UI y salas salen de generadores `.py` en `tools/level_gen/`), partidas guardadas viejas deben seguir cargando, no usar cruces como símbolo médico.
- **P11-a Llaves aparte:** los ítems `ItemData.Kind.KEY` **no ocupan casillas**: `Inventory.key_items` (lista aparte, sin límite), API `add/has_id/take/count_of` que los enruta bien, `to_data/from_data` **compatibles con partidas viejas** (si un guardado trae llaves en casillas, se migran). Pestaña **«LLAVES»** en la mochila (edita `tools/level_gen/inventory.py`). Pruebas.
- **P11-b DESCARTAR:** botón en el detalle del ítem con **confirmación**; en apilables elegir cantidad (−1 / −10 / TODO); **no** se pueden descartar llaves ni la única arma equipada (primero desequipar); mensaje breve de Isabella. Pruebas de `Inventory.remove_at`.
- **P11-c Llaves que se gastan:** campo `ItemData.lock_ids: PackedStringArray` (ids de las cerraduras que abre; mira `lock_id` y `key` en `levels/kit/interact/door.gd` y los generadores: `engineer_key` abre más de una puerta). Cuando **todas** sus cerraduras están abiertas (`unlocked:<id>`), la llave se quita sola con el aviso «Ya no necesito esta llave.». Rellena `lock_ids` de `gate_key`, `engineer_key`, `shed_key`. Pruebas.
- **P11-d Baúl en salas seguras:** `levels/kit/interact/storage_chest.gd` (Interactable «BAÚL»), `Inventory` secundario de **24 casillas compartido por todos los baúles** (`GameState.chest`, se guarda y se carga), pantalla que reutiliza la cuadrícula de la mochila para **mover ítems** entre mochila y baúl, y `Kit.storage_chest(name, pos)` en `tools/level_gen/roomkit.py`. Colócalo en **las salas con máquina de escribir** (editando sus generadores). Pruebas.
- **P11-e Armas por el camino:** quita las **7 armas y 5 municiones** de `new_game()` (deja `give_pistol()` para pruebas y capturas; ajusta `tests/` y `tools/capture_*.gd`); la partida nueva empieza **sin arma** (ya está soportado: HUD oculta botones, mochila «Sin arma»). Reparte las armas con `k.pickup(...)` en los generadores **actuales** (luego la zona rediseñada las moverá): **Pistola** boletería (ya existe: quita el duplicado del inicio) · **Escopeta** coche/vagón del cap. 2 (interior del vagón o costado del convoy: arma de un carabinero) · **Rifle Mauser** viña o bodega agrícola (cap. 3, rifle de cacería) · **Fusil de asalto** control militar (cap. 3) · **Rifle francotirador** y **Lanzagranadas** en La Maestranza (guardia/taller) · **Bazooka**: déjala **sin colocar** hasta el cap. 5 y anótalo en el log. **Ninguna a la vista en el piso:** ponlas sobre un mueble, junto a un cadáver o dentro de un contenedor existente (usa el patrón de `k.pickup` con `sets_flag`). Munición: reparte según `docs/CHATGPT_ENCARGO_LARGO.md` (P8-e) y `docs/zonas/` cuando exista; meta: un jugador cuidadoso llega al final del cap. 1 con **~25 balas de 9 mm**. Sube `max_range` de **todas** las armas (`data/weapons/*.tres`) a **40**. Pruebas: nueva partida sin armas; cada arma es recogible una sola vez; `levels_test`/auditorías siguen verdes.
- **P11-f Mochila llena al recoger:** en `pickup.gd`, si no cabe, ofrecer **«¿QUÉ DEJO?»**: abre la mochila en modo «elegir ítem a descartar»; al descartar, el pickup se completa. Si es un ítem clave (llave) **nunca falla** (P11-a). Pruebas.
- **P11-g Documentación:** `docs/GDD.md` (Mecánicas: mochila, llaves, baúl, descartar, armas por el camino), `docs/ROADMAP.md`, y entrega en `docs/CHATGPT_LOG.md` (qué debe probar Chris en el teléfono: llenar la mochila, descartar, baúl, llave que desaparece, empezar sin armas).
**Hecho cuando:** CI verde sin `SCRIPT ERROR`, PR fuera de borrador, log al día.

## P12 — Motor de puzzles, mapa de zona y pistas a demanda (código + datos, ~6 tareas) · rama `chatgpt/P12-puzzles`, PR aparte · **empieza cuando P10-a (catálogo de puzzles) esté entregado**
**Contexto:** el rediseño de niveles (`docs/REDISENO_NIVELES.md`) necesita mecánicas que hoy no existen: solo hay llave→puerta. Lee `docs/zonas/catalogo_puzzles.md` (P10-a) para las reglas y datos de cada puzzle; **los textos y ubicaciones concretas los pone P10, no tú**. Mismas reglas de P11.
- **P12-a Estado de puzzles:** `data/puzzles/` (recurso `PuzzleData`: id, tipo, código/secuencia, objetos requeridos) y `systems/puzzle_state.gd`: guarda en `GameState.flags` (se guarda y carga) códigos resueltos, fusibles puestos, palancas, contenedores revisados. Pruebas de guardar/cargar.
- **P12-b Interactuables nuevos** (`levels/kit/interact/`): `code_lock.gd` (teclado de 3–6 dígitos en pantalla táctil, intentos fallidos con sonido y mensaje, abre una puerta/caja por bandera), `fuse_box.gd` (necesita N fusibles de la mochila), `lever.gd` y `lever_sequence.gd` (orden correcto), `container.gd` («REGISTRAR» casilleros y cajones: muestra qué hay, entrega ítems **una sola vez**), y `Door` con opción **«solo se abre desde un lado»** (`one_way`). Pruebas por cada uno.
- **P12-c Combinar objetos:** recetas `data/recipes/*.tres` (A + B → C), botón **«COMBINAR»** en el detalle del ítem, `Inventory.combine(a, b)`. Pruebas.
- **P12-d Generadores:** métodos en `tools/level_gen/roomkit.py`: `k.code_lock(...)`, `k.fuse_box(...)`, `k.lever(...)`, `k.lever_sequence(...)`, `k.container(...)`, `k.one_way_door(...)`, con ejemplo mínimo en una sala de prueba `levels/test/` **no incluida en el recorrido** y probada por `levels_test`.
- **P12-e Mapa de zona:** recurso `data/zones/<zona>.tres` (`ZoneMapData`: salas con id, nombre, posición en cuadrícula, conexiones, llave que pide cada puerta) y pestaña **«MAPA»** en la mochila (`tools/level_gen/inventory.py`): casillas conectadas con colores **sin visitar / visitada / con pendientes / puerta cerrada con icono de llave**. Se activa al tener el ítem `map_<zona>` (crea el ítem). Haz los mapas **de las 4 zonas actuales** derivándolos de las puertas de los generadores (`k.door(...)`) como base. Pruebas.
- **P12-f Pistas de Leo a demanda:** Leo (`actors/companion/leo.gd`, `k.leo_hint`) hoy da 3 frases por pista, la 3.ª explícita. Nuevo comportamiento: **N1** mira/maúlla hacia el lugar (sin texto), **N2** frase vaga si el jugador lleva ~40 s sin avanzar, **N3 (explícita) solo con el botón «AYUDA»** del HUD (edita el generador del HUD si existe; si no, pregunta en «Preguntas»). Sin flechas amarillas permanentes salvo en puertas de **salida de zona**. Pruebas.
**Hecho cuando:** CI verde, PR fuera de borrador, log con **qué debe probar Chris** (cada puzzle de la sala de prueba). Claude revisa lo visual y conecta los puzzles reales de P10.

## Orden de trabajo de ChatGPT (2026-11-23)
**P9-b…f** (cooperativo, en curso) → **P10-a y P10-b** (catálogo y capítulo 1) → **P11** (mochila y armas) → **P10-c…i** (resto de zonas) → **P12** (puzzles y mapa). Cada uno en su rama y PR; **empuja y sigue sin esperar el CI**; si algo te bloquea, escríbelo en «Preguntas» con el error exacto.

---

## P13 — Cooperativo, hito 2: dos avatares en una sala de prueba (código, ~6 tareas) · rama `chatgpt/P13-coop-avatares`, PR aparte
**Base ya fusionada (P9):** `systems/net/` (`NetSession`, `LanDiscovery`, `NetMessages`), `ui/coop/coop_menu.*`, `systems/coop_lines.gd`, `docs/COOP_DISENO.md` (hito 2 del §8). **Objetivo:** que dos teléfonos conectados por el menú «COOPERATIVO (PRUEBA)» **entren a una sala segura de prueba y se vean moverse**: el anfitrión controla a **Isabella** y el invitado a **Ignacia** (`GameSettings.get_character()` ya cambia el modelo; ver `actors/player/player.gd`, `_enter_tree`). **Sin enemigos, sin disparos, sin puertas:** solo movimiento, animación y ping. Reglas de siempre (empuja y sigue sin esperar el CI; GDScript tipado, sin `var x := f()` que devuelva Variant; nada de editar `.tscn` a mano: las salas salen de generadores `.py`).
- **P13-a Sala de prueba** `tools/level_gen/coop_room.py` → `levels/test/coop_room.tscn` (agrégala a `regenerar_todo.sh`): sala segura de **10 × 8 m** con `roomkit.Kit` (piso, 4 muros con una puerta falsa, 3 muebles bajos, 2 spawns `host` e `guest`, cámaras provisionales; **sin enemigos**). Debe pasar `levels_test` (si la carpeta `levels/test/` no entra en los recorridos del test, agrégala a `tools/audit_*.gd` y a `tests/levels_test.gd` solo para auditoría). Usa las reglas de cámara de P8 (muebles < 1,3 m).
- **P13-b Avatar remoto:** `actors/player/remote_player.gd` (+ escena generada si hace falta): un `Node3D` con el modelo del otro jugador (Isabella o Ignacia según rol, mismos `cony_animations`), que **interpola** entre los dos últimos snapshots recibidos y reproduce la animación indicada (`Idle`/`Walk`/`Jog`). Sin física ni colisión.
- **P13-c Mensajes y replicación:** en `systems/net/net_messages.gd` agrega `state` (posición x/y/z, yaw, animación, velocidad de animación, `sequence`) **no fiable y ordenado a ~15 Hz** y `start_coop` (sala, roles). `systems/net/coop_sync.gd`: cada teléfono envía el estado de **su** jugador local y aplica el del remoto; descarta paquetes viejos (`sequence`) y valida rangos. Pruebas de codec y de «descarta viejos».
- **P13-d Flujo del menú:** cuando el anfitrión y el invitado están conectados, el **anfitrión** toca «EMPEZAR» y **ambos** cargan `coop_room` (`SceneLoader`), uno como Isabella y otro como Ignacia, **sin tocar la partida guardada** (no escribas guardados en modo prueba). Mensajes en español en el menú («Esperando a Ignacia…», «Conectado: Ignacia», «Se desconectó el otro jugador» → vuelve al título).
- **P13-e Pruebas:** en `tests/systems_test.gd` (solo **agregar**): interpolación del avatar remoto con snapshots simulados, descarte de paquetes viejos, que el menú arma `start_coop` correcto, y que la sala carga con los dos spawns. Si un bucle local ENet en el mismo proceso es viable en el CI, úsalo; si no, di por qué.
- **P13-f Documentación:** `docs/ROADMAP.md` (Hito 13), `docs/COOP_DISENO.md` (estado del hito 2, **hipótesis que se verificaron o no**) y el registro con **qué debe probar Chris en dos teléfonos reales** (paso a paso: crear, unirse, empezar, caminar, desconectar).
**Hecho cuando:** CI verde sin `SCRIPT ERROR`, PR fuera de borrador. **Claude** revisa, ajusta cámaras y hace la prueba con Chris en dos teléfonos.

## Orden de trabajo de ChatGPT (2026-11-24)
**P12** (puzzles, mapa, pistas a demanda: **empieza ya**) → **P13** (cooperativo, dos avatares) → **P10-c…i** (resto de zonas). Un PR por paquete. **Empuja y sigue sin esperar el CI**; si algo te bloquea, escríbelo en «Preguntas» con el error exacto.

---

## P14 — Infectados: oído, grupos y comportamiento (código + datos, ~5 tareas) · rama `chatgpt/P14-infectados-ia`, PR aparte
**Pedido de Chris (2026-11-24):** los infectados deben **oír los disparos y acudir**, y **venir en grupo**. **Claude hace la parte visual** (sangre, heridas, desmembramiento, variedad, reacciones al disparo) en `actors/enemies/infected_gore.gd` y deja **3 llamadas marcadas `# GORE`** en `actors/enemies/infected.gd` (`_ready`, `take_hit`, `_die`): **no las borres ni las muevas**. También hay un componente de lanzamiento de objetos (`infected_thrower.gd`, estado `THROW` al final del enum, `_thrower` en `infected.gd`): conserva esas líneas y no cambies el orden del enum (añade `ALERT` **al final**). Tú tocas la **IA** (estados, ruido, grupos). Lee `actors/enemies/infected.gd` (estados `IDLE, FEEDING, LYING, RISING, CHASE, ATTACK, STAGGER, DEAD`), `data/enemies/enemy_data.gd`, `actors/player/player_combat.gd` y `data/weapons/weapon_data.gd`. Reglas de siempre (empuja y sigue sin esperar el CI; GDScript tipado; sin `var x := f()` que devuelva Variant).
- **P14-a Ruido:** `systems/noise.gd` (clase con funciones estáticas, sin autoload): `Noise.make(tree: SceneTree, position: Vector3, radius: float)` llama al grupo `enemies` (`hear(position, radius)`). Campo nuevo `WeaponData.noise_radius` (pistola 14, Mauser 16, escopeta 22, fusil 20, francotirador 24, lanzagranadas/bazuca 30; ajusta los `.tres`). `player_combat.gd` emite ruido al disparar y en explosiones; pasos al trotar **radio 4** (caminar 0); abrir puertas **6**; recoger ítems **2**.
- **P14-b Estado ALERT:** nuevo estado en `infected.gd`: `hear(position, radius)` pone en ALERT a los infectados `IDLE`, `FEEDING` y `LYING` dentro del radio (distancia en el plano, con la **atenuación** `radius * data.hearing_scale`); caminan hasta el punto del ruido (a su `walk_speed`, mirando hacia allá), esperan 2–4 s buscando y si ven a Isabella pasan a `CHASE`; si no, vuelven a su estado. Los `LYING` se levantan (`RISING`) y acuden. Campo `EnemyData.hearing_scale` (1.0 por defecto; pesado 0.7, soldado 1.2, rápido 1.0).
- **P14-c Grupos:** cuando un infectado entra a `CHASE` por **ver** a Isabella, **alerta** a los infectados vivos dentro de `EnemyData.group_alert_radius` (7 m por defecto; el soldado 10) con un retraso aleatorio de 0,2–1,5 s cada uno, y esos entran a `CHASE`. **Tope de agresores:** como máximo **3** infectados en `ATTACK`/a menos de 1,6 m a la vez; los demás **esperan a 2,2–3 m rodeando** (desplazamiento lateral suave) hasta que quede un hueco. Sin teletransportes ni atravesar paredes (usa la misma lógica de movimiento).
- **P14-d Pruebas** (solo **agregar** a `tests/systems_test.gd`): un ruido despierta a los dormidos dentro del radio y **no** a los de fuera; `LYING` se levanta; la alerta en grupo se propaga con retraso; el tope de 3 agresores se respeta (instancia 6 infectados alrededor de Isabella); los infectados ya muertos (`dead:` flags) siguen sin reaccionar; nada de `SCRIPT ERROR`. Verifica que `levels_test`/auditorías siguen verdes.
- **P14-e Documentación y balance:** tabla en `docs/GDD.md` (Enemigos) con el radio de ruido de cada arma y qué implica (disparar a lo loco atrae a todos). Ajusta sin romper el balance de `docs/zonas/` (si un capítulo tiene demasiados infectados juntos, dilo en «Preguntas»). Entrega en `docs/CHATGPT_LOG.md` con **qué debe probar Chris** (disparar y mirar cómo acuden, sorprender a uno, pelear con un grupo).
**Hecho cuando:** CI verde sin `SCRIPT ERROR`, PR fuera de borrador.

## Orden de trabajo de ChatGPT (2026-11-24, actualizado)
**P12** (puzzles, mapa, pistas) → **P14** (IA de infectados: **antes que P13**, Chris lo pidió) → **P13** (cooperativo) → resto de **P10**.

---

# PRIORIDAD ABSOLUTA (2026-11-26): rehacer los niveles para terminar el juego

**Pedido de Chris:** «necesito terminar el juego». Los problemas que **sigue habiendo** en el juego que él prueba: **demasiado lineal** (ir siempre hacia adelante, llaves a la vista en el piso, puzzles básicos), **salas aburridas** (cajas grandes y vacías) y **dura poco**. La solución ya está diseñada (`docs/REDISENO_NIVELES.md`, `docs/zonas/`): **zonas de 8–12 salas pequeñas con bucles, atajos, mapa, puzzles variados y llaves escondidas**. Los motores ya existen (P12 está **fusionado en `main`**: códigos, fusibles, palancas, REGISTRAR, puertas de un solo lado, combinar objetos, mapa de zona, pistas de Leo a demanda). **Ahora toca construir las salas.**

**Reglas del flujo (leer antes de empezar):**
1. **Parte siempre de `main` actualizado** (`git fetch`; rama nueva desde `origin/main`). P12 y P10-a/b ya están en `main`; **no vuelvas a tocar P12** salvo para corregir un fallo que bloquee tu trabajo (dilo en el registro).
2. **Un commit por sala o por puzzle y empuja cada vez** (`git push`). No esperes al CI para seguir con la tarea siguiente. Si el CI pide aprobación o se cancela, **sigue**: Claude corre las pruebas completas en su entorno y corrige.
3. **GDScript tipado:** nada de `var x := f()` si `f` devuelve Variant (p. ej. métodos de un `Node3D` genérico): escribe `var x: String = f()`. Es el error que más rompe el juego.
4. Las salas **solo** se crean/editan en `tools/level_gen/*.py` con `roomkit.Kit`; **no edites `.tscn` a mano**: se regeneran (`./tools/level_gen/regenerar_todo.sh`; agrega cada generador nuevo a ese script). Mira `tools/level_gen/buin_checkpoint.py` y `docs/LECCIONES_SALAS.md` como modelo.
5. **No inventes cámaras definitivas**: deja 2–3 `k.camera(...)` provisorias **dentro** de la sala (la cámara no puede ver el vacío exterior: `levels_test` lo exige). Claude planifica cámaras y renderiza los fondos.
6. Salas de **6–10 m**, con forma **en L o en U** (muros interiores, recodos, mostradores) y **mucho más detalle** que hoy: mobiliario, desorden, cartelería, props de `tools/level_gen/props*.py` y `buin_props.py`. **Ninguna llave ni objeto clave a la vista en el piso.**
7. Cada sala nueva: ≥ 2 puertas (salvo rincones), `leo_hint` N1/N2/N3, `ambience`, `Room.id` estable, y entra en `ZoneMapData` (mapa de zona de P12-e) y en `levels_test`.
8. Cierra cada paquete con una entrada en `docs/CHATGPT_LOG.md` («qué debe probar Chris»: recorrer **dos rutas** distintas, abrir un atajo, resolver cada puzzle).

## P15 — Capítulo 1 rediseñado: Estación de Paine (piloto, ~8 tareas) · rama `chatgpt/P15-cap1`, PR aparte
**Fuente de verdad:** `docs/zonas/cap1_estacion.md` (diseño P10-b: 10 salas, 2 bucles, 2 atajos, 6+ puzzles, llaves, textos de notas). **Impleméntalo tal cual**; si algo es imposible o ambiguo, anótalo en «Preguntas» del registro y elige la opción más simple.
- **P15-a Cuatro salas nuevas:** `oficina_jefe` (D), `banos` (E), `sala_maquinas` (I), `cabina_senales` (J): un generador cada una (`tools/level_gen/<id>.py`), formas L/U, spawns, puertas del grafo, props, `leo_hint`, ambiente. Registra la escena en `SceneLoader`/`Room` como las demás.
- **P15-b Seis salas existentes reformadas:** `platform` (andén norte), `waiting_room`, `ticket_office`, `service_corridor`, `storeroom`, `south_platform`: darles forma en L/U y más objetos, **conectarlas según el grafo** (puertas nuevas: `door_anden_pasillo`, `door_espera_banos`, `door_banos_pasillo`, etc.), **quitar toda llave del piso** y reubicarla según la tabla «Objetos y llaves». Conserva IDs de escena y de puertas que el guardado ya usa (no rompas partidas) y los textos del guion.
- **P15-c Puzzles del capítulo** (usa el motor de P12, un commit por puzzle): caja fuerte de la boletería con **código 0712** (hora del reloj detenido, dos pistas), **dos fusibles** (baños y oficina) → tablero de `sala_maquinas` que habilita la compuerta eléctrica y la puerta `door_cabina_sur`, **palancas** de la cabina en el orden del diagrama de la oficina, **casillero 04** del pasillo con la `gate_key` (REGISTRAR tras la pista «04»), `office_key` en el abrigo de la oficina, pestillo del pasillo→bodega (barra caída), **dos puertas de un solo lado** (atajos).
- **P15-d Objetos, mapa y pistas:** ítem `map_station` colocado en la `oficina_jefe` (dentro de un archivador, no en el piso); notas nuevas con los textos exactos del diseño; pistas de Leo N1/N2/N3 por sala (sin flechas amarillas permanentes dentro de la zona; solo en la puerta de salida de zona).
- **P15-e Pruebas** (solo **agregar**; no borres pruebas existentes): `tests/levels_test.gd` carga las 10 salas, spawns cubiertos por cámara, puertas con destino válido y mapa de zona coherente; una **prueba de alcanzabilidad** que recorre el grafo por **dos rutas distintas** hasta `anden_sur` y demuestra que **cada llave se obtiene antes de la puerta que la exige** (sin cadenas imposibles); guardado/carga de puzzles resueltos; `puzzle_lab` sigue verde.
- **P15-f Equilibrio de recursos:** munición y curaciones repartidas en contenedores (sin duplicar el total actual del capítulo por más de +30 %), enemigos según el diseño (2 infectados comunes al volver con la pistola, 1 dormido, 1 fingiendo, Don Héctor).
- **P15-g Duración objetivo:** estima en el registro el tiempo de juego del capítulo con y sin ayuda (meta: **25–35 min** la primera vez, vs. ~8 min hoy) y qué hace que no se pueda terminar «corriendo hacia adelante».
- **P15-h Documentación:** `docs/ROADMAP.md`, `docs/GDD.md` (capítulo 1 nuevo: grafo, puertas, puzzles), y el registro con **qué debe probar Chris** (ruta A: andén→pasillo→bodega→andén sur; ruta B: espera→boletería→oficina→máquinas; abrir un atajo; la caja fuerte; los fusibles).
**Hecho cuando:** CI verde sin `SCRIPT ERROR` (o, si el CI no corre por aprobación pendiente, lo dices y Claude valida en su entorno), PR fuera de borrador.

## P16 — Capítulo 2 «Las vías»: diseño + implementación (~7 tareas) · rama `chatgpt/P16-cap2`
Es **P10-c** (diseño) **y** su implementación, en este orden: **(a)** `docs/zonas/cap2_vias.md` con el contrato de `docs/zonas/README.md` (8–12 salas, 2 bucles, 2 atajos, ≥ 6 puzzles de 4 tipos, pistas, mapa) respetando `docs/GUION.md` y las salas ya existentes (`track_north`, `derailed_train`, `wagon_interior`, `convoy_side`, `underpass`, `switch_house`); **(b)** generadores de las salas nuevas y reforma de las existentes **como en P15-a/b**; **(c)** puzzles; **(d)** objetos/mapa `map_tracks`/pistas; **(e)** pruebas de alcanzabilidad; **(f)** duración y balance; **(g)** documentación. Conserva el **final del capítulo** y la linterna/apagón, y la escena de Skull (`creature_door`).

## P17 — Capítulo 3 «Buin»: diseño + implementación (~7 tareas) · rama `chatgpt/P17-cap3`
Igual que P16 con **P10-d**: `docs/zonas/cap3_buin.md` y las siete salas actuales (`bridge`, `checkpoint`, `field`, `station`, `warehouse`, `vineyard`, `shed`) más nuevas. Conserva el **rescate de Kiara y Nala** (`rescue_scene.gd`) y la radio de Rosa.

## P18 — Capítulo 4 «La Maestranza»: diseño + implementación (~7 tareas) · rama `chatgpt/P18-cap4`
**P10-e** + implementación sobre `docs/cap4_*.md` y las salas `maestranza_*` ya hechas (acceso, guardia, enfermería, taller, vestuario, pasillo de cuarentena, puesto sanitario): más salas, bucles, puzzles, **patio de maniobras** (jefe, **sin mostrar su cuerpo completo antes del combate**) y encuentro con Paz. El vagón del Centro de Nos sigue sellado.

## P19 — Capítulo 5 «Centro de Nos» y epílogo: diseño + implementación (~8 tareas) · rama `chatgpt/P19-cap5`
**P10-f/g**: `docs/zonas/cap5_centro_nos.md` y `epilogo.md`, y luego **todas las salas nuevas** (acceso, recepción, archivo, enfermería, pasillo de transferencia, preaislamiento, sala de aislamiento del jefe final) con puzzles y la escena final del amanecer («Para Leo»). No hay nada implementado de este capítulo: es el más grande.

## P20 — Cierre de P10 (documentos) · rama `chatgpt/P20-guia`
**P10-h/i:** `docs/zonas/guia_de_jugada.md` (recorrido completo, guardados, economía global, **duración total objetivo ≥ 2,5–3 h**) y `docs/zonas/notas_nuevas_indice.md`. Se hace **al final** o en paralelo si no hay otra tarea.

## Orden de trabajo de ChatGPT (2026-11-26, vigente)
**P15** (capítulo 1: **empieza ya**) → **P16** → **P17** → **P18** → **P19** → **P14** (IA de infectados; antes tenía prioridad, ahora va después de los niveles porque Chris necesita **terminar el juego**) → **P13** (cooperativo) → **P20**. Un PR por paquete. **Empuja cada commit y sigue sin esperar el CI**; si algo te bloquea, escríbelo en «Preguntas» con el error exacto.
