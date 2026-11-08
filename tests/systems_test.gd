extends "res://tests/test_case.gd"
## Prueba automática (headless) de los sistemas del Hito 3: mochila, recoger,
## notas, puertas y cambio de sala, guardado, persistencia y aviso de Leo.
## Uso: godot --headless --path . -s res://tests/systems_test.gd

const AMMO := preload("res://data/items/ammo_9mm.tres")
const SUSHI := preload("res://data/items/sushi.tres")
const KEY := preload("res://data/items/boleteria_key.tres")
const PISTOL := preload("res://data/items/pistol.tres")
const WAITING_ROOM := "res://levels/station/waiting_room.tscn"


func _run() -> void:
    await _start_game("user://test_sistemas.json")
    var player: Player = main.player
    _inventory_rules()
    await _leo_warns(player)
    for enemy in main.room.get_tree().get_nodes_in_group("enemies"):
        enemy.free()
    await _pickup_and_note(player)
    await _backpack_menu(player)
    await _doors_and_rooms(player)
    await _locked_door(player)
    _finish()


func _inventory_rules() -> void:
    _check(GameState.inventory.has_id("pistol") and GameState.equipped == PISTOL, "Cony empieza con la pistola equipada")
    _check(GameState.inventory.count_of(AMMO) == 20, "y 20 balas de reserva en la mochila")
    var inventory := Inventory.new()
    _check(inventory.add(AMMO, 70) == 0 and inventory.get_count(0) == 60 and inventory.get_count(1) == 10,
        "las balas se apilan hasta 60 por casilla")
    _check(inventory.take(AMMO, 65) == 65 and inventory.count_of(AMMO) == 5, "sacar balas descuenta de las casillas")
    for i in 7:
        inventory.add(SUSHI)
    _check(inventory.space_for(SUSHI) == 0 and inventory.add(SUSHI) == 1, "con las 8 casillas llenas no cabe nada más")


func _leo_warns(player: Player) -> void:
    var leo: Node3D = main.leo
    var lying: Node3D = main.room.get_node("Enemies/Lying")
    player.global_position = Vector3(-1.6, 0.05, 2.6)
    leo.global_position = Vector3(-0.6, 0.05, 2.0)
    await _seconds(0.8)
    _check(leo.is_alert() and leo.threat == lying, "Leo nota al infectado que se hace el muerto y le bufa")
    player.global_position = Vector3(-5.0, 0.05, 3.0)
    leo.global_position = Vector3(-5.5, 0.05, 3.4)
    await _seconds(0.8)
    _check(not leo.is_alert(), "lejos de los infectados, Leo se calma")


func _pickup_and_note(player: Player) -> void:
    var room: Room = main.room
    var ammo := room.get_node("Interactables/Ammo") as Pickup
    player.global_position = ammo.global_position + Vector3(0.7, 0.05, 0.0)
    player.face_direction(Vector3.LEFT, 1.0)
    await _frames(3)
    _check(player.interaction.focus == ammo, "Cony tiene a mano la caja de balas")
    var action_button: Control = main.get_node("HUD/ActionButton")
    _check(action_button.visible and action_button.label == "RECOGER", "aparece el botón ACCIÓN con «RECOGER»")
    await _tap(&"interact")
    await _frames(3)
    _check(Dialogue.is_open() and paused, "al recoger aparece un mensaje y el juego se pausa")
    await _close_dialogues()
    _check(not paused and not player.controls_locked, "al cerrar el mensaje el juego sigue")
    _check(GameState.inventory.count_of(AMMO) == 30, "las 10 balas quedan en la mochila (hay %d)" % GameState.inventory.count_of(AMMO))
    _check(not is_instance_valid(ammo), "la caja desaparece del suelo")

    var note: Node3D = room.get_node("Interactables/Note")
    player.global_position = Vector3(note.global_position.x, 0.05, 3.9)
    player.face_direction(Vector3.BACK, 1.0)
    await _frames(3)
    _check(player.interaction.focus == note, "Cony tiene a mano la nota de la banca")
    player.interaction.use(note)
    await _frames(3)
    _check(main.get_node("Dialogue/Reader").visible, "la nota se abre en el lector")
    await _close_dialogues()
    _check(GameState.documents.has("res://data/documents/platform_note.tres"), "la nota queda guardada en NOTAS")


func _backpack_menu(player: Player) -> void:
    var menu: CanvasLayer = main.get_node("InventoryMenu")
    await _tap(&"inventory")
    await _frames(2)
    _check(menu.visible and paused, "MOCHILA abre el menú y pausa el juego")
    await _tap(&"inventory")
    await _frames(2)
    _check(not menu.visible and not paused, "MOCHILA otra vez lo cierra")

    player.health = 50
    GameState.inventory.add(SUSHI)
    menu.open(player)
    await _frames(2)
    var sushi_slot := -1
    for i in Inventory.SIZE:
        if GameState.inventory.get_item(i) == SUSHI:
            sushi_slot = i
    menu.select(sushi_slot)
    _check(menu.use_button.text == "COMER" and not menu.use_button.disabled, "el sushi se puede comer")
    menu._use_selected()
    _check(player.health == 50 + SUSHI.heal_amount and GameState.inventory.count_of(SUSHI) == 0,
        "comer sushi cura (vida: %d) y lo gasta" % player.health)
    menu.select(0)
    menu._examine_selected()
    _check(menu.examine.visible, "EXAMINAR muestra el ítem en grande")
    menu.close()
    await _frames(2)
    _check(not paused, "cerrar la mochila quita la pausa")


