# P16 — Capítulo 2 «Las vías» (diseño P10-c)
Fecha: 2026-11-26
Estado: **DISEÑO PARA REVISIÓN; no implementación**
Fuente narrativa: `docs/GUION.md` §2 y §5; `docs/GDD.md` «Capítulo 2 — Las vías»; estructura: `docs/GUION_FINAL.md` §2.
Respeta el aviso de lote 1 de P15: no tocar P15; trabajar en `chatgpt/P16-cap2`. Este documento se crea primero; los generadores y escenas se implementan después, siempre desde scripts.


## REVISIÓN DE CLAUDE (2026-11-26) — CAMBIOS OBLIGATORIOS ANTES DE IMPLEMENTAR
Veredicto: **aprobado con 7 correcciones.** La estructura (hub con tres alas, bucles, atajos, retroceso, verticalidad, tablas) está bien y respeta el canon (Skull, linterna, casa de cambios, final). Aplica esto **en este mismo documento** (commit «docs(P16): aplica revisión de Claude») y recién después implementa:

1. **El sello A no tiene sentido narrativo.** «Liberar el freno de emergencia» de una locomotora **volcada y descarrilada** no cambia nada (GUION §5: el tren está volcado, hay fuego al fondo). **Reemplázalo por «cortar el combustible y apagar el incendio de la locomotora»** (válvulas en secuencia **2 → 3 → 1** en la cabina; el fuego es el resplandor rojo de `track_north`, que ya es canon). El sello se llama `tracks:fire_out`; al activarse, el humo de `convoy_side` se despeja y se abre el cruce. Actualiza IDs, textos («Placa de servicio: CORTE DE COMBUSTIBLE: 2 · 3 · 1», parte de Jorge sobre el incendio tras el choque), pistas y la salida de `switch_house` (`tracks:fire_out`, `tracks:power_restored`, `tracks:line_aligned`).
2. **Los tres sellos NO están en tres alas distintas** (el diseño lo afirma, pero B y C caen los dos en el ala del drenaje y el ala B del convoy/carga no da ninguno). **Reasigna:** **A = ala Locomotora/Coche** (`tracks:fire_out`, cabina); **B = ala Convoy/Carga** (`tracks:power_restored`: instalar el fusible de `vagon_carga` en el tablero de la carga, que da luz al drenaje); **C = ala Túnel/Drenaje** (`tracks:line_aligned`: el `signal_pin` del gabinete + las palancas de la casa de cambios). El cuarto de drenaje **consume** la energía de B (la bomba), no la genera.
3. **Incoherencia interna sobre quién da el sello C** (§5 dice que lo da `signal_pin` en el drenaje; §6 dice que lo da la alineación de palancas en `switch_house`). **Decisión:** `signal_pin` es **un componente**; el sello C se activa **en `switch_house`** al alinear las palancas con él instalado. Corrige ambas secciones y la tabla de no linealidad.
4. **El mapa llega demasiado tarde:** `map_tracks` está en `switch_house`, que es **la última sala**. Un mapa se encuentra **al principio**. **Muévelo a `derailed_train` (el hub)**, dentro de un casillero del coche de pasajeros accesible desde el patio (REGISTRAR), no en el piso. Actualiza §5, §8 y la tabla.
5. **`vagon_carga` mide 6,2 m de alto con entrepiso: un vagón de carga real mide ~3 m por dentro.** Conviértelo en **`galpon_carga`** (bodega ferroviaria junto a la vía, 18 × 6 m, techo 6,2 m, entrepiso a 2,7 m). Lo mismo en `cabina_locomotora` (altura 5,8 m): una cabina real es baja; hazla la **sala de máquinas/inspección de la locomotora** (techo 3,4 m, entrepiso de pasarela a 2,1 m). Actualiza nombres e IDs (`galpon_carga`, `sala_locomotora`) antes de crear generadores.
6. **El estándar de cámaras cambió:** el mínimo es **≥ 2** (no 4) y las **cámaras las planifica Claude**; no las inventes. Quita «≥4 cámaras» de §4 y de la tabla.
7. **Garantía de «no linealidad real»:** cada sello debe poder **empezarse sin haber hecho ninguno de los otros** (en este diseño el sello B exige el cable del A y `engineer_key` exige el código del coche). Para que A, B y C sean de verdad independientes, **haz que cada ala contenga todo lo que necesita su sello** (los componentes que cruzan alas —cable, fusible— pasan a ser **opcionales/atajos**, no requisitos). Documenta en la tabla de alcanzabilidad **dos órdenes distintos** (A→B→C y C→B→A) y asegúrate de que la prueba los recorre.

