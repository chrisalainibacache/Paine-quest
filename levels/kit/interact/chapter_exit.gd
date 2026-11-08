extends Interactable
## Salida que cierra un capítulo (p. ej. bajar a la vía). Pregunta antes,
## porque no se puede volver.

@export var chapter: int = 1
@export_multiline var question: String = "¿Seguir? No podré volver."


func _init() -> void:
    prompt = "SEGUIR"


func interact(_player: Player) -> void:
    if await Dialogue.ask(question, ["SEGUIR", "TODAVÍA NO"]) == 0:
        SceneLoader.end_chapter(chapter)
