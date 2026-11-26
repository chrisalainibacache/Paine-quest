# Catálogo reutilizable de puzzles — P10-a

**Propósito:** biblioteca de patrones para diseñar las cinco zonas. Son plantillas narrativas y mecánicas; no afirman que el motor actual ya las soporte. Las cerraduras de código, fusibles, palancas, contenedores, combinación de objetos y puertas de un solo lado requieren el motor P12. El diseño de cada zona debe indicar qué patrón reutiliza y qué datos concretos cambia.

**Regla transversal:** cada puzzle tiene una solución deducible, al menos dos pistas físicas en lugares distintos, una respuesta visible/sonora al éxito y una consecuencia legible al fallar. No usar ensayo aleatorio ni castigar con daño inevitable. Si un puzzle bloquea el avance, Leo puede ofrecer N1/N2 y la solución N3 solo al pulsar AYUDA.

## Catálogo de plantillas

| ID | Tipo | Plantilla / ingredientes | Variante y persistencia | Dificultad |
| --- | --- | --- | --- | --- |
| PZ-01 | Código deducido | Reloj detenido + nota de incidente; el código es la hora en formato HHMM. | Cooperativo: uno localiza el reloj y dicta la hora; guardar `solved`. | Fácil |
| PZ-02 | Código deducido | Tres cifras marcadas en recibos fechados; ordenar cronológicamente. | Cooperativo: documentos en dos salas; guardar código validado. | Media |
| PZ-03 | Código deducido | Número de andén + coche + asiento que aparecen en boleto y planilla. | Cooperativo: cada jugador encuentra una fuente; guardar `solved`. | Media |
| PZ-04 | Código deducido | Secuencia de cuatro dígitos obtenida de un plano de evacuación con flechas numeradas. | Cooperativo: uno observa el plano, otro opera el teclado; guardar `solved`. | Media |
| PZ-05 | Código deducido | Código parcial en una nota y último dígito indicado por un objeto examinado (no texto aleatorio). | Sin variante; guardar `solved` y número de intentos solo si altera una recompensa. | Media |
| PZ-06 | Fusibles / energía | Tablero que necesita dos fusibles de amperaje compatible; piezas en alas diferentes. | Cooperativo: uno sostiene la caja abierta y otro instala; guardar slots instalados. | Media |
| PZ-07 | Fusibles / energía | Tres portafusibles, uno quemado; intercambiar el repuesto correcto según etiquetas. | Cooperativo: jugadores leen placas desde lados distintos; guardar posición de cada fusible. | Media |
| PZ-08 | Fusibles / energía | Generador con combustible, correa y fusible; inspeccionar y reparar en ese orden. | Cooperativo: uno acciona arranque y otro estabiliza interruptor; guardar pasos. | Difícil |
| PZ-09 | Palancas / válvulas | Tres palancas con posiciones arriba/centro/abajo; diagrama en pared indica secuencia. | Cooperativo: cada jugador ve un indicador distinto; guardar posiciones y `solved`. | Media |
| PZ-10 | Palancas / válvulas | Válvulas de presión: abrir la de retorno antes de cerrar la principal. | Cooperativo: uno observa manómetro, otro gira; guardar estado de cada válvula. | Media |
| PZ-11 | Palancas / válvulas | Desvío ferroviario: alinear agujas con un esquema de destino y bloquear el cambio. | Cooperativo: uno mira el indicador de vía, otro mueve la palanca; guardar alineación. | Media |
| PZ-12 | Palancas / válvulas | Panel de tres interruptores con orden descrito en un registro de turno. | Cooperativo: se puede accionar en paralelo con límite de tiempo generoso; guardar secuencia. | Fácil |
| PZ-13 | Combinar objetos | Manivela + eje oxidado = manija de reja. Ambas piezas se inspeccionan antes de combinar. | Cooperativo: cada uno encuentra una pieza; guardar receta reclamada y consumo de ingredientes. | Fácil |
| PZ-14 | Combinar objetos | Cable cortado + alicate aislado = puente temporal de energía. | Cooperativo: uno corta y otro conecta; guardar objeto resultante y bandera de energía. | Media |
| PZ-15 | Combinar objetos | Llave sin dientes + lima = llave reparada, si el perfil coincide con una plantilla. | Sin variante; guardar resultado, nunca duplicar ingredientes. | Difícil |
| PZ-16 | Combinar objetos | Manguera + abrazadera = sifón para vaciar un depósito y revelar un objeto. | Cooperativo: uno sostiene la manguera, otro abre la válvula; guardar depósito vacío. | Media |
| PZ-17 | Llave oculta / registrar | Casillero con una abolladura y pintura reciente; registrar el compartimento correcto. | Cooperativo: uno distrae al infectado cercano, otro registra; guardar contenedor revisado. | Fácil |
| PZ-18 | Llave oculta / registrar | Llave en bolsillo de infectado pesado; encontrarla al registrar el cuerpo tras neutralizarlo. | Sin variante; guardar caída/recogida por ID del enemigo. | Media |
| PZ-19 | Llave oculta / registrar | Cuadro torcido con dos fijaciones distintas; retirar el cuadro y revisar detrás. | Cooperativo: uno sostiene el cuadro, otro recoge; guardar cuadro retirado. | Fácil |
| PZ-20 | Llave oculta / registrar | Cajón con doble fondo; la pista es el sonido distinto al abrir/cerrar. | Cooperativo: uno escucha, otro registra; guardar cajón abierto y objeto reclamado. | Media |
| PZ-21 | Puerta de un solo lado | Reja que solo se abre desde dentro y crea atajo al volver a una sala ya visitada. | Cooperativo: uno abre desde el lado interior; guardar `unlocked:<id>`. | Fácil |
| PZ-22 | Puerta de un solo lado | Pestillo alto accesible desde una escalera lateral; el acceso inicial está bloqueado. | Cooperativo: uno sube la escalera y libera; guardar pestillo abierto. | Media |
| PZ-23 | Cooperativo | Dos placas de presión deben mantenerse activas simultáneamente para abrir una puerta. | Dos jugadores reales; temporizador de salida amplio; guardar puerta abierta una vez superada. | Media |
| PZ-24 | Cooperativo | Uno sostiene una palanca mientras el otro cruza y fija una cuña del otro lado. | Si se juega solo, la cuña puede trabarse con objeto pesado; guardar cuña instalada. | Media |
| PZ-25 | Cooperativo | Un jugador alumbra un código reflectante mientras el otro introduce la combinación. | Cooperativo; la linterna no consume batería crítica; guardar `solved`. | Fácil |
| PZ-26 | Ambiental / sonido | Apagar una máquina ruidosa permite oír golpes que marcan una secuencia en otra sala. | Cooperativo: uno apaga, otro escucha; guardar máquina apagada y secuencia descubierta. | Media |
| PZ-27 | Ambiental / sonido | Cerrar una compuerta para aislar un infectado y liberar un pasillo sin combate obligatorio. | Cooperativo: uno atrae, otro cierra; guardar compuerta y estado del enemigo. | Media |
| PZ-28 | Ambiental / luz | Orientar dos espejos o reflectores para iluminar una fotocelda y liberar un cerrojo. | Cooperativo: uno ajusta cada espejo; guardar ángulos discretos y `solved`. | Difícil |
| PZ-29 | Ambiental / peso | Carro de equipaje como contrapeso: desplazarlo a una plataforma para elevar una reja. | Cooperativo: empujar desde dos lados; guardar posición del carro y reja. | Fácil |
| PZ-30 | Observación / patrón | Comparar marcas de desgaste en cuatro piezas y seleccionar la única que encaja. | Cooperativo: cada uno inspecciona dos piezas; guardar elección y resultado. | Media |
| PZ-31 | Observación / patrón | Seguir un cable por varias salas hasta el tablero que alimenta el equipo correcto. | Cooperativo: uno sigue el cable y otro verifica la etiqueta; guardar circuito identificado. | Fácil |
| PZ-32 | Ruta / navegación | Plano incompleto en dos mitades; unir referencias de pasillos y puertas para marcar el atajo. | Cooperativo: cada jugador encuentra una mitad; guardar mapa completo. | Media |
| PZ-33 | Inventario / recurso | Elegir qué objeto transportar en un contenedor con un único espacio útil; la alternativa queda recuperable. | Cooperativo: comparar pistas y decidir; guardar elección sin destruir contenido crítico. | Media |
| PZ-34 | Temporización legible | Activar dos interruptores en orden dentro de una ventana amplia indicada por una luz piloto. | Cooperativo: cada jugador acciona uno; guardar éxito y no exigir reflejos de arcade. | Difícil |

