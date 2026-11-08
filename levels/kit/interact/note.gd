extends Interactable
## Nota o documento legible. Al leerla queda guardada en NOTAS de la mochila.

@export var document: DocumentData


func _init() -> void:
    prompt = "LEER"


func interact(_player: Player) -> void:
    Sfx.play("page", null, -6.0)
    await Dialogue.read(document)
    if GameState.add_document(document):
        await Dialogue.say(["«%s» quedó guardada en NOTAS." % document.title])
