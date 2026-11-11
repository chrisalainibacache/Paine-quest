class_name SceneLoader
extends Node
## Cambia de sala: fundido a negro, libera la sala anterior, instancia la nueva,
## ubica a Cony (y a Leo a su lado) en el punto de aparición y elige la cámara.
## Vive como hijo de Main; las puertas llaman a SceneLoader.go_to().

signal room_changed(room: Room)

const FADE_TIME := 0.35

static var _instance: SceneLoader

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
    await _fade_to(0.0)


func _go_to(room_path: String, spawn_id: String) -> void:
    if busy:
        return
    busy = true
    player.controls_locked = true
    await _fade_to(1.0)
    _place_room(room_path, spawn_id, false)
    await _settle()
    player.controls_locked = false
    await _fade_to(0.0)
    busy = false


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
    GameState.room_path = room_path
    GameState.spawn_id = spawn_id

    var spawn := GameState.spawn_transform if use_saved_transform else room.get_spawn(spawn_id)
    # Los marcadores miran hacia -Z; el modelo de Cony mira hacia +Z.
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


## Las áreas de cámara detectan a Cony recién en el siguiente paso de física.
func _settle() -> void:
    await get_tree().physics_frame
    await get_tree().physics_frame
    room.pick_camera_for(player)


func _fade_to(alpha: float) -> void:
    var tween := create_tween()
    tween.tween_property(fade, "color:a", alpha, FADE_TIME)
    await tween.finished
