extends RefCounted
## Skull, el original (jefe del capítulo 4): ~2,5 m, encorvado, brazos larguísimos con garras, cráneo alargado
## y púas de hueso en la espalda. Se arma sobre el modelo humanoide (así comparte animaciones y reacciones).
## Nunca se muestra entero antes del combate: la sala decide cuándo aparece.

const SCALE := 1.42
const ARM_STRETCH := 1.75
const BONE_COLOR := Color(0.52, 0.48, 0.4)


static func dress(model: Node3D, skeleton: Skeleton3D) -> void:
    model.scale = Vector3.ONE * SCALE
    # Brazos larguísimos: se alargan los huesos del brazo (el antebrazo y la mano heredan el largo).
    for side in ["Left", "Right"]:
        var upper := skeleton.find_bone(side + "UpperArm")
        if upper >= 0:
            skeleton.set_bone_pose_scale(upper, Vector3(1.0, ARM_STRETCH, 1.0))
        var hand := skeleton.find_bone(side + "Hand")
        if hand >= 0:
            skeleton.set_bone_pose_scale(hand, Vector3(1.2, 0.6, 1.2))  # compensa el largo heredado
            _claws(skeleton, side + "Hand")
    _skull_head(skeleton)
    _spikes(skeleton)


static func _bone_material() -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = BONE_COLOR
    material.roughness = 0.85
    return material


static func _attach(skeleton: Skeleton3D, bone_name: String) -> BoneAttachment3D:
    var attachment := BoneAttachment3D.new()
    attachment.bone_name = bone_name
    skeleton.add_child(attachment)
    return attachment


static func _cone(parent: Node3D, height: float, radius: float, at: Vector3, rotation_deg: Vector3) -> void:
    var piece := MeshInstance3D.new()
    var mesh := CylinderMesh.new()
    mesh.top_radius = 0.0
    mesh.bottom_radius = radius
    mesh.height = height
    mesh.radial_segments = 6
    piece.mesh = mesh
    piece.material_override = _bone_material()
    piece.position = at
    piece.rotation_degrees = rotation_deg
    parent.add_child(piece)


static func _claws(skeleton: Skeleton3D, bone_name: String) -> void:
    var attachment := _attach(skeleton, bone_name)
    for k in 3:
        _cone(attachment, 0.22, 0.014, Vector3((k - 1) * 0.03, 0.14, 0.01), Vector3(0, 0, (k - 1) * 8))


## Cráneo grande y alargado que cuelga hacia adelante, con cuencas negras (sin ojos).
static func _skull_head(skeleton: Skeleton3D) -> void:
    if skeleton.find_bone("Head") < 0:
        return
    var attachment := _attach(skeleton, "Head")
    var skull := MeshInstance3D.new()
    var sphere := SphereMesh.new()
    sphere.radius = 0.105
    sphere.height = 0.5
    sphere.radial_segments = 10
    sphere.rings = 6
    skull.mesh = sphere
    skull.material_override = _bone_material()
    skull.position = Vector3(0, 0.13, -0.045)
    skull.rotation_degrees = Vector3(-32, 0, 0)
    attachment.add_child(skull)
    var void_material := StandardMaterial3D.new()
    void_material.albedo_color = Color(0.01, 0.01, 0.01)
    for side in [-1.0, 1.0]:
        var socket := MeshInstance3D.new()
        var eye := SphereMesh.new()
        eye.radius = 0.032
        eye.height = 0.064
        socket.mesh = eye
        socket.material_override = void_material
        socket.position = Vector3(0.05 * side, 0.075, 0.09)
        attachment.add_child(socket)


static func _spikes(skeleton: Skeleton3D) -> void:
    if skeleton.find_bone("UpperChest") < 0:
        return
    var attachment := _attach(skeleton, "UpperChest")
    for i in 5:
        _cone(attachment, 0.26, 0.032, Vector3(0, 0.1 - i * 0.1, -0.075 - i * 0.012), Vector3(-125 + i * 6, 0, 0))
