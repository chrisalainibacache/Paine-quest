class_name SearchContainer
extends Interactable
## Casillero o cajón registrable. El contenido se entrega una sola vez y el
## estado se conserva aunque se descargue la sala o se cierre el juego.

@export var puzzle: PuzzleData
@export var content_item_ids: PackedStringArray = []
@export var counts: PackedInt32Array = []

func _init() -> void:
    prompt = "REGISTRAR"
    reach = 1.2


func can_interact() -> bool:
    return puzzle != null and puzzle.is_valid() and puzzle.puzzle_type == PuzzleData.PuzzleType.CONTAINER


func interact(_player: Player) -> void:
    if not can_interact():
        await Dialogue.say(["No encuentro nada que registrar."])
        return
    if PuzzleState.is_container_searched(puzzle.id):
        await Dialogue.say(["Ya revisé este lugar. No queda nada."])
        return

    var amounts: Array[int] = []
    var totals: Dictionary = {}
    var loaded_items: Array[ItemData] = []
    for index in content_item_ids.size():
        var amount: int = counts[index] if index < counts.size() else 1
        amounts.append(maxi(amount, 1))
        var item_path := "res://data/items/%s.tres" % content_item_ids[index]
        if not ResourceLoader.exists(item_path):
            await Dialogue.say(["No reconozco uno de los objetos guardados aquí."])
            return
        var item := load(item_path) as ItemData
        if item == null:
            await Dialogue.say(["No puedo identificar uno de los objetos."])
            return
        loaded_items.append(item)
        totals[item.id] = int(totals.get(item.id, 0)) + amounts[index]
    for item_id: String in totals:
        var item_path := "res://data/items/%s.tres" % item_id
        var item := load(item_path) as ItemData
        if item == null or GameState.inventory.space_for(item) < int(totals[item_id]):
            await Dialogue.say(["No me cabe todo en la mochila. Primero tengo que hacer espacio."])
            return

    var found: Array[String] = []
    for index in content_item_ids.size():
        var item: ItemData = loaded_items[index]
        var amount: int = amounts[index]
        GameState.inventory.add(item, amount)
        found.append(item.display_name + (" ×%d" % amount if amount > 1 else ""))

    if not PuzzleState.mark_container_searched(puzzle.id):
        return
    Sfx.play("pickup", global_position, -4.0)
    if found.is_empty():
        await Dialogue.say(["El cajón está vacío."])
    else:
        var lines := PackedStringArray(["Encontré:"])
        for entry: String in found:
            lines.append("— " + entry)
        await Dialogue.say(lines)
