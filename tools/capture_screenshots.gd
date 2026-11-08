extends SceneTree
## Toma capturas del juego para revisar cómo se ve (necesita pantalla: xvfb).
## Uso: xvfb-run godot --path . --rendering-driver opengl3 -s res://tools/capture_screenshots.gd -- <carpeta>

var out_dir := "user://screenshots"


func _init() -> void:
    var args := OS.get_cmdline_user_args()
    if args.size() > 0:
        out_dir = args[0]
    DirAccess.make_dir_recursive_absolute(out_dir)
    change_scene_to_file("res://main.tscn")
    _run.call_deferred()


func _run() -> void:
    await _wait(1.5)
    _shot("01_inicio")
    # Cony camina hacia el este (cruza al otro lado: corte de cámara).
    Input.action_press(&"move_right", 1.0)
    await _wait(1.0)
    _shot("02_trotando")
    await _wait(1.6)
    Input.action_release(&"move_right")
    await _wait(0.6)
    _shot("03_camara_este")
    Input.action_press(&"move_forward", 0.5)
    await _wait(1.2)
    _shot("04_caminando")
    Input.action_release(&"move_forward")

    # Combate: Cony frente al infectado que come junto al portón.
    var main := current_scene
    var player: Player = main.player
    player.global_position = Vector3(1.0, 0.05, 3.0)
    player.model.rotation.y = PI / 2.0
    await _wait(1.0)
    Input.action_press(&"aim")
    await _wait(0.8)
    _shot("05_apuntando")
    for i in 7:
        Input.action_press(&"fire")
        await _wait(0.05)
        if i == 0:
            _shot("06_disparo")
        Input.action_release(&"fire")
        await _wait(0.5)
    await _wait(1.5)
    _shot("07_infectado_muerto")
    Input.action_release(&"aim")
    quit()


func _wait(seconds: float) -> void:
    await create_timer(seconds).timeout


func _shot(shot_name: String) -> void:
    var image := root.get_viewport().get_texture().get_image()
    image.save_png(out_dir.path_join(shot_name + ".png"))
    print("captura: ", shot_name)
