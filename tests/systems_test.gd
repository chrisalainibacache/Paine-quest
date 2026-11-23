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


class FakeAdProvider extends AdProvider:
    var ready := true
    var pending: Callable

    func is_ready() -> bool:
        return ready

    func show(_placement: StringName, on_done: Callable) -> void:
        pending = on_done

    func complete(rewarded: bool) -> void:
        var callback := pending
        pending = Callable()
        if callback.is_valid():
            callback.call(rewarded)


func _run() -> void:
    GameState.new_game()
    var weapons := 0
    for i in Inventory.SIZE:
        var item := GameState.inventory.get_item(i)
        if item and item.kind == ItemData.Kind.WEAPON:
            weapons += 1
    _check(weapons == 7 and GameState.equipped == PISTOL, "partida nueva: Isabella empieza con las 7 armas en la mochila (hay %d)" % weapons)
    for ammo_id in ["ammo_9mm", "ammo_shells", "ammo_rifle", "ammo_grenades", "ammo_rockets"]:
        _check(GameState.inventory.has_id(ammo_id), "y munición %s" % ammo_id)
    await _start_game("user://test_sistemas.json")
    _audio_systems()
    _ads_systems()
    _ads_inventory_offers(main.player)
    await _opening_cinematic()
    var player: Player = main.player
    _inventory_rules()
    _coop_network()
    _coop_lines()
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
    await _cinematic()
    await _ignacia()
    _finish()


## Anuncios: proveedor falso, límites de frecuencia y compra para quitar anuncios.
func _ads_systems() -> void:
    var original_play_time := GameState.play_time
    var saved_enemy_states: Dictionary = {}
    for enemy: Node in get_nodes_in_group("enemies"):
        if enemy is Infected:
            saved_enemy_states[enemy] = enemy.state
            enemy.state = Infected.State.IDLE
    GameState.play_time = 60.0
    Ads.reset_for_tests()
    var provider := FakeAdProvider.new()
    Ads.configure_provider(provider)
    _check(Ads.available(), "anuncios: el proveedor de prueba está disponible tras 60 s de partida")

    var skipped_reward := [true]
    Ads.show_rewarded(&"test", func(was_rewarded: bool) -> void:
        skipped_reward[0] = was_rewarded
    )
    _check(provider.pending.is_valid(), "anuncios: al solicitarlo se abre el proveedor falso")
    provider.complete(false)
    _check(not skipped_reward[0], "anuncios: saltar el anuncio no entrega la recompensa")

    Ads._last_shown_unix = 0.0
    Ads._last_play_time = 0.0
    Ads._chapter_count = 0
    var rewarded := [false]
    Ads.show_rewarded(&"test", func(was_rewarded: bool) -> void:
        rewarded[0] = was_rewarded
    )
    _check(provider.pending.is_valid(), "anuncios: el proveedor permite iniciar otra prueba tras reiniciar el límite")
    provider.complete(true)
    _check(rewarded[0], "anuncios: completar la cuenta regresiva entrega la recompensa")
    _check(not Ads.available(), "anuncios: el enfriamiento impide mostrar otro anuncio")

    Ads._last_shown_unix = Time.get_unix_time_from_system() - Ads.config.cooldown_seconds - 1.0
    GameState.play_time += Ads.config.minimum_play_seconds
    Ads._last_play_time = GameState.play_time - Ads.config.minimum_play_seconds
    Ads._chapter_count = Ads.config.max_per_chapter
    _check(not Ads.available(), "anuncios: se respeta el máximo de tres por capítulo")

    Ads.removed = true
    provider.ready = false
    _check(Ads.available(), "anuncios: quitar publicidad habilita la recompensa sin proveedor")
    var removed_reward := [false]
    Ads.show_rewarded(&"test", func(was_rewarded: bool) -> void:
        removed_reward[0] = was_rewarded
    )
    _check(removed_reward[0] and not provider.pending.is_valid(),
        "anuncios: con publicidad quitada entrega la recompensa sin mostrar anuncio")
    var saved := ConfigFile.new()
    _check(saved.load(GameSettings.SETTINGS_PATH) == OK and bool(saved.get_value("ads", "removed", false)),
        "anuncios: Ads.removed queda persistido en ajustes.cfg")

    Ads.removed = false
    Ads.configure_provider(null)
    Ads.reset_for_tests()
    GameState.play_time = original_play_time
    for enemy: Node in saved_enemy_states:
        if is_instance_valid(enemy):
            enemy.state = saved_enemy_states[enemy]


