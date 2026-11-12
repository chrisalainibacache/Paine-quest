# Herramienta de conversión (se usó una vez; queda como registro).
# Proyecto temporal con Cat.fbx del Animal Pack Vol.2 de Quaternius (CC0):
#   godot --headless -s convert_leo.gd -- <salida.glb>
extends SceneTree
## Convierte el gato del Animal Pack Vol.2 de Quaternius (CC0) en Leo:
## gatita gris con pecho y patas blancas, mirando a +Z, con las animaciones
## Idle, Walk y Run (Run = Walk; la velocidad la pone leo.gd).
func color_mat(name: String, color: Color, rough: float) -> StandardMaterial3D:
    var mat := StandardMaterial3D.new()
    mat.resource_name = name
    mat.albedo_color = color
    mat.roughness = rough
    return mat

func _init() -> void:
    var src: Node3D = (load("res://cat.fbx") as PackedScene).instantiate()
    var root := Node3D.new()
    root.name = "Leo"
    var body := Node3D.new()
    body.name = "Body"
    root.add_child(body)
    body.owner = root
    # Lo del FBX va dentro de Body (giro de -90° para mirar a +Z).
    for child in src.get_children():
        src.remove_child(child)
        body.add_child(child)
    for n in body.find_children("*", "", true, false):
        n.owner = root
    body.rotation.y = -PI / 2.0
    var mats := {
        "Grey": color_mat("Fur", Color(0.36, 0.36, 0.38), 0.9),
        "White": color_mat("WhiteFur", Color(0.86, 0.85, 0.81), 0.9),
        "Pink": color_mat("Pink", Color(0.86, 0.56, 0.6), 0.6),
    }
    for m: MeshInstance3D in root.find_children("*", "MeshInstance3D", true, false):
        for i in m.mesh.get_surface_count():
            var old := m.get_active_material(i)
            var key := old.resource_name if old else "Grey"
            m.mesh.surface_set_material(i, mats.get(key, mats["Grey"]))
            m.set_surface_override_material(i, null)
    var ap := root.find_children("*", "AnimationPlayer", true, false)[0] as AnimationPlayer
    var lib := ap.get_animation_library(&"")
    var renamed := AnimationLibrary.new()
    for anim_name in lib.get_animation_list():
        var a := lib.get_animation(anim_name)
        var short := String(anim_name).get_slice("|", 1)
        if short == "Walking":
            renamed.add_animation(&"Walk", a)
            renamed.add_animation(&"Run", a.duplicate())
        else:
            renamed.add_animation(StringName(short), a)
    ap.remove_animation_library(&"")
    ap.add_animation_library(&"", renamed)
    print("anims ", ap.get_animation_list())
    var doc := GLTFDocument.new()
    var state := GLTFState.new()
    print("append ", doc.append_from_scene(root, state))
    print("write ", doc.write_to_filesystem(state, OS.get_cmdline_user_args()[0]))
    quit()
