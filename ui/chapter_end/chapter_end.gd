extends Control
## Pantalla de fin de capítulo. Tras el capítulo 1 se puede seguir al 2
## (punto de control: guarda la partida al empezar el capítulo); tras el 2,
## es el final del juego.

const TITLE_SCENE := "res://ui/title/title_screen.tscn"
const GAME_SCENE := "res://main.tscn"
const CHAPTER_2_ROOM := "res://levels/tracks/track_north.tscn"

const TEXTS := {
    1: ["FIN DEL CAPÍTULO 1", "La estación",
        "No va a pasar ningún tren. Cony y Leo bajan a la vía y caminan hacia el norte, hacia Santiago, hacia Javiera.\nDetrás queda la estación de Paine, en silencio.",
        "Continuará en el Capítulo 2: Las vías"],
    2: ["FIN", "Capítulo 2 · Las vías",
        "El tren de las 6:30 quedó atrás, volcado en el desvío. Cony y Leo siguen por la vía hacia Santiago.\nEmpieza a amanecer. En Alameda, Javiera las espera.",
        "Gracias por jugar PAINE"],
}

var chapter := 1


func _ready() -> void:
    get_tree().paused = false
    chapter = int(GameState.get_flag("last_chapter_done", 1))
    var texts: Array = TEXTS.get(chapter, TEXTS[1])
    $Title.text = texts[0]
    $Subtitle.text = texts[1]
    $Story.text = texts[2]
    $Next.text = texts[3]
    var minutes := int(GameState.play_time) / 60
    var seconds := int(GameState.play_time) % 60
    $Summary.text = "Tiempo: %d:%02d     Notas encontradas: %d" % [minutes, seconds, GameState.documents.size()]
    $Buttons/Continue.visible = chapter == 1
    $Buttons/Continue.pressed.connect(continue_to_next_chapter)
    $Buttons/Back.pressed.connect(func() -> void: get_tree().change_scene_to_file(TITLE_SCENE))
    modulate.a = 0.0
    create_tween().tween_property(self, "modulate:a", 1.0, 1.5)


## Empieza el capítulo 2 y guarda ahí (punto de control).
func continue_to_next_chapter() -> void:
    GameState.room_path = CHAPTER_2_ROOM
    GameState.spawn_id = "start"
    GameState.use_spawn_transform = false
    GameState.spawn_transform = Transform3D.IDENTITY
    GameState.set_flag("chapter_started:2")
    SaveSystem.save_game()
    # Al cargar se vuelve a la primera sala del capítulo 2 por su punto de inicio.
    GameState.use_spawn_transform = false
    get_tree().change_scene_to_file(GAME_SCENE)
