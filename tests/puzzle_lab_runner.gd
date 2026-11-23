extends SceneTree
## Arranca la escena principal en la sala de pruebas P12 sin tocar el guardado.

func _initialize() -> void:
    call_deferred("_launch")


func _launch() -> void:
    GameState.new_game()
    GameState.room_path = "res://levels/test/puzzle_lab.tscn"
    GameState.spawn_id = "start"
    GameState.use_spawn_transform = false
    var packed := load("res://main.tscn") as PackedScene
    if packed == null:
        push_error("No se pudo cargar main.tscn para la sala de pruebas P12.")
        quit(1)
        return
    var instance := packed.instantiate()
    root.add_child(instance)
    current_scene = instance
