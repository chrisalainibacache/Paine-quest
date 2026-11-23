class_name InfectedGore
extends RefCounted
## Violencia visual de los infectados (decisión de Chris: «fuerte»): sangre y manchas distintas en cada uno, heridas que quedan en el
## cuerpo donde pega cada tiro, reacciones al disparo según el lugar del impacto y desmembramiento (cabeza y miembros salen volando).
## Se usa desde infected.gd con tres llamadas marcadas «# GORE». Todo es procedural: texturas en assets/characters/infected/gore/.

const OVERLAYS: Array[Texture2D] = [preload("res://assets/characters/infected/gore/overlay_0.png"), preload("res://assets/characters/infected/gore/overlay_1.png"),
    preload("res://assets/characters/infected/gore/overlay_2.png"), preload("res://assets/characters/infected/gore/overlay_3.png")]
const WOUNDS: Array[Texture2D] = [preload("res://assets/characters/infected/gore/wound_0.png"), preload("res://assets/characters/infected/gore/wound_1.png"),
    preload("res://assets/characters/infected/gore/wound_2.png")]
const STUMP: Texture2D = preload("res://assets/characters/infected/gore/stump.png")
const MAX_WOUNDS := 10
## Daño desde el que un tiro mortal puede arrancar la cabeza / varios miembros (escopeta, francotirador, explosivos).
const HEAD_DAMAGE := 5
const BLAST_DAMAGE := 9


## Cada infectado sale distinto: manchas de sangre propias (textura, posición y cantidad al azar) sobre el cuerpo.
static func dress(zombie: Node3D) -> void:
    var model := zombie.get("model") as Node3D
    if model == null:
        return
    var overlay_texture: Texture2D = OVERLAYS[randi() % OVERLAYS.size()]
    var offset := Vector3(randf(), randf(), 0.0)
    var strength := randf_range(0.45, 1.0)
    for mi: MeshInstance3D in model.find_children("*", "MeshInstance3D", true, false):
        var material := StandardMaterial3D.new()
        material.albedo_texture = overlay_texture
        material.albedo_color = Color(1, 1, 1, strength)
        material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
        material.roughness = 0.3
        material.uv1_offset = offset
        material.uv1_scale = Vector3(randf_range(0.9, 1.7), randf_range(0.9, 1.7), 1.0)
        material.cull_mode = BaseMaterial3D.CULL_BACK
        mi.material_overlay = material


## Qué animación de reacción toca según dónde pegó el tiro: cabeza, pecho o empujón fuerte (escopeta y armas pesadas).
static func reaction(hit_point: Vector3, feet_y: float, damage: int) -> String:
    if hit_point.y - feet_y > 1.45:
        return "Hit_Head"
    if damage >= 3:
        return "Hit_Knockback"
    return "Hit_Chest"


## Herida que queda pegada al hueso más cercano al impacto (se mueve con el cuerpo).
static func wound(zombie: Node3D, hit_point: Vector3, from_position: Vector3) -> void:
    var skeleton := _skeleton(zombie)
    if skeleton == null:
        return
    var count := int(zombie.get_meta("wounds", 0))
    if count >= MAX_WOUNDS:
        return
    zombie.set_meta("wounds", count + 1)
    var bone := _nearest_bone(skeleton, hit_point)
    var attachment := BoneAttachment3D.new()
    attachment.bone_name = skeleton.get_bone_name(bone)
    skeleton.add_child(attachment)
    var normal := (from_position - hit_point).normalized()
    if normal.length() < 0.01:
        normal = Vector3.UP
    var quad := MeshInstance3D.new()
    var mesh := QuadMesh.new()
    mesh.size = Vector2.ONE * randf_range(0.2, 0.34)
    quad.mesh = mesh
    var material := StandardMaterial3D.new()
    material.albedo_texture = WOUNDS[randi() % WOUNDS.size()]
    material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    material.roughness = 0.35
    material.cull_mode = BaseMaterial3D.CULL_DISABLED
    material.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
    quad.material_override = material
    var up := Vector3.UP if absf(normal.y) < 0.95 else Vector3.RIGHT
    var world_target := Transform3D(Basis.looking_at(-normal, up), hit_point + normal * 0.025)
    var bone_world := skeleton.global_transform * skeleton.get_bone_global_pose(bone)
    quad.transform = bone_world.affine_inverse() * world_target
    attachment.add_child(quad)


