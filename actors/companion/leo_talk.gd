extends Interactable
## Botón ACCIÓN "LEO": aparece cuando Leo tiene algo que contarle a Cony.


func _ready() -> void:
    super._ready()
    prompt = "LEO"
    reach = 1.2


func can_interact() -> bool:
    var leo := get_parent()
    return leo.has_method("has_news") and leo.has_news()


func interact(_player: Player) -> void:
    await get_parent().explain_news()
