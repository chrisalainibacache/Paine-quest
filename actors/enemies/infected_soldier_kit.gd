extends RefCounted
## Equipo del soldado infectado: uniforme de camuflaje, casco de combate, chaleco táctico y cinturón.
## Todo se arma por código sobre los huesos del modelo (medidas en metros, huesos humanoides).

const CAMO := preload("res://assets/characters/infected/camo_woodland.png")
const GEAR_COLOR := Color(0.16, 0.18, 0.12)


## Viste al soldado. `skeleton` es el del modelo ya instanciado.
static func dress(model: Node3D, skeleton: Skeleton3D) -> void:
    _camo_outfit(model)
    _add_helmet(skeleton)
    _add_vest(skeleton)
    _add_belt(skeleton)


## El modelo Moderno trae la ropa como superficie «Outfit»: se cambia por camuflaje mate (sin brillo de mojado).
static func _camo_outfit(model: Node3D) -> void:
    for mesh_instance: MeshInstance3D in model.find_children("*", "MeshInstance3D", true, false):
        for i in mesh_instance.mesh.get_surface_count():
            var source := mesh_instance.mesh.surface_get_material(i) as BaseMaterial3D
            if source == null or source.resource_name != "Outfit":
                continue
            var material := source.duplicate() as BaseMaterial3D
            material.albedo_texture = CAMO
            material.albedo_color = Color(0.95, 0.95, 0.9)
            material.uv1_scale = Vector3(2.5, 2.5, 1.0)
            material.roughness = 0.95
            material.roughness_texture = null
            material.metallic = 0.0
            material.metallic_texture = null
            material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
            mesh_instance.set_surface_override_material(i, material)


static func _gear_material(color: Color, camo: bool = false) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = 0.9
    if camo:
        material.albedo_texture = CAMO
        material.uv1_scale = Vector3(2.0, 2.0, 1.0)
        material.albedo_color = Color(0.85, 0.85, 0.8)
    return material


static func _attach(skeleton: Skeleton3D, bone_name: String) -> BoneAttachment3D:
    var attachment := BoneAttachment3D.new()
    attachment.bone_name = bone_name
    skeleton.add_child(attachment)
    return attachment


static func _box(parent: Node3D, size: Vector3, at: Vector3, material: Material, tilt: float = 0.0) -> MeshInstance3D:
    var piece := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = size
    piece.mesh = mesh
    piece.material_override = material
    piece.position = at
    piece.rotation.x = tilt
    parent.add_child(piece)
    return piece


## Casco de combate: cúpula que cubre la coronilla y los lados, con una cinta; sin ala plana.
static func _add_helmet(skeleton: Skeleton3D) -> void:
    if skeleton.find_bone("Head") < 0:
        return
    var attachment := _attach(skeleton, "Head")
    var camo := _gear_material(Color.WHITE, true)
    var shell := MeshInstance3D.new()
    var dome := SphereMesh.new()
    dome.radius = 0.135
    dome.height = 0.2
    dome.radial_segments = 14
    dome.rings = 8
    shell.mesh = dome
    shell.material_override = camo
    shell.position = Vector3(0, 0.125, -0.012)
    shell.rotation.x = -0.12
    attachment.add_child(shell)
    # Borde inferior oscuro (forro) y correa bajo la barbilla.
    var band := MeshInstance3D.new()
    var ring := CylinderMesh.new()
    ring.top_radius = 0.139
    ring.bottom_radius = 0.139
    ring.height = 0.022
    ring.radial_segments = 14
    band.mesh = ring
    band.material_override = _gear_material(GEAR_COLOR)
    band.position = Vector3(0, 0.082, -0.012)
    band.rotation.x = -0.12
    attachment.add_child(band)
    for side in [-1.0, 1.0]:
        _box(attachment, Vector3(0.012, 0.11, 0.012), Vector3(0.118 * side, 0.03, 0.01), _gear_material(GEAR_COLOR))
    _box(attachment, Vector3(0.05, 0.04, 0.05), Vector3(0, 0.17, 0.115), _gear_material(GEAR_COLOR), 0.3)  # soporte frontal


## Chaleco táctico: una placa frontal con bolsillos de cargadores (pegada al pecho; el torso se encorva al caminar,
## así que no se pone placa trasera ni tirantes: se verían flotando).
static func _add_vest(skeleton: Skeleton3D) -> void:
    if skeleton.find_bone("Chest") < 0:
        return
    var attachment := _attach(skeleton, "Chest")
    _box(attachment, Vector3(0.30, 0.24, 0.05), Vector3(0, 0.15, 0.085), _gear_material(GEAR_COLOR))
    for i in 3:
        _box(attachment, Vector3(0.07, 0.09, 0.04), Vector3(-0.09 + i * 0.09, 0.09, 0.125), _gear_material(Color(0.22, 0.24, 0.15)))


static func _add_belt(skeleton: Skeleton3D) -> void:
    if skeleton.find_bone("Hips") < 0:
        return
    var attachment := _attach(skeleton, "Hips")
    var gear := _gear_material(GEAR_COLOR)
    _box(attachment, Vector3(0.36, 0.06, 0.24), Vector3(0, 0.1, 0.0), gear)
    _box(attachment, Vector3(0.07, 0.12, 0.05), Vector3(0.2, 0.0, 0.03), gear)  # funda en la cadera
