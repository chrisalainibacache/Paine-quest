extends SceneTree
## Verifica la pantalla de créditos y sus atribuciones obligatorias en el juego.

var failures: Array[String] = []


func _init() -> void:
    _run.call_deferred()


func _run() -> void:
    var credits_scene := load("res://ui/title/credits_screen.tscn") as PackedScene
    _check(credits_scene != null, "la escena de créditos carga")
    if credits_scene != null:
        var screen := credits_scene.instantiate()
        root.add_child(screen)
        await process_frame
        var content := screen.get_node_or_null("Panel/Layout/Scroll/Content") as RichTextLabel
        _check(content != null and not content.text.strip_edges().is_empty(), "la pantalla muestra créditos desde CREDITS.md")
        if content != null:
            for required in ["Kevin MacLeod", "Attribution 4.0", "Pixelhouse", "JashiPSX"]:
                _check(required in content.text, "créditos incluyen %s" % required)
            _check("`" not in content.text, "créditos sin acentos graves de Markdown")
            _check("**" not in content.text, "créditos sin marcadores dobles de Markdown")
            _check("assets/*/LICENSE.txt" in content.text, "créditos conservan la ruta comodín de licencias")
            _check("Créditos" not in content.text, "créditos no repiten el encabezado")
        _check(screen.get_node_or_null("Panel/Layout/Back") is Button, "la pantalla tiene botón VOLVER")
        screen.queue_free()

    var title_scene := load("res://ui/title/title_screen.tscn") as PackedScene
    _check(title_scene != null, "la pantalla de título carga")
    if title_scene != null:
        var title := title_scene.instantiate()
        _check(title.get_node_or_null("CreditsButton") is Button, "el título incluye el botón CRÉDITOS")
        _check(title.get_node_or_null("OptionsButton") is Button, "el título incluye el botón OPCIONES")
        _check(title.get_node_or_null("OptionsMenu") is Control, "el título integra el menú de opciones")
        title.free()


    GameSettings.load_and_apply()
    var original_sfx := GameSettings.get_volume_percent("Sfx")
    GameSettings.set_volume_percent("Sfx", 37.0)
    var saved := ConfigFile.new()
    var save_error := saved.load("user://ajustes.cfg")
    _check(save_error == OK and is_equal_approx(float(saved.get_value("audio", "Sfx", -1.0)), 37.0),
        "el volumen Sfx se guarda en user://ajustes.cfg")
    var sfx_bus := AudioServer.get_bus_index("Sfx")
    _check(sfx_bus >= 0 and AudioServer.get_bus_volume_db(sfx_bus) < 0.0,
        "el volumen guardado se aplica al bus Sfx")
    GameSettings.set_volume_percent("Sfx", original_sfx)

    var options_scene := load("res://ui/options/options_menu.tscn") as PackedScene
    _check(options_scene != null, "la escena de opciones carga")
    if options_scene != null:
        var options := options_scene.instantiate() as OptionsMenu
        root.add_child(options)
        await process_frame
        for path in ["Panel/Layout/SfxRow/Slider", "Panel/Layout/MusicRow/Slider", "Panel/Layout/AmbienceRow/Slider"]:
            var slider := options.get_node_or_null(path) as HSlider
            _check(slider != null and slider.min_value == 0.0 and slider.max_value == 100.0,
                "el control %s permite 0–100 %%" % path)
        _check(options.get_node_or_null("Panel/Layout/Buttons/Graphics") is Button, "opciones incluye el interruptor gráfico existente")
        _check(options.get_node_or_null("Panel/Layout/Buttons/Credits") is Button, "opciones incluye CRÉDITOS")
        _check(options.get_node_or_null("Panel/Layout/Buttons/Privacy") is Button, "opciones incluye POLÍTICA DE PRIVACIDAD")
        options.open()
        _check(options.visible, "el menú de opciones se puede abrir")
        options.close()
        _check(not options.visible, "el menú de opciones se puede cerrar")
        options.queue_free()

    var links := load("res://data/store_links.tres") as StoreLinks
    _check(links != null and links.privacy_policy_url == "[CONFIRMAR]",
        "la URL de privacidad queda pendiente de confirmar, sin inventarla")

    var inventory_scene := load("res://ui/inventory/inventory_menu.tscn") as PackedScene
    if inventory_scene != null:
        var inventory := inventory_scene.instantiate()
        root.add_child(inventory)
        await process_frame
        _check(inventory.get_node_or_null("Root/Header/Options") is Button, "la mochila incluye OPCIONES")
        _check(inventory.get_node_or_null("OptionsMenu") is Control, "la mochila integra el menú de opciones")
        inventory.queue_free()

    for failure in failures:
        printerr("FALLA: ", failure)
    print("RESULTADO: %s (%d fallas)" % ["OK" if failures.is_empty() else "ERROR", failures.size()])
    quit(0 if failures.is_empty() else 1)


func _check(condition: bool, description: String) -> void:
    print(("  ok  " if condition else "  XX  ") + description)
    if not condition:
        failures.append(description)