## Ofertas de mochila: munición escasa, curativo en Peligro y bloqueo durante combate.
func _ads_inventory_offers(player: Player) -> void:
    var original_play_time := GameState.play_time
    var original_health := player.health
    var original_reserve := GameState.inventory.count_of(AMMO)
    var saved_enemy_states: Dictionary = {}
    for enemy: Node in get_nodes_in_group("enemies"):
        if enemy is Infected:
            saved_enemy_states[enemy] = enemy.state
            enemy.state = Infected.State.IDLE

    var combat_enemy: Infected = (load("res://actors/enemies/infected.tscn") as PackedScene).instantiate()
    main.room.add_child(combat_enemy)
    combat_enemy.state = Infected.State.CHASE
    GameState.play_time = 60.0
    Ads.reset_for_tests()
    var provider := FakeAdProvider.new()
    Ads.configure_provider(provider)
    _check(not Ads.available(), "anuncios: se bloquean durante el combate")
    player.health = 0
    GameState.health = 0
    _check(Ads.available(), "anuncios: la pantalla de muerte permite ofrecer CONTINUAR")
    player.health = original_health
    GameState.health = original_health
    combat_enemy.free()

    GameState.inventory.take(AMMO, 999)
    var menu := (load("res://ui/inventory/inventory_menu.tscn") as PackedScene).instantiate()
    root.add_child(menu)
    menu.call("open", player)
    var reward_ammo_button := menu.get_node("Root/Info/RewardButtons/RewardAmmo") as Button
    var reward_heal_button := menu.get_node("Root/Info/RewardButtons/RewardHeal") as Button
    Ads.reset_for_tests()
    Ads.configure_provider(provider)
    _check(reward_ammo_button.visible, "mochila: aparece +MUNICIÓN cuando la reserva está vacía")
    reward_ammo_button.pressed.emit()
    _check(provider.pending.is_valid(), "mochila: +MUNICIÓN abre el proveedor")
    provider.complete(true)
    _check(GameState.inventory.count_of(AMMO) == Ads.config.pistol_ammo_reward,
        "mochila: completar el anuncio entrega la cantidad configurada de balas")

    Ads.reset_for_tests()
    player.health = 20
    GameState.health = 20
    menu.call("_refresh")
    _check(reward_heal_button.visible, "mochila: aparece +1 CURATIVO en Peligro sin curativos")
    reward_heal_button.pressed.emit()
    _check(provider.pending.is_valid(), "mochila: +1 CURATIVO abre el proveedor")
    provider.complete(true)
    _check(GameState.inventory.count_of(SUSHI) == 1, "mochila: completar el anuncio entrega un curativo")

    _check(main.get_node("HUD/DeathScreen/RewardContinue") is Button,
        "muerte: existe el botón VER ANUNCIO: CONTINUAR")
    _check(main.has_method("continue_after_reward"), "muerte: continuar usa el punto seguro y media salud")

    menu.call("close")
    menu.queue_free()
    GameState.inventory.take(AMMO, 999)
    GameState.inventory.add(AMMO, original_reserve)
    GameState.inventory.take(SUSHI, 999)
    player.health = original_health
    GameState.health = original_health
    GameState.play_time = original_play_time
    Ads.configure_provider(null)
    Ads.reset_for_tests()
    for enemy: Node in saved_enemy_states:
        if is_instance_valid(enemy):
            enemy.state = saved_enemy_states[enemy]


