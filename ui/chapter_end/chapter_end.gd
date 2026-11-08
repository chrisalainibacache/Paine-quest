extends Control
## Pantalla de fin de capítulo: resumen y vuelta al título.

const TITLE_SCENE := "res://ui/title/title_screen.tscn"


func _ready() -> void:
    get_tree().paused = false
    var minutes := int(GameState.play_time) / 60
    var seconds := int(GameState.play_time) % 60
    $Summary.text = "Tiempo: %d:%02d     Notas encontradas: %d" % [minutes, seconds, GameState.documents.size()]
    $Back.pressed.connect(func() -> void: get_tree().change_scene_to_file(TITLE_SCENE))
    modulate.a = 0.0
    create_tween().tween_property(self, "modulate:a", 1.0, 1.5)