## Al morir: la cabeza vuela con un tiro alto o fuerte; con daño de explosivo también salen brazos y piernas.
static func death_gore(zombie: Node3D, hit_point: Vector3, from_position: Vector3, damage: int) -> void:
    var skeleton := _skeleton(zombie)
    if skeleton == null or zombie.get_meta("gibbed", false):
        return
    var push := (hit_point - from_position)
    push.y = 0.0
    push = push.normalized() if push.length() > 0.01 else Vector3.BACK
    var high: bool = hit_point.y - zombie.global_position.y > 1.35
    var parts: Array[String] = []
    if high or (damage >= HEAD_DAMAGE and randf() < 0.65):
        parts.append("Head")
    if damage >= BLAST_DAMAGE:
        var limbs := ["LeftUpperArm", "RightUpperArm", "LeftLowerLeg", "RightLowerLeg"]
        limbs.shuffle()
        parts.append_array(limbs.slice(0, 2))
        if not parts.has("Head"):
            parts.append("Head")
    elif damage >= HEAD_DAMAGE and randf() < 0.3:
        parts.append(["LeftLowerArm", "RightLowerArm"][randi() % 2])
    if parts.is_empty():
        return
    zombie.set_meta("gibbed", true)
    for part_name in parts:
        _gib(zombie, skeleton, part_name, push)
    BloodBurst.spawn(zombie.get_parent(), hit_point, push * -1.0 + Vector3.UP, 3.0)


## Separa del cuerpo la parte que cuelga del hueso `root_bone` y la lanza como un objeto con física.
static func _gib(zombie: Node3D, skeleton: Skeleton3D, root_bone: String, push: Vector3) -> void:
    var root_index := skeleton.find_bone(root_bone)
    if root_index < 0:
        return
    var subtree := {}
    _collect(skeleton, root_index, subtree)
    var rest := skeleton.get_bone_global_rest(root_index)
    var pose_world := skeleton.global_transform * skeleton.get_bone_global_pose(root_index)
    for mi: MeshInstance3D in (zombie.get("model") as Node3D).find_children("*", "MeshInstance3D", true, false):
        if mi.mesh == null or mi.mesh.get_surface_count() != 1 or mi.skin == null:
            continue
        var arrays := mi.mesh.surface_get_arrays(0)
        var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
        var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
        var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
        var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
        if bones.is_empty() or verts.is_empty():
            continue
        var per := bones.size() / verts.size()
        var inside := PackedFloat32Array()
        inside.resize(verts.size())
        for v in verts.size():
            for k in per:
                var bone_index := _bind_bone(mi, skeleton, bones[v * per + k])
                if subtree.has(bone_index):
                    inside[v] += weights[v * per + k]
        var kept := PackedInt32Array()
        var cut := PackedInt32Array()
        for t in range(0, indices.size(), 3):
            var avg := (inside[indices[t]] + inside[indices[t + 1]] + inside[indices[t + 2]]) / 3.0
            var target := cut if avg > 0.5 else kept
            target.append_array([indices[t], indices[t + 1], indices[t + 2]])
        if cut.is_empty():
            continue
        # La parte: malla sin esqueleto, centrada en su centro; el cuerpo: la misma malla sin esos triángulos.
        var center := Vector3.ZERO
        var used := {}
        for i in cut:
            used[i] = true
        for i in used:
            center += verts[i]
        center /= float(used.size())
        var gib_arrays := []
        gib_arrays.resize(Mesh.ARRAY_MAX)
        var remap := {}
        var gv := PackedVector3Array()
        var gn := PackedVector3Array()
        var guv := PackedVector2Array()
        var gi := PackedInt32Array()
        var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
        var uvs: PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV]
        for i in cut:
            if not remap.has(i):
                remap[i] = gv.size()
                gv.append(verts[i] - center)
                gn.append(normals[i])
                guv.append(uvs[i] if not uvs.is_empty() else Vector2.ZERO)
            gi.append(remap[i])
        gib_arrays[Mesh.ARRAY_VERTEX] = gv
        gib_arrays[Mesh.ARRAY_NORMAL] = gn
        gib_arrays[Mesh.ARRAY_TEX_UV] = guv
        gib_arrays[Mesh.ARRAY_INDEX] = gi
        var gib_mesh := ArrayMesh.new()
        gib_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, gib_arrays)
        var material := mi.get_active_material(0)
        if material:
            gib_mesh.surface_set_material(0, material)
        arrays[Mesh.ARRAY_INDEX] = kept
        var body_mesh := ArrayMesh.new()
        body_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
        if material:
            body_mesh.surface_set_material(0, material)
        mi.mesh = body_mesh
        _launch(zombie, gib_mesh, pose_world * rest.affine_inverse() * Transform3D(Basis.IDENTITY, center), push, root_bone == "Head")
        _add_stump(skeleton, root_index)
        return


