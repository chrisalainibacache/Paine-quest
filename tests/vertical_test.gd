extends "res://tests/test_case.gd"
## Prueba (headless) de la verticalidad: se sube la escalera del entrepiso del taller y la pasarela del acceso,
## se camina arriba y la baranda impide caer. Uso: godot --headless --path . -s res://tests/vertical_test.gd


func _run() -> void:
    GameState.new_game()
    # Taller: escalera desde el este hasta el entrepiso (2,8 m); se camina hacia el oeste; la baranda sur detiene.
    var top := await _walk("res://levels/maestranza/maestranza_taller.tscn", Vector3(5.6, 0.05, -3.85), Vector3(-1, 0, 0))
    _check(absf(top.y - 2.8) < 0.15 and top.x < -3.0, "taller: se sube la escalera y se camina por el entrepiso (y=%.2f x=%.2f)" % [top.y, top.x])
    var rail := await _walk("res://levels/maestranza/maestranza_taller.tscn", Vector3(-3.0, 2.9, -3.5), Vector3(0, 0, 1))
    _check(rail.y > 2.5, "taller: la baranda impide caer del entrepiso (y=%.2f)" % rail.y)
    # Acceso: pasarela de vigilancia a 2,6 m.
    var walkway := await _walk("res://levels/maestranza/maestranza_acceso.tscn", Vector3(7.0, 0.05, -3.05), Vector3(-1, 0, 0))
    _check(absf(walkway.y - 2.6) < 0.15 and walkway.x < 0.0, "acceso: se sube a la pasarela (y=%.2f x=%.2f)" % [walkway.y, walkway.x])
    _finish()


## Carga la sala, pone una cápsula como Isabella y la empuja 6,5 s; devuelve dónde queda.
func _walk(scene: String, start: Vector3, direction: Vector3) -> Vector3:
    var room := (load(scene) as PackedScene).instantiate()
    root.add_child(room)
    var body := CharacterBody3D.new()
    body.collision_layer = 2
    body.collision_mask = 1
    var shape := CollisionShape3D.new()
    var capsule := CapsuleShape3D.new()
    capsule.radius = 0.28
    capsule.height = 1.7
    shape.shape = capsule
    shape.position = Vector3(0, 0.85, 0)
    body.add_child(shape)
    room.add_child(body)
    body.global_position = start
    for i in 400:
        await physics_frame
        body.velocity.x = direction.x * 2.0
        body.velocity.z = direction.z * 2.0
        body.velocity.y = 0.0 if body.is_on_floor() else body.velocity.y - 18.0 / 60.0
        body.move_and_slide()
    var end := body.global_position
    room.queue_free()
    await physics_frame
    return end
