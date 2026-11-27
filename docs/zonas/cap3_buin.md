# P17 — Capítulo 3 «Buin» (diseño P10-d)

**Estado:** diseño narrativo y de niveles para revisión de Claude. No es implementación.  
**Fuente de canon:** `docs/GUION.md` §2 y §6; `docs/GUION_FINAL.md` §2–3; generadores actuales de Buin.  
**IDs protegidos:** `bridge`, `checkpoint`, `field`, `station`, `warehouse`, `vineyard`, `shed`; puertas y spawns existentes se conservan. Las conexiones nuevas usan IDs nuevos.


## REVISIÓN DE CLAUDE (2026-11-27) — APROBADO CON 4 NOTAS
Veredicto: **aprobado.** Aplica bien el contrato (mapa al principio en el hub, tres sellos independientes con órdenes A→B→C y C→B→A, atajos de un solo lado, alturas realistas, 11 salas de plantas distintas, 6 con verticalidad, documentos y pistas completas). Claude lo implementará (como el capítulo 2). Notas para la implementación:
1. **`field` y `vineyard` tienen fondos prerenderizados:** no se puede añadir geometría sólida (el «paso de tablones sobre zanja» y los desniveles de `field` irán como elementos del grupo `Interactables` o exigirán re-renderizar). Ver `docs/ESTANDAR_DETALLE.md`.
2. **Sello A (control despejado):** el efecto visible será que la **barrera del control se levanta** al registrar el parte (hoy es decorado); si no, el sello no se nota.
3. **Radio:** la batería de 12 V es el objeto de paso del sello C; la radio exige además `buin:control_clear` y `buin:rosa_found` (se conserva el texto de Paz tal cual).
4. **IDs protegidos** se respetan; el `shed_key` pasa de pickup a contenedor (REGISTRAR) conservando su ID.

## 1. Resumen de la zona

Sábado, 6:50. Isabella y Leo cruzan el puente del Maipo y llegan al control militar. Tras atravesarlo, entran a la estación de Buin, convertida en sala de espera del tren sanitario. La estación pasa a ser el **hub** de la zona: desde allí se puede volver al control o explorar las alas agrícola y de riego en cualquier orden.

Objetivo: reunir tres condiciones independientes para que la radio del galpón de la viña pueda transmitir la respuesta de Paz y cerrar el capítulo:

- **Sello A — control despejado:** registrar el parte y restablecer el paso del control militar.
- **Sello B — Rosa localizada:** conseguir la llave del galpón en el tractor, abrir el portón de la viña y hablar con Rosa sin abrir la oficina.
- **Sello C — radio alimentada:** recuperar una batería de radio en el sistema de riego y activarla en la radio del galpón.

La radio conserva exactamente su función narrativa: Paz pregunta por sobrevivientes, dice que está en La Maestranza de San Bernardo y que el vagón del Centro de Nos permanece cerrado. La transmisión se corta; Isabella y Leo siguen hacia el capítulo 4.

**No se explica el origen de la infección.** No se nombra en textos del juego a la criatura de gran tamaño. En el potrero se ve solo su eco: silueta alta e inmóvil, huella enorme y árboles quebrados; nunca el cuerpo completo.

## 2. Grafo de 11 salas, mapa ASCII y puertas iniciales

### Salas

| ID | Nombre visible | Estado |
|---|---|---|
| `bridge` | Puente del Maipo | Existente; entrada del capítulo |
| `checkpoint` | Control militar | Existente |
| `station` | Estación de Buin | Existente; hub |
| `warehouse` | Bodega agrícola | Existente |
| `field` | Potrero | Existente; exploración con tres salidas principales |
| `vineyard` | Viña Santa Rosa | Existente |
| `shed` | Galpón de la viña | Existente; Rosa y radio, cierre |
| `canal_riego` | Canal de riego | Nueva |
| `caseta_bomba` | Caseta de bombas | Nueva |
| `patio_cosecha` | Patio de cosecha | Nueva |
| `pasarela_vina` | Pasarela de la viña | Nueva |

### Mapa ASCII