**Qué se conserva tal cual:** grafo de 10 salas (con los renombres), bucles, atajos, retroceso premiado, tamaños y verticalidad (con las alturas corregidas), textos de documentos (ajustando el 6:46 y la placa), pistas de Leo (ajustando las de la cabina y la carga), variante cooperativa, cinemática de Skull intacta.


## IMPLEMENTACIÓN DE CLAUDE (2026-11-27) — qué quedó hecho (reemplaza al diseño donde difieran)
ChatGPT no entregó la implementación (se quedó sin subir nada), así que **Claude implementó el capítulo 2** con las correcciones de la revisión:
- **Salas nuevas (4):** `sala_locomotora` (9×7, techo 3,4 m, pasarela de inspección a 2,1 m con escalera), `galpon_carga` (18×6, techo 6,2 m, entrepiso a 2,7 m), `pasarela_convoy` (20×4, pasarela elevada a 2,6 m), `cuarto_drenaje` (8×6). Las 6 salas existentes **no cambiaron de geometría** (siguen con sus fondos prerenderizados); solo se les añadieron **interactuables** (puertas, contenedores, palancas).
- **Tres sellos, uno por ala (independientes):** **A** `unlocked:tracks_fire_out` (válvulas 2→3→1 en la locomotora; **corta el combustible y apaga el incendio**); **B** `unlocked:tracks_power` (fusible 10 A de la estiba alta del galpón → tablero de carga); **C** `unlocked:tracks_line` + `unlocked:tracks_pin` (clavija de señales del gabinete del drenaje, que se abre con su propia bomba/compuerta, y palancas desvío→freno→norte de la casa de cambios). La salida de `switch_house` exige los **cuatro** flags.
- **Mapa** `map_tracks` en el equipaje del patio (`derailed_train`, REGISTRAR), al principio. **Llave del maquinista** en un estuche con código 0648 (planilla + reloj roto) en `wagon_interior`; ya **no es necesaria** (el drenaje da otro camino al paso bajo nivel).
- **Atajos de un solo lado:** pasarela → patio (`tracks_shortcut_walkway`) y drenaje → paso bajo nivel (`tracks_shortcut_drain`). Mapa de zona `data/zones/tracks.tres` con **10 salas**. Prueba `tests/chapter2_test.gd` (alcanzabilidad sin objetos previos, sellos en su ala, salida en dos órdenes distintos).
- **Pendiente:** textos de documentos extra (manifiesto, placas como documentos), cámaras definitivas con fondos prerenderizados de las 4 salas nuevas, balance de munición, prueba en el teléfono.

## 1. Resumen de la zona

Isabella y Leo salen del andén sur de Paine pasada la medianoche. La vía se divide en el cambio de vía: la principal continúa al norte hacia el túnel en llamas; el ramal termina en el tope doblado donde quedó el tren D-16008, descarrilado y destrozado. El túnel oeste por el que llegaron queda abierto pero oscuro y bloqueado para el retorno; la salida jugable es la puerta de servicio de la trinchera.

El capítulo no termina en el tren. El jugador rodea los restos a pie, atraviesa el convoy, recupera acceso al paso bajo nivel en apagón y llega a la casa de cambios. Allí guarda y decide seguir por la vía hacia el norte al amanecer, rumbo a Buin.

**Objetivo principal:** restaurar tres condiciones ferroviarias independientes y abrir la salida de la casa de cambios:
- liberar el freno de emergencia del convoy;
- restaurar la alimentación del sistema de drenaje/servicio;
- alinear el cambio de vía para dejar libre el recorrido norte.

