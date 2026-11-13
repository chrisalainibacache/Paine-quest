extends SceneTree
## Captura cada cámara de cada sala del capítulo (para revisar el arte).
## Uso: xvfb-run godot --path . --rendering-driver opengl3 -s res://tools/capture_rooms.gd -- <carpeta> [sala...]

var out_dir := "user://screenshots"


func _init() -> void:
    var args := OS.get_cmdline_user_args()
    if args.size() > 0:
        out_dir = args[0]
    DirAccess.make_dir_recursive_absolute(out_dir)
    _run.call_deferred()


func _run() -> void:
    SceneLoader.intros_enabled = false
    SaveSystem.save_path = "user://captura.json"
    # PAINE_GRAFICOS=moderno|retro elige el modo gráfico de las capturas.
    var mode := OS.get_environment("PAINE_GRAFICOS")
    if mode != "":
        GraphicsSettings.set_modern(mode == "moderno")
    GameState.new_game()
    GameState.give_pistol()
    change_scene_to_file("res://main.tscn")
    await _wait(1.2)
    var args := OS.get_cmdline_user_args()
    var rooms: Array = args.slice(1) if args.size() > 1 else \
        ["ticket_office", "service_corridor", "storeroom", "south_platform", "waiting_room", "platform"]
    for room_name: String in rooms:
        var path := "res://levels/station/%s.tscn" % room_name
        if not ResourceLoader.exists(path):
            path = "res://levels/tracks/%s.tscn" % room_name
        if not ResourceLoader.exists(path):
            path = "res://levels/buin/%s.tscn" % room_name
        var probe := (load(path) as PackedScene).instantiate()
        var spawn: String = probe.get_node("Spawns").get_child(0).name
        probe.free()
        SceneLoader.go_to(path, spawn)
        await _wait(1.3)
        var room: Room = current_scene.room
        for zone: CameraZone in room.find_children("*", "CameraZone", true, false):
            # PAINE_JUGADOR=centro: Cony de pie en el centro de cada zona (revisar encuadres).
            if OS.get_environment("PAINE_JUGADOR") == "centro":
                var spot := _reachable_near(room, zone.global_position)
                current_scene.player.global_position = spot
                current_scene.leo.global_position = spot + Vector3(0.7, 0.0, 0.5)
            zone.get_camera().make_current()
            await _wait(0.4)
            _shot("%s_%s" % [room_name, zone.name.to_lower()])
    quit()


func _wait(seconds: float) -> void:
    await create_timer(seconds).timeout


func _shot(shot_name: String) -> void:
    root.get_viewport().get_texture().get_image().save_png(out_dir.path_join(shot_name + ".png"))
    print("captura: ", shot_name)


## Punto del piso caminable más cercano a `center` (por rayos hacia abajo en una espiral).
func _reachable_near(room: Room, center: Vector3) -> Vector3:
    var space := room.get_world_3d().direct_space_state
    for radius in [0.0, 0.5, 1.0, 1.5, 2.0, 3.0]:
        for i in 12:
            var angle := TAU * i / 12.0
            var from := Vector3(center.x + cos(angle) * radius, 1.9, center.z + sin(angle) * radius)
            var q := PhysicsRayQueryParameters3D.create(from, from + Vector3.DOWN * 4.0)
            q.collision_mask = 1
            var hit := space.intersect_ray(q)
            if not hit.is_empty() and hit.normal.y > 0.9 and hit.position.y > -0.15 and hit.position.y < 0.3:
                return hit.position + Vector3.UP * 0.05
    return center
