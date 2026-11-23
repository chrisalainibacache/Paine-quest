class_name StorageChest
extends Interactable
## Baúl compartido de 24 casillas disponible en salas seguras.

func _init() -> void:
    prompt = "ABRIR BAÚL"
    reach = 1.4


func interact(player: Player) -> void:
    var menu: Node = get_tree().get_first_node_in_group("inventory_menu")
    if menu == null:
        await Dialogue.say(["No puedo abrir el baúl ahora."])
        return
    menu.call("open_chest", player)