**Hub no lineal:** el patio del descarrilamiento (`derailed_train`). Desde ahí se accede a tres alas y se vuelve varias veces. No se exige completar las alas en orden.

**Conservar sin cambios narrativos:** cinemática existente de Skull en `track_north` (una sola vez por partida, ya integrada); apagón y uso de linterna en `underpass`; la casa de cambios como sala segura y final de capítulo; la nota del maquinista y el final hacia el norte. No se explica el origen de la infección. Los personajes no pronuncian el nombre interno Skull.

## 2. Grafo y mapa ASCII

10 salas: las 6 existentes y 4 nuevas.

- Existentes: `track_north`, `derailed_train`, `wagon_interior`, `convoy_side`, `underpass`, `switch_house`.
- Nuevas: `cabina_locomotora`, `vagon_carga`, `pasarela_convoy`, `cuarto_drenaje`.

```text
                       [A: CABINA LOCOMOTORA]
                       (freno / sello A)
                              |
[track_north] ---> [HUB: DERAILED_TRAIN] ---- [WAGON_INTERIOR]
   entrada              |       \                 |
                        |        \                |
                        |         [CONVOY_SIDE] ---+
                        |            |  \
                        |            |   [VAGON_CARGA]
                        |            |       |
                        |            |   [PASARELA_CONVOY] --- vuelta al HUB
                        |            |       |
                        |            |   [CUARTO_DRENAJE] (entrada alta)
                        |            |       |
                        |        [UNDERPASS] --+
                        |            |        |
                        +------------+   [SWITCH_HOUSE]
                                           salida capítulo
```

Conexiones concretas y puertas:
1. `track_north ↔ derailed_train`: puerta de servicio existente; `track_north` es entrada y no se vuelve a la estación.
2. `derailed_train ↔ cabina_locomotora`: puerta de acceso al lateral de la locomotora.
3. `cabina_locomotora ↔ wagon_interior`: paso estrecho por el fuelle/puerta de conexión.
4. `derailed_train ↔ wagon_interior`: conservar el acceso existente por el estribo.
5. `wagon_interior ↔ convoy_side`: conservar el cruce por el coche.
6. `derailed_train ↔ convoy_side`: conservar el acceso lateral existente; funciona como tercer brazo del hub.
7. `convoy_side ↔ vagon_carga`: acceso a la carga por una puerta lateral.
8. `vagon_carga ↔ pasarela_convoy`: subir a la plataforma superior del vagón.
9. `pasarela_convoy ↔ derailed_train`: retorno elevado al hub; balcón con vista al descarrilamiento.
10. `pasarela_convoy ↔ cuarto_drenaje`: acceso superior de mantenimiento.
11. `convoy_side ↔ underpass`: conservar `underpass_gate`; inicialmente se abre con `engineer_key` o desde el lado interior por el atajo.
12. `underpass ↔ cuarto_drenaje`: puerta de mantenimiento, abre desde el lado del drenaje.
13. `cuarto_drenaje ↔ switch_house`: conexión de servicio.
14. `switch_house`: conservar la salida de capítulo hacia la vía norte; el final requiere los tres flags de paso.

Los enlaces 2–4, 7–10 y 12–13 se implementan en los generadores de las salas indicadas. No editar `.tscn` a mano.

## 3. Hub, tres alas, bucles y atajos

### Hub
`derailed_train` es el punto de decisión. Tres accesos identificables por señalética, iluminación y geometría:
- Ala A — **Locomotora y coche de pasajeros**: cabina + interior del vagón.
- Ala B — **Convoy y carga**: costado + vagón de carga + pasarela alta.
- Ala C — **Túnel y drenaje**: paso bajo nivel + cuarto de drenaje + casa de cambios.

El jugador puede empezar A, B o C. El acceso elevado a C desde la pasarela evita que la llave del paso bajo nivel convierta el orden en obligatorio.

### Dos bucles principales
- **Bucle 1 (mecánico):** HUB → cabina_locomotora → wagon_interior → HUB.
- **Bucle 2 (carga):** HUB → convoy_side → vagon_carga → pasarela_convoy → HUB.
- **Bucle 3 (servicio):** HUB → pasarela_convoy → cuarto_drenaje → underpass → convoy_side → HUB.

