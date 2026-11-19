extends CanvasLayer
## Pantalla DIAG: aparato, últimos eventos del juego y errores del motor. Se abre
## desde la mochila; con una captura de esta pantalla se ve qué falla en el teléfono.


func _ready() -> void:
    layer = 60
    process_mode = Node.PROCESS_MODE_ALWAYS
    var shade := ColorRect.new()
    shade.color = Color(0.02, 0.025, 0.03, 0.96)
    shade.set_anchors_preset(Control.PRESET_FULL_RECT)
    add_child(shade)
    var close := Button.new()
    close.text = "CERRAR"
    close.add_theme_font_size_override("font_size", 24)
    close.custom_minimum_size = Vector2(170, 60)
    close.position = Vector2(1090, 14)
    close.pressed.connect(queue_free)
    add_child(close)
    var scroll := ScrollContainer.new()
    scroll.position = Vector2(24, 84)
    scroll.size = Vector2(1232, 616)
    add_child(scroll)
    var label := Label.new()
    label.add_theme_font_size_override("font_size", 15)
    label.add_theme_color_override("font_color", Color(0.85, 0.88, 0.8))
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    label.custom_minimum_size = Vector2(1200, 0)
    label.text = _build_text()
    scroll.add_child(label)
    var title := Label.new()
    title.text = "DIAGNÓSTICO"
    title.add_theme_font_size_override("font_size", 28)
    title.position = Vector2(24, 20)
    add_child(title)


func _build_text() -> String:
    var text := Diag.device_info() + "\n\n--- Últimos eventos (más nuevo abajo) ---\n"
    text += "\n".join(Diag.lines) if not Diag.lines.is_empty() else "(sin eventos todavía)"
    text += "\n\n--- Errores del motor ---\n" + "\n".join(Diag.engine_errors())
    return text
