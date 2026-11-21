class_name SceneLoader
extends Node
## Cambia de sala: fundido a negro, libera la sala anterior, instancia la nueva,
## ubica a Isabella (y a Leo a su lado) en el punto de aparición y elige la cámara.
## Vive como hijo de Main; las puertas llaman a SceneLoader.go_to().

signal room_changed(room: Room)

const FADE_TIME := 0.35

static var _instance: SceneLoader

## Las pruebas automáticas las apagan (el diálogo pausa el juego).
static var intros_enabled := true
## Las pruebas y las capturas la apagan (no hay que esperar un video).
static var cinematics_enabled := true
const OPENING_VIDEO := "res://assets/video/intro.ogv"
var room: Room
var world: Node3D
var player: Player
var leo: Node3D
var fade: ColorRect
var busy := false


func _ready() -> void:
    _instance = self


func setup(world_node: Node3D, player_node: Player, leo_node: Node3D, fade_rect: ColorRect) -> void:
    world = world_node
    player = player_node
    leo = leo_node
    fade = fade_rect


## Empieza el cambio de sala y vuelve al tiro: quien lo pide (una puerta) se
## borra junto con su sala, así que no debe quedarse esperando.
static func go_to(room_path: String, spawn_id: String) -> void:
    if _instance:
        _instance._go_to(room_path, spawn_id)


## Cierra un capítulo: fundido y pantalla de fin.
static func end_chapter(chapter: int) -> void:
    if _instance:
        _instance._end_chapter(chapter)


static func is_busy() -> bool:
    return _instance != null and _instance.busy


static func current_room_path() -> String:
    if _instance and _instance.room:
        return _instance.room.scene_file_path
    return GameState.room_path


## Primera sala al empezar (o al cargar una partida): sin fundido de salida.
func enter_first_room() -> void:
    fade.color.a = 1.0
    _place_room(GameState.room_path, GameState.spawn_id, GameState.use_spawn_transform)
    GameState.use_spawn_transform = false
    await _settle()
    await _play_opening()
    await _fade_to(0.0)
    _announce_place()
    await _play_intro()


## Cinemática de apertura: solo en una partida nueva y una sola vez.
func _play_opening() -> void:
    if not cinematics_enabled or not GameState.has_flag("cinematic:intro_pending"):
        return
    GameState.set_flag("cinematic:intro")
    GameState.flags.erase("cinematic:intro_pending")
    player.controls_locked = true
    await VideoCinematic.play(self, OPENING_VIDEO, "PAINE", "Viernes · 23:40")
    player.controls_locked = false


func _go_to(room_path: String, spawn_id: String) -> void:
    if busy:
        return
    busy = true
    player.controls_locked = true
    await _fade_to(1.0)
    _place_room(room_path, spawn_id, false)
    await _settle()
    Sfx.play("door_close", null, -8.0)
    player.controls_locked = false
    await _fade_to(0.0)
    busy = false
    _announce_place()
    await _play_intro()


## Cartel con el nombre del lugar al entrar a una sala.
func _announce_place() -> void:
    if room != null and not room.room_name.is_empty():
        get_tree().call_group("hud", "show_place", room.room_name)


func _end_chapter(chapter: int) -> void:
    if busy:
        return
    busy = true
    player.controls_locked = true
    GameState.set_flag("chapter_done:%d" % chapter)
    GameState.set_flag("last_chapter_done", chapter)
    GameState.health = player.health
    await _fade_to(1.0)
    get_tree().change_scene_to_file("res://ui/chapter_end/chapter_end.tscn")


