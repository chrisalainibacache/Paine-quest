# Arquitectura

## Principios

1. **Una escena por cosa.** Jugador, infectado, Leo, cada sala, cada pantalla de UI
   es su propia escena (`.tscn`) con su script al lado.
2. **Escenas armadas en el editor, no en código.** Las salas se construyen con piezas
   modulares colocadas a mano. El código solo agrega comportamiento.
3. **Datos fuera del código.** Armas, ítems, enemigos y diálogos son recursos `.tres`
   en `data/`. Cambiar el daño de la pistola no requiere tocar scripts.
4. **Sistemas globales pequeños (autoloads)** que se comunican por señales.
5. **Nombres por función, nunca por versión.** Nada de `V68Game.gd`: el historial está en git.
6. **Scripts cortos.** Si un script pasa de ~300 líneas, se divide.

## Carpetas

```
res://
├─ assets/          Archivos importados tal cual (no se editan a mano)
│  ├─ characters/   Cony, Leo, infectados + animaciones
│  ├─ environment/  Kits modulares de cada zona (estación, tren, fábrica, mina)
│  ├─ props/        Barriles, cajas, señales, vehículos
│  ├─ weapons/      Modelos de armas
│  ├─ ui/           Íconos, fuentes de la interfaz, texturas de botones
│  ├─ audio/        Música, efectos, ambientes
│  ├─ fonts/
│  └─ vfx/
├─ actors/          Cosas vivas (escena + script juntos)
│  ├─ player/       Cony: movimiento, combate, animación
│  ├─ enemies/      Infectado, jefe
│  └─ companion/    Leo
├─ levels/          Una carpeta por zona; una escena por sala
│  ├─ kit/          Piezas modulares (KitBlock, vías, CameraZone, Room, interact/, items/, props/)
│  ├─ station/      Capítulo 1: platform.tscn, waiting_room.tscn, ...
│  └─ tracks/       Capítulo 2: vías y tren destruido
├─ systems/         Autoloads (ver abajo)
├─ ui/              hud/, inventory/, dialogue/, title/, theme/
├─ data/            Recursos .tres: items/, weapons/, enemies/, documents/
├─ shaders/         Filtro PS1, materiales especiales
├─ tests/           Pruebas automáticas (headless)
├─ tools/           Scripts de apoyo (export, importación)
└─ docs/            GDD, arquitectura, assets, convenciones
```

## Sistemas globales (systems/)

Los scripts que corren con `godot -s` (pruebas) no ven los autoloads al compilar, así
que el estado global es **estático** (`class_name` + `static var/func`) y los nodos que
necesitan el árbol registran su instancia al iniciar.

| Pieza | Tipo | Responsabilidad |
| --- | --- | --- |
| `InputSetup` | autoload | Registra las acciones (`move_*`, `aim`, `fire`, `interact`, `inventory`). |
| `Sfx` (`SfxPlayer`) | autoload + `Sfx.play()` estático | Efectos sintetizados con pool de reproductores. |
| `GameState` | estático | Mochila, arma equipada, notas, banderas, salud, cargador, sala actual. |
| `Inventory` | clase | 8 casillas con apilado; se serializa a rutas de recursos. |
| `SaveSystem` | estático | Guarda/carga `GameState` en `user://partida.json` (una ranura). |
| `SceneLoader` | nodo en `Main` | Cambia de sala: fundido, descarga, instancia, ubica a Cony y Leo, elige cámara. |
| `Dialogue` | escena en `Main` | Mensajes, preguntas (`ask`) y lector de documentos. Pausa el juego. |
| `InventoryMenu` | escena en `Main` | Mochila: casillas 3D, estado, usar/equipar/examinar, NOTAS. |

## Piezas reutilizables de una sala

| Nodo/escena | Uso |
| --- | --- |
| `Room` (script base) | Raíz de cada sala. Cámaras fijas y puntos de aparición (`Spawns/<id>`). |
| `CameraZone` | Area3D + Camera3D fija. Corte de cámara al entrar. |
| `Interactable` | Base de todo lo que usa el botón ACCIÓN (`prompt`, `reach`, `interact()`). |
| `Door` | Lleva a otra sala (`target_room`, `target_spawn`); puede pedir llave (`key_item`, `lock_id`). |
| `Pickup` | Ítem en el suelo (`ItemData` + cantidad) con brillo; se recuerda al recogerlo. |
| `note.gd` | Documento legible (`DocumentData`). |
| `examine_spot.gd` | Objeto que solo muestra mensajes. |
| `typewriter.gd` | Guardar partida. |
| `chapter_exit.gd` | Salida que cierra un capítulo (pregunta antes; `SceneLoader.end_chapter`). |
| `flicker_light.gd` | OmniLight3D que parpadea de vez en cuando. |
| `props/decal.tscn` | Calcomanía (grafiti, sangre, hoyo, mancha) en un QuadMesh pegado al muro o al piso (shader `decal`, con `wear` para pintura gastada). |
| `Infected` | `start_state` idle / feeding / lying / corpse; `requires_flag` lo hace aparecer según el progreso. |

### Pruebas

- `tests/smoke_test.gd`: movimiento, cámaras, Leo y combate.
- `tests/systems_test.gd`: mochila, recoger, notas, puertas, guardado, recorrido del capítulo.
- `tests/levels_test.gd`: revisa **todas** las salas de `levels/station/` (puertas y apariciones
  conectadas, Cony aparece sobre el piso y dentro de una cámara, ninguna cámara ve huecos, el
  capítulo se puede terminar). Una sala nueva queda cubierta solo por existir en la carpeta.

Cada sala se arma en `levels/<zona>/` con nodos `Interactables`, `Enemies`, `Cameras`
y `Spawns`. Las banderas de progreso usan `GameState.node_key(nodo)` =
`"<archivo de la sala>:<ruta del nodo>"`, así que **no renombres nodos de ítems o
infectados en salas ya publicadas** (se perdería lo guardado).

## Flujo de una sala

1. Una `Door` llama `SceneLoader.go_to(sala, spawn)` (sin esperar: la puerta se borra con su sala).
2. Fundido a negro; Cony queda sin controles.
3. Se saca la sala anterior del árbol; se instancia la nueva. Infectados y pickups
   consultan `GameState` en su `_ready` (muertos / ya recogidos).
4. Cony y Leo se ubican en `Spawns/<spawn>`; se elige la `CameraZone` que contiene a Cony.
5. Fundido de entrada y vuelven los controles.

## Convenciones de código

- GDScript con tipos estáticos (`var speed: float = 3.0`).
- `snake_case` para archivos, funciones y variables; `PascalCase` para `class_name` y nodos.
- `class_name` solo en clases reutilizables de verdad (`Room`, `Door`, `ItemData`...).
- Comentarios en español, breves, explicando el *por qué*.
- Indentación con 4 espacios (sin tabs).
