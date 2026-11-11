extends Button
## Botón "GRÁFICOS: RETRO / MODERNO" (título y mochila). Cambia el modo al tiro,
## sobre lo que está en pantalla.


func _ready() -> void:
    focus_mode = Control.FOCUS_NONE
    pressed.connect(_on_pressed)
    _refresh()
    # Al abrir la pantalla deja todo según el modo guardado (filtro incluido).
    GraphicsSettings.apply.call_deferred(get_tree().root)


func _on_pressed() -> void:
    Sfx.play("menu", null, -6.0)
    GraphicsSettings.toggle(get_tree())
    _refresh()


func _refresh() -> void:
    text = "GRÁFICOS: MODERNO" if GraphicsSettings.is_modern() else "GRÁFICOS: RETRO"