func _doors_and_rooms(player: Player) -> void:
    var platform: Room = main.room
    var door: Door = platform.get_node("Interactables/DoorToWaitingRoom")
    player.global_position = Vector3(3.0, 0.05, 4.3)
    player.face_direction(Vector3.BACK, 1.0)
    await _frames(3)
    _check(player.interaction.focus == door, "Cony tiene a mano la puerta de la sala de espera")
    player.interaction.use(door)
    await _seconds(1.4)
    var room: Room = main.room
    _check(room.scene_file_path == WAITING_ROOM, "la puerta lleva a la sala de espera")
    _check(not is_instance_valid(platform) or not platform.is_inside_tree(), "el andén se descarga")
    _check(player.global_position.distance_to(room.get_spawn("from_platform").origin) < 0.3, "Cony aparece en la entrada")
    _check(room.get_active_camera() == root.get_viewport().get_camera_3d(), "se activa una cámara de la sala nueva")
    _check(not player.controls_locked, "los controles vuelven tras el fundido")
    _check(player.global_position.distance_to(main.leo.global_position) < 1.5, "Leo entra con Cony")
    for zone: CameraZone in room.find_children("*", "CameraZone", true, false):
        var misses := await _count_void_rays(zone.get_camera())
        _check(misses == 0, "la cámara %s de la sala de espera no ve huecos (rayos perdidos: %d)" % [zone.name, misses])

    # El infectado de la sala muere y eso queda anotado.
    var standing: Infected = room.get_node("Enemies/Standing")
    standing.take_hit(100, player.global_position, standing.get_aim_point(), 0.0)
    _check(GameState.has_flag("dead:" + GameState.node_key(standing)), "la muerte del infectado queda anotada")

    # Máquina de escribir: guardar.
    var typewriter: Interactable = room.get_node("Interactables/Typewriter")
    player.global_position = Vector3(3.0, 0.05, 1.4)
    player.face_direction(Vector3.RIGHT, 1.0)
    await _frames(3)
    _check(player.interaction.focus == typewriter, "Cony tiene a mano la máquina de escribir")
    player.interaction.use(typewriter)
    await _frames(4)
    _check(Dialogue._instance._asking, "la máquina de escribir pregunta si guardar")
    Dialogue.choose(0)
    await _close_dialogues()
    _check(SaveSystem.has_save(), "la partida queda guardada")

    # Volver al andén: la caja de balas ya no está.
    var back: Door = room.get_node("Interactables/DoorToPlatform")
    player.interaction.use(back)
    await _seconds(1.4)
    _check(main.room.scene_file_path == GameState.START_ROOM, "la puerta de vuelta lleva al andén")
    _check(player.global_position.distance_to(main.room.get_spawn("from_waiting_room").origin) < 0.3, "Cony sale por la puerta de la sala")
    _check(main.room.get_node_or_null("Interactables/Ammo") == null, "lo recogido no vuelve a aparecer")

    # Y otra vez a la sala: el infectado sigue muerto en el suelo.
    player.interaction.use(main.room.get_node("Interactables/DoorToWaitingRoom"))
    await _seconds(1.4)
    var corpse: Infected = main.room.get_node("Enemies/Standing")
    _check(corpse.state == Infected.State.DEAD and not corpse.is_in_group("enemies"), "el infectado muerto sigue muerto al volver")

    # Cargar la partida restaura la mochila y la sala de la máquina de escribir.
    GameState.inventory.clear()
    GameState.flags.clear()
    _check(SaveSystem.load_game(), "la partida guardada se puede cargar")
    _check(GameState.inventory.count_of(AMMO) == 30 and GameState.equipped == PISTOL, "al cargar vuelve la mochila")
    _check(GameState.room_path == WAITING_ROOM and GameState.use_spawn_transform, "al cargar se vuelve a la sala donde se guardó")
    _check(GameState.has_flag("dead:" + GameState.node_key(corpse)), "al cargar se recuerdan los infectados muertos")
    GameState.use_spawn_transform = false


func _locked_door(player: Player) -> void:
    var door := Door.new()
    door.key_item = KEY
    door.lock_id = "prueba"
    main.room.add_child(door)
    door.global_position = player.global_position + player.get_forward() * 0.6
    player.interaction.use(door)
    await _close_dialogues()
    _check(door.is_locked(), "sin la llave la puerta sigue cerrada")
    GameState.inventory.add(KEY)
    player.interaction.use(door)
    await _close_dialogues()
    _check(not door.is_locked() and GameState.has_flag("unlocked:prueba"), "con la llave la puerta se abre y queda abierta")
    door.free()
