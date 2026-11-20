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
        _check(screen.get_node_or_null("Panel/Layout/Back") is Button, "la pantalla tiene botón VOLVER")
        screen.queue_free()

    var title_scene := load("res://ui/title/title_screen.tscn") as PackedScene
    _check(title_scene != null, "la pantalla de título carga")
    if title_scene != null:
        var title := title_scene.instantiate()
        _check(title.get_node_or_null("CreditsButton") is Button, "el título incluye el botón CRÉDITOS")
        title.free()

    for failure in failures:
        printerr("FALLA: ", failure)
    print("RESULTADO: %s (%d fallas)" % ["OK" if failures.is_empty() else "ERROR", failures.size()])
    quit(0 if failures.is_empty() else 1)


func _check(condition: bool, description: String) -> void:
    print(("  ok  " if condition else "  XX  ") + description)
    if not condition:
        failures.append(description)
