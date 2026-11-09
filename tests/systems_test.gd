extends "res://tests/test_case.gd"
## Prueba automática (headless) de los sistemas del Hito 3: mochila, recoger,
## notas, puertas y cambio de sala, guardado, persistencia y aviso de Leo.
## Uso: godot --headless --path . -s res://tests/systems_test.gd

const AMMO := preload("res://data/items/ammo_9mm.tres")
const SUSHI := preload("res://data/items/sushi.tres")
const KEY := preload("res://data/items/gate_key.tres")
const PISTOL := preload("res://data/items/pistol.tres")
const WAITING_ROOM := "res://levels/station/waiting_room.tscn"
const TICKET_OFFICE := "res://levels/station/ticket_office.tscn"
const SOUTH_PLATFORM := "res://levels/station/south_platform.tscn"


func _run() -> void:
    GameState.new_game()
    _check(GameState.equipped == null and GameState.inventory.count_of(AMMO) == 0 and not GameState.inventory.has_id("pistol"),
        "partida nueva: Cony empieza sin arma ni balas")
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
    await _chapter_route(player)
    _finish()


func _inventory_rules() -> void:
    _check(GameState.inventory.has_id("pistol") and GameState.equipped == PISTOL, "con la pistola, queda equipada")
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
    var dialogue := main.get_node("Dialogue") as Dialogue
    var platform_document := load("res://data/documents/platform_note.tres") as DocumentData
    _check(dialogue.reader_body.text == platform_document.pages[0], "el lector muestra la primera página")
    dialogue.reader_next.pressed.emit()
    await _frames(1)
    _check(dialogue.reader_body.text == platform_document.pages[1], "SIGUIENTE muestra la segunda página")
    dialogue.reader_previous.pressed.emit()
    await _frames(1)
    _check(dialogue.reader_body.text == platform_document.pages[0], "ANTERIOR permite volver a la primera página")
    dialogue.reader_next.pressed.emit()
    await _frames(1)
    dialogue.reader_close.pressed.emit()
    await _frames(2)
    _check(not dialogue.reader.visible, "CERRAR sale del lector de la nota")
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
    # Leer una nota desde NOTAS: mientras está abierta, los toques no llegan
    # a la mochila de abajo (antes la nota se volvía a abrir sola).
    menu._show_tab(true)
    await _frames(2)
    var note_button := menu.notes_list.get_child(0) as Button
    note_button.pressed.emit()
    await _frames(2)
    var blocker: Control = main.get_node("Dialogue/Blocker")
    _check(main.get_node("Dialogue/Reader").visible and blocker.visible and blocker.mouse_filter == Control.MOUSE_FILTER_STOP,
        "la nota se lee desde NOTAS y bloquea los toques a la mochila")
    var dialogue := main.get_node("Dialogue") as Dialogue
    dialogue.reader_next.pressed.emit()
    await _frames(1)
    _check(dialogue.reader_body.text == platform_document.pages[1], "desde la mochila también se puede cambiar de página")
    dialogue.reader_close.pressed.emit()
    await _frames(2)
    _check(not dialogue.reader.visible, "el botón CERRAR funciona al leer desde la mochila")
    await _close_dialogues()
    _check(not Dialogue.is_open() and paused and menu.visible, "al cerrar la nota se vuelve a la mochila")
    menu._show_tab(false)
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
    var standing: Infected = room.get_node("Enemies/Feeding")
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
    var corpse: Infected = main.room.get_node("Enemies/Feeding")
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


## Recorrido del capítulo sin arma: encontrar la pistola, abrir el portón con
## la llave y bajar a la vía.
func _chapter_route(player: Player) -> void:
    GameState.inventory.clear()
    GameState.equipped = null
    GameState.clip = 0
    GameState.flags.clear()
    player.combat.sync_from_state()
    await _frames(2)
    _check(not main.get_node("HUD/AimButton").visible, "sin arma no aparece APUNTAR")

    SceneLoader.go_to(TICKET_OFFICE, "from_waiting_room")
    await _seconds(1.4)
    _check(main.room.scene_file_path == TICKET_OFFICE, "se puede entrar a la boletería")
    var pistol: Pickup = main.room.get_node("Interactables/Pistol")
    player.global_position = Vector3(pistol.global_position.x + 0.65, 0.05, pistol.global_position.z)
    player.face_direction(Vector3.LEFT, 1.0)
    await _frames(3)
    _check(player.interaction.focus == pistol, "Cony tiene a mano la pistola del escritorio")
    player.interaction.use(pistol)
    await _close_dialogues()
    _check(GameState.equipped == PISTOL and player.combat.clip == 10, "la pistola encontrada queda equipada y cargada")
    _check(GameState.has_flag("found:pistol"), "encontrar la pistola queda anotado")
    _check(main.get_node("HUD/AimButton").visible, "con la pistola aparece APUNTAR")

    # Con la pistola, el andén ya tiene infectados.
    SceneLoader.go_to(GameState.START_ROOM, "from_south_platform")
    await _seconds(1.4)
    _check(main.room.get_tree().get_nodes_in_group("enemies").size() == 2, "al volver armada, llegaron infectados al andén")
    for enemy in main.room.get_tree().get_nodes_in_group("enemies"):
        enemy.free()
    var gate: Door = main.room.get_node("Interactables/Gate")
    _check(gate.is_locked(), "el portón al andén sur tiene candado")
    GameState.inventory.add(KEY)
    player.interaction.use(gate)
    await _close_dialogues()
    await _seconds(1.4)
    _check(main.room.scene_file_path == SOUTH_PLATFORM, "con la llave, el portón lleva al andén sur")

    for enemy in main.room.get_tree().get_nodes_in_group("enemies"):
        enemy.free()
    var exit: Interactable = main.room.get_node("Interactables/TrackExit")
    player.global_position = Vector3(exit.global_position.x, 0.05, exit.global_position.z + 0.7)
    player.face_direction(Vector3.FORWARD, 1.0)
    await _frames(3)
    _check(player.interaction.focus == exit, "Cony tiene a mano la bajada a la vía")
    player.interaction.use(exit)
    await _frames(4)
    _check(Dialogue._instance._asking, "bajar a la vía pide confirmación")
    Dialogue.choose(0)
    await _seconds(1.2)
    _check(current_scene != null and current_scene.scene_file_path == "res://ui/chapter_end/chapter_end.tscn",
        "bajar a la vía cierra el capítulo 1")
    _check(GameState.has_flag("chapter_done:1"), "el capítulo 1 queda anotado como terminado")
