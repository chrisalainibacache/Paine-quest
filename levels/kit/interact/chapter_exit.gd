extends Interactable
## Salida que cierra un capítulo (p. ej. bajar a la vía). Pregunta antes,
## porque no se puede volver.

@export var chapter: int = 1
@export var required_flags: PackedStringArray = []
@export_multiline var blocked_text: String = "Todavía faltan pasos para abrir la salida."
@export_multiline var question: String = "¿Seguir? No podré volver."
## Lo que se oye/lee al aceptar, antes de cerrar el capítulo (p. ej. la radio).
@export var before_lines: PackedStringArray = []
@export var accept_text: String = "SEGUIR"


func _init() -> void:
    prompt = "SEGUIR"


func _play_radio_static() -> void:
    if name.to_lower().contains("radio"):
        Sfx.play("radio_static", global_position, -8.0)


func requirements_met() -> bool:
    for required_flag: String in required_flags:
        if not GameState.has_flag(required_flag):
            return false
    return true


func interact(_player: Player) -> void:
    if not requirements_met():
        await Dialogue.say([blocked_text])
        return
    if await Dialogue.ask(question, [accept_text, "TODAVÍA NO"]) == 0:
        if not before_lines.is_empty():
            _play_radio_static()
            await Dialogue.say(Array(before_lines))
        SceneLoader.end_chapter(chapter)