```text
                     [bridge]
                        |
                  [checkpoint] --(ruta lateral nueva)--+
                        |                             |
                 +---- [station: HUB] ----+            |
                 |          |             |            |
          Ala A  |   Ala B |       Ala C  |            |
                 |          |             |            |
             [warehouse]  [field] ------ [canal_riego]
                 |          |                 |
          [patio_cosecha]  [vineyard]     [caseta_bomba]
                 |          |                 |
           [pasarela_vina]-+                 +-- atajo al HUB
                 |          |
                 +------ [shed]  (Rosa + radio)
```

### Tabla de puertas — estado inicial

| Sala / ID de puerta existente o nueva | Destino | Estado inicial | Observación |
|---|---|---|---|
| `bridge / ToCheckpoint` | `checkpoint` | Abierta | Conservar ID y spawn `from_bridge`. |
| `checkpoint / ToBridge` | `bridge` | Abierta | Conservar; retorno. |
| `checkpoint / ToStation` | `station` | Abierta | Conservar; llegada al hub. |
| `station / ToCheckpoint` | `checkpoint` | Abierta | Conservar; acceso a Ala A. |
| `station / ToWarehouse` | `warehouse` | Abierta | Conservar; acceso a Ala B. |
| `station / ToVineyard` | `field` | Abierta | Conservar ID y destino actual; rótulo visible «POTRERO». |
| `warehouse / ToStation` | `station` | Abierta | Conservar; bucle de retorno. |
| `warehouse / door_warehouse_field` | `field` | Abierta | Nueva; acceso directo al potrero. |
| `warehouse / door_warehouse_patio` | `patio_cosecha` | Abierta | Nueva; ruta larga agrícola. |
| `field / ToStation` | `station` | Abierta | Conservar; retorno al hub. |
| `field / ToVineyard` | `vineyard` | Abierta | Conservar; salida a viña. |
| `field / door_field_warehouse` | `warehouse` | Abierta | Nueva; salida exploratoria del potrero. |
| `field / door_field_canal` | `canal_riego` | Abierta | Nueva; tercera salida de exploración. |
| `field / door_field_checkpoint` | `checkpoint` | Abierta | Nueva ruta rural larga; no es requisito para completar el sello A. |
| `vineyard / ToStation` | `field` | Abierta | Conservar ID y destino actual; retorno. |
| `vineyard / ToShed` | `shed` | Cerrada; requiere `shed_key`, lock `shed_door` | Conservar ID, llave y lock. |
| `vineyard / door_vineyard_walkway` | `pasarela_vina` | Abierta | Nueva; acceso elevado. |
| `pasarela_vina / door_walkway_patio` | `patio_cosecha` | Abierta | Nueva; conexión alta. |
| `pasarela_vina / door_walkway_canal` | `canal_riego` | Cerrada desde canal | Nueva ruta alternativa, abre desde el canal. |
| `patio_cosecha / door_patio_warehouse` | `warehouse` | Abierta | Nueva; bucle agrícola. |
| `patio_cosecha / door_shortcut_patio_shed` | `shed` | Cerrada; pestillo solo desde patio | Atajo unidireccional B; abrir desde el otro lado. |
| `canal_riego / door_canal_pump` | `caseta_bomba` | Abierta | Nueva; acceso al puzzle de energía. |
| `caseta_bomba / door_shortcut_pump_station` | `station` | Cerrada; abre desde caseta | Atajo unidireccional A; no puede abrirse desde el hub al inicio. |
| `shed / ToVineyard` | `vineyard` | Abierta | Conservar ID y spawn `from_vineyard`. |
| `shed / Radio` | Fin capítulo 3 | Cerrada hasta los tres sellos y conversación con Rosa | Conservar interactuable `Radio`, `chapter="3"` y texto de Paz. |

**Puertas protegidas:** no renombrar ni eliminar los IDs existentes `ToCheckpoint`, `ToBridge`, `ToStation`, `ToWarehouse`, `ToVineyard`, `ToShed`, ni cambiar sus destinos/spawns actuales. La tabla describe conexiones nuevas sin sustituirlas.

## 3. Hub, tres alas, bucles, atajos y retroceso

### Hub
`station` (Estación de Buin). El mapa de zona está en un archivador de atención dentro de un contenedor; se obtiene al principio con **REGISTRAR**, sin llave ni sello previo. La máquina de escribir existente se conserva.

### Tres alas y sellos independientes

