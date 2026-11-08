@tool
class_name KitBlock
extends StaticBody3D
## Pieza modular del escenario: una caja con material PS1 y su colisión.
## Muros, pisos, techos, zócalos, bancas... todo se arma con estas piezas
## colocadas sobre la grilla de 1 m (ver docs/ART_PIPELINE.md).
## El material usa coordenadas del mundo, así que la caja puede tener
## cualquier tamaño sin que la textura se estire.

@export var size: Vector3 = Vector3(1.0, 3.0, 0.3):
    set(value):
        size = value
        _rebuild()
@export var surface: Material:
    set(value):
        surface = value
        _rebuild()
## false = sólo visual (Cony la atraviesa).
@export var solid: bool = true:
    set(value):
        solid = value
        _rebuild()
@export var cast_shadow: bool = false:
    set(value):
        cast_shadow = value
        _rebuild()

var _mesh_instance: MeshInstance3D
var _shape: CollisionShape3D


func _ready() -> void:
    _rebuild()


func _rebuild() -> void:
    if not is_inside_tree():
        return
    if _mesh_instance == null:
        _mesh_instance = MeshInstance3D.new()
        _mesh_instance.name = "Mesh"
        add_child(_mesh_instance, false, Node.INTERNAL_MODE_FRONT)
        _shape = CollisionShape3D.new()
        _shape.name = "Shape"
        add_child(_shape, false, Node.INTERNAL_MODE_FRONT)
    var box := BoxMesh.new()
    box.size = size
    _mesh_instance.mesh = box
    _mesh_instance.material_override = surface
    _mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if cast_shadow else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    var shape := BoxShape3D.new()
    shape.size = size
    _shape.shape = shape
    _shape.disabled = not solid
