extends Node3D
## Levanta una barrera (nodo de la sala, por nombre) cuando se activa una bandera. Si ya estaba activa, aparece levantada.

@export var flag: String = ""
@export var target_name: String = "Barrier"
@export var lift_angle: float = 1.25

var _done := false


func _ready() -> void:
    _check(false)
    if not _done:
        var timer := Timer.new()
        timer.wait_time = 0.4
        timer.timeout.connect(func() -> void: _check(true))
        add_child(timer)
        timer.start()


func _check(animate: bool) -> void:
    if _done or flag.is_empty() or not GameState.has_flag(flag):
        return
    _done = true
    var scene_root: Node = get_tree().current_scene if get_tree().current_scene != null else owner
    var target: Node3D = scene_root.find_child(target_name, true, false) as Node3D if scene_root != null else null
    if target == null:
        return
    if animate:
        Sfx.play("unlock", global_position, -4.0)
        var tween := create_tween()
        tween.tween_property(target, "rotation:z", -lift_angle, 1.2).set_trans(Tween.TRANS_SINE)
    else:
        target.rotation.z = -lift_angle