## Contrato de cerraduras y códigos

Los datos concretos del puzzle se almacenan en un recurso de datos (futuro `PuzzleData` de P12), no en condicionales dispersos por las salas. Campos propuestos:

| Campo | Tipo | Uso |
| --- | --- | --- |
| `id` | StringName | ID estable único del puzzle. |
| `type` | StringName | `code`, `fuse`, `lever`, `sequence`, `combine`, `container`, `one_way`, `environment`, `co_op`. |
| `room_id` | StringName | Sala donde está el interactuable principal. |
| `lock_id` | StringName | Identificador de cerradura/puerta que cambia de estado; vacío si no abre puerta. |
| `code_length` | int | Entre 3 y 6 para teclado; no guardar el texto digitado en el save. |
| `code_hash` / `solution_id` | String | Validación de solución; el diseño puede declarar el código visible en el documento, pero el recurso de runtime no necesita exponerlo en UI. |
| `required_items` | Array[StringName] | IDs y cantidades de objetos/fusibles necesarios. |
| `slots` | Array[StringName] | Puntos de instalación con estado vacío/ocupado. |
| `sequence` | Array[int] | Orden correcto de palancas/interruptores. |
| `attempt_limit` | int | Normalmente 0 (sin límite); evitar bloqueos permanentes. |
| `failure_feedback` | String | Respuesta breve y comprensible al fallar. |
| `reward_items` | Array[StringName] | Objetos entregados una sola vez. |
| `success_flag` | StringName | Bandera persistente `puzzle:<id>:solved`. |

