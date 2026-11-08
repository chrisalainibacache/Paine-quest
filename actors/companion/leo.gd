extends CharacterBody3D
## Leo, la gatita de Cony. Por ahora sólo la sigue a una distancia cómoda
## (Hito 3: bufar cuando hay infectados cerca).

const FOLLOW_DISTANCE := 1.3
const WALK_SPEED := 1.6
const RUN_SPEED := 3.6
const TURN_SPEED := 8.0
const GRAVITY := 18.0

@onready var model: Node3D = $Model

var target: Node3D
var _step_time := 0.0


func _ready() -> void:
    collision_layer = 4
    collision_mask = 1
    Player._make_textures_crisp(model)


func _physics_process(delta: float) -> void:
    var move := Vector3.ZERO
    if target:
        var to_target := target.global_position - global_position
        to_target.y = 0.0
        var distance := to_target.length()
        if distance > FOLLOW_DISTANCE:
            var speed := RUN_SPEED if distance > FOLLOW_DISTANCE * 2.5 else WALK_SPEED
            move = to_target / distance * minf(speed, (distance - FOLLOW_DISTANCE) * 4.0)
    velocity.x = move.x
    velocity.z = move.z
    velocity.y = 0.0 if is_on_floor() else velocity.y - GRAVITY * delta
    move_and_slide()

    var horizontal := Vector2(velocity.x, velocity.z).length()
    if horizontal > 0.1:
        model.rotation.y = lerp_angle(model.rotation.y, atan2(velocity.x, velocity.z), minf(TURN_SPEED * delta, 1.0))
        # Trotecito: el modelo no tiene esqueleto, así que se balancea un poco.
        _step_time += delta * horizontal * 6.0
        model.position.y = absf(sin(_step_time)) * 0.03
        model.rotation.z = sin(_step_time) * 0.05
    else:
        model.position.y = lerpf(model.position.y, 0.0, minf(10.0 * delta, 1.0))
        model.rotation.z = lerpf(model.rotation.z, 0.0, minf(10.0 * delta, 1.0))
