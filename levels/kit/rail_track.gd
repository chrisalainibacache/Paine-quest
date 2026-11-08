@tool
class_name RailTrack
extends Node3D
## Tramo de vía recto a lo largo del eje X local: durmientes de madera
## (MultiMesh: un solo dibujo para todos) y dos rieles de metal.

@export var length: float = 10.0:
    set(value):
        length = value
        _rebuild()
@export var sleeper_material: Material:
    set(value):
        sleeper_material = value
        _rebuild()
@export var rail_material: Material:
    set(value):
        rail_material = value
        _rebuild()

const GAUGE := 1.0
const SLEEPER_STEP := 0.65

var _built: Array[Node] = []


func _ready() -> void:
    _rebuild()


func _rebuild() -> void:
    if not is_inside_tree():
        return
    for node in _built:
        node.queue_free()
    _built.clear()

    var sleeper := BoxMesh.new()
    sleeper.size = Vector3(0.24, 0.12, GAUGE + 0.8)
    var multimesh := MultiMesh.new()
    multimesh.transform_format = MultiMesh.TRANSFORM_3D
    multimesh.mesh = sleeper
    var count := int(length / SLEEPER_STEP)
    multimesh.instance_count = count
    for i in count:
        var x := -length * 0.5 + (i + 0.5) * SLEEPER_STEP
        # Pequeño desorden: durmientes viejos, no perfectos.
        var jitter := sin(i * 12.9898) * 0.04
        var basis := Basis(Vector3.UP, jitter)
        multimesh.set_instance_transform(i, Transform3D(basis, Vector3(x, 0.06, jitter * 0.5)))
    var sleepers := MultiMeshInstance3D.new()
    sleepers.multimesh = multimesh
    sleepers.material_override = sleeper_material
    _add(sleepers)

    for side in [-1.0, 1.0]:
        var rail := MeshInstance3D.new()
        var rail_mesh := BoxMesh.new()
        rail_mesh.size = Vector3(length, 0.14, 0.08)
        rail.mesh = rail_mesh
        rail.material_override = rail_material
        rail.position = Vector3(0.0, 0.19, side * GAUGE * 0.5)
        _add(rail)


func _add(node: Node3D) -> void:
    add_child(node, false, Node.INTERNAL_MODE_FRONT)
    _built.append(node)