## Cinemática de apertura: una partida nueva la deja pendiente; sin video no cuelga nada.
func _opening_cinematic() -> void:
    _check(GameState.has_flag("cinematic:intro_pending"), "cinemática: una partida nueva deja la apertura pendiente")
    await VideoCinematic.play(main, "res://assets/video/no_existe.ogv", "X", "Y")
    _check(true, "cinemática: un video que no existe se salta sin colgar el juego")
    if ResourceLoader.exists(SceneLoader.OPENING_VIDEO):
        _check(load(SceneLoader.OPENING_VIDEO) is VideoStream, "cinemática: el video de apertura se puede leer")
    _check(not SceneLoader.cinematics_enabled, "cinemática: las pruebas la tienen apagada")


## Audio: muestras reales, alias de armas, fallback sintetizado y director.
func _audio_systems() -> void:
    _check(AudioServer.get_bus_index("Master") == 0 and AudioServer.get_bus_index("Sfx") >= 0
        and AudioServer.get_bus_index("Music") >= 0 and AudioServer.get_bus_index("Ambience") >= 0
        and AudioServer.get_bus_index("Ui") >= 0, "audio: existen los cinco buses")
    for sound in ["shot", "shotgun", "assault", "bazooka", "mauser"]:
        _check(Sfx._instance._stream_for(sound) is AudioStreamOggVorbis, "audio: carga muestra OGG para %s" % sound)
    _check(Sfx._instance._choose_stream("assault", []) == Sfx._instance._streams["rifle"],
        "audio: assault cae al sintetizador rifle si falta su OGG")
    _check(Sfx._instance._choose_stream("bazooka", []) == Sfx._instance._streams["launcher"],
        "audio: bazooka cae al sintetizador launcher si falta su OGG")
    _check(Sfx._instance._choose_stream("mauser", []) == Sfx._instance._streams["shot"],
        "audio: mauser cae al sintetizador shot si falta su OGG")
    _check(Sfx._instance._choose_stream("nombre_sin_sonido", []) == null,
        "audio: un nombre sin OGG ni receta no inventa sonido")
    var assault := load("res://data/weapons/assault_rifle.tres") as WeaponData
    var bazooka := load("res://data/weapons/bazooka.tres") as WeaponData
    var mauser := load("res://data/weapons/mauser.tres") as WeaponData
    _check(assault.sound == "assault" and bazooka.sound == "bazooka" and mauser.sound == "mauser",
        "audio: las tres armas nuevas usan sus alias de muestra propios")
    _check(main.get_node_or_null("AudioDirector") != null and AudioDirector._instance != null,
        "audio: el director está integrado en la escena principal")
    var new_fallbacks := {
        "chase": "groan_short", "death": "fall", "rise": "groan", "heavy_step": "fall",
        "groan_far": "groan", "hurt_low": "hurt", "breath_low": "hurt", "door_close": "door",
        "door_metal": "door", "gate_chain": "locked", "heal": "pickup", "radio_static": "typewriter",
    }
    for sound: String in new_fallbacks:
        _check(Sfx._instance._stream_for(sound) is AudioStreamOggVorbis, "audio: carga OGG para %s" % sound)
        _check(Sfx._instance._choose_stream(sound, []) == Sfx._instance._streams[new_fallbacks[sound]],
            "audio: %s conserva fallback sintetizado" % sound)

    AudioDirector.play_music("title")
    _check(AudioDirector.current_music_track() == "title", "audio: la música title se puede seleccionar")
    AudioDirector.play_music("leo")
    _check(AudioDirector.current_music_track() == "leo", "audio: la música leo se puede seleccionar para el epílogo")
    var safe_room := Room.new()
    var typewriter := Node.new()
    typewriter.name = "Typewriter"
    safe_room.add_child(typewriter)
    AudioDirector._instance._on_room_changed(safe_room)
    _check(AudioDirector._instance._chapter_track == "safe" and AudioDirector.current_music_track() == "safe",
        "audio: una sala con máquina de escribir usa la pista safe")
    AudioDirector._instance._on_room_changed(main.room)
    safe_room.free()

    Sfx.reset_play_counts()
    var heavy_infected := Infected.new()
    heavy_infected.data = load("res://data/enemies/infected_heavy.tres") as EnemyData
    heavy_infected._play_chase_sound()
    heavy_infected._play_rise_sound()
    heavy_infected._play_death_sound()
    heavy_infected._play_heavy_step()
    heavy_infected._play_groan(true)
    _check(Sfx.play_count("chase") == 1 and Sfx.play_count("rise") == 1 and Sfx.play_count("death") == 1,
        "audio: persecución rápida, levantarse y muerte solicitan sus sonidos")
    _check(Sfx.play_count("heavy_step") == 1 and Sfx.play_count("groan_far") == 1,
        "audio: infectado pesado y gruñido fuera de cuadro solicitan sus sonidos")
    heavy_infected.free()

    var locked_before := Sfx.play_count("locked")
    var name_only_gate := Door.new()
    name_only_gate.name = "Gate"
    name_only_gate._play_locked_sound()
    _check(Sfx.play_count("locked") == locked_before + 1,
        "audio: el nombre Gate no convierte una puerta de madera en metálica")
    name_only_gate.free()

    var gate := Door.new()
    gate.name = "GateToNorth"
    gate.metal_door = true
    gate._play_locked_sound()
    gate._play_open_sound()
    _check(Sfx.play_count("gate_chain") == 1 and Sfx.play_count("door_metal") == 1,
        "audio: el campo metal_door selecciona cadena y puerta metálica")
    gate.free()

    var heavy_data := load("res://data/enemies/infected_heavy.tres") as EnemyData
    var normal_data := load("res://data/enemies/infected.tres") as EnemyData
    _check(heavy_data != null and heavy_data.heavy, "enemigos: el tipo pesado se define con EnemyData.heavy")
    _check(normal_data != null and not normal_data.heavy, "enemigos: el tipo normal no usa pasos pesados")

    var radio_script := load("res://levels/kit/interact/chapter_exit.gd") as GDScript
    var radio: Interactable = radio_script.new()
    radio.name = "Radio"
    radio.call("_play_radio_static")
    _check(Sfx.play_count("radio_static") == 1, "audio: la radio de Paz solicita estática")
    radio.free()

    var test_player: Player = main.player
    var old_health: int = test_player.health
    var old_controls_locked: bool = test_player.controls_locked
    test_player.controls_locked = false
    test_player.health = 20
    Sfx.reset_play_counts()
    test_player._play_hurt_sound()
    test_player._danger_breath_timer = 0.0
    test_player._update_danger_breath(0.1)
    _check(Sfx.play_count("hurt_low") == 1 and Sfx.play_count("breath_low") == 1,
        "audio: Isabella en Peligro usa quejido y respiración baja")
    test_player.health = old_health
    test_player.controls_locked = old_controls_locked
    test_player._danger_breath_timer = 0.0
    var was_enabled := AudioDirector.enabled
    AudioDirector.enabled = false
    _check(not AudioDirector.enabled, "audio: el director se puede apagar para pruebas")
    AudioDirector.enabled = was_enabled


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


