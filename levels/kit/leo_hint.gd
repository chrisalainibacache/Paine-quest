extends Marker3D
## Pista de Leo. Mientras esté activa, Leo mira y maúlla hacia este lugar;
## tras 40 s sin progreso usa la segunda línea vaga; la tercera es AYUDA explícita.
## La primera línea queda por compatibilidad con datos antiguos y no se muestra.

## Frases por nivel (cada línea empieza con "Leo: ").
@export var lines: PackedStringArray = []
## Solo si existe esta bandera (p. ej. "found:pistol").
@export var show_if_flag: String = ""
## Ya no hace falta cuando existe esta bandera (p. ej. "unlocked:gate_south").
@export var hide_if_flag: String = ""
## Solo si Isabella lleva este ítem en la mochila.
@export var show_if_item: String = ""
## Ya no hace falta cuando Isabella lleva este ítem.
@export var hide_if_item: String = ""


func _ready() -> void:
    add_to_group("leo_hints")


func is_active() -> bool:
    if not show_if_flag.is_empty() and not GameState.has_flag(show_if_flag):
        return false
    if not hide_if_flag.is_empty() and GameState.has_flag(hide_if_flag):
        return false
    if not show_if_item.is_empty() and not GameState.inventory.has_id(show_if_item):
        return false
    if not hide_if_item.is_empty() and GameState.inventory.has_id(hide_if_item):
        return false
    return true


func heard_flag() -> String:
    return "leo:%s:%s" % [GameState.room_path.get_file().get_basename(), name]


func was_heard() -> bool:
    return GameState.has_flag(heard_flag())



## Nivel 1: señal no verbal. No se muestra ninguna línea de texto.
func look_flag() -> String:
    return "leo:n1:%s:%s" % [GameState.room_path.get_file().get_basename(), name]


func was_looked() -> bool:
    return GameState.has_flag(look_flag())


## Nivel 2: segunda línea, deliberadamente vaga, tras 40 segundos sin progreso.
func vague_line_text() -> String:
    return lines[1].trim_prefix("Leo: ") if lines.size() >= 2 else ""


func vague_flag() -> String:
    return "leo:n2:%s:%s" % [GameState.room_path.get_file().get_basename(), name]


func was_vague() -> bool:
    return GameState.has_flag(vague_flag())


## Nivel 3: tercera línea, explícita, solo cuando se pulsa AYUDA.
func explicit_line_text() -> String:
    return lines[2].trim_prefix("Leo: ") if lines.size() >= 3 else ""


func has_explicit_help() -> bool:
    return not explicit_line_text().is_empty()
