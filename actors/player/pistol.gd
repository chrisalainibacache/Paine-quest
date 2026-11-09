extends Node3D
## Pistola 9 mm de Cony. El fogonazo dura pocos fotogramas, como en PS1.

@onready var _light: OmniLight3D = $Grip/Muzzle/Light
@onready var _flash_mesh: MeshInstance3D = $Grip/Muzzle/Flash
@onready var _core_mesh: MeshInstance3D = $Grip/Muzzle/Core


func _ready() -> void:
    _light.visible = false
    _flash_mesh.visible = false
    _core_mesh.visible = false


func flash() -> void:
    # Variar forma y giro evita que cada disparo parezca una imagen repetida.
    _light.light_energy = randf_range(2.2, 3.2)
    _flash_mesh.rotation.z = randf() * TAU
    _flash_mesh.scale = Vector3(randf_range(0.85, 1.15), randf_range(0.8, 1.2), 1.0)
    _core_mesh.scale = Vector3.ONE * randf_range(0.85, 1.1)
    _light.visible = true
    _flash_mesh.visible = true
    _core_mesh.visible = true
    await get_tree().create_timer(0.055).timeout
    _light.visible = false
    _flash_mesh.visible = false
    _core_mesh.visible = false


func get_muzzle_position() -> Vector3:
    return $Grip/Muzzle.global_position
