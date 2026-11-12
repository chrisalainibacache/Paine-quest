extends Marker3D
## Pista de Leo: un lugar al que Leo lleva a Cony cuando no sabe por dónde
## seguir, y lo que Leo le explica al llegar. Leo la usa mientras esté activa
## (según banderas e ítems de la mochila). Lo que dice se oye una sola vez.

## Lo que dice Leo (cada línea empieza con "Leo: ").
@export var lines: PackedStringArray = []
## Solo si existe esta bandera (p. ej. "found:pistol").
@export var show_if_flag: String = ""
## Ya no hace falta cuando existe esta bandera (p. ej. "unlocked:gate_south").
@export var hide_if_flag: String = ""
## Solo si Cony lleva este ítem en la mochila.
@export var show_if_item: String = ""
## Ya no hace falta cuando Cony lleva este ítem.
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
