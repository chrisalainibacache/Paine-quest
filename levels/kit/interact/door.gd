class_name Door
extends Interactable
## Puerta a otra sala. Puede pedir una llave (se abre una vez y queda abierta
## para siempre, de los dos lados si comparten `lock_id`). Sin `target_room`
## es una puerta que no se puede usar (solo muestra `locked_text`).

@export_file("*.tscn") var target_room: String = ""
@export var target_spawn: String = ""
## Llave necesaria (vacío = no tiene llave).
@export var key_item: ItemData
## Identificador compartido por los dos lados de la puerta.
@export var lock_id: String = ""
@export_multiline var locked_text: String = "Está cerrada con llave."


func _init() -> void:
    prompt = "ABRIR"


func is_locked() -> bool:
    return key_item != null and not GameState.has_flag("unlocked:" + _lock_key())


func interact(_player: Player) -> void:
    if is_locked():
        if GameState.inventory.has_id(key_item.id):
            GameState.set_flag("unlocked:" + _lock_key())
            Sfx.play("unlock", null, -3.0)
            await Dialogue.say(["Usé: %s." % key_item.display_name])
        else:
            Sfx.play("locked", null, -3.0)
            await Dialogue.say([locked_text])
            return
    if target_room.is_empty():
        Sfx.play("locked", null, -3.0)
        await Dialogue.say([locked_text])
        return
    Sfx.play("door", null, -2.0)
    # Sin await: esta puerta se borra junto con la sala al cambiar.
    SceneLoader.go_to(target_room, target_spawn)


func _lock_key() -> String:
    return lock_id if not lock_id.is_empty() else GameState.node_key(self)
