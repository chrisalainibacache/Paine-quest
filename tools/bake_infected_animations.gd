extends SceneTree
## Biblioteca de animaciones de los infectados: zombi (Quaternius UAL2) más
## reacciones y muerte (UAL1). Todo ya reasignado al esqueleto humanoide.
## Uso: godot --headless --path . -s res://tools/bake_infected_animations.gd

const SOURCES := {
    "res://assets/characters/animations/ual2_zombie.glb": ["Zombie_Idle", "Zombie_Walk_Fwd", "Zombie_Scratch", "Hit_Knockback", "LayToIdle", "Consume"],
    "res://assets/characters/animations/ual_humanoid.glb": ["Hit_Chest", "Hit_Head", "Death01"],
}
const TARGET := "res://actors/enemies/infected_animations.res"
const LOOPING := ["Zombie_Idle", "Zombie_Walk_Fwd", "Consume"]


func _init() -> void:
    var library := AnimationLibrary.new()
    for source: String in SOURCES:
        var scene := (load(source) as PackedScene).instantiate()
        var player: AnimationPlayer = scene.find_children("*", "AnimationPlayer", true, false)[0]
        for anim_name: String in SOURCES[source]:
            var animation := player.get_animation(anim_name).duplicate(true) as Animation
            animation.loop_mode = Animation.LOOP_LINEAR if anim_name in LOOPING else Animation.LOOP_NONE
            library.add_animation(anim_name, animation)
        scene.free()
    var err := ResourceSaver.save(library, TARGET, ResourceSaver.FLAG_COMPRESS)
    print("bake_infected_animations: ", library.get_animation_list(), " (", error_string(err), ")")
    quit(0 if err == OK else 1)
