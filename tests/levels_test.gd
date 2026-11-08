extends "res://tests/test_case.gd"
## Revisa todas las salas del capítulo 1 sin jugar: puertas y puntos de
## aparición conectados, Cony aparece sobre el piso y dentro de una cámara,
## ninguna cámara ve huecos y el capítulo se puede terminar (las llaves están
## antes de las puertas que abren).
## Uso: godot --headless --path . -s res://tests/levels_test.gd

const ROOMS_DIR := "res://levels/station/"
const START_ROOM := "res://levels/station/platform.tscn"
const START_SPAWN := "start"


func _run() -> void:
    SaveSystem.save_path = "user://test_niveles.json"
    GameState.new_game()
    GameState.give_pistol()
    var rooms := _room_paths()
    _check(rooms.size() >= 6, "el capítulo 1 tiene sus 6 salas (hay %d)" % rooms.size())
    for path in rooms:
        await _check_room(path)
    _check_chapter_flow()
    _finish()


func _room_paths() -> Array[String]:
    var paths: Array[String] = []
    for file in DirAccess.get_files_at(ROOMS_DIR):
        if file.ends_with(".tscn"):
            paths.append(ROOMS_DIR + file)
    return paths


func _check_room(path: String) -> void:
    var room := (load(path) as PackedScene).instantiate() as Room
    root.add_child(room)
    await _frames(3)
    var name := path.get_file().get_basename()
    var zones: Array = room.find_children("*", "CameraZone", true, false)
    _check(not zones.is_empty(), "%s: tiene cámaras fijas" % name)

    # Puertas: la sala y el punto de aparición de destino existen.
    for door: Door in room.find_children("*", "Door", true, false):
        if door.target_room.is_empty():
            continue
        var exists := ResourceLoader.exists(door.target_room)
        var spawn_ok := false
        if exists:
            var target := (load(door.target_room) as PackedScene).instantiate()
            spawn_ok = target.get_node_or_null("Spawns/" + door.target_spawn) != null
            target.free()
        _check(exists and spawn_ok, "%s: la puerta %s lleva a %s/%s" % [name, door.name, door.target_room.get_file(), door.target_spawn])

    # Puntos de aparición: sobre el piso, sin chocar con nada y cubiertos por una cámara.
    var space := room.get_world_3d().direct_space_state
    for spawn: Node3D in room.get_node("Spawns").get_children():
        var origin := spawn.global_position
        var down := PhysicsRayQueryParameters3D.create(origin + Vector3.UP * 0.5, origin + Vector3.DOWN * 0.6)
        down.collision_mask = 1
        var hit := space.intersect_ray(down)
        _check(not hit.is_empty() and absf(hit.position.y - origin.y) < 0.2, "%s: «%s» está sobre el piso" % [name, spawn.name])
        var capsule := CapsuleShape3D.new()
        capsule.radius = 0.28
        capsule.height = 1.5
        var shape_query := PhysicsShapeQueryParameters3D.new()
        shape_query.shape = capsule
        shape_query.transform = Transform3D(Basis.IDENTITY, origin + Vector3.UP * 0.95)
        shape_query.collision_mask = 1
        _check(space.intersect_shape(shape_query, 1).is_empty(), "%s: «%s» no queda dentro de un muro" % [name, spawn.name])
        var covered := false
        for zone: CameraZone in zones:
            var shape := zone.get_node("Zone") as CollisionShape3D
            var box := shape.shape as BoxShape3D
            var local := shape.global_transform.affine_inverse() * (origin + Vector3.UP * 0.9)
            if absf(local.x) <= box.size.x / 2 and absf(local.y) <= box.size.y / 2 and absf(local.z) <= box.size.z / 2:
                covered = true
        _check(covered, "%s: alguna cámara cubre «%s»" % [name, spawn.name])

    # Ninguna cámara ve el vacío.
    for zone: CameraZone in zones:
        var misses := await _count_void_rays(zone.get_camera())
        _check(misses == 0, "%s: la cámara %s no ve huecos (rayos perdidos: %d)" % [name, zone.name, misses])
    room.free()
    await _frames(1)


## Recorre las salas desde el inicio como lo haría el jugador: una puerta con
## llave solo se cruza si la llave está en alguna sala ya alcanzada.
func _check_chapter_flow() -> void:
    var reached := {START_ROOM: true}
    var keys := {}
    var exit_found := false
    var changed := true
    while changed:
        changed = false
        for path: String in reached.keys():
            var room := (load(path) as PackedScene).instantiate()
            for pickup: Pickup in room.find_children("*", "Pickup", true, false):
                if pickup.item and pickup.item.kind == ItemData.Kind.KEY and not keys.has(pickup.item.id):
                    keys[pickup.item.id] = true
                    changed = true
            for node in room.find_children("*", "Interactable", true, false):
                if node.get_script().resource_path.ends_with("chapter_exit.gd"):
                    exit_found = true
            for door: Door in room.find_children("*", "Door", true, false):
                if door.target_room.is_empty() or reached.has(door.target_room):
                    continue
                if door.key_item == null or keys.has(door.key_item.id):
                    reached[door.target_room] = true
                    changed = true
            room.free()
    _check(reached.size() == _room_paths().size(), "desde el andén se llega a todas las salas (%d de %d)" % [reached.size(), _room_paths().size()])
    _check(keys.has("gate_key"), "la llave del portón se encuentra antes del portón")
    _check(exit_found, "se llega a la salida que cierra el capítulo")