### Atajos unidireccionales
- **Atajo A — compuerta del fuelle:** se abre desde el lado de cabina/wagon interior y crea un retorno rápido al hub.
- **Atajo B — escotilla de drenaje:** se libera desde cuarto_drenaje hacia underpass/convoy_side; evita volver por la pasarela.
Ambos se abren desde el lado opuesto y quedan persistentes. El portón de `underpass_gate` conserva el comportamiento de llave/atajo desde el lado interior.

### Retroceso premiado (≥3)
1. Tras liberar el freno, se puede registrar el compartimento de herramientas en la cabina.
2. Tras restaurar energía, se activa el armario de señalización en el convoy.
3. Tras encontrar el diagrama de palancas, se puede volver al cambio de vía y abrir el contenedor de contrapesos.
4. Con la escotilla abierta, volver al paso bajo nivel permite recoger la caja opcional de munición sin cruzar de nuevo todo el tren.

## 4. Tamaños, forma y verticalidad

Medidas propuestas en metros; se ajustan al espacio real del generador y a las cámaras. Ninguna sala comparte exactamente la misma planta. ≥5/10 salas tienen recorrido vertical (50%, por encima del mínimo 40%).

| Sala | Planta / altura | Forma y verticalidad |
|---|---:|---|
| `track_north` | 18×9 / 5.5 | Trinchera irregular en Y; desvío, ramal y puerta de servicio. |
| `derailed_train` (hub) | 26×11 / 5.8 | Patio largo; escalera sobre el vagón volcado y plataforma superior. |
| `cabina_locomotora` | 9×7 / 5.8 | L/U, cabina de costado; escalera y entrepiso de inspección. |
| `wagon_interior` | 14×3.3 / 2.5 | Pasillo estrecho y angosto; asientos arrancados y fuelle de conexión. |
| `convoy_side` | 26×7.5 / 5.5 | Pasillo exterior largo entre vagones; sin duplicar la planta del hub. |
| `vagon_carga` | 18×6 / 6.2 | Galpón ferroviario; plataforma alta/estiba con escalera. |
| `pasarela_convoy` | 20×4 / 5.6 | Pasarela elevada con balcón mirando al hub y acceso a drenaje. |
| `underpass` | 14×3.6 / 3.2 | Túnel largo; escalones/desnivel en ambos extremos. |
| `cuarto_drenaje` | 8×6 / 3.4 | Sala pequeña en L con canal de agua y desnivel. |
| `switch_house` | 6×5 / 2.8 | Caseta compacta segura, conserva máquina de escribir y salida. |

### Uso de `tools/level_gen/vertical.py`
- `derailed_train`: `vertical.stairs(... rise=2.4)` a una plataforma de observación sobre el vagón; no bloquea el paso inferior.
- `cabina_locomotora`: `vertical.stairs(... rise=2.1)` y `vertical.balcony(... y=2.1)`; el objeto opcional queda arriba.
- `vagon_carga`: `vertical.stairs(... rise=2.7)` a una estiba/entrepiso; el fusible está en contenedor, no en el piso.
- `pasarela_convoy`: `vertical.balcony(... y=2.6)`, barandas con colisión y vista hacia el HUB.
- `underpass`: escaleras de acceso con desnivel; el apagón sigue siendo el reto de iluminación.

Los generadores deben importar `vertical` desde `tools/level_gen` como los ejemplos existentes. Añadir salas nuevas a `tools/detail_rooms.json`; cada sala rehecha también debe permanecer registrada. Ejecutar `python3 tools/audit_detail.py --check` tras la implementación. Umbrales: ≥150 nodos, ≥40 props, ≥14 tipos, ≥15 decals, ≥4 cámaras. Claude planifica cámaras y prerenders. Añadir pruebas de ascenso/estabilidad a `tests/vertical_test.gd`: Isabella sube, alcanza el nivel alto y no cae por bordes/barandas.

## 5. Objetos, llaves y tres sellos

Ningún objeto clave aparece suelto a la vista; se registra, abre un contenedor, se combina o se obtiene de un enemigo/objeto interactivo.