- **A — Control militar:** desde el hub por `ToCheckpoint`; el puzzle de orden/código usa solo documentos y objetos del propio control. Sello `buin:control_clear`.
- **B — Agricultura / Rosa:** desde el hub por `ToWarehouse`; el compartimento del tractor contiene `shed_key`. La llave abre `shed_door`; hablar con Rosa activa `buin:rosa_found`. Todo lo necesario para este sello está en esta ala.
- **C — Riego / radio:** desde el hub a `field` y `canal_riego`, o por la ruta alta desde `pasarela_vina`. Las piezas del puzzle de bomba están dentro del ala; la batería recuperada activa `buin:radio_power`. No requiere llave ni sello de A/B.

Cada ala puede iniciarse antes de completar las otras. Los objetos que cruzan alas son opcionales, recompensas o atajos; nunca requisitos de los sellos.

### Bucles
1. **Bucle estación–bodega–potrero:** `station → warehouse → field → station`, usando la nueva puerta `door_warehouse_field`.
2. **Bucle agrícola alto:** `warehouse → patio_cosecha → pasarela_vina → vineyard → field → warehouse`.
3. **Bucle de riego:** `field → canal_riego → caseta_bomba → station` una vez abierto el atajo.

### Dos atajos de un solo lado
- **A `door_shortcut_pump_station`:** desde la caseta de bombas se abre una puerta de servicio hacia la estación. No se abre desde el hub al inicio.
- **B `door_shortcut_patio_shed`:** desde el patio de cosecha se levanta un pestillo alto hacia el galpón seguro. No se abre desde el galpón al inicio.

### Retroceso premiado
1. Tras `buin:control_clear`, volver al control permite registrar el armario de suministros (recompensa redistribuida, no munición nueva).
2. Tras activar `buin:radio_power`, volver a la estación abre el cajón de mantenimiento bajo el mapa (nota opcional y un recurso ya contabilizado).
3. Tras abrir `shed_door`, volver a la bodega permite registrar una caja agrícola que antes estaba trabada.
4. Tras vaciar el canal, volver al potrero permite examinar la huella y recoger la nota de campo.
5. Tras hablar con Rosa, volver a la pasarela permite abrir un estuche de observación opcional.

## 4. Tamaños, altura y verticalidad por sala

Medidas de diseño en metros; Claude decide la geometría final y cámaras. Todas las plantas son distintas. Se proponen 6/11 salas con recorrido vertical (54,5 %).

| Sala | Planta / altura | Forma, altura y recorrido |
|---|---:|---|
| `bridge` | 22×4,6 / estructura abierta | Conservar el puente angosto; sin verticalidad añadida. |
| `checkpoint` | 18×10 / 5,2 | Carpa + patio militar; escalera a plataforma de observación de 2,2 m (vertical). |
| `station` | 10×7 / 3,6 | Hall compacto; balcón de archivo a 1,8 m con escalera corta (vertical). |
| `warehouse` | 12×8 / 4,4 | Bodega irregular en L; mezzanine de carga a 2,1 m (vertical, altura libre realista). |
| `field` | 20×12 / cielo abierto | Potrero exploratorio, tres salidas; paso de tablones sobre zanja, desnivel pequeño. |
| `vineyard` | 20×10 / cielo abierto | Hileras de parras; camino central y puerta al galpón. |
| `shed` | 10×8 / 4,8 | Galpón de barricas y oficina de Rosa; altillo de almacenamiento a 2,2 m (vertical). |
| `canal_riego` | 20×4,5 / 3,8 | Pasillo largo y estrecho junto al canal; pasarela de mantenimiento a 2,3 m (vertical). |
| `caseta_bomba` | 8×6 / 4,5 | Sala pequeña en L; escalera a plataforma de válvulas a 2,0 m (vertical). |
| `patio_cosecha` | 14×8 / 5,5 | Patio alto con galpón de herramientas, plataforma de carga y escalones. |
| `pasarela_vina` | 16×3,5 / abierta | Pasarela elevada a 2,4 m sobre hileras, baranda con colisión; vista al potrero y al galpón (vertical). |

