@tool
class_name CameraZone
extends Area3D
## Zona invisible con una cámara fija (estilo Resident Evil). Cuando Cony entra,
## la sala corta a esta cámara. Se usa con un hijo Camera3D y un
## CollisionShape3D que define la zona.

signal player_entered(zone: CameraZone)
signal player_exited(zone: CameraZone)

## Si dos zonas se solapan, gana la de mayor prioridad.
@export var camera_priority: int = 0


func _ready() -> void:
    if Engine.is_editor_hint():
        return
    collision_layer = 0
    collision_mask = 2  # capa del jugador
    monitorable = false
    body_entered.connect(func(body: Node3D) -> void:
        if body.is_in_group("player"):
            player_entered.emit(self))
    body_exited.connect(func(body: Node3D) -> void:
        if body.is_in_group("player"):
            player_exited.emit(self))


func get_camera() -> Camera3D:
    for child in get_children():
        if child is Camera3D:
            return child
    return null