| ID / bandera | Ubicación y adquisición | Función |
|---|---|---|
| `engineer_key` | Enrollada dentro de un estuche de herramientas cerrado en `wagon_interior`; se abre con la pista de 06:48. | Abre `underpass_gate`; también se puede liberar desde el lado interior como atajo. |
| `fuse_10a` | Contenedor de estiba en `vagon_carga`, tras registrar el manifiesto. | Componente para restaurar energía. |
| `insulated_cable` | Cajón de mantenimiento en `cabina_locomotora`, con alicate aislado; registrar y combinar según PZ-04. | Puente temporal del circuito de drenaje. |
| `brake_handle` | Contenedor bajo el asiento de inspección en `cabina_locomotora`, tras la secuencia mecánica. | Activa `tracks:brake_released` (sello A). |
| `map_tracks` | En `switch_house`, dentro del cajón de planos; acceso después de restaurar la energía. | Mapa de zona; nunca pickup en el suelo. |
| `signal_pin` | Dentro del gabinete de señales de `cuarto_drenaje`, después de seguir el cable y activar el panel. | Activa `tracks:line_aligned` (sello C). |
| `tracks:power_restored` | Dos componentes instalados y circuito puenteado en `cuarto_drenaje`. | Sello B; abre compuertas y luz de servicio. |

**Salida de capítulo:** `switch_house` exige `tracks:brake_released`, `tracks:power_restored` y `tracks:line_aligned`. Cada sello puede obtenerse en orden libre; ningún recurso crítico está detrás de la puerta que lo exige.

## 6. Puzzles (≥6; 4 tipos)

Cada puzzle usa el motor P12, bandera persistente, dos pistas con ubicación exacta, resultado, fallo y estado guardado. IDs estables:

| ID / tipo | Sala | Diseño, pistas y resultado |
|---|---|---|
| `cap2_tracks_code_0648` — código | `wagon_interior` | Código 0648, hora del último registro de la planilla. Pista 1: planilla del conductor en el asiento; pista 2: reloj digital roto de la cabina muestra 06:48. Abre estuche de herramientas para `engineer_key`. Error: mensaje «El cierre no cede» y sin consumir ítems. |
| `cap2_tracks_brake_sequence` — secuencia/palancas | `cabina_locomotora` | Orden deducido del diagrama de freno: **2 → 3 → 1** (aislar, liberar, confirmar). Pista 1: placa de servicio; pista 2: nota de Jorge. Éxito entrega `brake_handle` y sello A. Fallo reinicia palancas; sin daño al jugador. |
| `cap2_tracks_cable_bridge` — combinar objetos | `cabina_locomotora` / `cuarto_drenaje` | Cable cortado + alicate aislado → puente temporal (P10/PZ-14). Pista 1: etiqueta de cable; pista 2: manual de mantenimiento. Consume componentes solo si hay espacio para el resultado; guarda el puente creado. |
| `cap2_tracks_fuse_panel` — fusible/energía | `cuarto_drenaje` | Instalar fusible de 10 A y puente; no acepta circuito incompleto ni consume piezas en fallo. Enciende luz de servicio, bomba y sello B. Pista 1: placa «10 A»; pista 2: manifiesto de carga. |
| `cap2_tracks_drain_siphon` — ambiental/combinar | `cuarto_drenaje` | Manguera + abrazadera → sifón (PZ-16); vacía el canal y revela el contenedor del `signal_pin`. Pista 1: marcas de nivel; pista 2: nota del encargado. Guardar `drain:empty`. |
| `cap2_tracks_signal_alignment` — palancas/observación | `switch_house` | Alinear tres palancas con el esquema de vías: **desvío → freno → norte** (secuencia 1-2-3 del diagrama de la caseta). Pista 1: marcas de desgaste; pista 2: plano de cambios. Activa sello C y libera salida cuando están los tres sellos. |
| `cap2_tracks_freight_counterweight` — ambiental/peso | `vagon_carga` | Mover carro de equipaje a plataforma marcada para levantar una reja y abrir opcional. Pista 1: marcas en el piso; pista 2: nota de carga. Sin temporizador estricto; guardar posición. |
| `cap2_tracks_underpass_gate` — atajo unidireccional | `underpass` | Abrir la escotilla desde dentro con el pestillo alto; crea atajo persistente al convoy. Se puede acceder por la ruta elevada si el candado principal aún está cerrado. |

