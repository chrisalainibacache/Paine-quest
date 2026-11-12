extends Interactable
## Puerta cerrada con alguien adentro que habla (Rosa en el galpón). La primera
## vez dice todo y deja una bandera; después, una línea corta.

@export var lines: PackedStringArray = []
@export var repeat_lines: PackedStringArray = []
@export var sets_flag: String = ""


func _init() -> void:
    prompt = "LLAMAR"


func interact(_player: Player) -> void:
    Sfx.play("door", global_position, -14.0)
    var first := sets_flag.is_empty() or not GameState.has_flag(sets_flag)
    await Dialogue.say(Array(lines if first or repeat_lines.is_empty() else repeat_lines))
    if not sets_flag.is_empty():
        GameState.set_flag(sets_flag)
