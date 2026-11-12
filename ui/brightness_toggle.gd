extends Button
## Botón "BRILLO" (título y mochila): cada toque sube un nivel; tras el último
## vuelve al primero. Sirve para ajustar el juego a la pantalla del teléfono.


func _ready() -> void:
    focus_mode = Control.FOCUS_NONE
    pressed.connect(_on_pressed)
    _refresh()


func _on_pressed() -> void:
    Sfx.play("menu", null, -6.0)
    GraphicsSettings.cycle_brightness(get_tree())
    _refresh()


func _refresh() -> void:
    text = "BRILLO %d/%d" % [GraphicsSettings.brightness_level(), GraphicsSettings.BRIGHTNESS_LEVELS.size()]
