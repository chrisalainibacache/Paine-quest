# P16 — Capítulo 2 «Las vías» (diseño P10-c)
Fecha: 2026-11-26
Estado: **diseño P16-a corregido; listo para implementación**
Fuente narrativa: `docs/GUION.md` §2 y §5; `docs/GDD.md` «Capítulo 2 — Las vías»; estructura: `docs/GUION_FINAL.md` §2.
Respeta el aviso de lote 1 de P15: no tocar P15; trabajar en `chatgpt/P16-cap2`. Este documento se crea primero; los generadores y escenas se implementan después, siempre desde scripts.


## REVISIÓN DE CLAUDE (2026-11-26) — 7 CORRECCIONES APLICADAS

Esta versión aplica los siete puntos obligatorios: A corta combustible y extingue el incendio; cada ala obtiene un sello independiente; el pasador es un componente y C se activa en la casa de cambios; el mapa se recoge en el hub; los espacios de máquinas y carga tienen alturas y usos realistas; las cámaras las planifica Claude con mínimo global de dos; y A, B y C pueden empezarse en cualquier orden, con rutas verificables A→B→C y C→B→A.

## 1. Resumen de la zona

Isabella y Leo salen del andén sur de Paine pasada la medianoche. La vía se divide en el cambio de vía: la principal continúa al norte hacia el túnel en llamas; el ramal termina en el tope doblado donde quedó el tren D-16008, descarrilado y destrozado. El túnel oeste por el que llegaron queda abierto pero oscuro y bloqueado para el retorno; la salida jugable es la puerta de servicio de la trinchera.

El capítulo no termina en el tren. El jugador rodea los restos a pie, atraviesa el convoy, recupera acceso al paso bajo nivel en apagón y llega a la casa de cambios. Allí guarda y decide seguir por la vía hacia el norte al amanecer, rumbo a Buin.

**Objetivo principal:** restaurar tres condiciones ferroviarias independientes y abrir la salida de la casa de cambios:
- cortar el combustible y apagar el incendio de la locomotora;
- restaurar la alimentación del sistema de drenaje/servicio;
- alinear el cambio de vía para dejar libre el recorrido norte.

**Hub no lineal:** el patio del descarrilamiento (`derailed_train`). Desde ahí se accede a tres alas y se vuelve varias veces. No se exige completar las alas en orden.

**Conservar sin cambios narrativos:** cinemática existente de Skull en `track_north` (una sola vez por partida, ya integrada); apagón y uso de linterna en `underpass`; la casa de cambios como sala segura y final de capítulo; la nota del maquinista y el final hacia el norte. No se explica el origen de la infección. Los personajes no pronuncian el nombre interno Skull.

## 2. Grafo y mapa ASCII

10 salas: las 6 existentes y 4 nuevas.

- Existentes: `track_north`, `derailed_train`, `wagon_interior`, `convoy_side`, `underpass`, `switch_house`.
- Nuevas: `sala_locomotora`, `galpon_carga`, `pasarela_convoy`, `cuarto_drenaje`.

