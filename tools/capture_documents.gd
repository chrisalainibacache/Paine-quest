extends SceneTree
## Captura cada página de cada documento tal como se ve en el lector (revisión
## de legibilidad). PAINE_GRAFICOS=moderno|retro elige el modo.
## Uso: xvfb-run godot --path . --rendering-driver opengl3 -s res://tools/capture_documents.gd -- <carpeta>


func _init() -> void:
    _run.call_deferred()


func _run() -> void:
    var out: String = OS.get_cmdline_user_args()[0]
    DirAccess.make_dir_recursive_absolute(out)
    var mode := OS.get_environment("PAINE_GRAFICOS")
    if mode != "":
        GraphicsSettings.set_modern(mode == "moderno")
    SaveSystem.save_path = "user://captura.json"
    GameState.new_game()
    change_scene_to_file("res://main.tscn")
    await create_timer(1.5).timeout
    var dialogue := current_scene.get_node("Dialogue")
    for file in DirAccess.get_files_at("res://data/documents"):
        if not file.ends_with(".tres"):
            continue
        var document := load("res://data/documents/" + file) as DocumentData
        Dialogue.read(document)
        await create_timer(0.3).timeout
        for page in document.pages.size():
            await process_frame
            root.get_viewport().get_texture().get_image().save_png(out.path_join("%s_%d.png" % [document.id, page + 1]))
            dialogue._next_reader_page()
            await create_timer(0.3).timeout
        print("documento: ", document.id)
    quit()
