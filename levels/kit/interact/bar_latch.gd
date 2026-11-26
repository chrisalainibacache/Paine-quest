class_name BarLatch
extends Interactable
## Retira una barra caída que bloquea un paso; no consume llave.

@export var lock_id: String = "station_latch_removed"

func _init() -> void:
    prompt = "RETIRAR BARRA"
    reach = 1.3


func can_interact() -> bool:
    return not lock_id.strip_edges().is_empty() and not GameState.has_flag("unlocked:" + lock_id)


func interact(_player: Player) -> void:
    var flag_name: String = "unlocked:" + lock_id
    if GameState.has_flag(flag_name):
        await Dialogue.say(["La barra ya está apartada."])
        return
    GameState.set_flag(flag_name)
    Sfx.play("unlock", global_position, -5.0)
    await Dialogue.say(["Aparté la barra caída. El paso entre el pasillo y la bodega queda libre desde ambos lados."])
