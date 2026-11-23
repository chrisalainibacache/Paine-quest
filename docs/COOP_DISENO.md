# Diseño cooperativo por Wi‑Fi (P9-a)

Estado: diseño técnico inicial; no habilita todavía el juego compartido. El modo cooperativo se activa explícitamente y solo entonces se cargan las líneas de Ignacia. La partida individual conserva el flujo actual.

## 1. Objetivo y límites

- Dos teléfonos Android en la misma red Wi‑Fi y la misma APK.
- Un anfitrión (peer 1) controla a Isabella y es la autoridad de simulación.
- Un invitado controla a Ignacia. El invitado transmite intención/entrada; el anfitrión valida y publica el estado resultante.
- Ambos permanececen en la misma sala, con el mismo progreso, inventario y eventos narrativos.
- Puerto UDP de juego: **7777**. Descubrimiento LAN por broadcast UDP separado; conexión manual por IP siempre disponible.
- No es multijugador por Internet: no se promete atravesar NAT, redes móviles ni routers que bloqueen broadcast/UDP. El router puede tener aislamiento de clientes activado; en ese caso se usa IP manual o se cambia la configuración de la Wi‑Fi.
- No se cambia la estructura de salas ni se modifica `levels/**` en P9.

## 2. Autoridad y responsabilidades

| Dominio | Autoridad | Comportamiento |
| --- | --- | --- |
| Crear/cargar partida y guardado | Anfitrión | Solo el anfitrión llama `GameState.new_game()`, `SaveSystem.load_game()` y `SaveSystem.save_game()`. El invitado no escribe un guardado independiente. |
| Movimiento de Isabella | Anfitrión simula; cliente envía entrada | El anfitrión valida el estado y transmite snapshots. |
| Movimiento de Ignacia | Invitado propone entrada; anfitrión simula | El anfitrión limita frecuencia, magnitud y velocidad; no acepta posición arbitraria como verdad. |
| Infectados, IA, detección, daño | Anfitrión | Solo el anfitrión ejecuta decisiones de IA y aplica `Infected.take_hit(...)` / `Player.take_damage(...)`. |
| Disparos | Invitado solicita; anfitrión valida | El anfitrión valida arma, munición, cadencia, origen y dirección antes de aplicar daño. |
| Puertas y transición de sala | Anfitrión | El anfitrión decide destino/spawn y ordena el cambio a ambos clientes. |
| Inventario, curas, objetos y banderas | Anfitrión | Operaciones atómicas en un único estado compartido; el cliente solicita, nunca escribe directamente. |
| Diálogos y cinemáticas | Anfitrión inicia; ambos reproducen | El anfitrión emite evento + identificador; ambos bloquean controles y avanzan sincronizados. |
| Cámara y presentación | Cada teléfono | Cada cliente selecciona su cámara local con el mismo jugador/sala; no se transmite la cámara. |

**Regla antitrampas/consistencia:** los RPC del invitado son solicitudes, no órdenes. El anfitrión verifica autoridad, sala, distancia, estado del jugador, cooldown y recursos antes de mutar el estado.

## 3. Estado que se sincroniza

Frecuencia objetivo de movimiento: **15 snapshots/s** (intervalo ≈ 66,7 ms). El receptor interpola entre los dos snapshots más recientes; no teletransporta cada paquete. Los eventos discretos son fiables.

| Datos | Frecuencia / canal | Campos mínimos |
| --- | --- | --- |
| Transform y animación de ambos jugadores | 15 Hz, no fiable y ordenado | `peer_id`, `sequence`, `room_id`, `position`, `yaw`, `velocity`, `animation`, `health`, `alive` |
| Entrada del invitado | 15–30 Hz, no fiable y ordenado | `sequence`, `move`, `aim`, `fire`, `interact`; nunca una posición final autoritativa |
| Disparo / impacto / daño | fiable | `event_id`, `actor_id`, `weapon_id`, `origin`, `direction`, `target_id`, `damage`, `health_after` |
| Infectados | snapshots 10–15 Hz no fiables; aparición/muerte fiable | `net_id`, `room_id`, `position`, `yaw`, `state`, `health`, `alive` |
| Objetos recogidos, puertas, banderas | fiable | `event_id`, `node_key`/ `lock_id`, `operation`, `value` |
| Inventario compartido | fiable, tras cada operación confirmada | lista serializada de ítem/cantidad, arma equipada, cargador |
| Diálogo / cinemática | fiable | `event_id`, `dialogue_id` o `cinematic_id`, `start_tick`, `room_id` |
| Ping y señal | ping/pong fiable; señal fiable | `nonce`, `sent_msec`; señal: `event_id`, `tone_id` |

