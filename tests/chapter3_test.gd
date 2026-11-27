extends "res://tests/test_case.gd"
## Prueba (headless) del capítulo 3 no lineal (Buin): la estación es el hub, cada sello vive en su ala, todas las salas se
## alcanzan sin objetos previos (las llaves van en contenedores, no en el piso) y la radio exige los tres sellos en cualquier orden.
## Uso: godot --headless --path . -s res://tests/chapter3_test.gd

const DIR := "res://levels/buin/"
const ROOMS := ["bridge", "checkpoint", "station", "warehouse", "field", "vineyard", "shed", "canal_riego", "caseta_bomba",
    "patio_cosecha", "pasarela_vina"]


func _run() -> void:
    GameState.new_game()
    _seals_exist()
    _reachability()
    _radio_in_any_order()
    _finish()


func _room(name: String) -> Node:
    return (load(DIR + name + ".tscn") as PackedScene).instantiate()


func _count(room: Node, script_name: String) -> int:
    var n := 0
    for node in room.find_children("*", "Interactable", true, false):
        if node.get_script().resource_path.ends_with(script_name):
            n += 1
    return n


func _seals_exist() -> void:
    var checkpoint := _room("checkpoint")
    _check(_count(checkpoint, "code_lock.gd") == 1, "ala A: el control tiene la carpeta con código")
    var locker: Interactable = checkpoint.get_node("Interactables/SupplyLocker")
    _check(locker.required_flag == "unlocked:buin_control_clear", "retroceso premiado: el armario de suministros abre tras despejar el control")
    checkpoint.free()
    var station := _room("station")
    var cabinet: Interactable = station.get_node("Interactables/AttendanceCabinet")
    _check("map_buin" in cabinet.content_item_ids and str(cabinet.required_flag).is_empty(), "hub: el mapa está en el archivador de atención, sin requisitos")
    station.free()
    var warehouse := _room("warehouse")
    var tractor: Interactable = warehouse.get_node("Interactables/TractorCompartment")
    _check("shed_key" in tractor.content_item_ids and str(tractor.required_flag).is_empty(), "ala B: la llave del galpón está en el compartimento del tractor")
    _check(warehouse.get_node_or_null("Interactables/ShedKey") == null, "ala B: la llave no está a la vista en el piso")
    warehouse.free()
    var canal := _room("canal_riego")
    _check(_count(canal, "lever_sequence.gd") == 1 and _count(canal, "lever.gd") == 2, "ala C: el canal tiene la compuerta y el desagüe")
    canal.free()
    var pump := _room("caseta_bomba")
    _check(_count(pump, "lever_sequence.gd") == 1 and _count(pump, "lever.gd") == 3, "ala C: la caseta tiene las tres válvulas")
    var battery: Interactable = pump.get_node("Interactables/BatteryCabinet")
    _check("radio_cell" in battery.content_item_ids and battery.required_flag == "unlocked:buin_pump", "ala C: la batería está en el gabinete que abre la bomba")
    pump.free()
    var shed := _room("shed")
    _check(_count(shed, "fuse_box.gd") == 1, "ala C: el galpón tiene el zócalo de la batería de la radio")
    shed.free()


## Recorre el grafo sin ningún objeto: las puertas de un solo lado y las que piden llave o palanca están cerradas hasta ganar el acceso.
func _reachability() -> void:
    var reached := {"bridge": true}
    var keys := {}
    var opened := {}
    var changed := true
    while changed:
        changed = false
        for name: String in reached.keys():
            var room := _room(name)
            for node in room.find_children("*", "Interactable", true, false):
                if node.get_script().resource_path.ends_with("container.gd") and str(node.required_flag).is_empty():
                    for item_id: String in node.content_item_ids:
                        var item := load("res://data/items/%s.tres" % item_id) as ItemData
                        if item != null and item.kind == ItemData.Kind.KEY and not keys.has(item.id):
                            keys[item.id] = true
                            changed = true
                if node.get_script().resource_path.ends_with("lever_sequence.gd") and not opened.has("lever:" + node.puzzle.id):
                    opened["lever:" + node.puzzle.id] = true   # las palancas de la sala se accionan sin objetos
                    changed = true
            for door: Door in room.find_children("*", "Door", true, false):
                var target := door.target_room.get_file().get_basename()
                if target.is_empty() or reached.has(target):
                    continue
                var open := true
                if door.one_way and not door.one_way_origin and not opened.has(door.lock_id):
                    open = false
                if door.key_item != null and not keys.has(door.key_item.id):
                    open = false
                if door.requires_flag and not opened.has("lever:buin_canal_levers"):
                    open = false
                if open:
                    reached[target] = true
                    changed = true
                if door.one_way and door.one_way_origin:
                    opened[door.lock_id] = true     # se abre desde este lado
            room.free()
    for name: String in ROOMS:
        _check(reached.has(name), "alcanzable desde el inicio sin objetos previos: %s" % name)


## La radio exige los tres sellos; vale cualquier orden (A→B→C y C→B→A).
func _radio_in_any_order() -> void:
    var steps := ["unlocked:buin_control_clear", "talked:rosa", "unlocked:buin_radio_power"]
    var shed := _room("shed")
    root.add_child(shed)
    var radio: Interactable = shed.get_node("Interactables/Radio")
    for order in [[0, 1, 2], [2, 1, 0]]:
        for f in steps:
            GameState.flags.erase(f)
        for i in order:
            _check(not radio.call("requirements_met"), "la radio sigue muda hasta completar los tres sellos (faltan %d)" % (3 - order.find(i)))
            GameState.set_flag(steps[i])
        _check(radio.call("requirements_met"), "la radio funciona con los tres sellos en el orden %s" % str(order))
    for f in steps:
        GameState.flags.erase(f)
    shed.queue_free()
