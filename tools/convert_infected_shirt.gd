# Herramienta de conversión (se usó una vez; queda como registro).
# Proyecto temporal con walk.FBX y sus texturas (zombie de Pixelhouse, OpenGameArt, CC-BY 3.0):
#   godot --headless -s convert_infected_shirt.gd -- <salida.glb>
extends SceneTree
## Convierte el zombie de Pixelhouse (walk.FBX, esqueleto Biped de 3ds Max) en un
## GLB para Paine: de pie en el origen, mirando a +Z, 1,75 m, texturas 1024/512.
## El esqueleto queda con nombres Biped; el import usa biped_bone_map.tres.
func tex(path: String, size: int) -> ImageTexture:
    var img := Image.load_from_file(path)
    img.resize(size, size, Image.INTERPOLATE_LANCZOS)
    img.generate_mipmaps()
    return ImageTexture.create_from_image(img)

func _init() -> void:
    var root: Node3D = (load("res://walk.fbx") as PackedScene).instantiate()
    for n in root.find_children("*", "", true, false):
        if is_instance_valid(n) and (n is AnimationPlayer or n is Camera3D or n is BoneAttachment3D or n is Light3D):
            n.get_parent().remove_child(n)
            n.free()
    var sk := root.find_children("*", "Skeleton3D", true, false)[0] as Skeleton3D
    # Pelvis al origen, planta en el piso, de frente a +Z y a escala humana.
    # Se hornea en huesos, poses de unión y vértices (sin escalas en nodos:
    # el reajuste de animaciones las necesita limpias).
    var m := root.find_children("*", "MeshInstance3D", true, false)[0] as MeshInstance3D
    print("sk xf ", sk.transform, " mesh xf ", m.transform)
    var center := Vector3(0.416, -0.03, -0.231)
    var s := 1.75 / 0.6
    var rot := Basis(Vector3.UP, PI / 2.0)
    var xf := Transform3D(rot.scaled(Vector3.ONE * s), rot * (-center * s)) * sk.transform
    sk.transform = Transform3D.IDENTITY
    var globals := []
    for i in sk.get_bone_count():
        globals.append(sk.get_bone_global_rest(i))
    for i in sk.get_bone_count():
        var rest := sk.get_bone_rest(i)
        if sk.get_bone_parent(i) < 0:
            rest = Transform3D(xf.basis.orthonormalized() * rest.basis, xf * rest.origin)
        else:
            rest.origin *= s
        sk.set_bone_rest(i, rest)
    # Bip01 (raíz de Biped) baja al piso: las animaciones ponen la cadera a su
    # altura real relativa a la raíz, como en Mixamo.
    var root_bone := sk.find_bone("Bip01")
    var pelvis := sk.find_bone("Bip01 Pelvis")
    var root_rest := sk.get_bone_rest(root_bone)
    var offset := root_rest.origin * Vector3(1, 1, 1)
    sk.set_bone_rest(root_bone, Transform3D(root_rest.basis, Vector3(0, 0, 0)))
    var pelvis_rest := sk.get_bone_rest(pelvis)
    pelvis_rest.origin += root_rest.basis.inverse() * offset
    sk.set_bone_rest(pelvis, pelvis_rest)
    sk.reset_bone_poses()
    var skin := m.skin.duplicate() as Skin
    for b in skin.get_bind_count():
        var bone := sk.find_bone(skin.get_bind_name(b)) if skin.get_bind_name(b) != &"" else skin.get_bind_bone(b)
        var g_new := sk.get_bone_global_rest(bone)
        skin.set_bind_pose(b, g_new.affine_inverse() * xf * globals[bone] * skin.get_bind_pose(b) * xf.affine_inverse())
    m.skin = skin
    var src := m.mesh as ArrayMesh
    var out := ArrayMesh.new()
    for i in src.get_surface_count():
        var arrays := src.surface_get_arrays(i)
        var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
        for v in verts.size(): verts[v] = xf * verts[v]
        arrays[Mesh.ARRAY_VERTEX] = verts
        var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
        for v in normals.size(): normals[v] = rot * normals[v]
        arrays[Mesh.ARRAY_NORMAL] = normals
        if arrays[Mesh.ARRAY_TANGENT] != null:
            var tan: PackedFloat32Array = arrays[Mesh.ARRAY_TANGENT]
            for v in range(0, tan.size(), 4):
                var tv := rot * Vector3(tan[v], tan[v + 1], tan[v + 2])
                tan[v] = tv.x; tan[v + 1] = tv.y; tan[v + 2] = tv.z
            arrays[Mesh.ARRAY_TANGENT] = tan
        out.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays, [], {}, src.surface_get_format(i) & Mesh.ARRAY_FLAG_USE_8_BONE_WEIGHTS)
    m.mesh = out
    var mat := StandardMaterial3D.new()
    mat.resource_name = "Zombie"
    mat.albedo_texture = tex("difusse.jpg", 1024)
    mat.normal_enabled = true
    mat.normal_texture = tex("normal.JPG", 512)
    mat.roughness = 0.8
    for i in m.mesh.get_surface_count():
        m.mesh.surface_set_material(i, mat)
    for i in m.get_surface_override_material_count():
        m.set_surface_override_material(i, null)
    var doc := GLTFDocument.new()
    var state := GLTFState.new()
    print("append ", doc.append_from_scene(root, state))
    print("write ", doc.write_to_filesystem(state, OS.get_cmdline_user_args()[0]))
    quit()
