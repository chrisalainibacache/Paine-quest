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
    var weapons := 0
    for i in Inventory.SIZE:
        var item := GameState.inventory.get_item(i)
        if item and item.kind == ItemData.Kind.WEAPON:
            weapons += 1
    _check(weapons == 7 and GameState.equipped == PISTOL, "partida nueva: Cony empieza con las 7 armas en la mochila (hay %d)" % weapons)
    for ammo_id in ["ammo_9mm", "ammo_shells", "ammo_rifle", "ammo_grenades", "ammo_rockets"]:
        _check(GameState.inventory.has_id(ammo_id), "y munición %s" % ammo_id)
    await _start_game("user://test_sistemas.json")
    var player: Player = main.player
    _inventory_rules()
    await _leo_warns(player)
    _graphics_modes()
    _leo_guides(player)
    _documents_fit()
    for enemy in main.room.get_tree().get_nodes_in_group("enemies"):
        enemy.free()
    await _pickup_and_note(player)
    await _backpack_menu(player)
    await _doors_and_rooms(player)
    await _locked_door(player)
    await _weapons(player)
    await _chapter_route(player)
    await _chapter_two()
    _finish()


func _inventory_rules() -> void:
    _check(GameState.inventory.has_id("pistol") and GameState.equipped == PISTOL, "con la pistola, queda equipada")
    _check(GameState.inventory.count_of(AMMO) == 20, "y 20 balas de reserva en la mochila")
    var inventory := Inventory.new()
    _check(inventory.add(AMMO, 70) == 0 and inventory.get_count(0) == 60 and inventory.get_count(1) == 10,
        "las balas se apilan hasta 60 por casilla")
    _check(inventory.take(AMMO, 65) == 65 and inventory.count_of(AMMO) == 5, "sacar balas descuenta de las casillas")
    for i in Inventory.SIZE - 1:
        inventory.add(SUSHI)
    _check(inventory.space_for(SUSHI) == 0 and inventory.add(SUSHI) == 1, "con las %d casillas llenas no cabe nada más" % Inventory.SIZE)


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


## Leo guía: con Cony quieta, elige la pista activa de la sala; al encontrar la
## pistola, la pista del andén cambia (de la sala de espera al portón sur).
func _leo_guides(player: Player) -> void:
    var leo: Node3D = main.leo
    var had_pistol_flag := GameState.has_flag("found:pistol")
    GameState.flags.erase("found:pistol")
    var hint: Node3D = leo.active_hint()
    _check(hint != null and hint.name == "LeoWaitingRoom" and leo.has_news(), "Leo: en el andén guía a la sala de espera")
    _check(String(hint.lines[0]).begins_with("Leo: "), "Leo: sus líneas van con su nombre")
    GameState.set_flag("found:pistol")
    hint = leo.active_hint()
    _check(hint != null and hint.name == "LeoGateKey", "Leo: con la pistola, guía al portón sur y a la bodega")
    if not had_pistol_flag:
        GameState.flags.erase("found:pistol")
    var dialogue := main.get_node("Dialogue")
    dialogue._show_text("Leo: Hola, Cony.")
    _check(dialogue.speaker.visible and dialogue.text.text == "Hola, Cony.", "Leo: el cuadro de diálogo muestra su nombre")
    dialogue._show_text("Una línea normal.")
    _check(not dialogue.speaker.visible, "diálogo normal sin nombre")


## Todas las notas caben en el papel del lector (se parten solas si son largas).
func _documents_fit() -> void:
    var dialogue := main.get_node("Dialogue")
    for file in DirAccess.get_files_at("res://data/documents"):
        if not file.ends_with(".tres"):
            continue
        var document := load("res://data/documents/" + file) as DocumentData
        var ok := true
        for page in dialogue.fit_pages(document.pages):
            ok = ok and dialogue._fits_on_paper(page)
        _check(ok, "nota legible sin cortes: %s" % document.title)


