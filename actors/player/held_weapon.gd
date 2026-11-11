extends Node3D
## Arma en la mano de Cony (todas menos la pistola, que tiene su escena propia).
## El modelo viene del WeaponData; el fogonazo se ubica en la boca del cañón.

@onready var _grip: Node3D = $Grip
@onready var _muzzle: Node3D = $Grip/Muzzle
@onready var _light: OmniLight3D = $Grip/Muzzle/Light
@onready var _flash_mesh: MeshInstance3D = $Grip/Muzzle/Flash
@onready var _core_mesh: MeshInstance3D = $Grip/Muzzle/Core

var _flash_scale := 1.0


func _ready() -> void:
    _light.visible = false
    _flash_mesh.visible = false
    _core_mesh.visible = false


func setup(weapon: WeaponData) -> void:
    if weapon.held_model:
        var model := weapon.held_model.instantiate() as Node3D
        _grip.add_child(model)
        _grip.move_child(model, 0)
        Player._make_textures_crisp(model)
    _muzzle.position = weapon.muzzle_offset
    _flash_scale = weapon.flash_scale


func flash() -> void:
    _light.light_energy = randf_range(2.2, 3.2) * _flash_scale
    _flash_mesh.rotation.z = randf() * TAU
    _flash_mesh.scale = Vector3(randf_range(0.85, 1.15), randf_range(0.8, 1.2), 1.0) * _flash_scale
    _core_mesh.scale = Vector3.ONE * randf_range(0.85, 1.1) * _flash_scale
    _light.visible = true
    _flash_mesh.visible = true
    _core_mesh.visible = true
    await get_tree().create_timer(0.055).timeout
    _light.visible = false
    _flash_mesh.visible = false
    _core_mesh.visible = false


func get_muzzle_position() -> Vector3:
    return _muzzle.global_position
