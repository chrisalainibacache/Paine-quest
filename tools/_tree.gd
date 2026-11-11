extends SceneTree
func _init() -> void:
    var r: Node = (load(OS.get_cmdline_user_args()[0]) as PackedScene).instantiate()
    var sk := r.find_children("*", "Skeleton3D", true, false)[0] as Skeleton3D
    var names := []
    for i in sk.get_bone_count(): names.append(sk.get_bone_name(i))
    print("BONES ", sk.get_bone_count(), " ", names.slice(0, 8), " path ", r.get_path_to(sk))
    print("NODES ", r.find_children("*", "", true, false).size())
    quit()
