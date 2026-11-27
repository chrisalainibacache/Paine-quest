class_name FuseBox
extends Interactable
## Tablero que consume los fusibles requeridos una sola vez y abre la bandera
## configurada por el generador de la sala.

@export var puzzle: PuzzleData
@export var fuse_item: ItemData
@export var unlock_id: String = ""
@export_multiline var missing_text: String = "Todavía faltan fusibles."
@export_multiline var solved_text: String = "La energía volvió."

func _init() -> void:
    prompt = "INSTALAR COMPONENTE"
    reach = 1.4


func can_interact() -> bool:
    return puzzle != null and puzzle.is_valid() and not _is_solved()


func interact(_player: Player) -> void:
    if puzzle == null or not puzzle.is_valid():
        await Dialogue.say(["El tablero está dañado."])
        return
    if _is_solved():
        await Dialogue.say(["El tablero ya tiene energía."])
        return

    var requirements: Array[ItemData] = []
    if not puzzle.required_items.is_empty():
        for item_id: String in puzzle.required_items:
            var item_path := "res://data/items/%s.tres" % item_id
            if not ResourceLoader.exists(item_path):
                await Dialogue.say(["No reconozco el tipo de fusible que pide este tablero."])
                return
            var required_item := load(item_path) as ItemData
            if required_item == null:
                await Dialogue.say(["No puedo identificar uno de los fusibles."])
                return
            requirements.append(required_item)
    elif fuse_item != null and puzzle.required_count > 0:
        for index in puzzle.required_count:
            requirements.append(fuse_item)
    else:
        await Dialogue.say(["No hay una configuración de fusibles para este tablero."])
        return

    var needed: Dictionary = {}
    for item: ItemData in requirements:
        needed[item.id] = int(needed.get(item.id, 0)) + 1
    for item_id: String in needed:
        var path := "res://data/items/%s.tres" % item_id
        var item := load(path) as ItemData
        if item == null or GameState.inventory.count_of(item) < int(needed[item_id]):
            await Dialogue.say([missing_text])
            return

    for index in requirements.size():
        var item: ItemData = requirements[index]
        GameState.inventory.take(item, 1)
        PuzzleState.set_fuse_installed(puzzle.id, "%s:%d" % [item.id, index])

    GameState.set_flag("puzzle:" + puzzle.id + ":fuse_solved")
    if not puzzle.success_flag.is_empty():
        GameState.set_flag(puzzle.success_flag)
    if not unlock_id.is_empty():
        GameState.set_flag("unlocked:" + unlock_id)
    Sfx.play("unlock", global_position, -4.0)
    await Dialogue.say([solved_text])


func _is_solved() -> bool:
    return GameState.has_flag("puzzle:" + puzzle.id + ":fuse_solved") if puzzle != null else false
