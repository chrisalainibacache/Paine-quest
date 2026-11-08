extends SceneTree
## Prueba automática (headless). Carga el juego y verifica lo básico.
## Uso: godot --headless --path . -s res://tests/smoke_test.gd
## Sale con código 1 si algo falla (así GitHub no publica un APK roto).

var failures: Array[String] = []
var main: Node


func _init() -> void:
    _run.call_deferred()


func _run() -> void:
    main = (load("res://main.tscn") as PackedScene).instantiate()
    root.add_child(main)
    await _frames(10)
    var player: Player = main.player
    var room: Room = main.room

    _check(room != null and player != null, "la sala y Cony se cargan")
    _check(room.get_active_camera() != null, "hay una cámara fija activa al empezar")
    _check(player.get_current_animation() == "Idle", "Cony empieza en Idle (está: %s)" % player.get_current_animation())

    # Caminar: la animación cambia y Cony se desplaza.
    var start := player.global_position
    Input.action_press(&"move_left", 1.0)
    await _seconds(1.0)
    _check(player.global_position.distance_to(start) > 1.5, "Cony trota con el stick a fondo (avanzó %.2f m)" % player.global_position.distance_to(start))
    _check(player.get_current_animation() == "Jog_Fwd", "animación de trote (está: %s)" % player.get_current_animation())
    Input.action_release(&"move_left")
    await _seconds(0.3)
    _check(player.get_current_animation() == "Idle", "vuelve a Idle al soltar")

    # Corte de cámara al cruzar a la otra mitad del andén.
    var first_camera := room.get_active_camera()
    player.global_position = Vector3(4.0, 0.05, 2.5)
    await _frames(6)
    _check(room.get_active_camera() != first_camera, "corte de cámara al cruzar al lado este")
    _check(room.get_active_camera() == root.get_viewport().get_camera_3d(), "la cámara activa es la que se ve")

    # Cony no puede caer a la vía.
    player.global_position = Vector3(0.0, 0.05, -0.4)
    var cam_basis := Player._flat_basis(room.get_active_camera().global_basis)
    # Empuja el stick en la dirección que, para esta cámara, apunta a la vía.
    var to_tracks := Vector2(cam_basis.x.dot(Vector3.FORWARD), cam_basis.z.dot(Vector3.FORWARD)).normalized()
    _press_vector(to_tracks)
    await _seconds(1.5)
    _press_vector(Vector2.ZERO)
    _check(player.global_position.z > -1.4, "el borde del andén bloquea el paso (z=%.2f)" % player.global_position.z)

    # Ninguna cámara ve el vacío: todo rayo hacia abajo u horizontal choca con algo.
    for zone: CameraZone in room.find_children("*", "CameraZone", true, false):
        var misses := await _count_void_rays(zone.get_camera())
        _check(misses == 0, "la cámara %s no ve huecos (rayos perdidos: %d)" % [zone.name, misses])

    for failure in failures:
        printerr("FALLA: ", failure)
    print("RESULTADO: %s (%d fallas)" % ["OK" if failures.is_empty() else "ERROR", failures.size()])
    quit(0 if failures.is_empty() else 1)


func _count_void_rays(camera: Camera3D) -> int:
    await physics_frame
    var space := camera.get_world_3d().direct_space_state
    var size := Vector2(1280, 720)
    var misses := 0
    for gx in 16:
        for gy in 9:
            var screen := Vector2((gx + 0.5) / 16.0, (gy + 0.5) / 9.0) * size
            var origin := camera.project_ray_origin(screen)
            var direction := _project_dir(camera, screen, size)
            # Mirar al cielo nocturno sobre los muros está permitido.
            if direction.y > 0.15:
                continue
            var query := PhysicsRayQueryParameters3D.create(origin, origin + direction * camera.far)
            query.collision_mask = 1
            if space.intersect_ray(query).is_empty():
                misses += 1
    return misses


## Dirección del rayo de cámara calculada a mano (en headless no hay viewport real).
func _project_dir(camera: Camera3D, screen: Vector2, size: Vector2) -> Vector3:
    var ndc := (screen / size) * 2.0 - Vector2.ONE
    var tan_y := tan(deg_to_rad(camera.fov) * 0.5)
    var local := Vector3(ndc.x * tan_y * size.x / size.y, -ndc.y * tan_y, -1.0).normalized()
    return (camera.global_basis * local).normalized()


func _press_vector(v: Vector2) -> void:
    for action in [&"move_left", &"move_right", &"move_forward", &"move_back"]:
        Input.action_release(action)
    if v.x < 0.0: Input.action_press(&"move_left", -v.x)
    if v.x > 0.0: Input.action_press(&"move_right", v.x)
    if v.y < 0.0: Input.action_press(&"move_forward", -v.y)
    if v.y > 0.0: Input.action_press(&"move_back", v.y)


func _check(condition: bool, description: String) -> void:
    print(("  ok  " if condition else "  XX  ") + description)
    if not condition:
        failures.append(description)


func _frames(count: int) -> void:
    for i in count:
        await physics_frame


func _seconds(time: float) -> void:
    await create_timer(time).timeout
