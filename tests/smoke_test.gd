extends "res://tests/test_case.gd"
## Prueba automática (headless): movimiento, cámaras, Leo y combate.
## Uso: godot --headless --path . -s res://tests/smoke_test.gd
## Sale con código 1 si algo falla (así GitHub no publica un APK roto).


func _run() -> void:
    await _start_game("user://test_smoke.json")
    var player: Player = main.player
    var room: Room = main.room
    _check(room.get_tree().get_nodes_in_group("enemies").size() == 2, "la sala trae 2 infectados")
    # Las pruebas de movimiento se hacen sin infectados; el combate se prueba aparte.
    for enemy in room.get_tree().get_nodes_in_group("enemies"):
        enemy.free()

    _check(room != null and player != null, "la sala y Cony se cargan")
    _check(room.get_active_camera() != null, "hay una cámara fija activa al empezar")
    _check(player.get_current_animation() == "Idle", "Cony empieza en Idle (está: %s)" % player.get_current_animation())

    # Caminar: la animación cambia y Cony se desplaza.
    var start := player.global_position
    Input.action_press(&"move_left", 1.0)
    await _seconds(1.0)
    _check(player.global_position.distance_to(start) > 1.5, "Cony trota con el stick a fondo (avanzó %.2f m)" % player.global_position.distance_to(start))
    _check(player.get_current_animation() == "Jog", "animación de trote (está: %s)" % player.get_current_animation())
    Input.action_release(&"move_left")
    await _seconds(0.3)
    _check(player.get_current_animation() == "Idle", "vuelve a Idle al soltar")

    # Leo la sigue con animación (no una pose fija).
    var leo: Node3D = main.leo
    player.global_position = leo.global_position + Vector3(4.0, 0.0, 0.0)
    await _seconds(0.4)
    _check(leo._current in ["Walk", "Run"], "Leo camina/corre al seguirla (está: %s)" % leo._current)

    # Corte de cámara con el stick sostenido: la dirección se mantiene...
    var cameras: Array = room.find_children("*", "CameraZone", true, false)
    player.global_position = Vector3(-2.0, 0.05, 2.5)
    player.set_camera(cameras[0].get_camera())
    Input.action_press(&"move_right", 1.0)
    await _seconds(0.3)
    var before := Vector3(player.velocity.x, 0, player.velocity.z).normalized()
    player.set_camera(cameras[1].get_camera())
    await _seconds(0.2)
    var after := Vector3(player.velocity.x, 0, player.velocity.z).normalized()
    _check(before.dot(after) > 0.95, "tras el corte, la dirección se mantiene con el stick quieto")
    # ...y al girar el stick manda la cámara nueva.
    Input.action_release(&"move_right")
    Input.action_press(&"move_forward", 1.0)
    await _seconds(0.2)
    var expected := -Player._flat_basis(cameras[1].get_camera().global_basis).z
    var now := Vector3(player.velocity.x, 0, player.velocity.z).normalized()
    _check(now.dot(expected) > 0.95, "al corregir el stick, se usa la cámara nueva")
    Input.action_release(&"move_forward")
    await _seconds(0.3)

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

    await _combat_tests(player, room)

    _finish()


func _combat_tests(player: Player, room: Room) -> void:
    var combat := player.combat
    player.global_position = Vector3(-4.0, 0.05, 2.5)
    player.model.rotation.y = PI / 2.0  # mirando hacia +X
    await _frames(3)

    # Apuntar sin infectados: se planta con la pose de apuntar.
    Input.action_press(&"aim")
    Input.action_press(&"move_right", 1.0)
    var before := player.global_position
    await _seconds(0.5)
    _check(combat.aiming, "mantener APUNTAR activa la puntería")
    _check(player.get_current_animation() == "Pistol_Aim_Neutral", "pose de apuntar (está: %s)" % player.get_current_animation())
    _check(player.global_position.distance_to(before) < 0.05, "apuntando no camina")
    Input.action_release(&"move_right")
    player.model.rotation.y = PI / 2.0

    # Un infectado de pie a 4 m: el auto-apuntado lo toma y 5 tiros lo matan.
    var infected: Infected = (load("res://actors/enemies/infected.tscn") as PackedScene).instantiate()
    room.add_child(infected)
    infected.global_position = player.global_position + Vector3(4.0, 0.0, 0.0)
    await _seconds(0.4)
    _check(combat.target == infected, "el auto-apuntado elige al infectado")
    var clip_before := combat.clip
    for i in 5:
        await _tap(&"fire")
        await _seconds(0.5)
    _check(combat.clip == clip_before - 5, "cada disparo gasta una bala (%d -> %d)" % [clip_before, combat.clip])
    _check(not infected.is_alive(), "5 tiros de pistola matan al infectado (vida: %d)" % infected.health)
    await _seconds(0.3)
    _check(combat.target == null, "al morir, deja de ser blanco")

    # Recarga automática al vaciar el cargador.
    combat.clip = 1
    var reserve_before := combat.reserve
    await _tap(&"fire")
    await _seconds(0.5 + combat.weapon.reload_time)
    _check(combat.clip == combat.weapon.clip_size, "recarga automática (cargador: %d)" % combat.clip)
    _check(combat.reserve == reserve_before - combat.weapon.clip_size, "la recarga usa la munición de reserva")
    Input.action_release(&"aim")
    await _frames(3)

    # Un infectado pegado a Cony la ataca y le quita vida.
    var biter: Infected = (load("res://actors/enemies/infected.tscn") as PackedScene).instantiate()
    room.add_child(biter)
    biter.global_position = player.global_position + Vector3(1.0, 0.0, 0.0)
    await _seconds(3.0)
    _check(player.health < Player.MAX_HEALTH, "el infectado muerde a Cony (vida: %d)" % player.health)
    biter.free()

    # Infectado haciéndose el muerto: se levanta al acercarse Cony.
    var liar: Infected = (load("res://actors/enemies/infected.tscn") as PackedScene).instantiate()
    liar.start_state = "lying"
    room.add_child(liar)
    liar.global_position = player.global_position + Vector3(2.5, 0.0, 0.0)
    await _frames(5)
    _check(liar.state == Infected.State.RISING, "el que se hace el muerto se levanta al acercarse")
    liar.free()

    # Un infectado colocado girado en la sala camina de frente hacia Cony.
    var turned: Infected = (load("res://actors/enemies/infected.tscn") as PackedScene).instantiate()
    turned.rotation.y = 2.2
    room.add_child(turned)
    turned.global_position = player.global_position + Vector3(3.5, 0.0, 0.0)
    await _frames(2)
    turned._enter(Infected.State.CHASE)
    var gap_before := turned.global_position.distance_to(player.global_position)
    await _seconds(1.2)
    var to_player := player.global_position - turned.global_position
    to_player.y = 0.0
    _check(turned.global_position.distance_to(player.global_position) < gap_before - 0.3,
        "el infectado girado se acerca a Cony")
    _check(turned._forward().dot(to_player.normalized()) > 0.9, "y la mira de frente (no camina de espaldas)")
    turned.free()

    # Muerte de Cony y pantalla de reintentar.
    player.take_damage(1000, player.global_position + Vector3.RIGHT)
    _check(not player.is_alive(), "Cony muere con daño suficiente")
    await _seconds(2.8)
    _check(main.get_node("HUD/DeathScreen").visible, "aparece la pantalla de muerte")