**Cuatro tipos cubiertos:** código; secuencia/palancas; combinación/ítems; ambiental (peso, drenaje, energía); puerta unidireccional. No convertir todos los retos en cerraduras numéricas.

## 7. Pistas de Leo N1/N2/N3

Cada sala tiene al menos una pista activa, sin flechas amarillas permanentes dentro de la zona. Las ubicaciones se definen en los generadores junto al interactuable, pero fuera de la colisión y de la ruta de enemigos.

| Sala | N1 (mirada/maullido) | N2 (≤12 palabras, vaga) | N3 (solo AYUDA, explícita) |
|---|---|---|---|
| `track_north` | Mira la puerta de servicio y luego el ramal. | «El tren no está al final de la vía principal.» | «Entra por la puerta de servicio y rodea el vagón volcado.» |
| `derailed_train` | Se sienta junto al paso entre locomotora y coche. | «Hay más de una forma de cruzar estos restos.» | «Explora cabina, coche y costado; vuelve al patio entre alas.» |
| `cabina_locomotora` | Mira el panel de freno y la escalera. | «Jorge dejó un orden antes de irse.» | «Lee el diagrama y acciona las palancas 2, 3 y 1.» |
| `wagon_interior` | Mira el estuche bajo el asiento. | «La hora quedó escrita en dos lugares.» | «Compara planilla y reloj; el código es 0648.» |
| `convoy_side` | Mira el candado y luego la pasarela. | «El camino bajo también tiene una vuelta arriba.» | «Busca la llave en el coche o accede por la pasarela elevada.» |
| `vagon_carga` | Mira el manifiesto y la estiba alta. | «Lo pesado puede abrir algo que una llave no abre.» | «Registra el manifiesto, consigue el fusible y mueve el carro al contrapeso.» |
| `pasarela_convoy` | Mira el balcón y el acceso al drenaje. | «Desde arriba se ve otra manera de volver.» | «Cruza la pasarela; abre el retorno al HUB y baja al cuarto de drenaje.» |
| `underpass` | Se sienta junto a la luz de emergencia, no al fondo oscuro. | «La linterna no es un adorno aquí.» | «Avanza con la linterna, evita a los rápidos y busca el pestillo interior.» |
| `cuarto_drenaje` | Mira el canal y el tablero apagado. | «Primero escucha el agua; después sigue el cable.» | «Combina cable y alicate, instala el fusible y vacía el canal con el sifón.» |
| `switch_house` | Mira la máquina de escribir y luego las palancas. | «El amanecer espera al otro lado de tres decisiones.» | «Guarda, completa los tres sellos y alinea las palancas para salir.» |

N1 no revela texto. N2 solo aparece según el temporizador de progreso P12. N3 nunca se invoca automáticamente.

## 8. Mapa de zona

Recurso final: `data/zones/tracks.tres`, `id="tracks"`, `map_item_id="map_tracks"`, 10 salas. Mantener IDs estables de las seis salas existentes. Añadir los cuatro nuevos IDs y todas las conexiones reales, incluidas las puertas con llave/flags y los atajos unidireccionales. No duplicar el grafo en el save: el estado visitado y los pendientes se deriva de las banderas.

El ítem `map_tracks` se obtiene dentro de un cajón de planos de `switch_house` después de restaurar energía; la sala segura garantiza que el mapa se obtiene antes de salir. La representación debe indicar sala visitada, objetivo pendiente, puertas bloqueadas y atajos abiertos.

## 9. Enemigos y recursos