## Interruptor Retro / Moderno: cambia materiales, ambiente y filtro, y vuelve.
func _graphics_modes() -> void:
    var block := main.room.find_children("*", "KitBlock", true, false)[0] as KitBlock
    var mesh := block.get_child(0, true) as MeshInstance3D
    var filter := main.get_node("PS1Filter") as CanvasLayer
    GraphicsSettings.set_modern(true)
    GraphicsSettings.apply(main)
    var mat := mesh.material_override as ShaderMaterial
    # El andén norte tiene fondos prerenderizados: sus muros muestran la imagen.
    var prerendered: Node = main.room.get_node_or_null("PrerenderedBackground")
    _check(prerendered != null and mat.shader == preload("res://shaders/prerendered_projection.gdshader")
        and mat.get_shader_parameter("background") != null, "gráficos modernos: el andén usa su fondo prerenderizado")
    # Las salas sin fondo usan el shader HD con relieve.
    var hd := GraphicsSettings._material(load("res://levels/kit/materials/concrete_wall.tres"), true) as ShaderMaterial
    _check(hd.shader == GraphicsSettings.MODERN_SHADER and hd.get_shader_parameter("normal_tex") != null,
        "gráficos modernos: muros con shader HD y relieve")
    _check(not filter.visible, "gráficos modernos: sin filtro PS1")
    var zombie := (load("res://actors/enemies/infected.tscn") as PackedScene).instantiate() as Infected
    main.room.add_child(zombie)
    _check(zombie.model.scene_file_path.ends_with("infected_city.glb") and zombie._anim.has_animation("z/Zombie_Walk_Fwd"),
        "gráficos modernos: infectado detallado con sus animaciones")
    zombie.free()
    var worker := (load("res://actors/enemies/infected.tscn") as PackedScene).instantiate() as Infected
    worker.data = load("res://data/enemies/infected_worker.tres")
    main.room.add_child(worker)
    _check(worker.model.scene_file_path.ends_with("infected_shirt.glb") and worker._anim.has_animation("z/Zombie_Walk_Fwd"),
        "gráficos modernos: obrero con modelo detallado (Biped) y animaciones")
    worker.free()
    GraphicsSettings.set_modern(false)
    GraphicsSettings.apply(main)
    mat = mesh.material_override as ShaderMaterial
    _check(mat.shader == GraphicsSettings.RETRO_SHADER and filter.visible and main.room.get_node_or_null("PrerenderedBackground") == null,
        "gráficos retro: vuelve el look PS1 (sin fondo prerenderizado)")
    var env := (main.room.get_node("Environment") as WorldEnvironment).environment
    var before := env.adjustment_brightness
    GraphicsSettings.cycle_brightness(main.get_tree())
    _check(env.adjustment_enabled and env.adjustment_brightness != before, "brillo: el botón cambia la luz de la sala")
    for i in GraphicsSettings.BRIGHTNESS_LEVELS.size() - 1:
        GraphicsSettings.cycle_brightness(main.get_tree())
    _check(is_equal_approx(env.adjustment_brightness, before), "brillo: después del último nivel vuelve al primero")


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
    var platform_document := load("res://data/documents/platform_note.tres") as DocumentData
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


