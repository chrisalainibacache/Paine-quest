extends Interactable
## Objeto que solo se examina: muestra uno o más mensajes.

@export_multiline var lines: PackedStringArray = []


func interact(_player: Player) -> void:
    await Dialogue.say(lines)