La sala `field` deja de ser escena guionada: es exploración con salida a `vineyard`, `warehouse` y `canal_riego`, además del retorno al hub. Al fondo, junto al borde de árboles, el jugador ve una **silueta muy alta e inmóvil**. Leo se eriza; al apuntar, la silueta desaparece. Queda una huella enorme en el barro y ramas quebradas. No se muestra el cuerpo completo ni se dispara una cinemática.

## 5. Objetos, llaves y tres sellos

| ID | Ubicación / contenedor | Acción | Uso / flag |
|---|---|---|---|
| `map_buin` | Archivador de atención en `station` | REGISTRAR | Mapa de zona; disponible en primera visita. |
| `shed_key` | Compartimento de herramientas del tractor en `warehouse` | REGISTRAR, no pickup visible | Conserva ID de objeto; abre `shed_door`. |
| `buin_control_register` | Carpeta cerrada en `checkpoint` | Puzzle de código; luego REGISTRAR | Sello A: `buin:control_clear`. |
| `radio_cell` | Caja de baterías de `caseta_bomba` | REGISTRAR tras puzzle de bomba | Sello C: `buin:radio_power`. |
| `buin:rosa_found` | Conversación con `RosaDoor` en `shed` | Escuchar texto completo; no abrir puerta | Sello B. |
| `pump_handle` | Armario de mantenimiento en `canal_riego` | REGISTRAR | Solo puzzle local de bomba; no es llave de salida. |
| `hose` + `clamp` | Contenedores del canal y caseta | REGISTRAR y combinar | Sifón opcional; no bloquea sello C. |

**No dejar llaves, mapa ni objetos de paso sobre el suelo.** Munición y curaciones existentes pueden conservar sus pickups actuales, pero los objetos críticos se encuentran dentro de contenedores, tras puzzle o por interacción registrable. No cambiar `found:assault_rifle`, `shed_door`, `talked:rosa` ni IDs de notas existentes.

## 6. Puzzles (8; al menos 4 tipos)

Todos guardan estado, muestran feedback claro, no causan daño inevitable y son resolubles en solo. Las pistas se encuentran en lugares distintos. N3 de Leo ofrece la solución solo al pulsar AYUDA.

| ID / tipo | Sala | Pistas exactas | Solución y resultado | Fallo |
|---|---|---|---|---|
| `cap3_buin_control_code` — código deducido | `checkpoint` | 1) `military_order` en la carpa: orden fechada 21:00. 2) Reloj de campaña en el poste del patio detenido a las 21:00. | Código `2100`; abre la carpeta de control y permite REGISTRAR el sello A `buin:control_clear`. | «La carpeta sigue cerrada». No consume objetos; se puede reintentar. |
| `cap3_buin_tractor_compartment` — contenedor / observación | `warehouse` | 1) `worker_letter` junto al tractor indica que la llave se dejó en el compartimento de herramientas. 2) Abolladura y pintura fresca en el pestillo del compartimento, al examinar el tractor. | Interactuar con el compartimento y REGISTRAR `shed_key`; abre `shed_door` en la viña. Activa el progreso de Ala B. | El compartimento no cede; la pista N2 orienta a revisar la herramienta, sin perder llave. |
| `cap3_buin_harvest_counterweight` — ambiental / peso | `patio_cosecha` | 1) `buin_harvest_manifest` en el tablón de carga indica la marca de la plataforma. 2) Dos marcas de rueda en el suelo señalan la posición final del carro. | Empujar el carro hasta la marca; abre el portón de retorno y el opcional de cosecha. No es sello obligatorio. | Carro vuelve a la posición inicial; sin daño ni temporizador estricto. |
| `cap3_buin_canal_siphon` — combinar / ambiental | `canal_riego` | 1) `buin_irrigation_plan` en la caseta del canal muestra el registro bajo. 2) La marca de agua en la pared indica que el canal debe vaciarse antes de abrir la rejilla. | Combinar `hose`+`clamp`; vaciar el canal y abrir rejilla. Revela la entrada a la caseta y una nota opcional. | Si falta una pieza, el sistema no consume ninguna; muestra «Falta ajustar la manguera». |
| `cap3_buin_pump_sequence` — válvulas / secuencia | `caseta_bomba` | 1) `buin_pump_log` junto al manómetro: retorno → canal → bomba. 2) Tres válvulas tienen marcas de desgaste 1, 2, 3 y flechas de flujo en la tubería. | Accionar retorno → canal → bomba; se estabiliza el manómetro y abre el gabinete de batería. REGISTRAR `radio_cell`; sello C `buin:radio_power`. | Se oye golpe de aire y las válvulas vuelven a posición segura; no consume batería ni daña. |
| `cap3_buin_vineyard_latch` — puerta de un solo lado | `pasarela_vina` | 1) `buin_vineyard_shift_note` en el estuche alto describe el pestillo de retorno. 2) La barra del pestillo se ve desde el balcón, pero solo se alcanza desde la plataforma interior. | Bajar la barra desde pasarela; abre retorno hacia `patio_cosecha` (atajo B). | La barra queda bloqueada; se puede volver por la escalera normal. |
| `cap3_buin_radio_install` — combinar / energía | `shed` (radio existente) | 1) `buin_radio_battery_note` en `caseta_bomba` indica el tipo de batería. 2) La tapa de la radio tiene dos contactos vacíos y etiqueta «12 V». | Con `buin:control_clear`, `buin:rosa_found` y `buin:radio_power`, insertar batería y escuchar el mensaje de Paz. Conserva `Radio` y `chapter="3"`. | Radio emite estática; batería no se consume hasta cumplir condiciones. |
| `cap3_buin_optional_supply` — llave oculta / registrar | `checkpoint` tras volver | 1) `buin_control_register` menciona el armario de suministros. 2) El armario tiene una marca de llave bajo la bisagra. | REGISTRAR el armario después de sello A; recompensa de recurso ya incluido en la economía y nota opcional. | Armario no abre si no se completó el sello A; no consume objetos. |

