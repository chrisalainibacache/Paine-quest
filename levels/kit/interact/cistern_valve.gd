class_name CisternValve
extends Interactable
## Válvula ambiental que debe cerrarse antes de registrar la cisterna.

@export var puzzle_id: String = "station_cistern"

func _init() -> void:
    prompt = "CERRAR VÁLVULA"
    reach = 1.2


func can_interact() -> bool:
    return not puzzle_id.strip_edges().is_empty()


func interact(_player: Player) -> void:
    var closed_flag: String = "puzzle:" + puzzle_id + ":valve_closed"
    if GameState.has_flag(closed_flag):
        await Dialogue.say(["La válvula ya está cerrada."])
        return
    GameState.set_flag(closed_flag)
    Sfx.play("unlock", global_position, -6.0)
    await Dialogue.say(["Cerré la llave de paso. El agua dejó de correr. Ahora puedo registrar la cisterna."])