```text
                       [A: CABINA LOCOMOTORA]
                       (corte de combustible / sello A)
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
2. `derailed_train ↔ sala_locomotora`: puerta de acceso al lateral de la locomotora.
3. `sala_locomotora ↔ wagon_interior`: paso estrecho por el fuelle/puerta de conexión.
4. `derailed_train ↔ wagon_interior`: conservar el acceso existente por el estribo.
5. `wagon_interior ↔ convoy_side`: conservar el cruce por el coche.
6. `derailed_train ↔ convoy_side`: conservar el acceso lateral existente; funciona como tercer brazo del hub.
7. `convoy_side ↔ galpon_carga`: acceso a la carga por una puerta lateral.
8. `galpon_carga ↔ pasarela_convoy`: subir a la plataforma superior del vagón.
9. `pasarela_convoy ↔ derailed_train`: retorno elevado al hub; balcón con vista al descarrilamiento.
10. `pasarela_convoy ↔ cuarto_drenaje`: acceso superior de mantenimiento.
11. `convoy_side ↔ underpass`: conservar `underpass_gate`; inicialmente se abre con `engineer_key` o desde el lado interior por el atajo.
12. `underpass ↔ cuarto_drenaje`: puerta de mantenimiento, abre desde el lado del drenaje.
13. `cuarto_drenaje ↔ switch_house`: conexión de servicio.
14. `switch_house`: conservar la salida de capítulo hacia la vía norte; el final requiere los tres flags de paso.
15. `derailed_train ↔ underpass`: escalera de servicio abierta desde el hub; permite iniciar el ala C sin llave, sello ni energía. `underpass_gate` queda como atajo lateral opcional.

Los enlaces 2–4, 7–10 y 12–13 se implementan en los generadores de las salas indicadas. No editar `.tscn` a mano.

## 3. Hub, tres alas, bucles y atajos

### Hub
`derailed_train` es el punto de decisión. Tres accesos identificables por señalética, iluminación y geometría:
- Ala A — **Locomotora y coche de pasajeros**: sala de máquinas/inspección + interior del vagón.
- Ala B — **Convoy y carga**: costado + galpón de carga + pasarela alta.
- Ala C — **Túnel y drenaje**: paso bajo nivel + cuarto de drenaje + casa de cambios.

El jugador puede empezar A, B o C. Las tres alas tienen entrada abierta desde el hub: A por `sala_locomotora`, B por `convoy_side` hacia `galpon_carga` y C por la escalera directa desde `derailed_train` a `underpass`. La pasarela añade una ruta superior alternativa hacia drenaje; las llaves solo abren atajos.

### Dos bucles principales
- **Bucle 1 (mecánico):** HUB → sala_locomotora → wagon_interior → HUB.
- **Bucle 2 (carga):** HUB → convoy_side → galpon_carga → pasarela_convoy → HUB.
- **Bucle 3 (servicio):** HUB → pasarela_convoy → cuarto_drenaje → underpass → convoy_side → HUB.

### Atajos unidireccionales
- **Atajo A — compuerta del fuelle:** se abre desde el lado de sala de máquinas/wagon interior y crea un retorno rápido al hub.
- **Atajo B — escotilla de drenaje:** se libera desde cuarto_drenaje hacia underpass/convoy_side; evita volver por la pasarela.
Ambos se abren desde el lado opuesto y quedan persistentes. El portón de `underpass_gate` conserva el comportamiento de llave/atajo desde el lado interior.

### Retroceso premiado (≥3)
1. Tras apagar el incendio, se puede registrar el compartimento de herramientas de la sala de máquinas.
2. Tras restaurar energía, se activa el armario de señalización en el convoy.
3. Tras encontrar el diagrama de palancas, se puede volver al cambio de vía y abrir el contenedor de contrapesos.
4. Con la escotilla abierta, volver al paso bajo nivel permite recoger la caja opcional de munición sin cruzar de nuevo todo el tren.

## 4. Tamaños, forma y verticalidad

Medidas propuestas en metros; se ajustan al espacio real del generador y a las cámaras. Ninguna sala comparte exactamente la misma planta. ≥5/10 salas tienen recorrido vertical (50%, por encima del mínimo 40%).

| Sala | Planta / altura | Forma y verticalidad |
|---|---:|---|
| `track_north` | 18×9 / 5.5 | Trinchera irregular en Y; desvío, ramal y puerta de servicio. |
| `derailed_train` (hub) | 26×11 / 5.8 | Patio largo; escalera sobre el vagón volcado y plataforma superior. |
| `sala_locomotora` | Mira las válvulas del panel y luego la pasarela. | «El fuego no se apaga golpeándolo.» | «Corta el combustible en orden 2, 3 y 1.» |
| `wagon_interior` | 14×3.3 / 2.5 | Pasillo estrecho y angosto; asientos arrancados y fuelle de conexión. |
| `convoy_side` | 26×7.5 / 5.5 | Pasillo exterior largo entre vagones; sin duplicar la planta del hub. |
| `galpon_carga` | Mira el tablero local y después el carro de contrapeso. | «La carga todavía guarda corriente.» | «Registra el fusible 10 A e instálalo en el tablero del galpón; el carro abre el opcional.» |
| `pasarela_convoy` | 20×4 / 5.6 | Pasarela elevada con balcón mirando al hub y acceso a drenaje. |
| `underpass` | Se sienta junto al acceso directo desde el patio y luego mira la luz roja. | «La linterna no es un adorno aquí.» | «Entra por la escalera abierta del hub; la reja lateral es un atajo opcional.» |
| `cuarto_drenaje` | Mira el canal, la bomba manual y el gabinete. | «Primero escucha el agua; después busca el pasador.» | «Vacía el canal manualmente, registra `signal_pin` y llévalo a la casa de cambios.» |
| `switch_house` | 6×5 / 2.8 | Caseta compacta segura, conserva máquina de escribir y salida. |

### Uso de `tools/level_gen/vertical.py`
- `derailed_train`: `vertical.stairs(... rise=2.4)` a una plataforma de observación sobre el vagón; no bloquea el paso inferior.
- `sala_locomotora`: `vertical.stairs(... rise=2.1)` y `vertical.balcony(... y=2.1)` para la pasarela de inspección; el objeto opcional queda arriba.
- `galpon_carga`: `vertical.stairs(... rise=2.7)` al entrepiso a 2.7 m; el fusible queda en un armario, no en el suelo.
- `pasarela_convoy`: `vertical.balcony(... y=2.6)`, barandas con colisión y vista hacia el HUB.
- `underpass`: escaleras de acceso con desnivel; el apagón sigue siendo el reto de iluminación.

Los generadores deben importar `vertical` desde `tools/level_gen` como los ejemplos existentes. Añadir salas nuevas a `tools/detail_rooms.json`; cada sala rehecha también debe permanecer registrada. Ejecutar `python3 tools/audit_detail.py --check` tras la implementación. Umbrales: ≥150 nodos, ≥40 props, ≥14 tipos, ≥15 decals, ≥2 cámaras. Claude planifica cámaras y prerenders. Añadir pruebas de ascenso/estabilidad a `tests/vertical_test.gd`: Isabella sube, alcanza el nivel alto y no cae por bordes/barandas.

## 5. Objetos, llaves y tres sellos

Ningún objeto clave aparece suelto a la vista; se registra, abre un contenedor, se combina o se obtiene de un enemigo/objeto interactivo.

| ID / bandera | Ubicación y adquisición | Función |
|---|---|---|
| `engineer_key` | Estuche cerrado en `wagon_interior`, abierto con el código 0648. | Llave opcional para la reja lateral `underpass_gate`; no bloquea la ruta del sello C. |
| `fuse_10a` | Armario de mantenimiento de `galpon_carga`, junto al manifiesto. | Se instala en el tablero local del galpón y activa `tracks:power_restored` (sello B); no requiere cable ni objetos de otra ala. |
| `insulated_cable` | Cajón de mantenimiento opcional en `sala_locomotora`, con alicate aislado. | Puente temporal para abrir un atajo eléctrico hacia drenaje; no es requisito de ningún sello. |
| `fuel_valve_sequence` | Panel interactivo de válvulas de `sala_locomotora`; no se recoge ni requiere objetos externos. | Completar 2 → 3 → 1 apaga el incendio y activa `tracks:fire_out` (sello A). |
| `map_tracks` | Casillero ferroviario del coche dentro de `derailed_train` (hub), accesible al REGISTRAR desde el patio. | Mapa de zona disponible desde el comienzo; no requiere sellos ni llaves. |
| `signal_pin` | Gabinete de señales en `cuarto_drenaje`, revelado tras vaciar manualmente el canal. | Componente que se instala en `switch_house`; por sí solo no activa el sello C. |
| `tracks:power_restored` | Tablero local de `galpon_carga`, después de instalar `fuse_10a`. | Sello B; también alimenta luces y bomba del drenaje como recompensa, pero no es necesario para resolver C. |

**Salida de capítulo:** `switch_house` exige `tracks:fire_out`, `tracks:power_restored` y `tracks:line_aligned`. A, B y C son sellos independientes y cada uno puede iniciarse desde el hub sin completar los otros.

## 6. Puzzles (≥6; 4 tipos)

Cada puzzle usa el motor P12, bandera persistente, dos pistas con ubicación exacta, resultado, fallo y estado guardado. IDs estables:

| ID / tipo | Sala | Diseño, pistas y resultado |
|---|---|---|
| `cap2_tracks_code_0648` — código | `wagon_interior` | Código 0648, deducido de la planilla del conductor y del reloj digital roto de `sala_locomotora`. Abre el estuche de `engineer_key`, usado solo para el atajo opcional del paso bajo nivel. Error: «El cierre no cede»; no consume ítems. |
| `cap2_tracks_fuel_cut_sequence` — secuencia/válvulas | `sala_locomotora` | Orden **2 → 3 → 1**: cerrar retorno, cerrar válvula principal y confirmar presión cero. Pista 1: placa junto al panel; pista 2: parte de Jorge. Éxito apaga el incendio, despeja el humo de `convoy_side` y activa `tracks:fire_out`. Fallo reinicia válvulas, sin daño. |
| `cap2_tracks_cable_bridge` — combinación de objetos (opcional) | `sala_locomotora` / `cuarto_drenaje` | Cable + alicate aislado → puente para abrir un atajo eléctrico y encender luces auxiliares. Pista 1: etiqueta en sala de máquinas; pista 2: esquema junto al registro de drenaje. Nunca es requisito de un sello; consume piezas solo si hay espacio para el resultado. |
| `cap2_tracks_fuse_panel` — fusible/energía | `galpon_carga` | Instalar fusible de 10 A en el tablero propio del galpón. No acepta fusible incorrecto y no consume pieza en fallo. Activa `tracks:power_restored` (sello B); además enciende luces y bomba del drenaje como beneficio de retroceso. Pista 1: placa 10 A; pista 2: manifiesto del armario. |
| `cap2_tracks_drain_siphon` — ambiental/manual | `cuarto_drenaje` | Accionar la bomba manual y usar manguera con abrazadera para vaciar el canal, sin depender de la energía del ala B; revela el gabinete de `signal_pin`. Pista 1: marcas de nivel; pista 2: nota del encargado. Guarda `drain:empty`. |
| `cap2_tracks_signal_alignment` — palancas/observación | `switch_house` | Instalar `signal_pin` y alinear **desvío → bloqueo → norte**. Pista 1: marcas de desgaste; pista 2: plano de cambios. Solo la alineación con el pasador instalado activa `tracks:line_aligned` (sello C). |
| `cap2_tracks_freight_counterweight` — ambiental/peso | `galpon_carga` | Mover el carro de equipaje a la plataforma marcada para abrir un rincón opcional. Pista 1: marcas del piso; pista 2: nota de carga. Sin temporizador estricto; guardar posición. |
| `cap2_tracks_underpass_gate` — atajo unidireccional | `underpass` | Abrir la reja lateral desde dentro con el pestillo alto; crea un retorno persistente a `convoy_side`. La entrada desde la escalera del hub permanece abierta: la llave solo habilita el atajo. |

**Cuatro tipos cubiertos:** código; secuencia/palancas; combinación/ítems; ambiental (peso, drenaje, energía); puerta unidireccional. No convertir todos los retos en cerraduras numéricas.

## 7. Pistas de Leo N1/N2/N3

Cada sala tiene al menos una pista activa, sin flechas amarillas permanentes dentro de la zona. Las ubicaciones se definen en los generadores junto al interactuable, pero fuera de la colisión y de la ruta de enemigos.

| Sala | N1 (mirada/maullido) | N2 (≤12 palabras, vaga) | N3 (solo AYUDA, explícita) |
|---|---|---|---|
| `track_north` | Mira la puerta de servicio y luego el ramal. | «El tren no está al final de la vía principal.» | «Entra por la puerta de servicio y rodea el vagón volcado.» |
| `derailed_train` | Se sienta junto al paso entre locomotora y coche. | «Hay más de una forma de cruzar estos restos.» | «Explora sala de máquinas, coche y costado; vuelve al patio entre alas.» |
| `sala_locomotora` | Mira el panel de válvulas y la escalera. | «Jorge dejó un orden antes de irse.» | «Lee el diagrama y acciona las palancas 2, 3 y 1.» |
| `wagon_interior` | Mira el estuche bajo el asiento. | «La hora quedó escrita en dos lugares.» | «Compara planilla y reloj; el código es 0648.» |
| `convoy_side` | Mira el candado y luego la pasarela. | «El camino bajo también tiene una vuelta arriba.» | «Busca la llave en el coche o accede por la pasarela elevada.» |
| `galpon_carga` | Mira el manifiesto y la estiba alta. | «Lo pesado puede abrir algo que una llave no abre.» | «Registra el manifiesto, consigue el fusible y mueve el carro al contrapeso.» |
| `pasarela_convoy` | Mira el balcón y el acceso al drenaje. | «Desde arriba se ve otra manera de volver.» | «Cruza la pasarela; abre el retorno al HUB y baja al cuarto de drenaje.» |
| `underpass` | Se sienta junto a la luz de emergencia, no al fondo oscuro. | «La linterna no es un adorno aquí.» | «Avanza con la linterna, evita a los rápidos y busca el pestillo interior.» |
| `cuarto_drenaje` | Mira el canal y el tablero apagado. | «Primero escucha el agua; después sigue el cable.» | «Combina cable y alicate, instala el fusible y vacía el canal con el sifón.» |
| `switch_house` | Mira la máquina de escribir y luego las palancas. | «El amanecer espera al otro lado de tres decisiones.» | «Guarda, completa los tres sellos y alinea las palancas para salir.» |

N1 no revela texto. N2 solo aparece según el temporizador de progreso P12. N3 nunca se invoca automáticamente.

## 8. Mapa de zona

Recurso final: `data/zones/tracks.tres`, `id="tracks"`, `map_item_id="map_tracks"`, 10 salas. Mantener IDs estables de las seis salas existentes. Añadir los cuatro nuevos IDs y todas las conexiones reales, incluidas las puertas con llave/flags y los atajos unidireccionales. No duplicar el grafo en el save: el estado visitado y los pendientes se deriva de las banderas.

El ítem `map_tracks` se obtiene al REGISTRAR el casillero del coche de pasajeros en `derailed_train`, al comienzo del capítulo y sin requisitos. La representación debe indicar sala visitada, objetivo pendiente, puertas bloqueadas y atajos abiertos.

## 9. Enemigos y recursos

### Enemigos
- `track_north`: conservar el primer infectado rápido y el eco de la señal roja.
- `derailed_train`: conservar el infectado pesado que se alimenta; evitar que bloquee el único acceso a cualquiera de las tres alas.
- `wagon_interior`: un infectado dormido/caído y otro que finge estar muerto; Leo avisa.
- `convoy_side`: infectado rápido y uno alimentándose, con ruta de evasión.
- `underpass`: conservar dos rápidos; el apagón es tensión de orientación, no un combate obligatorio.
- `galpon_carga`: un infectado entre estibas; puede distraerse con el carro/ruido.
- `sala_locomotora` y `cuarto_drenaje`: como máximo un enemigo por espacio estrecho.
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

**Parte de mantenimiento — sala de máquinas de la locomotora**
«6:46. Después del impacto, la línea de combustible quedó abierta. El fuego alcanzó el lateral de la locomotora; la llave de corte sigue accesible. Cierren las válvulas según la placa, sin mover la locomotora. — J. Muñoz»

**Placa de servicio — sala de máquinas de la locomotora**
«CORTE DE COMBUSTIBLE: 2 CERRAR RETORNO · 3 CERRAR VÁLVULA PRINCIPAL · 1 CONFIRMAR PRESIÓN CERO. No arranque la locomotora.»

**Manifiesto de carga — galpón de carga**
«D-16008 / CARGA DE SERVICIO. Un fusible 10 A, cable aislado, abrazadera y manguera de drenaje. Revisión pendiente: el carro de equipaje debe quedar sobre la marca amarilla para liberar la compuerta.»

**Nota del encargado del paso — cuarto de drenaje**
«El canal se llena cuando la bomba pierde energía. Si vuelve la corriente, la bomba puede ayudar; la bomba manual y la manguera con abrazadera permiten vaciar primero el registro incluso sin electricidad.»

**Etiqueta del gabinete — cuarto de drenaje**
«CIRCUITO DE SERVICIO 10 A. La alimentación del galpón puede dar energía a la bomba; el drenaje conserva accionamiento manual. Cable cortado: puente temporal solo con alicate aislado. No conecte con las manos mojadas.»

**Plano de cambios — casa de cambios**
«DESVÍO / BLOQUEO / NORTE. Instale el pasador de señal y alinee las tres palancas para dejar libre la línea norte.»

**Nota opcional — pasarela convoy**
«Desde esta altura se ve el patio entero. Jorge dijo que si alguien encontraba el tren, no intentara arreglarlo: solo había que dejar la vía norte libre.»

Los textos no explican el origen de la infección ni vinculan Skull con el asiento 15. No añaden nombres de personajes nuevos ni contradicen las horas de `docs/GUION.md`.

## 11. Cámaras y aspecto (a cargo de Claude)

La geometría debe dejar visibles los interactuables y las rutas; **Claude planifica el número, los ángulos y los prerenders** según `docs/ART_PIPELINE.md`. Cada sala debe cumplir al menos **2 cámaras**; las salas largas, verticales o con bifurcaciones necesitarán las suficientes para cubrir rutas e interacciones sin ocultar salidas.

- **`track_north`**: conservar la división de vías, la señal roja, el ramal, la puerta de servicio y la cinemática existente.
- **`derailed_train`**: cubrir el hub, la escalera del vagón, el casillero del mapa y los tres accesos a las alas.
- **`sala_locomotora`**: leer el panel de válvulas, la salida al coche y la pasarela de inspección.
- **`wagon_interior`**: conservar la lectura longitudinal, el estuche opcional y las conexiones al hub y sala de máquinas.
- **`convoy_side`**: mostrar la reja lateral, la puerta del galpón y el acceso a la pasarela.
- **`galpon_carga`**: cubrir el tablero, el armario del fusible, el carro de contrapeso y el entrepiso.
- **`pasarela_convoy`**: mostrar a Isabella en altura y el hub al fondo.
- **`underpass`**: conservar el apagón, la linterna, la luz roja de emergencia y el acceso directo desde el hub.
- **`cuarto_drenaje`**: mostrar el canal, la bomba manual, el gabinete de señales y la puerta de servicio.
- **`switch_house`**: conservar la sala segura, máquina de escribir, palancas y salida hacia el norte.

Todas las salas siguen la tubería de `docs/ART_PIPELINE.md`, con fondos WebP del mismo tamaño y compresión del andén norte. Claude renderiza y compara las capturas. Si cambia geometría o cámara, borrar fondos antiguos hasta regenerarlos.

## 12. Variante cooperativa

El recorrido sigue siendo completable en solo. En cooperativo:
- Las palancas de sala de máquinas pueden accionarse por turnos; no requieren dos jugadores simultáneos.
- En el puente de cable, un jugador puede seguir la línea mientras el otro busca el alicate; en solo, ambas acciones quedan disponibles.
- En el paso bajo nivel, un jugador puede atraer a los rápidos mientras el otro abre la escotilla; en solo, la compuerta se mantiene abierta una vez accionada.
- El carro de contrapeso puede empujarse por ambos jugadores, pero también por uno con recorrido lento.
- No introducir puertas que exijan simultaneidad imposible en solo, ni bloquear el capítulo por una muerte/desconexión cooperativa.
- La cinemática de Skull no se duplica: se reproduce una sola vez por partida y ambos jugadores recuperan control al terminar/saltar.

## 13. Tabla de no linealidad y checklist de diseño

| Criterio | Evidencia en el diseño |
|---|---|
| Hub + 3 alas | HUB `derailed_train`; A sala de máquinas/coche, B convoy/carga, C túnel/drenaje. |
| Objetos de paso | `tracks:fire_out` (ala A, sala de máquinas); `tracks:power_restored` (ala B, galpón); `tracks:line_aligned` (ala C, casa de cambios). |
| Dos rutas por objetivo | A: acceso directo del hub a sala de máquinas o bucle del coche de pasajeros; B: acceso por `convoy_side` o por pasarela alta; C: escalera directa del hub a `underpass` o ruta superior por `pasarela_convoy` hacia drenaje. Ninguna requiere sello previo. |
| Dos bucles | Bucle mecánico sala de máquinas–coche–hub; bucle carga convoy–vagón–pasarela–hub. |
| Dos atajos | Fuelle de sala de máquinas y escotilla de drenaje, ambos abiertos desde el lado opuesto. |
| ≥3 zonas que se abren al volver | Estuche de sala de máquinas, gabinete de convoy, contenedor de contrapeso, caja de munición del paso. |
| ≥2 opcionales con recompensa | Contrapeso en galpón de carga; caja de munición/nota en pasarela; recurso extra en drenaje. |
| Alcanzabilidad e independencia | La prueba comienza con cero sellos y recorre **A→B→C** y **C→B→A** desde `derailed_train`; también inicia cada ala por separado. A usa válvulas locales en `sala_locomotora`; B instala el fusible local de `galpon_carga`; C usa acceso abierto, bomba manual, `signal_pin` y palancas en `switch_house`. Ningún sello requiere `engineer_key`, `insulated_cable` ni piezas de otra ala. |
| Variedad/verticalidad | 10 plantas diferentes; 5 salas con escaleras, balcón, entrepiso o pasarela; prueba `tests/vertical_test.gd`. |
| Estándar de detalle | Todas las 10 salas en `tools/detail_rooms.json`; auditoría ≥150 nodos, ≥40 props, ≥14 tipos, ≥15 decals y ≥2 cámaras; Claude planifica encuadres y fondos. |
| Guion y canon | Final del capítulo y linterna/apagón preservados; cinemática de Skull existente; origen de infección no explicado. |

**Antes de implementar:** Claude revisa este diseño y sus conexiones contra las escenas actuales. Si hay incompatibilidad técnica con un ID/puerta existente, anotarla en `docs/CHATGPT_LOG.md` y conservar el ID/flag de guardado; no borrar puertas ni cambiar el final silenciosamente.