**Tipos:** código, contenedor/observación, ambiental/peso, combinación, secuencia de válvulas, puerta unidireccional, energía, llave oculta/registrar.

## 7. Pistas de Leo N1/N2/N3 por sala

N1 es conducta no verbal, N2 máximo 12 palabras, N3 solución explícita solo al pulsar AYUDA. No hay flechas permanentes dentro de la zona. N3 no se muestra automáticamente.

| Sala | Objeto / ruta | N1 (mirada / maullido) | N2 (≤12 palabras) | N3 (AYUDA) |
|---|---|---|---|---|
| `bridge` | Puerta `ToCheckpoint` | Leo mira el paso entre los sacos y maúlla una vez. | «El camino sigue después de la barrera.» | «Cruza el puente y entra al control militar por SEGUIR.» |
| `checkpoint` | `military_order`, sello A | Se sienta junto a la carpa y mira la carpeta. | «El papel del control tiene una hora importante.» | «Lee la orden y el reloj de campaña; introduce 2100 en la carpeta.» |
| `station` | `map_buin`, puertas `ToWarehouse`/`ToVineyard` | Mira el archivador bajo el mapa de pared. | «Antes de salir, registra el mueble junto al mesón.» | «Registra el archivador de atención para obtener `map_buin`; luego elige una ala.» |
| `warehouse` | Tractor, `shed_key`, `worker_letter` | Mira el tractor, después el pestillo lateral. | «La llave quedó guardada donde se revisan herramientas.» | «Lee la carta y registra el compartimento del tractor para recoger `shed_key`.» |
| `field` | Tres salidas: `vineyard`, `warehouse`, `canal_riego`; eco | Leo se eriza y mira el borde de árboles; luego la huella. | «No sigas la silueta; mira lo que dejó.» | «Explora las tres salidas del potrero; examina la huella y sigue el canal si buscas el sello de riego.» |
| `vineyard` | `ToShed` / `shed_door` | Mira el candado del galpón y vuelve a mirar hacia el tractor. | «La puerta pide algo que ya viste en la bodega.» | «Usa `shed_key` en `ToShed`; no abras la oficina de Rosa.» |
| `shed` | `RosaDoor`, `Radio` | Se sienta junto a la radio; no se acerca a la puerta de oficina. | «Primero escucha a Rosa; después revisa la radio.» | «Habla con Rosa a través de `RosaDoor`; con los tres sellos, instala la batería y escucha a Paz.» |
| `canal_riego` | `hose`, `clamp`, rejilla | Mira la marca de agua y luego la abrazadera. | «El nivel del canal debe bajar antes de abrir.» | «Combina manguera y abrazadera, vacía el canal y abre la rejilla hacia la caseta.» |
| `caseta_bomba` | Válvulas, `radio_cell` | Mira el manómetro y la válvula de retorno. | «Sigue el recorrido del agua, no el orden de las etiquetas.» | «Acciona retorno, canal y bomba; registra la batería en el gabinete.» |
| `patio_cosecha` | Carro / opcional / atajo B | Mira las marcas de rueda y se acerca al carro. | «El carro debe terminar donde se detiene la plataforma.» | «Empuja el carro hasta la marca del manifiesto para abrir el opcional y el retorno.» |
| `pasarela_vina` | Atajo B, nota opcional | Mira hacia abajo al pestillo y después a la escalera. | «Desde arriba se ve cómo volver sin cruzar las parras.» | «Baja el pestillo desde la pasarela y abre `door_shortcut_patio_shed`.» |

