extends SceneTree
## Capturas de los sistemas del Hito 3 (título, mensajes, notas, mochila, sala
## de espera). Necesita pantalla (xvfb).
## Uso: xvfb-run godot --path . --rendering-driver opengl3 -s res://tools/capture_systems.gd -- <carpeta>

var out_dir := "user://screenshots"


func _init() -> void:
    var args := OS.get_cmdline_user_args()
    if args.size() > 0:
        out_dir = args[0]
    DirAccess.make_dir_recursive_absolute(out_dir)
    _run.call_deferred()


func _run() -> void:
    SceneLoader.intros_enabled = false
    SaveSystem.save_path = "user://captura.json"
    SaveSystem.delete_save()
    change_scene_to_file("res://ui/title/title_screen.tscn")
    await _wait(2.4)
    _shot("10_titulo")

    GameState.new_game()
    GameState.inventory.add(load("res://data/items/sushi.tres"))
    GameState.inventory.add(load("res://data/items/handroll.tres"))
    GameState.inventory.add(load("res://data/items/gate_key.tres"))
    change_scene_to_file("res://main.tscn")
    await _wait(1.5)
    var main := current_scene
    var player: Player = main.player
    for enemy in main.room.get_tree().get_nodes_in_group("enemies"):
        enemy.queue_free()

    # Nota de la banca: botón LEER y el lector.
    var note: Node3D = main.room.get_node("Interactables/Note")
    player.global_position = Vector3(note.global_position.x, 0.05, 3.9)
    player.face_direction(Vector3.BACK, 1.0)
    await _wait(0.6)
    _shot("11_boton_leer")
    player.interaction.use(note)
    await _wait(0.5)
    _shot("12_nota")
    await _close_dialogues()

    # Mochila.
    player.health = 45
    main.get_node("InventoryMenu").open(player)
    await _wait(0.8)
    _shot("13_mochila")
    main.get_node("InventoryMenu").select(3)
    main.get_node("InventoryMenu")._examine_selected()
    await _wait(0.8)
    _shot("14_examinar")
    main.get_node("InventoryMenu").close()

    # Sala de espera.
    player.global_position = Vector3(3.0, 0.05, 4.3)
    await _wait(0.2)
    player.interaction.use(main.room.get_node("Interactables/DoorToWaitingRoom"))
    await _wait(1.6)
    _shot("15_sala_espera_entrada")
    player.global_position = Vector3(2.9, 0.05, 1.4)
    player.face_direction(Vector3.RIGHT, 1.0)
    await _wait(0.8)
    _shot("16_sala_espera_maquina")
    player.interaction.use(main.room.get_node("Interactables/Typewriter"))
    await _wait(0.6)
    _shot("17_guardar")
    Dialogue.choose(1)
    await _wait(0.3)
    SaveSystem.delete_save()
    quit()


func _close_dialogues() -> void:
    for i in 30:
        await _wait(0.1)
        if not Dialogue.is_open():
            return
        Dialogue.advance()


func _wait(seconds: float) -> void:
    await create_timer(seconds).timeout


func _shot(shot_name: String) -> void:
    var image := root.get_viewport().get_texture().get_image()
    image.save_png(out_dir.path_join(shot_name + ".png"))
    print("captura: ", shot_name)
