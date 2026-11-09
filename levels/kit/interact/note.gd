extends Interactable
## Nota o documento legible. Al leerla queda guardada en NOTAS de la mochila.

@export var document: DocumentData


func _init() -> void:
    prompt = "LEER"


func interact(_player: Player) -> void:
    if document == null or document.pages.is_empty():
        push_warning("La nota %s no tiene contenido." % name)
        return
    Sfx.play("page", null, -6.0)
    var added := GameState.add_document(document)
    await Dialogue.read(document)
    if added:
        await Dialogue.say(["«%s» quedó guardada en NOTAS." % document.title])
