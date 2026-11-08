extends Interactable
## Máquina de escribir: guarda la partida (una ranura, sin cintas de tinta).


func _init() -> void:
    prompt = "USAR"


func interact(player: Player) -> void:
    var choice := await Dialogue.ask("Una máquina de escribir vieja. Todavía tiene una hoja puesta.\n¿Guardar la partida?", ["GUARDAR", "NO"])
    if choice != 0:
        return
    GameState.room_path = SceneLoader.current_room_path()
    GameState.spawn_transform = Transform3D(Basis(Vector3.UP, player.model.rotation.y), player.global_position)
    GameState.health = player.health
    GameState.clip = player.combat.clip
    Sfx.play("typewriter", null, -3.0)
    if SaveSystem.save_game():
        await Dialogue.say(["Partida guardada."])
    else:
        await Dialogue.say(["No se pudo guardar la partida."])
