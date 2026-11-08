extends SceneTree
## Base de las pruebas headless: arranca el juego con una partida nueva y una
## ranura de guardado aparte, y trae utilidades (esperar, tocar botones, revisar).

var failures: Array[String] = []
var main: Node


func _init() -> void:
    _run.call_deferred()


func _run() -> void:
    pass


## Partida nueva; por defecto con la pistola (como si ya la hubiera encontrado).
func _start_game(save_path: String, armed: bool = true) -> void:
    SaveSystem.save_path = save_path
    SaveSystem.delete_save()
    GameState.new_game()
    if armed:
        GameState.give_pistol()
    main = (load("res://main.tscn") as PackedScene).instantiate()
    root.add_child(main)
    await _frames(10)


func _finish() -> void:
    SaveSystem.delete_save()
    for failure in failures:
        printerr("FALLA: ", failure)
    print("RESULTADO: %s (%d fallas)" % ["OK" if failures.is_empty() else "ERROR", failures.size()])
    quit(0 if failures.is_empty() else 1)


## Avanza todos los mensajes abiertos (se detiene si hay una pregunta).
func _close_dialogues() -> void:
    for i in 30:
        await _frames(3)
        if not Dialogue.is_open() or Dialogue._instance._asking:
            return
        Dialogue.advance()


func _tap(action: StringName) -> void:
    Input.action_press(action)
    await _frames(2)
    Input.action_release(action)


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
