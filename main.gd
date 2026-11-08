extends Node
## Escena principal: carga la sala inicial, ubica a Cony y a Leo, y conecta
## la cámara activa de la sala con el control de Cony.
## (Hito 3: el cambio de sala pasará a systems/scene_loader.gd.)

@export var start_room: PackedScene = preload("res://levels/station/platform.tscn")
@export var start_spawn: String = "start"

const PLAYER_SCENE := preload("res://actors/player/player.tscn")
const LEO_SCENE := preload("res://actors/companion/leo.tscn")

var room: Room
var player: Player
var leo: Node3D


func _ready() -> void:
    room = start_room.instantiate() as Room
    $World.add_child(room)

    player = PLAYER_SCENE.instantiate() as Player
    $World.add_child(player)
    player.global_transform = room.get_spawn(start_spawn)
    # El modelo, no el cuerpo, es el que gira hacia donde camina.
    player.model.rotation.y = player.rotation.y + PI
    player.rotation = Vector3.ZERO
    room.camera_changed.connect(player.set_camera)
    $HUD.bind(player)

    leo = LEO_SCENE.instantiate()
    $World.add_child(leo)
    leo.global_position = player.global_position + Vector3(-1.0, 0.0, 0.6)
    leo.target = player

    # Las áreas detectan cuerpos recién en el siguiente paso de física.
    await get_tree().physics_frame
    await get_tree().physics_frame
    room.pick_camera_for(player)
