# Herramienta de conversión (se usó una vez; queda como registro).
# Proyecto temporal con dog.fbx y wolf.fbx del Animal Pack Vol.2 de Quaternius (CC0):
#   godot --headless -s convert_dogs.gd -- <carpeta_salida>
extends SceneTree
## Convierte el perro y el lobo del Animal Pack Vol.2 de Quaternius (CC0) en las
## perras de Chris: Nala (bull terrier gris atigrado con café, hocico claro) y
## Kiara (akita grande naranja con pecho, guata y hocico crema). El pelaje se
## pinta por vértice según la posición en reposo (X adelante, Y lado, Z arriba).
const ORANGE := Color(0.84, 0.46, 0.17)
const CREAM := Color(0.95, 0.88, 0.74)
const GRAY := Color(0.46, 0.45, 0.44)
const BROWN := Color(0.42, 0.27, 0.15)
const LIGHT := Color(0.82, 0.8, 0.76)

func rest_positions(m: MeshInstance3D, sk: Skeleton3D, arrays: Array) -> PackedVector3Array:
    var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
    var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
    var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
    var per := bones.size() / verts.size()
    var out := PackedVector3Array()
    out.resize(verts.size())
    for v in verts.size():
        var p := Vector3.ZERO
        for j in per:
            var w := weights[v * per + j]
            if w <= 0.0:
                continue
            var b := bones[v * per + j]
            var bone := sk.find_bone(m.skin.get_bind_name(b)) if m.skin.get_bind_name(b) != &"" else m.skin.get_bind_bone(b)
            p += (sk.get_bone_global_rest(bone) * m.skin.get_bind_pose(b) * verts[v]) * w
        out[v] = p
    return out

func color_for(dog: String, p: Vector3, lo: Vector3, hi: Vector3) -> Color:
    var t := (p - lo) / (hi - lo)  # 0..1 en cada eje
    if dog == "kiara":
        var belly := t.z < 0.42 and t.x > 0.25 and t.x < 0.72
        var legs := t.z < 0.18
        var chest := t.x > 0.72 and t.z < 0.62
        var muzzle := t.x > 0.88
        return CREAM if belly or legs or chest or muzzle else ORANGE
    # Nala: atigrado (franjas café sobre gris) y hocico/pecho claros.
    if t.x > 0.86 or (t.x > 0.7 and t.z < 0.45):
        return LIGHT
    var stripe := sin(p.x * 900.0 + sin(p.z * 400.0) * 1.5 + p.y * 200.0)
    return BROWN.lerp(GRAY, 0.25) if stripe > 0.35 else GRAY

func convert_dog(src_path: String, dog: String, out_path: String) -> void:
    var src: Node3D = (load(src_path) as PackedScene).instantiate()
    get_root().add_child(src)
    var root := Node3D.new()
    root.name = dog.capitalize()
    var body := Node3D.new()
    body.name = "Body"
    root.add_child(body)
    body.owner = root
    for child in src.get_children():
        src.remove_child(child)
        body.add_child(child)
    for n in body.find_children("*", "", true, false):
        n.owner = root
    body.rotation.y = -PI / 2.0
    var sk := root.find_children("*", "Skeleton3D", true, false)[0] as Skeleton3D
    var m := root.find_children("*", "MeshInstance3D", true, false)[0] as MeshInstance3D
    var src_mesh := m.mesh as ArrayMesh
    var out := ArrayMesh.new()
    for s in src_mesh.get_surface_count():
        var arrays := src_mesh.surface_get_arrays(s)
        var rest := rest_positions(m, sk, arrays)
        var lo := Vector3(INF, INF, INF)
        var hi := -lo
        for p in rest:
            lo = lo.min(p)
            hi = hi.max(p)
        var colors := PackedColorArray()
        for p in rest:
            colors.append(color_for(dog, p, lo, hi))
        arrays[Mesh.ARRAY_COLOR] = colors
        out.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays, [], {}, src_mesh.surface_get_format(s) & Mesh.ARRAY_FLAG_USE_8_BONE_WEIGHTS)
        var mat := StandardMaterial3D.new()
        mat.resource_name = "Fur"
        mat.vertex_color_use_as_albedo = true
        mat.roughness = 0.9
        out.surface_set_material(s, mat)
    m.mesh = out
    m.set_surface_override_material(0, null)
    var ap := root.find_children("*", "AnimationPlayer", true, false)[0] as AnimationPlayer
    var lib := ap.get_animation_library(&"")
    var renamed := AnimationLibrary.new()
    for anim_name in lib.get_animation_list():
        var short := String(anim_name).get_slice("|", 1)
        renamed.add_animation(&"Walk" if short == "Walking" else StringName(short), lib.get_animation(anim_name))
    ap.remove_animation_library(&"")
    ap.add_animation_library(&"", renamed)
    var doc := GLTFDocument.new()
    var state := GLTFState.new()
    print(dog, " append ", doc.append_from_scene(root, state), " write ", doc.write_to_filesystem(state, out_path))

func _init() -> void:
    var out: String = OS.get_cmdline_user_args()[0]
    convert_dog("res://dog.fbx", "nala", out + "/nala.glb")
    convert_dog("res://wolf.fbx", "kiara", out + "/kiara.glb")
    quit()