## 8. Mapa de zona

- **ID de zona:** `buin`.
- **Ítem:** `map_buin`; se obtiene al inicio en `station`, dentro del archivador de atención (REGISTRAR).
- **11 salas** con conexiones y puertas de estado inicial según §2.
- El mapa debe mostrar sala visitada, puertas bloqueadas, objetivos pendientes A/B/C y atajos abiertos. El estado visitado se deriva de las banderas del guardado; no duplicar el grafo.
- Coordenadas sugeridas: `bridge (0,1)`, `checkpoint (1,1)`, `station (2,1)`, `warehouse (2,2)`, `field (3,1)`, `vineyard (4,1)`, `shed (5,1)`, `canal_riego (3,2)`, `caseta_bomba (4,2)`, `patio_cosecha (3,3)`, `pasarela_vina (4,3)`. El mapa no tiene que reflejar distancias exactas; sí rutas y cierres.

## 9. Enemigos y recursos: balance

### Enemigos por sala
- `bridge`: conservar infectado común y el que yace; no agregar otro rápido.
- `checkpoint`: conservar soldados con casco y el infectado que se alimenta; no convertir el control en combate obligatorio.
- `station`: conservar alimentándose y el que yace; no añadir enemigo en la sala de guardado.
- `warehouse`: conservar dos rápidos y cadáver; su ruta de evasión sigue abierta.
- `field`: exploración con infectados dispersos; ninguno bloquea las tres salidas. El eco de la criatura no combate.
- `vineyard`: conservar infectados existentes; ruta central transitable.
- `shed`: sala segura, sin enemigo; Rosa sigue detrás de la puerta.
- `canal_riego`: máximo un común, evitable.
- `caseta_bomba`: un infectado alimentándose opcional, sin bloquear el panel.
- `patio_cosecha`: un común que puede distraerse con el carro.
- `pasarela_vina`: sin enemigo obligatorio; tensión por altura y vista.

### Economía
La versión actual tiene, como referencia, munición distribuida en puente/control/potrero/estación/bodega/viña/galpón (rifle, 9 mm, cartuchos y granadas) y curaciones en pickups existentes. **Este diseño no aumenta el total base**: reubicar o mover a contenedores los recursos actuales; cualquier premio de regreso se descuenta de otro pickup del mismo tipo. No se añade arma ni cura garantizada nueva. El límite duro es **≤ +30 % por tipo de munición y curación**, incluyendo contenedores. No aumentar el número de enemigos para justificar recursos.

Duración objetivo: **25–35 min** primera partida con AYUDA; 35–45 min sin AYUDA. No se puede terminar corriendo: el capítulo requiere tres sellos de alas diferentes, registrar el mapa, resolver al menos la ruta de batería y volver al galpón para el diálogo de Rosa y la radio.

## 10. Textos exactos de notas y documentos nuevos

Los documentos oficiales no tutean. Cada página se mantiene por debajo de ~350 caracteres. Se conservan sin reescribir `military_order`, `evacuee_list` y `worker_letter`.

### Documento 1 — Registro del control (`buin_control_register`, checkpoint)
«CONTROL SANITARIO BUIN — Viernes, 21:00. El acceso al patio queda habilitado cuando el parte de traslado está registrado y la barrera vuelve a posición de cierre. La carpeta de servicio se abre con la hora del aviso. — Control militar»

