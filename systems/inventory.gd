class_name Inventory
extends RefCounted
## Mochila de Isabella: 16 casillas. Cada casilla guarda un ítem y su cantidad
## (las balas se apilan; la comida y las llaves ocupan una casilla cada una).

signal changed

const SIZE := 16

## Cada casilla: {"item": ItemData, "count": int} o vacía ({}).
var slots: Array[Dictionary] = []
## Llaves fuera de las casillas: cada entrada guarda ItemData y cantidad.
var key_items: Array[Dictionary] = []
var capacity: int = SIZE


static func _is_key_item(item: ItemData) -> bool:
    return item != null and (item.kind == ItemData.Kind.KEY or item.kind == ItemData.Kind.MAP)


func _init(slot_count: int = SIZE) -> void:
    capacity = maxi(slot_count, 1)
    clear()


func clear() -> void:
    slots.clear()
    key_items.clear()
    for i in capacity:
        slots.append({})
    changed.emit()


func get_item(index: int) -> ItemData:
    return slots[index].get("item") as ItemData


func get_count(index: int) -> int:
    return slots[index].get("count", 0)


## Guarda hasta `count` unidades. Devuelve las que no cupieron.
func add(item: ItemData, count: int = 1) -> int:
    if item == null or count <= 0:
        return count
    if _is_key_item(item):
        _store_key(item, count)
        changed.emit()
        return 0
    var left := count
    # Primero completa las casillas que ya tienen ese ítem.
    for slot in slots:
        if left > 0 and slot.get("item") == item and slot.count < item.max_stack:
            var moved := mini(left, item.max_stack - slot.count)
            slot.count += moved
            left -= moved
    for i in capacity:
        if left > 0 and slots[i].is_empty():
            var moved := mini(left, item.max_stack)
            slots[i] = {"item": item, "count": moved}
            left -= moved
    if left != count:
        changed.emit()
    return left


## Cuántas unidades de un ítem se pueden guardar ahora.
func space_for(item: ItemData) -> int:
    if _is_key_item(item):
        return 2147483647
    var space := 0
    for slot in slots:
        if slot.is_empty():
            space += item.max_stack
        elif slot.item == item:
            space += item.max_stack - slot.count
    return space


func count_of(item: ItemData) -> int:
    if _is_key_item(item):
        for entry: Dictionary in key_items:
            var key: ItemData = entry.get("item") as ItemData
            if key != null and key.id == item.id:
                return int(entry.get("count", 0))
        return 0
    var total := 0
    for slot in slots:
        if not slot.is_empty() and slot.item == item:
            total += slot.count
    return total


func has_id(item_id: String) -> bool:
    for entry: Dictionary in key_items:
        var key: ItemData = entry.get("item") as ItemData
        if key != null and key.id == item_id:
            return true
    for slot in slots:
        if not slot.is_empty() and slot.item.id == item_id:
            return true
    return false


## Saca hasta `amount` unidades del ítem. Devuelve cuántas sacó.
func take(item: ItemData, amount: int) -> int:
    if _is_key_item(item):
        for index in range(key_items.size() - 1, -1, -1):
            var entry: Dictionary = key_items[index]
            var key: ItemData = entry.get("item") as ItemData
            if key != null and key.id == item.id:
                var taken_key: int = mini(maxi(amount, 0), int(entry.get("count", 0)))
                entry["count"] = int(entry.get("count", 0)) - taken_key
                if int(entry["count"]) <= 0:
                    key_items.remove_at(index)
                if taken_key > 0:
                    changed.emit()
                return taken_key
        return 0
    var taken := 0
    # Desde la última casilla, para vaciar primero las cajas a medio usar.
    for i in range(capacity - 1, -1, -1):
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


## Ingredientes compatibles que el jugador ya lleva en la mochila.
func combination_partners(item: ItemData) -> Array[ItemData]:
    var partners: Array[ItemData] = []
    if item == null:
        return partners
    for recipe: RecipeData in RecipeData.all_recipes():
        var partner := recipe.partner_for(item)
        if partner != null and count_of(partner) > 0 and not partners.has(partner):
            partners.append(partner)
    return partners


## Consume A y B y entrega el resultado. Si no cabe, restaura la mochila intacta.
func combine(a: ItemData, b: ItemData) -> ItemData:
    if a == null or b == null:
        return null
    var recipe := RecipeData.find_recipe(a, b)
    if recipe == null:
        return null
    if a.id == b.id:
        if count_of(a) < 2:
            return null
    elif count_of(a) < 1 or count_of(b) < 1:
        return null

    var before: Array = to_data()
    if take(a, 1) != 1 or take(b, 1) != 1:
        from_data(before)
        return null
    if add(recipe.result_item, recipe.result_count) > 0:
        from_data(before)
        return null
    GameState.register_progress()
    return recipe.result_item


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
    var data: Array = []
    for slot: Dictionary in slots:
        data.append([] if slot.is_empty() else [slot.item.resource_path, slot.count])
    var saved_keys: Array = []
    for entry: Dictionary in key_items:
        var key: ItemData = entry.get("item") as ItemData
        if key != null:
            saved_keys.append([key.resource_path, int(entry.get("count", 1))])
    data.append({"_inventory_version": 2, "key_items": saved_keys})
    return data


func from_data(data: Array) -> void:
    slots.clear()
    key_items.clear()
    var saved_keys: Array = []
    for raw_entry: Variant in data:
        if raw_entry is Dictionary and int(raw_entry.get("_inventory_version", 0)) == 2:
            saved_keys = raw_entry.get("key_items", [])
            continue
        if slots.size() >= capacity:
            continue
        if raw_entry is Array and raw_entry.size() == 2:
            var path: String = String(raw_entry[0])
            if ResourceLoader.exists(path):
                var item: ItemData = load(path) as ItemData
                var amount: int = int(raw_entry[1])
                if _is_key_item(item):
                    _store_key(item, amount)
                elif item != null:
                    slots.append({"item": item, "count": amount})
                else:
                    slots.append({})
            else:
                slots.append({})
        else:
            slots.append({})
    while slots.size() < capacity:
        slots.append({})
    for raw_key: Variant in saved_keys:
        if raw_key is Array and raw_key.size() == 2:
            var key_path: String = String(raw_key[0])
            if ResourceLoader.exists(key_path):
                var key_item: ItemData = load(key_path) as ItemData
                if _is_key_item(key_item):
                    _store_key(key_item, int(raw_key[1]))
    changed.emit()


func _store_key(item: ItemData, count: int) -> void:
    if item == null or count <= 0:
        return
    for entry: Dictionary in key_items:
        var existing: ItemData = entry.get("item") as ItemData
        if existing != null and existing.id == item.id:
            entry["count"] = int(entry.get("count", 0)) + count
            return
    key_items.append({"item": item, "count": count})


func key_item_at(index: int) -> ItemData:
    if index < 0 or index >= key_items.size():
        return null
    return key_items[index].get("item") as ItemData


func key_count_at(index: int) -> int:
    if index < 0 or index >= key_items.size():
        return 0
    return int(key_items[index].get("count", 0))