## Leo guía: con Isabella quieta, elige la pista activa de la sala; al encontrar la
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
    dialogue._show_text("Leo: Hola, Isabella.")
    _check(dialogue.speaker.visible and dialogue.text.text == "Hola, Isabella.", "Leo: el cuadro de diálogo muestra su nombre")
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


## Pantalla DIAG: junta los eventos del juego y los muestra sin errores.
func _diagnostics() -> void:
    Diag.log("prueba de diagnóstico")
    _check(Diag.lines.size() > 0 and "prueba de diagnóstico" in Diag.lines[-1], "diagnóstico: guarda los eventos")
    _check("Paine" in Diag.device_info() and "Ventana" in Diag.device_info(), "diagnóstico: informa del aparato")
    var panel := (load("res://ui/diag_panel.gd") as GDScript).new() as CanvasLayer
    main.add_child(panel)
    var label_found := false
    for node in panel.find_children("*", "Label", true, false):
        label_found = label_found or "prueba de diagnóstico" in (node as Label).text
    _check(label_found, "diagnóstico: la pantalla DIAG muestra los eventos")
    panel.free()


## La malla biselada: caras hacia afuera, normales unitarias y cilindros más redondos.
func _bevel_geometry() -> void:
    var mesh := KitBlock.BEVEL.build(Vector3(2.0, 1.0, 0.5)) as ArrayMesh
    var arrays := mesh.surface_get_arrays(0)
    var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
    var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
    var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
    var outward := true
    for i in range(0, indices.size(), 3):
        var a := vertices[indices[i]]
        var b := vertices[indices[i + 1]]
        var c := vertices[indices[i + 2]]
        var facing := (b - a).cross(c - a)
        var normal := normals[indices[i]] + normals[indices[i + 1]] + normals[indices[i + 2]]
        # Godot: sentido horario = cara frontal, así que la normal geométrica mira hacia adentro.
        if facing.dot(normal) >= 0.0:
            outward = false
    _check(outward, "bisel: todas las caras miran hacia afuera")
    var unit := true
    for n in normals:
        unit = unit and is_equal_approx(n.length(), 1.0)
    _check(unit and mesh.get_aabb().size.is_equal_approx(Vector3(2.0, 1.0, 0.5)), "bisel: normales unitarias y mismo tamaño que la caja")
    _check(KitBlock.BEVEL.build(Vector3(2.0, 0.03, 0.5)) is BoxMesh, "bisel: lo muy delgado queda como caja")
    var wheel := CylinderMesh.new()
    wheel.top_radius = 0.42
    wheel.bottom_radius = 0.42
    wheel.radial_segments = 10
    GraphicsSettings._smooth_cylinder(wheel, true)
    var smooth := wheel.radial_segments
    GraphicsSettings._smooth_cylinder(wheel, false)
    _check(smooth >= 24 and wheel.radial_segments == 10, "cilindros: más lados en Moderno y los originales en Retro")


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
    # Solo si la sala ya tiene imágenes renderizadas para sus cámaras actuales (si se
    # cambian las cámaras hay que volver a renderizar: ver "update grafica.txt").
    if GraphicsSettings.PRERENDERED.has_backgrounds(main.room):
        _check(prerendered != null and mat.shader == preload("res://shaders/prerendered_projection.gdshader")
            and mat.get_shader_parameter("background") != null, "gráficos modernos: el andén usa su fondo prerenderizado")
    else:
        _check(prerendered == null and mat.shader == GraphicsSettings.MODERN_SHADER,
            "gráficos modernos: sin fondos para estas cámaras, la sala se dibuja en vivo")
    # Las salas sin fondo usan el shader HD con relieve.
    var hd := GraphicsSettings._material(load("res://levels/kit/materials/concrete_wall.tres"), true) as ShaderMaterial
    _check(hd.shader == GraphicsSettings.MODERN_SHADER and hd.get_shader_parameter("normal_tex") != null,
        "gráficos modernos: muros con shader HD y relieve")
    _check(not filter.visible, "gráficos modernos: sin filtro PS1")
    _check(mesh.mesh is ArrayMesh, "gráficos modernos: las cajas tienen las aristas biseladas")
    _bevel_geometry()
    _diagnostics()
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
    _check(mesh.mesh is BoxMesh, "gráficos retro: las cajas vuelven a ser cajas (look PS1)")
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
    _check(player.interaction.focus == ammo, "Isabella tiene a mano la caja de balas")
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
    _check(player.interaction.focus == note, "Isabella tiene a mano la nota de la banca")
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
    Sfx.reset_play_counts()
    menu._use_selected()
    _check(Sfx.play_count("heal") == 1, "audio: comer solicita el sonido heal")
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
    _check(player.interaction.focus == door, "Isabella tiene a mano la puerta de la sala de espera")
    Sfx.reset_play_counts()
    player.interaction.use(door)
    await _seconds(1.4)
    _check(Sfx.play_count("door") > 0 and Sfx.play_count("door_close") > 0,
        "audio: abrir y cerrar una puerta solicita sus dos sonidos")
    var room: Room = main.room
    _check(room.scene_file_path == WAITING_ROOM, "la puerta lleva a la sala de espera")
    _check(not is_instance_valid(platform) or not platform.is_inside_tree(), "el andén se descarga")
    _check(player.global_position.distance_to(room.get_spawn("from_platform").origin) < 0.3, "Isabella aparece en la entrada")
    _check(room.get_active_camera() == root.get_viewport().get_camera_3d(), "se activa una cámara de la sala nueva")
    _check(not player.controls_locked, "los controles vuelven tras el fundido")
    _check(player.global_position.distance_to(main.leo.global_position) < 1.5, "Leo entra con Isabella")
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
    _check(player.interaction.focus == typewriter, "Isabella tiene a mano la máquina de escribir")
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
    _check(player.global_position.distance_to(main.room.get_spawn("from_waiting_room").origin) < 0.3, "Isabella sale por la puerta de la sala")
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
    _check(player.interaction.focus == guard_ammo, "Isabella tiene a mano la munición del guardia")
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
    _check(player.interaction.focus == exit, "Isabella tiene a mano la bajada a la vía")
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
    _check(main.room.dark and flashlight != null and flashlight.visible, "en el paso bajo nivel (apagón) Isabella enciende la linterna")

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


