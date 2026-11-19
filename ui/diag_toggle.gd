extends Button
## Botón DIAG de la mochila: abre la pantalla de diagnóstico.


func _ready() -> void:
    focus_mode = Control.FOCUS_NONE
    pressed.connect(func() -> void:
        get_tree().root.add_child((load("res://ui/diag_panel.gd") as GDScript).new()))
