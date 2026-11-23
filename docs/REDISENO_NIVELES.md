# Rediseño de niveles «estilo RE3 de PS1» (propuesta, 2026-11-23)

Origen: feedback de Chris sobre la build-129 (ver GDD). **Pendiente de aprobación**; nada de esto está implementado.

## 1. Diagnóstico (qué hace que hoy sea lineal)
1. Cada capítulo es una **cadena** de salas: A → B → C. No hay bifurcaciones ni vueltas atrás con sentido.
2. Cada puerta cerrada tiene **una llave a la vista** en la sala anterior (a veces en el piso) y **Leo explica la solución** con una flecha amarilla.
3. Solo hay **un tipo de puzzle** (llave → puerta). Las notas cuentan historia pero **nunca sirven para resolver algo**.
4. Las salas son **cajas grandes** (16×10 m y más) con pocos objetos y cámaras que muestran espacio vacío.

## 2. Estructura de zonas (la base del cambio)
- Cada capítulo es una **zona de 8 a 12 salas pequeñas** unidas en **bucles** (no en fila): al menos **2 caminos** hacia cada objetivo y **2 atajos** que se abren **desde el otro lado** (puerta que solo se puede abrir por dentro, reja que se levanta con una palanca).
- **Volver atrás** es parte del juego: llaves y objetos que sirven en salas ya visitadas. Se evita el «vaciado»: siempre queda algo por hacer.
- Salas **de 6 a 10 m**, con **curvas, esquinas, recovecos y desniveles** (rampas, escaleras cortas, pasillos en L y en U). Cámaras fijas en esquinas, como en RE3.
- **Todo prerenderizado** (ya tenemos la tubería). Presupuesto: ≈ 0,5–0,8 MB por cámara con **WebP con pérdida**, no PNG (el APK ya pesa 112 MB).

## 3. Mapas
- **Objeto «Mapa de zona»** (uno por zona, a veces en dos mitades) que se encuentra en un lugar con sentido (oficina de la estación, caseta del guardia).
- **Pantalla de mapa** en la mochila: las salas son casillas conectadas; **color según estado** (sin visitar, visitada, con objetos pendientes, puerta cerrada con el icono de la llave que pide). Se dibuja sola a partir de los datos de las salas (`tools/room_map.gd` ya genera el plano de cada sala).
- Sin mapa, la pantalla solo muestra las salas ya visitadas.

## 4. Catálogo de puzzles (más allá de la llave)
| Tipo | Ejemplo en el juego |
| --- | --- |
| **Código deducido de notas** | La caja fuerte de la boletería («no sé la combinación»): el código es **0712**, la hora del reloj parado con el balazo (sala de espera). |
| **Fusibles / energía** | Un tablero pide **2 fusibles**, uno en cada ala; sin energía no abre el ascensor o la reja. |
| **Palancas y válvulas** | Orden de 3 palancas según un diagrama que se ve en otra sala. |
| **Combinar objetos** | Manivela + eje = manija de la reja; cable + alicate; llave sin dientes + lima. |
| **Llaves ocultas** | Dentro de casilleros/cajones (acción **Registrar**), en el bolsillo de un infectado (cae al morir), detrás de un cuadro, dentro de un objeto que se examina y se abre. |
| **Puertas de un solo lado** | Solo se abren desde dentro; crean atajos al volver. |
| **Cooperativo** | Uno sostiene la palanca mientras el otro cruza; uno alumbra, el otro abre (se aprovecha a Ignacia). |
| **Ambientales** | Apagar una máquina para oír algo, cortar el agua, cerrar una puerta para atrapar a un infectado. |
Regla: **ninguna llave ni objeto clave a la vista sin un pequeño reto o contexto**; y **cada puzzle tiene ≥ 2 pistas** repartidas por la zona.

## 5. Pistas de Leo (menos «mano»)
- Nivel 1: Leo **mira o maúlla hacia un lugar** (no dice qué hacer). Nivel 2 (solo si se queda quieto mucho rato): una frase vaga. **Nivel 3 (solución explícita): solo a demanda** (botón «AYUDA»). Sin flechas amarillas permanentes; solo marcadores en puertas de **salida de zona**.

## 6. Piloto y plan
1. **Piloto: capítulo 1 (estación de Paine)**: rehacer como zona de ~9 salas con bucles, el mapa, 3 tipos de puzzle (código del reloj, fusibles, llave oculta en casillero) y pistas a demanda. Es el capítulo más corto y el que el jugador ve primero.
2. **Herramientas (Claude):** `Registrar` (contenedores), cerradura de código, objeto combinable, mapa/pantalla de mapa, puertas de un solo lado, guardado de estado de puzzles.
3. **Diseño de zonas (ChatGPT, solo texto):** por capítulo, **grafo de salas**, lista de puzzles con sus pistas, y textos de notas nuevas; yo lo implemento en los generadores.
4. Después del piloto: capítulos 2 a 5 (los de ChatGPT P7/P8 se **rehacen con este modelo**, no se siguen como están).

## 7. Riesgos
- **Trabajo grande**: es un rediseño, no un parche. Por eso el piloto.
- **Rendimiento/peso:** más salas pequeñas = más fondos; el WebP y las cámaras justas son obligatorios.
- **Cámaras:** más curvas = más difícil que una cámara no pierda a Isabella (ya hay auditoría ≤ 4 %).
- **Guardado:** hay que guardar el estado de puzzles (códigos resueltos, fusibles puestos, palancas).
