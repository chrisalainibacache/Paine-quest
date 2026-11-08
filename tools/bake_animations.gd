extends SceneTree
## Extrae las animaciones de la biblioteca Quaternius (ya reasignadas al
## esqueleto humanoide al importar) y las guarda como recurso para Cony.
## Uso: godot --headless --path . -s res://tools/bake_animations.gd

const SOURCE := "res://assets/characters/animations/ual_humanoid.glb"
const TARGET := "res://actors/player/cony_animations.res"
## Animaciones Mixamo hechas para el esqueleto de Cony (tools/extract_mixamo_animation.gd).
const EXTRA := {"Jog": "res://assets/characters/animations/cony_jog.res"}
const LOOPING := ["Idle", "Walk", "Jog_Fwd", "Sprint", "Pistol_Idle", "Pistol_Aim_Neutral",
    "Pistol_Aim_Down", "Pistol_Aim_Up", "Crouch_Idle"]


func _init() -> void:
    var scene := (load(SOURCE) as PackedScene).instantiate()
    var player: AnimationPlayer = scene.find_children("*", "AnimationPlayer", true, false)[0]
    var library := AnimationLibrary.new()
    for anim_name in player.get_animation_list():
        if anim_name == "A_TPose":
            continue
        var animation := player.get_animation(anim_name).duplicate(true) as Animation
        animation.loop_mode = Animation.LOOP_LINEAR if String(anim_name) in LOOPING else Animation.LOOP_NONE
        library.add_animation(anim_name, animation)
    for anim_name in EXTRA:
        library.add_animation(anim_name, load(EXTRA[anim_name]) as Animation)
    var err := ResourceSaver.save(library, TARGET, ResourceSaver.FLAG_COMPRESS)
    print("bake_animations: ", library.get_animation_list().size(), " animaciones -> ", TARGET, " (", error_string(err), ")")
    scene.free()
    quit(0 if err == OK else 1)
