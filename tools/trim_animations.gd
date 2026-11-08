# Herramienta de conversión de assets (se usó una vez; se guarda como registro).
# Se ejecuta en un proyecto temporal junto al archivo original, por ejemplo:
#   godot --headless -s trim_animations.gd -- <origen> <destino>
# Los originales (FBX de 20 MB, texturas de 2048 px) no se suben al repositorio.
extends SceneTree
const KEEP := ["Idle", "Walk", "Jog_Fwd", "Sprint", "Pistol_Idle", "Pistol_Aim_Neutral", "Pistol_Aim_Down", "Pistol_Aim_Up", "Pistol_Shoot", "Pistol_Reload", "Hit_Chest", "Hit_Head", "Death01", "Interact", "PickUp_Table", "Crouch_Idle", "A_TPose"]
func _init():
    var root: Node = (load("res://UAL1_Standard.glb") as PackedScene).instantiate()
    var ap: AnimationPlayer = root.find_children("*", "AnimationPlayer", true, false)[0]
    for lib_name in ap.get_animation_library_list():
        var lib := ap.get_animation_library(lib_name)
        for a in lib.get_animation_list():
            if not (String(a) in KEEP):
                lib.remove_animation(a)
    print(ap.get_animation_list())
    var doc := GLTFDocument.new()
    var state := GLTFState.new()
    print("append ", doc.append_from_scene(root, state))
    print("write ", doc.write_to_filesystem(state, "res://out_ual.glb"))
    quit()