### Enemigos
- `track_north`: conservar el primer infectado rápido y el eco de la señal roja.
- `derailed_train`: conservar el infectado pesado que se alimenta; evitar que bloquee el único acceso a cualquiera de las tres alas.
- `wagon_interior`: un infectado dormido/caído y otro que finge estar muerto; Leo avisa.
- `convoy_side`: infectado rápido y uno alimentándose, con ruta de evasión.
- `underpass`: conservar dos rápidos; el apagón es tensión de orientación, no un combate obligatorio.
- `vagon_carga`: un infectado entre estibas; puede distraerse con el carro/ruido.
- `cabina_locomotora` y `cuarto_drenaje`: como máximo un enemigo por espacio estrecho.
- `switch_house`: sala segura, no añadir enemigos.

### Balance
- No aumentar el total de munición del capítulo por encima de **+30 %** del total de la versión de referencia.
- Mantener munición en contenedores, estuches y cadáveres registrables; no colocar llaves ni sellos como pickups visibles en el suelo.
- Curaciones: una pequeña en la ruta corta peligrosa y una en la ruta larga/puzzle; recompensa adicional opcional en carga o pasarela.
- Arma pesada/munición grande solo en opcional de contrapeso; no necesaria para terminar.
- Primera partida objetivo: **25–35 min con ayuda**; sin ayuda, **35–45 min**. La duración viene de explorar tres alas, resolver puzzles y volver a zonas abiertas, no de corredores artificialmente largos.
- No se puede terminar «corriendo hacia adelante»: el final requiere los tres sellos, cada uno en un ala distinta; los recursos clave están en contenedores/puzzles, no en el trayecto directo.

## 10. Textos exactos de documentos y notas

### Conservar los documentos existentes (sin reescribir su canon)
- **Boleto con un mensaje** (en `track_north`): conserva el texto actual de `passenger_ticket`.
- **Planilla del conductor** (en `wagon_interior`): conserva el texto actual de `conductor_log`.
- **Nota del maquinista** (en `switch_house`): conserva el texto actual de `engineer_note`.

### Nuevos documentos propuestos (texto literal)

**Parte de mantenimiento — cabina de locomotora**
«6:46. El freno de emergencia quedó trabado después de cerrar el coche 3. La palanca secundaria está en posición de aislamiento. No la muevan sin seguir el orden de la placa. — J. Muñoz»

**Placa de servicio — cabina de locomotora**
«FRENO DE EMERGENCIA: 2 AISLAR · 3 LIBERAR · 1 CONFIRMAR. Si el testigo rojo sigue encendido, no mueva el tren.»

**Manifiesto de carga — vagón de carga**
«D-16008 / CARGA DE SERVICIO. Un fusible 10 A, cable aislado, abrazadera y manguera de drenaje. Revisión pendiente: el carro de equipaje debe quedar sobre la marca amarilla para liberar la compuerta.»

**Nota del encargado del paso — cuarto de drenaje**
«El canal se llena cuando la bomba pierde energía. Si vuelve la corriente, no arranque la bomba con el canal lleno. Use la manguera y la abrazadera; vacíe primero el registro.»

**Etiqueta del gabinete — cuarto de drenaje**
«CIRCUITO DE SERVICIO 10 A. Cable cortado: puente temporal solo con alicate aislado. No conecte con las manos mojadas.»

**Plano de cambios — casa de cambios**
«DESVÍO / FRENO / NORTE. El tren fue enviado al ramal para que el coche 3 no llegara a Alameda. La línea norte queda libre cuando el cambio vuelve a posición N.»

**Nota opcional — pasarela convoy**
«Desde esta altura se ve el patio entero. Jorge dijo que si alguien encontraba el tren, no intentara arreglarlo: solo había que dejar la vía norte libre.»

Los textos no explican el origen de la infección ni vinculan Skull con el asiento 15. No añaden nombres de personajes nuevos ni contradicen las horas de `docs/GUION.md`.

## 11. Cámaras y aspecto (propuesta para Claude)