## Recorrido del capítulo: munición del guardia en la boletería, abrir el
## portón con la llave y bajar a la vía.
func _chapter_route(player: Player) -> void:
    GameState.inventory.clear()
    GameState.equipped = null
    GameState.clip = 0
    GameState.flags.clear()
    player.combat.sync_from_state()
    await _frames(2)
    _check(not main.get_node("HUD/AimButton").visible, "sin arma no aparece APUNTAR")

    # Un arma recogida sin tener otra equipada queda lista y cargada.
    var found := Pickup.new()
    found.item = PISTOL
    main.room.add_child(found)
    found.global_position = player.global_position + player.get_forward() * 0.6
    player.interaction.use(found)
    await _close_dialogues()
    _check(GameState.equipped == PISTOL and player.combat.clip == 10, "un arma recogida sin otra equipada queda equipada y cargada")
    _check(main.get_node("HUD/AimButton").visible, "con un arma aparece APUNTAR")

    SceneLoader.go_to(TICKET_OFFICE, "from_waiting_room")
    await _seconds(1.4)
    _check(main.room.scene_file_path == TICKET_OFFICE, "se puede entrar a la boletería")
    var guard_ammo: Pickup = main.room.get_node("Interactables/GuardAmmo")
    var ammo_before := GameState.inventory.count_of(AMMO)
    player.global_position = Vector3(guard_ammo.global_position.x + 0.65, 0.05, guard_ammo.global_position.z)
    player.face_direction(Vector3.LEFT, 1.0)
    await _frames(3)
    _check(player.interaction.focus == guard_ammo, "Cony tiene a mano la munición del guardia")
    player.interaction.use(guard_ammo)
    await _close_dialogues()
    _check(GameState.inventory.count_of(AMMO) > ammo_before, "la munición del guardia queda en la mochila")
    _check(GameState.has_flag("found:pistol"), "pasar por la boletería queda anotado")

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


## Armas del arsenal: daño de la escopeta según distancia, ráfaga del fusil,
## cargador propio por arma y explosión que alcanza a varios infectados.
func _weapons(player: Player) -> void:
    var shotgun := load("res://data/weapons/shotgun.tres") as WeaponData
    _check(shotgun.damage_at(1.5) == 5 and shotgun.damage_at(9.0) == 1, "la escopeta pega fuerte de cerca y casi nada de lejos")
    for enemy in main.room.get_tree().get_nodes_in_group("enemies"):
        enemy.free()
    var combat := player.combat
    var room: Room = main.room
    player.global_position = Vector3(-4.0, 0.05, 2.5)
    player.model.rotation.y = PI / 2.0

    # Fusil de asalto: un toque = ráfaga de 3.
    var rifle_item := load("res://data/items/assault_rifle.tres") as ItemData
    GameState.inventory.add(rifle_item)
    GameState.inventory.add(load("res://data/items/ammo_rifle.tres"), 30)
    var pistol_clip := combat.clip
    GameState.equip(rifle_item)
    combat.sync_from_state()
    _check(combat.clip == 30 and combat.held != null, "el fusil se equipa con su cargador y su modelo en la mano")
    var dummy: Infected = (load("res://actors/enemies/infected.tscn") as PackedScene).instantiate()
    room.add_child(dummy)
    dummy.global_position = player.global_position + Vector3(5.0, 0, 0)
    dummy.data = dummy.data.duplicate()
    dummy.health = 100
    Input.action_press(&"aim")
    await _seconds(0.5)
    await _tap(&"fire")
    await _seconds(0.5)
    _check(combat.clip == 27, "una ráfaga del fusil gasta 3 balas (quedan %d)" % combat.clip)
    Input.action_release(&"aim")
    dummy.free()
    GameState.equip(PISTOL)
    combat.sync_from_state()
    _check(combat.clip == pistol_clip, "al volver a la pistola conserva su cargador (%d)" % combat.clip)

    # Lanzagranadas: una explosión mata a dos infectados juntos.
    var launcher := load("res://data/items/grenade_launcher.tres") as ItemData
    GameState.inventory.add(launcher)
    GameState.equip(launcher)
    combat.sync_from_state()
    var group: Array[Infected] = []
    for i in 2:
        var infected: Infected = (load("res://actors/enemies/infected.tscn") as PackedScene).instantiate()
        room.add_child(infected)
        infected.global_position = player.global_position + Vector3(6.0, 0, -0.5 + i * 1.0)
        infected.set_physics_process(false)
        group.append(infected)
    Input.action_press(&"aim")
    await _seconds(0.5)
    await _tap(&"fire")
    await _seconds(1.0)
    Input.action_release(&"aim")
    _check(not group[0].is_alive() and not group[1].is_alive(), "una granada mata a los dos infectados juntos")
    for infected in group:
        infected.free()
    GameState.equip(PISTOL)
    combat.sync_from_state()

    # Infectado rápido: alterna carreras y pausas.
    var runner: Infected = (load("res://actors/enemies/infected.tscn") as PackedScene).instantiate()
    runner.data = load("res://data/enemies/infected_fast.tres")
    room.add_child(runner)
    runner.set_physics_process(false)
    var fastest := 0.0
    var slowest := INF
    for i in 300:
        var speed := runner._chase_speed(0.02)
        fastest = maxf(fastest, speed)
        slowest = minf(slowest, speed)
    _check(fastest >= 3.0 and slowest < 1.0, "el infectado rápido corre a ráfagas (%.1f / %.1f m/s)" % [fastest, slowest])
    runner.free()