static func _launch(zombie: Node3D, mesh: Mesh, at: Transform3D, push: Vector3, is_head: bool) -> void:
    var body := RigidBody3D.new()
    body.collision_layer = 0
    body.collision_mask = 1
    body.mass = 3.0 if is_head else 5.0
    body.linear_damp = 0.4
    body.angular_damp = 0.6
    var shape := CollisionShape3D.new()
    var sphere := SphereShape3D.new()
    sphere.radius = 0.13 if is_head else 0.1
    shape.shape = sphere
    body.add_child(shape)
    var visual := MeshInstance3D.new()
    visual.mesh = mesh
    body.add_child(visual)
    zombie.get_parent().add_child(body)
    body.global_transform = at
    body.linear_velocity = push * randf_range(2.2, 4.0) + Vector3(randf_range(-0.8, 0.8), randf_range(2.8, 4.2), randf_range(-0.8, 0.8))
    body.angular_velocity = Vector3(randf_range(-9, 9), randf_range(-9, 9), randf_range(-9, 9))
    zombie.get_tree().create_timer(18.0).timeout.connect(body.queue_free)


## Muñón rojo en el corte (queda en el cuerpo, pegado al hueso padre).
static func _add_stump(skeleton: Skeleton3D, root_index: int) -> void:
    var parent_index := skeleton.get_bone_parent(root_index)
    if parent_index < 0:
        return
    var attachment := BoneAttachment3D.new()
    attachment.bone_name = skeleton.get_bone_name(parent_index)
    skeleton.add_child(attachment)
    var disc := MeshInstance3D.new()
    var cylinder := CylinderMesh.new()
    var is_neck := skeleton.get_bone_name(root_index) == "Head"
    cylinder.top_radius = 0.07 if is_neck else 0.05
    cylinder.bottom_radius = cylinder.top_radius
    cylinder.height = 0.03
    disc.mesh = cylinder
    var material := StandardMaterial3D.new()
    material.albedo_texture = STUMP
    material.albedo_color = Color(0.55, 0.42, 0.42)
    material.roughness = 0.35
    disc.material_override = material
    var parent_world := skeleton.global_transform * skeleton.get_bone_global_pose(parent_index)
    var root_world := skeleton.global_transform * skeleton.get_bone_global_pose(root_index)
    var offset := Transform3D(Basis.IDENTITY, Vector3(0, 0.0, 0))
    disc.transform = parent_world.affine_inverse() * root_world * offset
    attachment.add_child(disc)


static func _skeleton(zombie: Node3D) -> Skeleton3D:
    var model := zombie.get("model") as Node3D
    if model == null:
        return null
    for s: Node in model.find_children("*", "Skeleton3D", true, false):
        return s as Skeleton3D
    return null


static func _nearest_bone(skeleton: Skeleton3D, point: Vector3) -> int:
    var best := 0
    var best_distance := INF
    for i in skeleton.get_bone_count():
        var position := (skeleton.global_transform * skeleton.get_bone_global_pose(i)).origin
        var distance := position.distance_to(point)
        if distance < best_distance:
            best_distance = distance
            best = i
    return best


static func _collect(skeleton: Skeleton3D, root_index: int, into: Dictionary) -> void:
    into[root_index] = true
    for child in skeleton.get_bone_children(root_index):
        _collect(skeleton, child, into)


static func _bind_bone(mi: MeshInstance3D, skeleton: Skeleton3D, bind_index: int) -> int:
    var skin := mi.skin
    var bone := skin.get_bind_bone(bind_index)
    if bone >= 0:
        return bone
    return skeleton.find_bone(skin.get_bind_name(bind_index))