- **`track_north`**: conservar el encuadre de la división de vías, la señal roja, el ramal y la puerta de servicio. No ocultar la salida jugable.
- **`derailed_train`**: 4–6 cámaras; plano general del hub y encuadres separados para la escalera del vagón, el acceso a cabina y la puerta al convoy.
- **`cabina_locomotora`**: cámara baja que lea palancas; cámara superior que muestre el entrepiso y su recompensa.
- **`wagon_interior`**: conservar las tres cámaras longitudinales; ajustar para estuche bajo asiento y nueva conexión a cabina sin perder los puntos de spawn.
- **`convoy_side`**: 4 cámaras a lo largo del convoy, con lectura de reja, puerta de carga y acceso a la pasarela.
- **`vagon_carga`**: plano de entrada + vista del entrepiso + encuadre del carro de contrapeso.
- **`pasarela_convoy`**: cámara que muestra a Isabella en altura y el HUB al fondo; nunca dejar el balcón fuera de cobertura.
- **`underpass`**: conservar apagón, linterna y luz roja de emergencia; evitar que la oscuridad esconda la puerta de salida.
- **`cuarto_drenaje`**: plano de canal, tablero y puerta de servicio; una cámara cubre el desnivel.
- **`switch_house`**: conservar la sala segura, máquina de escribir, palancas y salida hacia el norte.

Todas las salas deben usar la tubería de `docs/ART_PIPELINE.md`, fondos WebP del mismo tamaño/compresión que el andén norte y comparación de capturas junto a la referencia. Claude planifica/renderiza; quien implementa la geometría no edita fondos manualmente. Si cambia geometría/cámara, borrar fondos antiguos hasta regenerarlos.

## 12. Variante cooperativa

El recorrido sigue siendo completable en solo. En cooperativo:
- Las palancas de cabina pueden accionarse por turnos; no requieren dos jugadores simultáneos.
- En el puente de cable, un jugador puede seguir la línea mientras el otro busca el alicate; en solo, ambas acciones quedan disponibles.
- En el paso bajo nivel, un jugador puede atraer a los rápidos mientras el otro abre la escotilla; en solo, la compuerta se mantiene abierta una vez accionada.
- El carro de contrapeso puede empujarse por ambos jugadores, pero también por uno con recorrido lento.
- No introducir puertas que exijan simultaneidad imposible en solo, ni bloquear el capítulo por una muerte/desconexión cooperativa.
- La cinemática de Skull no se duplica: se reproduce una sola vez por partida y ambos jugadores recuperan control al terminar/saltar.

## 13. Tabla de no linealidad y checklist de diseño

| Criterio | Evidencia en el diseño |
|---|---|
| Hub + 3 alas | HUB `derailed_train`; A cabina/coche, B convoy/carga, C túnel/drenaje. |
| Objetos de paso | `tracks:brake_released`, `tracks:power_restored`, `tracks:line_aligned`. |
| Dos rutas por objetivo | Ruta corta peligrosa por convoy/underpass; ruta larga segura por pasarela/drenaje; acceso a drenaje desde nivel alto y paso inferior. |
| Dos bucles | Bucle mecánico cabina–coche–hub; bucle carga convoy–vagón–pasarela–hub. |
| Dos atajos | Fuelle de cabina y escotilla de drenaje, ambos abiertos desde el lado opuesto. |
| ≥3 zonas que se abren al volver | Estuche de cabina, gabinete de convoy, contenedor de contrapeso, caja de munición del paso. |
| ≥2 opcionales con recompensa | Contrapeso en vagón de carga; caja de munición/nota en pasarela; recurso extra en drenaje. |
| Alcanzabilidad | El test debe simular al menos dos rutas desde `track_north` hasta cada sello y hasta `switch_house`, comprobando que cada llave/componente se obtiene antes de su puerta. |
| Variedad/verticalidad | 10 plantas diferentes; 5 salas con escaleras, balcón, entrepiso o pasarela; prueba `tests/vertical_test.gd`. |
| Estándar de detalle | Todas las 10 salas en `tools/detail_rooms.json`; audit ≥150 nodos, 40 props, 14 tipos, 15 decals, 4 cámaras. |
| Guion y canon | Final del capítulo y linterna/apagón preservados; cinemática de Skull existente; origen de infección no explicado. |

**Antes de implementar:** Claude revisa este diseño y sus conexiones contra las escenas actuales. Si hay incompatibilidad técnica con un ID/puerta existente, anotarla en `docs/CHATGPT_LOG.md` y conservar el ID/flag de guardado; no borrar puertas ni cambiar el final silenciosamente.