## Capítulo 2: continuar desde el fin del capítulo 1 (punto de control), la
## linterna en el apagón, la reja con la llave del maquinista y el final.
func _chapter_two() -> void:
    var end_screen := current_scene
    _check(end_screen != null and end_screen.has_method("continue_to_next_chapter"), "el fin del capítulo 1 ofrece seguir al capítulo 2")
    main.queue_free()
    await _frames(2)
    end_screen.continue_to_next_chapter()
    await _seconds(2.0)
    main = current_scene
    _check(main != null and main.has_method("retry") and main.room != null, "el capítulo 2 carga")
    if main == null or main.room == null:
        return
    var player: Player = main.player
    _check(main.room.scene_file_path == "res://levels/tracks/track_north.tscn", "el capítulo 2 empieza en la vía norte")
    _check(SaveSystem.has_save() and GameState.has_flag("chapter_started:2"), "al empezar el capítulo 2 se guarda un punto de control")
    var flashlight := player.model.get_node_or_null("Flashlight") as SpotLight3D
    _check(flashlight == null or not flashlight.visible, "en la vía (con luna) la linterna va apagada")

    SceneLoader.go_to("res://levels/tracks/underpass.tscn", "from_convoy")
    await _seconds(1.4)
    flashlight = player.model.get_node_or_null("Flashlight") as SpotLight3D
    _check(main.room.dark and flashlight != null and flashlight.visible, "en el paso bajo nivel (apagón) Cony enciende la linterna")

    SceneLoader.go_to("res://levels/tracks/convoy_side.tscn", "from_underpass")
    await _seconds(1.4)
    for enemy in main.room.get_tree().get_nodes_in_group("enemies"):
        enemy.free()
    var gate: Door = main.room.get_node("Interactables/ToUnderpass")
    _check(gate.is_locked(), "la reja del paso bajo nivel tiene candado")
    GameState.inventory.add(load("res://data/items/engineer_key.tres"))
    player.interaction.use(gate)
    await _close_dialogues()
    await _seconds(1.4)
    _check(main.room.scene_file_path == "res://levels/tracks/underpass.tscn", "con la llave del maquinista se baja al paso")

    SceneLoader.go_to("res://levels/tracks/switch_house.tscn", "from_underpass")
    await _seconds(1.4)
    var exit: Interactable = main.room.get_node("Interactables/TrackExit")
    player.interaction.use(exit)
    await _frames(4)
    Dialogue.choose(0)
    await _seconds(1.2)
    _check(current_scene != null and current_scene.scene_file_path == "res://ui/chapter_end/chapter_end.tscn"
        and GameState.has_flag("chapter_done:2"), "salir de la casa de cambios termina el capítulo 2")
    if current_scene and current_scene.has_node("Title"):
        _check(current_scene.get_node("Title").text == "FIN DEL CAPÍTULO 2" and current_scene.get_node("Buttons/Continue").visible,
            "fin del capítulo 2: se puede seguir al capítulo 3")
        current_scene.continue_to_next_chapter()
        await _seconds(1.5)
        _check(current_scene != null and current_scene.has_node("SceneLoader") and current_scene.room.scene_file_path == "res://levels/buin/bridge.tscn",
            "CONTINUAR lleva al puente del Maipo (capítulo 3)")
