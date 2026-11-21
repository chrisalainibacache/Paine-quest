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
const BALLAST := preload("res://levels/kit/materials/gravel.tres")

var _built: Array[Node] = []


func _ready() -> void:
    _rebuild()


func _rebuild() -> void:
    if not is_inside_tree():
        return
    for node in _built:
        node.queue_free()
    _built.clear()

    # Acero oxidado de los rieles y las placas.
    var steel := StandardMaterial3D.new()
    steel.albedo_color = Color(0.26, 0.21, 0.17)
    steel.metallic = 0.35
    steel.roughness = 0.7

    # Balasto: lecho de piedra chancada con hombros inclinados, más ancho que los durmientes.
    _add_box(Vector3(length, 0.16, GAUGE + 1.5), Vector3(0.0, 0.07, 0.0), BALLAST)
    _add_box(Vector3(length, 0.07, GAUGE + 2.5), Vector3(0.0, 0.035, 0.0), BALLAST)

    var sleeper := BoxMesh.new()
    sleeper.size = Vector3(0.24, 0.13, GAUGE + 0.9)
    var plate := BoxMesh.new()
    plate.size = Vector3(0.2, 0.025, 0.2)
    var multimesh := MultiMesh.new()
    multimesh.transform_format = MultiMesh.TRANSFORM_3D
    multimesh.mesh = sleeper
    var plates := MultiMesh.new()
    plates.transform_format = MultiMesh.TRANSFORM_3D
    plates.mesh = plate
    var count := int(length / SLEEPER_STEP)
    multimesh.instance_count = count
    plates.instance_count = count * 2
    for i in count:
        var x := -length * 0.5 + (i + 0.5) * SLEEPER_STEP
        # Desorden: durmientes viejos, hundidos y girados a distinto grado.
        var jitter := sin(i * 12.9898) * 0.05
        var sink := 0.02 * sin(i * 4.7)
        var basis := Basis(Vector3.UP, jitter)
        multimesh.set_instance_transform(i, Transform3D(basis, Vector3(x, 0.14 + sink, jitter * 0.6)))
        for k in 2:
            var side := -1.0 if k == 0 else 1.0
            plates.set_instance_transform(i * 2 + k, Transform3D(basis, Vector3(x, 0.215 + sink, side * GAUGE * 0.5 + jitter * 0.6)))
    var sleepers := MultiMeshInstance3D.new()
    sleepers.multimesh = multimesh
    sleepers.material_override = sleeper_material
    _add(sleepers)
    var plate_nodes := MultiMeshInstance3D.new()
    plate_nodes.multimesh = plates
    plate_nodes.material_override = steel
    _add(plate_nodes)

    # Riel de verdad: patín (base), alma y hongo, con el hongo más gastado y brillante.
    var worn := StandardMaterial3D.new()
    worn.albedo_color = Color(0.5, 0.47, 0.44)
    worn.metallic = 0.6
    worn.roughness = 0.38
    for side in [-1.0, 1.0]:
        var z: float = side * GAUGE * 0.5
        _add_box(Vector3(length, 0.03, 0.15), Vector3(0.0, 0.24, z), steel)
        _add_box(Vector3(length, 0.12, 0.045), Vector3(0.0, 0.315, z), steel)
        _add_box(Vector3(length, 0.05, 0.085), Vector3(0.0, 0.4, z), worn)


func _add_box(size: Vector3, pos: Vector3, material: Material) -> void:
    var mesh := MeshInstance3D.new()
    var box := BoxMesh.new()
    box.size = size
    mesh.mesh = box
    mesh.material_override = material
    mesh.position = pos
    _add(mesh)


func _add(node: Node3D) -> void:
    add_child(node, false, Node.INTERNAL_MODE_FRONT)
    _built.append(node)
