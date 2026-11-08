extends CharacterBody3D
## Leo, la gatita de Cony. La sigue a una distancia cómoda, camina o corre
## según qué tan lejos quedó, y se queda sentada mirando cuando Cony se detiene.
## (Hito 3: bufar cuando hay infectados cerca.)

const FOLLOW_DISTANCE := 1.3
const WALK_SPEED := 1.4
const RUN_SPEED := 3.8
const TURN_SPEED := 8.0
const GRAVITY := 18.0
const LOOPING := ["Idle", "Idle_Eating", "Walk", "Run"]

@onready var model: Node3D = $Model

var target: Node3D
var _anim: AnimationPlayer
var _current := ""


func _ready() -> void:
    collision_layer = 4
    collision_mask = 1
    Player._make_textures_crisp(model)
    _anim = model.find_children("*", "AnimationPlayer", true, false)[0]
    for anim_name in LOOPING:
        if _anim.has_animation(anim_name):
            _anim.get_animation(anim_name).loop_mode = Animation.LOOP_LINEAR
    _play("Idle")


func _physics_process(delta: float) -> void:
    var move := Vector3.ZERO
    if target:
        var to_target := target.global_position - global_position
        to_target.y = 0.0
        var distance := to_target.length()
        if distance > FOLLOW_DISTANCE:
            var speed := RUN_SPEED if distance > FOLLOW_DISTANCE * 2.2 else WALK_SPEED
            move = to_target / distance * minf(speed, (distance - FOLLOW_DISTANCE) * 4.0)
    velocity.x = move.x
    velocity.z = move.z
    velocity.y = 0.0 if is_on_floor() else velocity.y - GRAVITY * delta
    move_and_slide()

    var horizontal := Vector2(velocity.x, velocity.z).length()
    if horizontal > 0.1:
        model.rotation.y = lerp_angle(model.rotation.y, atan2(velocity.x, velocity.z), minf(TURN_SPEED * delta, 1.0))
    if horizontal > WALK_SPEED * 1.4:
        _play("Run", clampf(horizontal / RUN_SPEED, 0.7, 1.2))
    elif horizontal > 0.15:
        _play("Walk", clampf(horizontal / WALK_SPEED, 0.6, 1.3))
    else:
        _play("Idle")


func _play(anim_name: String, speed_scale: float = 1.0) -> void:
    _anim.speed_scale = speed_scale
    if _current == anim_name:
        return
    _current = anim_name
    _anim.play(anim_name, 0.2)