### Documento 2 — Plano del riego (`buin_irrigation_plan`, canal_riego)
«CANAL DE RIEGO — El registro bajo queda junto a la compuerta norte. Para vaciarlo, conecte manguera y abrazadera antes de abrir el desagüe. La pasarela alta conduce a la caseta de bombas. — Mantención»

### Documento 3 — Bitácora de bomba (`buin_pump_log`, caseta_bomba)
«Sábado, 6:20. La presión no baja si se acciona primero la bomba. Orden de servicio: retorno, canal, bomba. Cuando el manómetro quede estable, registrar la batería de radio del gabinete. — Mantención»

### Documento 4 — Manifiesto de cosecha (`buin_harvest_manifest`, patio_cosecha)
«VIÑA SANTA ROSA — Carga de vendimia. El carro debe quedar sobre la marca doble para liberar el portón de retorno. Las cajas del fondo se registran después de despejar la plataforma. No bloquear el paso al galpón.»

### Documento 5 — Etiqueta de batería (`buin_radio_battery_note`, caseta_bomba)
«RADIO PORTÁTIL — Batería de servicio: 12 V. Revisar polaridad antes de instalar. No forzar los contactos. La radio de enlace quedó en el galpón de la viña; la batería no debe retirarse hasta estabilizar la bomba. — Comunicaciones»

### Documento 6 — Nota del turno de viña (`buin_vineyard_shift_note`, pasarela_vina)
«Sábado, 6:35. El pestillo de retorno se traba desde el lado del galpón. La barra solo se alcanza desde la pasarela de mantenimiento. La llave del galpón está en la bodega, dentro del compartimento del tractor.»

### Eco ambiental (sin documento)
En el borde del potrero: «Una silueta demasiado alta, inmóvil entre los árboles. Leo se eriza. Cuando Isabella apunta, desaparece. En el barro queda una huella enorme; dos ramas están quebradas a una altura imposible». Sin nombre, sin cuerpo completo, sin cinemática.

## 11. Cámaras y aspecto — propuesta para Claude

No se fijan cámaras definitivas; Claude elige y renderiza. **Mínimo 2 cámaras por sala**, más en salas grandes. Cada encuadre debe cubrir la llegada, el personaje completo y el interactuable de avance.

| Sala | Propuesta de cobertura |
|---|---|
| `bridge` | Mantener el eje longitudinal del puente; que se lean la salida al control y el río, sin perder a Isabella. |
| `checkpoint` | General de barrera/camión y encuadre interior de carpa/carpeta; cubrir la escalera de observación. |
| `station` | General del hall y plano del archivador/mapa; cubrir las tres puertas del hub y máquina de escribir. |
| `warehouse` | Entrada hacia tractor y carta; contraplano de compartimento y escalera al mezzanine. |
| `field` | Tres encuadres de salida (viña, bodega, canal) y plano del eco/huella que nunca revele el cuerpo. |
| `vineyard` | Eje entre parras hacia el galpón; contraplano de llave/puerta y salida a pasarela. |
| `shed` | General de barricas/radio y encuadre de `RosaDoor`; no mostrar el interior de la oficina. |
| `canal_riego` | Plano largo del canal, cámara de rejilla y vista elevada desde pasarela. |
| `caseta_bomba` | Plano de válvulas/manómetro y cámara del gabinete de batería; que se lea la escalera. |
| `patio_cosecha` | General del carro/plataforma y contraplano del atajo hacia el galpón. |
| `pasarela_vina` | Cámara que muestra la altura, baranda, pestillo y vista al potrero/viña; evitar que el personaje quede fuera de cobertura. |

Todas las salas nuevas o rehechas deben alcanzar el estándar de `docs/ESTANDAR_DETALLE.md`: ≥150 nodos, ≥40 props, ≥14 tipos, ≥15 decals y ≥2 cámaras; añadir sus IDs a `tools/detail_rooms.json` en implementación. Claude decide los fondos prerenderizados.

## 12. Variante cooperativa

El capítulo sigue siendo completamente resoluble en solo.