## T9: carga, finalización, bandera de una sola vez y restauración del juego.
func _cinematic() -> void:
    var loader := current_scene.get_node("SceneLoader") as SceneLoader
    loader._place_room("res://levels/tracks/track_north.tscn", "start", false)
    var path := loader.room.cinematic
    _check(path == "res://levels/cinematics/creature_door.tscn", "T9: la vía norte tiene asignada su cinemática")
    var packed := load(path) as PackedScene
    _check(packed != null, "T9: la escena de la cinemática carga")
    if packed == null:
        return
    SceneLoader.cinematics_enabled = true
    loader.call_deferred("_play_cinematic")
    await _frames(2)
    var active := get_root().get_tree().get_first_node_in_group("cinematics") as Cinematic
    _check(active != null, "T9: SceneLoader inicia la cinemática")
    if active:
        active.skip()
    # Espera a que la cinemática termine de verdad (no un número fijo de cuadros: con la máquina cargada varía).
    for i in 240:
        if get_root().get_tree().get_first_node_in_group("cinematics") == null:
            break
        await _frames(1)
    # La restauración corre unos cuadros DESPUÉS de que la cinemática desaparece: se espera la condición, no un número fijo.
    for i in 240:
        if not loader.player.controls_locked and loader.player.model.visible and loader.leo.visible:
            break
        await _frames(1)
    var flag := "cinematic:res://levels/tracks/track_north.tscn"
    _check(GameState.has_flag(flag), "T9: al terminar queda marcada la bandera de esta partida")
    _check(not loader.player.controls_locked and loader.player.model.visible and loader.leo.visible,
        "T9: al terminar vuelven los controles y los personajes (bloqueado=%s, modelo=%s, leo=%s)"
        % [loader.player.controls_locked, loader.player.model.visible, loader.leo.visible])
    await loader._play_cinematic()
    await _frames(1)
    _check(get_root().get_tree().get_first_node_in_group("cinematics") == null,
        "T9: la cinemática no se reproduce una segunda vez")
    SceneLoader.cinematics_enabled = false


