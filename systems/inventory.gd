class_name Inventory
extends RefCounted
## Mochila de Cony: 8 casillas. Cada casilla guarda un ítem y su cantidad
## (las balas se apilan; la comida y las llaves ocupan una casilla cada una).

signal changed

const SIZE := 8

## Cada casilla: {"item": ItemData, "count": int} o vacía ({}).
var slots: Array[Dictionary] = []


func _init() -> void:
    clear()


func clear() -> void:
    slots.clear()
    for i in SIZE:
        slots.append({})
    changed.emit()


func get_item(index: int) -> ItemData:
    return slots[index].get("item") as ItemData


func get_count(index: int) -> int:
    return slots[index].get("count", 0)


## Guarda hasta `count` unidades. Devuelve las que no cupieron.
func add(item: ItemData, count: int = 1) -> int:
    var left := count
    # Primero completa las casillas que ya tienen ese ítem.
    for slot in slots:
        if left > 0 and slot.get("item") == item and slot.count < item.max_stack:
            var moved := mini(left, item.max_stack - slot.count)
            slot.count += moved
            left -= moved
    for i in SIZE:
        if left > 0 and slots[i].is_empty():
            var moved := mini(left, item.max_stack)
            slots[i] = {"item": item, "count": moved}
            left -= moved
    if left != count:
        changed.emit()
    return left


## Cuántas unidades de un ítem se pueden guardar ahora.
func space_for(item: ItemData) -> int:
    var space := 0
    for slot in slots:
        if slot.is_empty():
            space += item.max_stack
        elif slot.item == item:
            space += item.max_stack - slot.count
    return space


func count_of(item: ItemData) -> int:
    var total := 0
    for slot in slots:
        if not slot.is_empty() and slot.item == item:
            total += slot.count
    return total


func has_id(item_id: String) -> bool:
    for slot in slots:
        if not slot.is_empty() and slot.item.id == item_id:
            return true
    return false


## Saca hasta `amount` unidades del ítem. Devuelve cuántas sacó.
func take(item: ItemData, amount: int) -> int:
    var taken := 0
    # Desde la última casilla, para vaciar primero las cajas a medio usar.
    for i in range(SIZE - 1, -1, -1):
        var slot := slots[i]
        if taken < amount and not slot.is_empty() and slot.item == item:
            var moved := mini(amount - taken, slot.count)
            slot.count -= moved
            taken += moved
            if slot.count <= 0:
                slots[i] = {}
    if taken > 0:
        changed.emit()
    return taken


func remove_at(index: int, amount: int = 1) -> void:
    var slot := slots[index]
    if slot.is_empty():
        return
    slot.count -= amount
    if slot.count <= 0:
        slots[index] = {}
    changed.emit()


## Para guardar la partida: [[ruta del ítem, cantidad], ...].
func to_data() -> Array:
    var data := []
    for slot in slots:
        data.append([] if slot.is_empty() else [slot.item.resource_path, slot.count])
    return data


func from_data(data: Array) -> void:
    slots.clear()
    for i in SIZE:
        var entry: Array = data[i] if i < data.size() else []
        if entry.size() == 2 and ResourceLoader.exists(entry[0]):
            slots.append({"item": load(entry[0]) as ItemData, "count": int(entry[1])})
        else:
            slots.append({})
    changed.emit()