- En el control, una persona lee `military_order` y la otra el reloj; en solo ambas pistas son accesibles sin simultaneidad.
- En el canal, un jugador sigue el flujo y otro prepara la manguera; en solo se registra cada componente y se combina.
- En la caseta, se pueden repartir válvulas; en solo se accionan una a una con feedback claro.
- En el patio, ambos pueden empujar el carro; en solo el movimiento es lento, no exige fuerza ni tiempo límite.
- Ignacia no altera el canon individual ni reemplaza a Leo. Sus líneas nuevas no mencionan animales eliminados; sus observaciones se limitan a la barrera, la altura de la silueta y el ruido de la bomba.
- No se exige dos jugadores, dos teléfonos ni simultaneidad para abrir la radio o terminar el capítulo.

## 13. Tabla de no linealidad y checklist

| Requisito | Evidencia / prueba de diseño |
|---|---|
| Hub + 3 alas | `station`; A control, B agricultura/Rosa, C riego/radio. |
| Tres sellos independientes | `buin:control_clear`, `buin:rosa_found`, `buin:radio_power`; cada ala contiene todas sus pistas y objetos. |
| Orden A→B→C | Desde `station`: control → bodega/viña/Rosa → canal/bomba → radio. |
| Orden C→B→A | Desde `station`: canal/bomba → bodega/viña/Rosa → control → radio. |
| Dos rutas por objetivo | A: directa por `ToCheckpoint` o perímetro rural por `field → door_field_checkpoint`. B: peligrosa `warehouse → field → vineyard`; larga `warehouse → patio → pasarela → vineyard`. C: directa `field → canal`; alta `pasarela → canal`. |
| Dos bucles | `station → warehouse → field → station`; `warehouse → patio → pasarela → vineyard → field → warehouse`. |
| Dos atajos de un solo lado | `door_shortcut_pump_station`; `door_shortcut_patio_shed`. Ambos abren desde el lado contrario. |
| ≥3 áreas que se abren al volver | Armario del control; cajón de estación; caja de bodega; estuche de viña. |
| ≥2 opcionales con recompensa | Patio de cosecha (recurso ya contabilizado); pasarela (nota y recurso reubicado); estuche de viña (nota opcional). |
| Mapa al principio | `map_buin` en contenedor de `station`, antes de completar sellos. |
| Llaves/objetos clave en contenedores | `shed_key` en compartimento del tractor; batería en gabinete; mapa en archivador. |
| Potrero según canon | Exploración; salidas a viña, bodega y canal; eco alto, huella, ramas; no escena guionada. |
| Duración y balance | 25–35 min con ayuda; recursos base conservados, aumento ≤30 %. |
| Detalle/verticalidad | 11 salas; 6 con recorrido vertical; prueba de subida/descenso segura por Claude. |
| Alcanzabilidad | Simular ambas órdenes de sellos y verificar cada llave antes de la cerradura; ninguna ala depende de otra. |

### Preguntas

1. **[CONFIRMAR]** El actual `shed_key` se recoge del tractor como pickup. Propongo conservar el ID de objeto y mover su interacción a REGISTRAR dentro del compartimento, para cumplir el contrato de objetos clave.
2. **[CONFIRMAR]** Propongo `station` como hub porque ya conecta con control, bodega y potrero; si Claude detecta que una puerta existente no puede conservarse como se indica, debe mantener su ID y añadir una conexión nueva, no cambiar el destino de guardado.
3. **[CONFIRMAR]** El sello B se activa al hablar con Rosa a través de la puerta; no se abre la oficina ni se resuelve qué es ella.
4. **[CONFIRMAR]** La radio requiere batería 12 V además de los tres flags; la batería no consume hasta que se confirma la interacción final.
5. El archivo actual `docs/zonas/cap1_estacion.md` no contiene una sección de revisión/implementación de Claude. Se tomó como referencia el contrato y las correcciones explícitas de `cap2_vias.md`; Claude debe confirmar si hay otro documento de revisión de P15.

**Qué debe revisar Claude:** IDs y destinos de puertas/spawns existentes; compatibilidad de las conexiones nuevas con `buin_common`; independencia real de los tres sellos; accesibilidad del mapa al principio; altura/colisión de las seis rutas verticales; que el potrero tenga tres salidas jugables; texto y orden temporal de Rosa/Paz; recursos totales comparados con los generadores actuales; lista de documentos y flags antes de implementar.
