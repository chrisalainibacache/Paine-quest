extends Node3D
## Pistola 9 mm de Cony (low poly). Va pegada al hueso de la mano derecha.
## flash() enciende el fogonazo un instante.

@onready var _light: OmniLight3D = $Grip/Muzzle/Light
@onready var _flash_mesh: MeshInstance3D = $Grip/Muzzle/Flash


func _ready() -> void:
    _light.visible = false
    _flash_mesh.visible = false


func flash() -> void:
    _light.visible = true
    _flash_mesh.visible = true
    _flash_mesh.rotation.z = randf() * TAU
    await get_tree().create_timer(0.06).timeout
    _light.visible = false
    _flash_mesh.visible = false


func get_muzzle_position() -> Vector3:
    return $Grip/Muzzle.global_position
