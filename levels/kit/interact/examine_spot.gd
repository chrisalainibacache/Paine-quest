extends Interactable
## Objeto que solo se examina: muestra uno o más mensajes.

@export_multiline var lines: PackedStringArray = []


func _init() -> void:
    # Cerca de una nota, un ítem o una puerta, esos mandan sobre "examinar".
    focus_penalty = 0.7


func interact(_player: Player) -> void:
    await Dialogue.say(lines)
