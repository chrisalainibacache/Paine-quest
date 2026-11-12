extends Interactable
## Salida que cierra un capítulo (p. ej. bajar a la vía). Pregunta antes,
## porque no se puede volver.

@export var chapter: int = 1
@export_multiline var question: String = "¿Seguir? No podré volver."
## Lo que se oye/lee al aceptar, antes de cerrar el capítulo (p. ej. la radio).
@export var before_lines: PackedStringArray = []
@export var accept_text: String = "SEGUIR"


func _init() -> void:
    prompt = "SEGUIR"


func interact(_player: Player) -> void:
    if await Dialogue.ask(question, [accept_text, "TODAVÍA NO"]) == 0:
        if not before_lines.is_empty():
            await Dialogue.say(Array(before_lines))
        SceneLoader.end_chapter(chapter)
