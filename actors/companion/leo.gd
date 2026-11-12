extends CharacterBody3D
## Leo, la gatita de Cony. La sigue a una distancia cómoda, camina o corre
## según qué tan lejos quedó, y se queda sentada mirando cuando Cony se detiene.
## Si hay un infectado cerca (aunque se esté haciendo el muerto), Leo lo mira
## y le bufa: es el aviso para el jugador.

const FOLLOW_DISTANCE := 1.3
const WALK_SPEED := 1.4
const RUN_SPEED := 3.8
const TURN_SPEED := 8.0
const GRAVITY := 18.0
const LOOPING := ["Idle", "Walk", "Run"]
## Distancia a la que Leo nota a un infectado.
const WARN_RANGE := 5.5
const HISS_INTERVAL := 2.8
const SCAN_INTERVAL := 0.3
## Hueso de la cabeza del modelo y dónde van los ojos (espacio del esqueleto,
## X hacia adelante, Z hacia arriba, en la pose de reposo).
const HEAD_BONE := "Bone_003"
const EYE_POINTS := [Vector3(0.0281, 0.0025, 0.0296), Vector3(0.0281, -0.0025, 0.0296)]
const EYE_COLOR := Color(0.55, 0.85, 0.25)

@onready var model: Node3D = $Model

var target: Node3D
var _anim: AnimationPlayer
var _current := ""
## Infectado al que Leo le está bufando (null = tranquila).
var threat: Node3D
var _scan_timer := 0.0
var _hiss_timer := 0.0
var _hiss_anim_time := 0.0


func _ready() -> void:
    collision_layer = 4
    collision_mask = 1
    Player._make_textures_crisp(model)
    _add_eyes()
    _anim = model.find_children("*", "AnimationPlayer", true, false)[0]
    for anim_name in LOOPING:
        if _anim.has_animation(anim_name):
            _anim.get_animation(anim_name).loop_mode = Animation.LOOP_LINEAR
    _play("Idle")


## Ojos verdes con un leve brillo (en la oscuridad se ven como ojos de gato).
func _add_eyes() -> void:
    var skeletons := model.find_children("*", "Skeleton3D", true, false)
    if skeletons.is_empty():
        return
    var skeleton := skeletons[0] as Skeleton3D
    var head := skeleton.find_bone(HEAD_BONE)
    if head < 0:
        return
    var attachment := BoneAttachment3D.new()
    attachment.bone_name = HEAD_BONE
    skeleton.add_child(attachment)
    var head_rest := skeleton.get_bone_global_rest(head)
    var material := StandardMaterial3D.new()
    material.albedo_color = EYE_COLOR
    material.emission_enabled = true
    material.emission = EYE_COLOR
    material.emission_energy_multiplier = 0.6
    var mesh := SphereMesh.new()
    mesh.radius = 0.0007
    mesh.height = 0.0011
    mesh.radial_segments = 8
    mesh.rings = 4
    for point: Vector3 in EYE_POINTS:
        var eye := MeshInstance3D.new()
        eye.mesh = mesh
        eye.material_override = material
        eye.position = head_rest.affine_inverse() * point
        attachment.add_child(eye)


func is_alert() -> bool:
    return threat != null


func _physics_process(delta: float) -> void:
    _update_threat(delta)
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
    elif threat:
        var to_threat := threat.global_position - global_position
        model.rotation.y = lerp_angle(model.rotation.y, atan2(to_threat.x, to_threat.z), minf(TURN_SPEED * delta, 1.0))
    if _hiss_anim_time > 0.0 and horizontal <= 0.15:
        _play("Idle", 2.6)
    elif horizontal > WALK_SPEED * 1.4:
        _play("Run", clampf(horizontal / RUN_SPEED, 0.7, 1.2))
    elif horizontal > 0.15:
        _play("Walk", clampf(horizontal / WALK_SPEED, 0.6, 1.3))
    else:
        _play("Idle")


func _update_threat(delta: float) -> void:
    _scan_timer -= delta
    _hiss_anim_time = maxf(_hiss_anim_time - delta, 0.0)
    if _scan_timer <= 0.0:
        _scan_timer = SCAN_INTERVAL
        var previous := threat
        threat = _find_threat()
        if threat and previous == null:
            _hiss_timer = 0.0
    if threat == null:
        return
    _hiss_timer -= delta
    if _hiss_timer <= 0.0:
        _hiss_timer = HISS_INTERVAL
        _hiss_anim_time = 0.9
        Sfx.play("hiss", global_position + Vector3.UP * 0.3, -3.0, 0.1)


func _find_threat() -> Node3D:
    var best: Node3D = null
    var best_distance := WARN_RANGE
    for enemy: Node3D in get_tree().get_nodes_in_group("enemies"):
        if not enemy.is_alive():
            continue
        var distance := global_position.distance_to(enemy.global_position)
        if distance < best_distance:
            best_distance = distance
            best = enemy
    return best


func _play(anim_name: String, speed_scale: float = 1.0) -> void:
    _anim.speed_scale = speed_scale
    if _current == anim_name:
        return
    _current = anim_name
    _anim.play(anim_name, 0.2)