## Ignacia (jugadora 2): el modelo con esqueleto carga, comparte las animaciones de Isabella y puede llevar arma.
func _ignacia() -> void:
    var previous := GameSettings.get_character()
    GameSettings.set_character("ignacia")
    var player := (load("res://actors/player/player.tscn") as PackedScene).instantiate() as Player
    current_scene.add_child(player)
    await _frames(2)
    _check(player.model.scene_file_path == "res://assets/characters/ignacia/ignacia.glb", "Ignacia: el jugador usa su modelo")
    var skeleton := player.model.find_child("GeneralSkeleton", true, false) as Skeleton3D
    _check(skeleton != null and skeleton.find_bone("RightHand") >= 0, "Ignacia: tiene esqueleto humanoide con mano derecha")
    var idle := player.anim.get_animation("cony/Idle")
    var resolved := 0
    for t in idle.get_track_count():
        if player.model.get_node_or_null(String(idle.track_get_path(t)).get_slice(":", 0)) != null:
            resolved += 1
    _check(idle.get_track_count() > 0 and resolved == idle.get_track_count(), "Ignacia: las animaciones de Isabella encajan en su esqueleto (%d/%d)" % [resolved, idle.get_track_count()])
    player.queue_free()
    GameSettings.set_character(previous)
    await _frames(1)