Cada mensaje lleva versión de protocolo y límite de tamaño. Rechazar paquetes malformados, versiones incompatibles, campos desconocidos críticos y secuencias repetidas. El transporte ENet ya ofrece canales; separar entrada/snapshots de eventos fiables evita que un diálogo bloquee el movimiento.

## 4. Contrato de mensajes

| Nombre lógico | Dirección | Fiabilidad | Campos |
| --- | --- | --- | --- |
| `hello` | invitado → anfitrión | fiable | `protocol_version`, `display_name`, `role=ignacia` |
| `welcome` | anfitrión → invitado | fiable | `protocol_version`, `host_name`, `guest_name`, `room_id`, `session_id` |
| `input` | invitado → anfitrión | no fiable/ordenado | `sequence`, `move`, `aim`, `actions` |
| `snapshot` | anfitrión → invitado | no fiable/ordenado | `sequence`, `server_tick`, `players`, `enemies` |
| `event` | anfitrión → invitado | fiable | `event_id`, `kind`, `payload` |
| `request` | invitado → anfitrión | fiable | `request_id`, `kind`, `payload` |
| `request_result` | anfitrión → invitado | fiable | `request_id`, `accepted`, `reason`, `state_delta` |
| `ping` / `pong` | ambos sentidos | fiable | `nonce`, `sent_msec` |
| `signal` | cualquiera → otro | fiable | `event_id`, `tone_id` |
| `room_prepare` / `room_commit` | anfitrión → invitado | fiable | `transition_id`, `room_path`, `spawn_id`, `server_tick` |

En P9-b, `net_messages.gd` será un codec puro que valida diccionarios y campos. No usar `var x := decode()` si el retorno es Variant: declarar el tipo explícito y comprobar el tipo antes de convertir.

## 5. Descubrimiento LAN y conexión

1. El anfitrión crea ENet en UDP/7777 y publica un anuncio UDP con versión, nombre de partida, nombre de anfitrión, IP local y puerto.
2. El invitado escucha anuncios en la LAN y muestra una lista. El anuncio es solo descubrimiento; no concede acceso.
3. El invitado conecta por ENet a la IP y puerto anunciados. La conexión manual permite escribir IPv4 cuando el broadcast está filtrado.
4. El anfitrión acepta un solo invitado, valida `hello` y protocolo, y responde `welcome`. No se permite un tercer peer.
5. Mostrar dirección IPv4 local del anfitrión, pero no afirmar que una IP es accesible antes de completar ENet.

**Hipótesis por validar en dos Android reales:** broadcast UDP puede variar según router, permisos y versión Android; el envío desde una app puede requerir revisar permisos de red local en el manifiesto de exportación. No se debe tocar `export_presets.cfg` ni afirmar compatibilidad móvil completa hasta probarlo. La conexión manual es el respaldo funcional.

## 6. Transición de sala y desconexión

- El anfitrión inicia `room_prepare`, bloquea entradas y espera ACK del invitado con timeout corto (3 s). Luego cambia su escena y envía `room_commit`; el invitado instancia exactamente `room_path` y `spawn_id`.
- Ambos conservan el mismo `GameState.room_path`; una divergencia de sala fuerza reconexión de estado completo o cancela la transición.
- Si el invitado se desconecta: el anfitrión pausa la simulación cooperativa y ofrece «ESPERANDO A IGNACIA» / «VOLVER AL TÍTULO». No convertir silenciosamente la sesión a individual.
- Reconexión: token aleatorio de sesión + estado completo versionado. El anfitrión decide si acepta la reconexión y reenvía sala, spawn, transformaciones, salud, inventario, banderas, puertas, documentos y enemigos. Token inválido o sesión terminada: rechazar.
- Si el anfitrión se desconecta, la sesión termina; no hay migración de host en esta versión.
- Timeout de latido (hipótesis inicial: 8 s) libera la sesión y notifica a ambos.

## 7. Código individual que debe adaptarse después de P9