### Reglas de persistencia

1. El estado se guarda en `GameState.flags` o en un diccionario de estado versionado serializado por el guardado; no se guarda una referencia a un nodo.
2. Al resolver: escribir la bandera primero, luego animar/abrir la puerta y entregar recompensa. Repetir la interacción no duplica objetos.
3. Al cargar: reconstruir el estado visual desde banderas (pestillo abierto, fusible instalado, contenedor vacío, palanca en su posición); no volver a ejecutar la recompensa.
4. Los códigos aceptan solo la longitud y caracteres definidos. Entrada inválida no consume intentos. Un código incorrecto produce sonido y texto, no daño arbitrario.
5. Un puzzle obligatorio nunca queda irrecuperable por un fallo. Si el objeto requerido se consume, la puerta ya debe quedar marcada como resuelta.
6. Una llave que abre varias puertas declara todos sus `lock_ids`; solo se consume cuando todas esas cerraduras están abiertas.
7. La variante cooperativa debe ser opcional para la historia individual. Ningún puzzle exige dos dispositivos si no existe una solución equivalente en solitario.

## Criterios de aceptación P10-a

- [x] Más de 30 patrones (34), con ingredientes, variante/persistencia y dificultad.
- [x] Incluye códigos, fusibles, palancas, combinación, llaves ocultas, atajos unidireccionales, ambientales y cooperativos.
- [x] Contrato de datos para códigos, secuencias, objetos instalados, recompensas y banderas.
- [x] Separa diseño futuro de mecánicas ya implementadas.