## P9-d: codec puro, validación de transporte y carga del menú cooperativo.
func _coop_network() -> void:
    var encoded: Dictionary = NetMessages.encode("ping", {"nonce": 7, "sent_msec": 12})
    _check(bool(encoded.get("ok", false)), "P9: el codec codifica un ping válido")
    var decoded: Dictionary = NetMessages.decode(encoded.get("message", {}))
    _check(bool(decoded.get("ok", false)) and decoded.get("kind", "") == "ping",
        "P9: el codec decodifica el ping")
    _check(decoded.get("fields", {}).get("nonce", -1) == 7, "P9: el codec conserva los campos")

    var unknown: Dictionary = NetMessages.encode("unknown", {})
    _check(not bool(unknown.get("ok", false)), "P9: el codec rechaza tipos desconocidos")
    var extra: Dictionary = {"protocol_version": NetMessages.PROTOCOL_VERSION,
        "kind": "ping", "fields": {"nonce": 1, "sent_msec": 2, "admin": true}}
    _check(not bool(NetMessages.decode(extra).get("ok", false)),
        "P9: el codec rechaza campos no permitidos")
    var wrong_type: Dictionary = {"protocol_version": NetMessages.PROTOCOL_VERSION,
        "kind": "ping", "fields": {"nonce": "7", "sent_msec": 2}}
    _check(not bool(NetMessages.decode(wrong_type).get("ok", false)),
        "P9: el codec rechaza tipos de campo incorrectos")
    var wrong_version: Dictionary = {"protocol_version": 999, "kind": "ping",
        "fields": {"nonce": 1, "sent_msec": 2}}
    _check(not bool(NetMessages.decode(wrong_version).get("ok", false)),
        "P9: el codec rechaza versiones incompatibles")
    var oversized: Dictionary = NetMessages.encode("event",
        {"event_id": 1, "kind": "large", "payload": {"text": "x".repeat(70000)}})
    _check(not bool(oversized.get("ok", false)), "P9: el codec limita el tamaño de los mensajes")

    var session: Node = load("res://systems/net/net_session.gd").new()
    _check(session.call("join", "esto-no-es-una-ip", 7777) == ERR_INVALID_PARAMETER,
        "P9: la sesión rechaza una IP inválida")
    _check(session.call("host", 0) == ERR_INVALID_PARAMETER,
        "P9: la sesión rechaza un puerto fuera de rango")
    session.free()

    var menu: PackedScene = load("res://ui/coop/coop_menu.tscn") as PackedScene
    _check(menu != null, "P9: el menú cooperativo carga como PackedScene")
    if menu != null:
        var instance: Control = menu.instantiate() as Control
        _check(instance != null and instance.has_node("Panel/Layout/TestPanel/Ping"),
            "P9: el menú contiene el panel de ping")
        if instance != null:
            instance.free()


## P9-e: las líneas de Ignacia solo aparecen cuando la partida es cooperativa.
func _coop_lines() -> void:
    var lines: CoopLines = load("res://data/coop/ignacia_lines.tres") as CoopLines
    _check(lines != null and lines.entries.size() >= 35, "P9: el recurso de líneas de Ignacia contiene el guion cooperativo")
    GameState.cooperative = false
    _check(lines.lines_for("station/platform", "coop_intro").is_empty(),
        "P9: una partida individual no muestra líneas de Ignacia")
    GameState.cooperative = true
    var intro: PackedStringArray = lines.lines_for("station/platform", "coop_intro")
    _check(intro.size() == 9, "P9: el encuentro de Ignacia devuelve las nueve líneas aprobadas")
    _check(lines.lines_for("station/ticket_office", "pistol").size() == 1,
        "P9: las líneas se filtran por sala y disparador")
    var forbidden: int = 0
    for entry: Dictionary in lines.entries:
        var line: String = String(entry.get("text", ""))
        if line.contains("Skull") or line.contains("skull") or line.contains("net_session") or line.contains("GameState"):
            forbidden += 1
    _check(forbidden == 0, "P9: los textos no revelan nombres internos ni el nombre de diseño de la criatura")
    GameState.cooperative = false