| Archivo | Funciones/estado real observado | Cambio mínimo propuesto |
| --- | --- | --- |
| `systems/game_state.gd` | `new_game()`, `set_flag()`, `has_flag()`, `to_data()`, `from_data()`; estado estático de mochila, salud, sala y banderas | Añadir bandera booleana cooperativa por defecto falsa; después, separar autoridad y serialización de snapshot. No mezclar datos de red con el guardado local. |
| `systems/scene_loader.gd` | `setup()`, `go_to()`, `_go_to()`, `_place_room()`, `enter_first_room()`, `_end_chapter()` | En hito posterior, que solo el host decida destino; introducir transición preparada/confirmada para los dos y ubicar ambos jugadores. |
| `actors/player/player.gd` | `_physics_process()`, `take_damage()`, `heal()`, `is_alive()`, `set_camera()` | Separar lectura de input, simulación y presentación; instanciar un Player por peer, dueño de input local y réplica remota interpolada. |
| `actors/enemies/infected.gd` | `_physics_process()`, `take_hit()`, `_die()`, `_can_see_target()` | Ejecutar IA/daño solo en host; replicar transform/estado y eventos. No ejecutar IA duplicada en invitado. |
| `actors/companion/leo.gd` | `_physics_process()`, `_update_guide()`, `active_hint()`, `explain()` | Mantener una sola instancia narrativa; pistas visibles para ambos. Solo Isabella oye voz de Leo; Ignacia no recibe voz. |
| `levels/kit/interact/door.gd` | `interact(_player)`, `is_locked()`, `_lock_key()` | En futuro, la interacción del invitado se convierte en solicitud; host valida llave/bandera y ordena transición. **No editar salas en P9.** |
| `systems/save_system.gd` | `save_game()`, `load_game()`, `has_save()` | Solo host guarda/carga; un único archivo de progreso compartido. |
| `systems/inventory.gd` | `add()`, `take()`, `remove_at()`, `to_data()`, `from_data()` | Host serializa y confirma operaciones; UI del invitado muestra el mismo inventario. |
| `ui/dialogue/dialogue.gd` | `say()`, `ask()`, `read()`, `advance()` | Host inicia diálogos; ambos reciben el mismo identificador y sincronizan avance/respuestas. |
| `systems/audio_director.gd` / `systems/sfx.gd` | `play_music()`, `Sfx.play()` | Audio local en cada teléfono; eventos remotos disparan SFX local, no se transmite audio. |
| `ui/title/title_screen.gd` | `_ready()`, `_new_game()`, `_continue()` | Añadir entrada al menú de prueba; no cambiar el flujo individual. |

Los nombres de funciones anteriores se comprobaron en los scripts de la rama principal al redactar este documento. Las políticas de sincronización son diseño, no código ya implementado.

## 8. Hitos de implementación (cada uno jugable y con prueba)

1. **Conexión LAN (P9):** host/invitado, descubrimiento + IP manual, ping y señal. Prueba de codec, validación, menú, conexión local y dos Android.
2. **Doble avatar en sala segura:** dos personajes visibles, propietario de input, snapshots/interpolación. Prueba de movimiento simultáneo sin salas nuevas.
3. **Combate autoritativo:** input de disparo, daño, enemigos replicados y muerte. Prueba de munición/cadencia y un único daño aplicado.
4. **Estado compartido:** objetos, inventario, curas, puertas y banderas. Prueba de recogida/puerta vista igual en ambos.
5. **Guion cooperativo:** diálogos, pistas de Leo, cinemáticas y datos de Ignacia. Prueba de individual sin líneas y coop con líneas sincronizadas.
6. **Robustez móvil:** transición de sala, reconexión, pausa, latencia y desconexión. Prueba prolongada en dos Android y export APK.

## 9. Riesgos y decisiones pendientes

- **Riesgo alto:** el juego actual instancia un único `World/Player`; P9 solo deja lista la capa de red y un menú de prueba. No significa que dos personajes puedan jugar juntos todavía.
- **Riesgo alto:** el guardado actual es de una ranura; el guardado compartido requiere que solo el anfitrión escriba.
- **Riesgo medio:** Android puede filtrar broadcast o tráfico entre clientes; verificar en el router y en teléfonos físicos.
- **Riesgo medio:** snapshots 15 Hz son objetivo inicial; medir ancho de banda y jitter antes de fijar frecuencia.
- **[CONFIRMAR en prueba]:** nombres mostrados por defecto («Isabella» / «Ignacia») y si el anfitrión puede cambiar el alias.
- **Fuera de alcance P9:** sincronizar gameplay, adaptar salas, integrar líneas de Ignacia en interacciones y habilitar Internet público.
