extends "res://tests/test_case.gd"
## Prueba (headless) del capítulo 2 no lineal: cada sello se puede empezar sin los otros, las llaves se obtienen antes de
## la puerta que las exige (sin cadenas imposibles) y la salida exige los cuatro pasos en cualquier orden.
## Uso: godot --headless --path . -s res://tests/chapter2_test.gd

const DIR := "res://levels/tracks/"
const ROOMS := ["track_north", "derailed_train", "sala_locomotora", "wagon_interior", "convoy_side", "galpon_carga",
    "pasarela_convoy", "cuarto_drenaje", "underpass", "switch_house"]


func _run() -> void:
    GameState.new_game()
    _seals_exist()
    _reachability()
    _exit_in_any_order()
    _finish()


func _room(name: String) -> Node:
    return (load(DIR + name + ".tscn") as PackedScene).instantiate()


func _count(room: Node, script_name: String) -> int:
    var n := 0
    for node in room.find_children("*", "Interactable", true, false):
        if node.get_script().resource_path.ends_with(script_name):
            n += 1
    return n


## Cada sello vive en su ala: válvulas (A), tablero de carga con el fusible en la estiba (B), palancas y clavija (C).
func _seals_exist() -> void:
    var locomotive := _room("sala_locomotora")
    _check(_count(locomotive, "lever_sequence.gd") == 1 and _count(locomotive, "lever.gd") == 3, "ala A: la sala de la locomotora tiene las tres válvulas")
    locomotive.free()
    var shed := _room("galpon_carga")
    _check(_count(shed, "fuse_box.gd") == 1 and _count(shed, "container.gd") == 1, "ala B: el galpón tiene el tablero de carga y la estiba con el fusible")
    var stock: Interactable = shed.get_node("Interactables/CargoStock")
    _check("fuse_10a" in stock.content_item_ids and str(stock.required_flag).is_empty(), "ala B: el fusible no exige ningún otro sello")
    shed.free()
    var drain := _room("cuarto_drenaje")
    var cabinet: Interactable = drain.get_node("Interactables/DrainCabinet")
    _check("signal_pin" in cabinet.content_item_ids and cabinet.required_flag == "unlocked:tracks_drain", "ala C: la clavija está en el gabinete del drenaje (abre con su propia bomba)")
    drain.free()
    var house := _room("switch_house")
    _check(_count(house, "lever.gd") == 3 and _count(house, "fuse_box.gd") == 1, "ala C: la casa de cambios tiene las palancas y el encaje de la clavija")
    house.free()
    var wagon := _room("wagon_interior")
    _check(_count(wagon, "code_lock.gd") == 1 and wagon.get_node_or_null("Interactables/EngineerKey") == null, "la llave del maquinista no está a la vista: va en un estuche con código")
    wagon.free()


## Recorre el grafo sin ningún objeto: las puertas de un solo lado y las que piden llave están cerradas hasta ganar el acceso.
func _reachability() -> void:
    var reached := {"track_north": true}
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
            for door: Door in room.find_children("*", "Door", true, false):
                var target := door.target_room.get_file().get_basename()
                if target.is_empty() or reached.has(target):
                    continue
                var open := true
                if door.one_way and not door.one_way_origin and not opened.has(door.lock_id):
                    open = false
                if door.key_item != null and not keys.has(door.key_item.id):
                    open = false
                if open:
                    reached[target] = true
                    changed = true
                if door.one_way and door.one_way_origin:
                    opened[door.lock_id] = true     # se abre desde este lado
            room.free()
    for name: String in ROOMS:
        _check(reached.has(name), "alcanzable desde el inicio sin objetos previos: %s" % name)
    # La llave del maquinista exige el código (se obtiene en el coche) pero NO es necesaria: el drenaje da otro camino al paso bajo nivel.
    _check(reached.has("underpass") and reached.has("switch_house"), "el paso bajo nivel se alcanza también por la pasarela y el drenaje (sin la llave)")


## La salida pide los cuatro pasos; vale cualquier orden (A→B→C y C→B→A).
func _exit_in_any_order() -> void:
    var steps := ["unlocked:tracks_fire_out", "unlocked:tracks_power", "unlocked:tracks_pin", "unlocked:tracks_line"]
    var house := _room("switch_house")
    root.add_child(house)
    var exit: Interactable = house.get_node("Interactables/TrackExit")
    for order in [[0, 1, 2, 3], [3, 2, 1, 0]]:
        for f in steps:
            GameState.flags.erase(f)
        for i in order:
            _check(not exit.call("requirements_met"), "salida cerrada hasta completar los cuatro pasos (faltan %d)" % (4 - order.find(i)))
            GameState.set_flag(steps[i])
        _check(exit.call("requirements_met"), "salida abierta con los cuatro pasos en el orden %s" % str(order))
    for f in steps:
        GameState.flags.erase(f)
    house.queue_free()
