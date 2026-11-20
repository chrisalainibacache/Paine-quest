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
