extends CharacterBody3D
## Leo, la gatita de Isabella. La sigue a una distancia cómoda, camina o corre
## según qué tan lejos quedó, y se queda sentada mirando cuando Isabella se detiene.
## Si hay un infectado cerca (aunque se esté haciendo el muerto), Leo lo mira
## y le bufa: es el aviso para el jugador.
## Ayuda escalonada: primero mira y maúlla hacia la pista, luego da una frase vaga
## tras 40 s sin progreso; la explicación explícita solo sale con el botón AYUDA.

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
## Segundos sin progreso antes de la señal no verbal de Leo.
const LOOK_HINT_DELAY := 6.0
## Segundos sin progreso antes de la pista vaga.
const VAGUE_HINT_DELAY := 40.0

## Las pruebas automáticas lo apagan (los diálogos pausan el juego).
static var guide_enabled := true

@onready var model: Node3D = $Model

var target: Node3D
var _anim: AnimationPlayer
var _current := ""
## Infectado al que Leo le está bufando (null = tranquila).
var threat: Node3D
var _scan_timer := 0.0
var _hiss_timer := 0.0
var _hiss_anim_time := 0.0
## Pista a la que Leo mira (no camina hasta ella).
var _point_hint: Node3D
var _last_progress_revision := -1
var _no_progress_time := 0.0
var _vague_requested := false
var _vague_speaking := false
var _explaining := false


func _ready() -> void:
    add_to_group("leo")
    _last_progress_revision = GameState.progress_revision
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
    _update_hint_behavior(delta)
    var move := Vector3.ZERO
    if target:
        var to_target := target.global_position - global_position
        to_target.y = 0.0
        var distance := to_target.length()
        if distance > FOLLOW_DISTANCE:
            var speed := RUN_SPEED if distance > FOLLOW_DISTANCE + 1.6 else WALK_SPEED
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
    elif _point_hint and is_instance_valid(_point_hint):
        var to_hint := _point_hint.global_position - global_position
        model.rotation.y = lerp_angle(model.rotation.y, atan2(to_hint.x, to_hint.z), minf(TURN_SPEED * delta, 1.0))
    elif target:
        var to_cony := target.global_position - global_position
        model.rotation.y = lerp_angle(model.rotation.y, atan2(to_cony.x, to_cony.z), minf(TURN_SPEED * delta, 1.0))
    if _hiss_anim_time > 0.0 and horizontal <= 0.15:
        _play("Idle", 2.6)
    elif horizontal > WALK_SPEED * 1.4:
        _play("Run", clampf(horizontal / RUN_SPEED, 0.7, 1.2))
    elif horizontal > 0.15:
        _play("Walk", clampf(horizontal / WALK_SPEED, 0.6, 1.3))
    else:
        _play("Idle")


## Ayuda escalonada: señal visual/sonora, frase vaga y ayuda explícita manual.
func _update_hint_behavior(delta: float) -> void:
    if target == null or not guide_enabled:
        return
    if threat:
        _point_hint = null
        return
    if _last_progress_revision != GameState.progress_revision:
        _last_progress_revision = GameState.progress_revision
        _no_progress_time = 0.0
        _point_hint = null
        _vague_requested = false
        return
    _no_progress_time += delta
    var hint := active_hint()
    if hint == null:
        _point_hint = null
        return
    if not hint.was_looked() and _no_progress_time >= LOOK_HINT_DELAY:
        GameState.set_flag(hint.look_flag())
        _point_hint = hint
        Sfx.play("meow", global_position + Vector3.UP * 0.3, -4.0, 0.08)
    if not hint.was_vague() and not hint.vague_line_text().is_empty() \
            and _no_progress_time >= VAGUE_HINT_DELAY and not _vague_requested and not Dialogue.is_open():
        _vague_requested = true
        _say_vague.call_deferred(hint)


func _say_vague(hint: Node3D) -> void:
    if _vague_speaking or Dialogue.is_open() or not is_instance_valid(hint) or not hint.is_active():
        _vague_requested = false
        return
    var line := hint.vague_line_text()
    if line.is_empty() or hint.was_vague():
        _vague_requested = false
        return
    _vague_speaking = true
    GameState.set_flag(hint.vague_flag())
    Sfx.play("meow", global_position + Vector3.UP * 0.3, -3.0, 0.08)
    await Dialogue.say([line])
    _vague_speaking = false
    _vague_requested = false


## Primera pista activa de la sala (en el orden en que están en la escena).
func active_hint() -> Node3D:
    for hint: Node3D in get_tree().get_nodes_in_group("leo_hints"):
        if hint.is_inside_tree() and hint.is_active() and not hint.was_heard():
            return hint
    return null


## El botón AYUDA aparece solo si la pista tiene una tercera línea explícita.
func has_news() -> bool:
    var hint := active_hint()
    return hint != null and hint.has_explicit_help() and not _explaining


func explain_news() -> void:
    var hint := active_hint()
    if hint:
        await explain(hint)


func explain(hint: Node3D) -> void:
    if _explaining or Dialogue.is_open() or SceneLoader.is_busy() or not hint.has_explicit_help():
        return
    _explaining = true
    _no_progress_time = 0.0
    _point_hint = null
    _vague_requested = false
    GameState.set_flag(hint.heard_flag())
    Sfx.play("meow", global_position + Vector3.UP * 0.3, -2.0, 0.05)
    await Dialogue.say([hint.explicit_line_text()])
    _explaining = false


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
