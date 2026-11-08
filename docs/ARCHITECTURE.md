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
│  └─ station/      platform.tscn, waiting_room.tscn, ...
├─ systems/         Autoloads (ver abajo)
├─ ui/              hud/, inventory/, menus/, reader/
├─ data/            Recursos .tres: items/, weapons/, enemies/, dialogue/
├─ shaders/         Filtro PS1, materiales especiales
├─ tests/           Pruebas automáticas (headless)
├─ tools/           Scripts de apoyo (export, importación)
└─ docs/            GDD, arquitectura, assets, convenciones
```

## Autoloads (systems/)

| Autoload | Responsabilidad |
| --- | --- |
| `Events` | Bus de señales globales (`item_picked`, `door_used`, `player_died`, ...). |
| `GameState` | Banderas de historia, inventario, salud, sala actual. Fuente única de verdad del progreso. |
| `SaveSystem` | Serializa `GameState` a `user://` (máquina de escribir y puntos de control). |
| `SceneLoader` | Cambia de sala: fundido, carga en segundo plano, coloca a Cony en el `SpawnPoint` indicado. |
| `AudioManager` | Música, ambiente por zona y efectos con pool de reproductores. |
| `Dialogue` | Muestra diálogos y documentos; pausa el juego cuando corresponde. |

## Piezas reutilizables de una sala

| Nodo/escena | Uso |
| --- | --- |
| `Room` (script base) | Raíz de cada sala. Declara zona, música y ambiente. |
| `CameraZone` | Area3D + Camera3D fija (o en riel). Corte de cámara al entrar. |
| `Door` | Lleva a otra sala (`target_room`, `target_spawn`), puede pedir llave. |
| `SpawnPoint` | Dónde aparece Cony al entrar desde una puerta concreta. |
| `Pickup` | Ítem en el suelo (referencia a un `ItemData`). |
| `Interactable` | Examinar objetos, notas, máquina de escribir. |
| `EnemySpawn` | Infectado que aparece según banderas de `GameState`. |

## Flujo de una sala

1. `SceneLoader.go_to(room_path, spawn_id)` → fundido a negro.
2. Se libera la sala anterior; se instancia la nueva.
3. Cony se coloca en el `SpawnPoint` con ese `spawn_id`.
4. La `CameraZone` que contiene a Cony se activa.
5. Fundido de entrada. `Events.room_entered` se emite.

## Convenciones de código

- GDScript con tipos estáticos (`var speed: float = 3.0`).
- `snake_case` para archivos, funciones y variables; `PascalCase` para `class_name` y nodos.
- `class_name` solo en clases reutilizables de verdad (`Room`, `Door`, `ItemData`...).
- Comentarios en español, breves, explicando el *por qué*.
- Indentación con 4 espacios (sin tabs).