func _place_room(room_path: String, spawn_id: String, use_saved_transform: bool) -> void:
    if room:
        # Se saca del árbol al tiro para que sus infectados e interactuables
        # dejen de contar (grupos) en este mismo cuadro.
        world.remove_child(room)
        room.queue_free()
    var scene := load(room_path) as PackedScene
    room = scene.instantiate() as Room
    world.add_child(room)
    # Modo gráfico (Retro / Moderno) sobre la sala recién armada.
    GraphicsSettings.apply(room)
    GameState.room_path = room_path
    GameState.spawn_id = spawn_id

    var spawn := GameState.spawn_transform if use_saved_transform else room.get_spawn(spawn_id)
    # Los marcadores miran hacia -Z; el modelo de Isabella mira hacia +Z.
    var yaw := spawn.basis.get_euler().y + (0.0 if use_saved_transform else PI)
    player.global_position = spawn.origin
    player.rotation = Vector3.ZERO
    player.model.rotation.y = yaw
    player.velocity = Vector3.ZERO
    player.reset_motion()
    room.camera_changed.connect(player.set_camera)
    player.set_flashlight(room.dark)
    # Selección inmediata con la geometría del spawn; _settle la confirma
    # de nuevo después de que el servidor de física actualice las áreas.
    room.pick_camera_for(player)

    var forward := Vector3(sin(yaw), 0.0, cos(yaw))
    var right := Vector3(cos(yaw), 0.0, -sin(yaw))
    leo.global_position = spawn.origin - forward * 0.3 + right * 0.7
    leo.velocity = Vector3.ZERO
    room_changed.emit(room)


## Reproduce la cinemática de la sala una sola vez por partida.
func _play_cinematic() -> void:
    if not SceneLoader.cinematics_enabled or room == null or room.cinematic.is_empty():
        return
    var flag := "cinematic:" + room.scene_file_path
    if GameState.has_flag(flag) or not ResourceLoader.exists(room.cinematic):
        return
    var packed := load(room.cinematic) as PackedScene
    if packed == null:
        push_warning("No se pudo cargar la cinemática de %s" % room.scene_file_path)
        return
    var cinematic := packed.instantiate() as Cinematic
    if cinematic == null:
        push_warning("La cinemática de %s no tiene el nodo esperado" % room.scene_file_path)
        return

    GameState.set_flag(flag)
    var previous_camera := room.get_active_camera()
    var player_was_locked := player.controls_locked
    var hud := get_tree().get_first_node_in_group("hud") as CanvasLayer
    var hud_was_visible := hud.visible if hud else false
    var room_lights: Array[Light3D] = []
    for node: Node in room.find_children("*", "Light3D", true, false):
        var light := node as Light3D
        room_lights.append(light)
        light.visible = false
    player.controls_locked = true
    player.model.visible = false
    leo.visible = false
    if hud:
        hud.visible = false
    world.add_child(cinematic)
    await cinematic.play()
    cinematic.queue_free()
    await get_tree().process_frame
    await get_tree().process_frame
    if is_instance_valid(previous_camera):
        previous_camera.make_current()
    for light in room_lights:
        if is_instance_valid(light):
            light.visible = true
    # En juego Isabella y Leo siempre se ven: restaurar «lo que había» fallaba si la sala los tenía ocultos un instante.
    player.model.visible = true
    leo.visible = true
    if hud:
        hud.visible = hud_was_visible
    player.controls_locked = player_was_locked


## Primera visita a una sala con intro: Isabella cuenta qué ve (una sola vez).
func _play_intro() -> void:
    if room == null:
        return
    await _play_cinematic()
    if room.intro_lines.is_empty() or not intros_enabled:
        return
    var flag := "intro:" + GameState.room_path
    if GameState.has_flag(flag):
        return
    GameState.set_flag(flag)
    await Dialogue.say(Array(room.intro_lines))


## Las áreas de cámara detectan a Isabella recién en el siguiente paso de física.
func _settle() -> void:
    await get_tree().physics_frame
    await get_tree().physics_frame
    room.pick_camera_for(player)


func _fade_to(alpha: float) -> void:
    var tween := create_tween()
    tween.tween_property(fade, "color:a", alpha, FADE_TIME)
    await tween.finished
