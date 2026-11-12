extends CharacterBody3D
## Leo, la gatita de Cony. La sigue a una distancia cómoda, camina o corre
## según qué tan lejos quedó, y se queda sentada mirando cuando Cony se detiene.
## Si hay un infectado cerca (aunque se esté haciendo el muerto), Leo lo mira
## y le bufa: es el aviso para el jugador.
## Leo también guía: si Cony se queda quieta un rato, Leo camina hasta la pista
## activa de la sala (nodos del grupo "leo_hints"), maúlla y, cuando Cony llega,
## le explica qué hacer.

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
## Segundos quieta antes de que Leo guíe.
const GUIDE_DELAY := 5.0
## Distancia a la pista a la que Leo se sienta a esperar.
const GUIDE_ARRIVE := 0.6
## Leo habla cuando Cony llega a esta distancia de ella (estando en la pista).
const EXPLAIN_RANGE := 1.8
## Si Cony se aleja tanto, Leo deja de guiar y vuelve con ella.
const GUIDE_GIVE_UP := 8.0
const MEOW_INTERVAL := 3.5

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
## Pista a la que Leo está guiando (null = sigue a Cony).
var guide: Node3D
var _idle_time := 0.0
var _meow_timer := 0.0
var _explaining := false


func _ready() -> void:
    add_to_group("leo")
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
    _update_guide(delta)
    var move := Vector3.ZERO
    if target:
        var goal := guide.global_position if guide else target.global_position
        var stop := GUIDE_ARRIVE if guide else FOLLOW_DISTANCE
        var to_target := goal - global_position
        to_target.y = 0.0
        var distance := to_target.length()
        if distance > stop:
            var speed := RUN_SPEED if distance > stop + 1.6 else WALK_SPEED
            move = to_target / distance * minf(speed, (distance - stop) * 4.0)
    velocity.x = move.x
    velocity.z = move.z
    velocity.y = 0.0 if is_on_floor() else velocity.y - GRAVITY * delta
    move_and_slide()

    var horizontal := Vector2(velocity.x, velocity.z).length()
    if horizontal > 0.1:
        model.rotation.y = lerp_angle(model.rotation.y, atan2(velocity.x, velocity.z), minf(TURN_SPEED * delta, 1.0))
    elif guide and target:
        # Esperando en la pista: mira a Cony para que la siga.
        var to_cony := target.global_position - global_position
        model.rotation.y = lerp_angle(model.rotation.y, atan2(to_cony.x, to_cony.z), minf(TURN_SPEED * delta, 1.0))
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


## Guía: decide cuándo llevar a Cony a la pista activa y cuándo explicarle.
func _update_guide(delta: float) -> void:
    if target == null or not guide_enabled:
        return
    var cony_moving := target is CharacterBody3D and Vector2(target.velocity.x, target.velocity.z).length() > 0.2
    _idle_time = 0.0 if cony_moving else _idle_time + delta
    if threat:
        guide = null
        return
    if guide and (not is_instance_valid(guide) or not guide.is_inside_tree() or not guide.is_active()):
        guide = null
    if guide == null:
        if _idle_time >= GUIDE_DELAY:
            var hint := active_hint()
            if hint and target.global_position.distance_to(hint.global_position) > 2.4:
                guide = hint
                _meow_timer = 0.0
        return
    var cony_to_leo := target.global_position.distance_to(global_position)
    var cony_to_hint := target.global_position.distance_to(guide.global_position)
    if cony_to_leo > GUIDE_GIVE_UP:
        guide = null
        _idle_time = 0.0
        return
    var arrived := global_position.distance_to(guide.global_position) <= GUIDE_ARRIVE + 0.2
    if arrived:
        _meow_timer -= delta
        if _meow_timer <= 0.0:
            _meow_timer = MEOW_INTERVAL
            Sfx.play("meow", global_position + Vector3.UP * 0.3, -4.0, 0.08)
    if (arrived and cony_to_leo <= EXPLAIN_RANGE) or cony_to_hint <= 1.4:
        var hint := guide
        guide = null
        _idle_time = 0.0
        if not hint.was_heard():
            explain(hint)


## Primera pista activa de la sala (en el orden en que están en la escena).
func active_hint() -> Node3D:
    for hint: Node3D in get_tree().get_nodes_in_group("leo_hints"):
        if hint.is_inside_tree() and hint.is_active():
            return hint
    return null


## Leo tiene algo que no ha contado en esta sala.
func has_news() -> bool:
    var hint := active_hint()
    return hint != null and not hint.was_heard() and not _explaining


func explain_news() -> void:
    var hint := active_hint()
    if hint:
        await explain(hint)


func explain(hint: Node3D) -> void:
    if _explaining or Dialogue.is_open() or SceneLoader.is_busy() or hint.lines.is_empty():
        return
    _explaining = true
    GameState.set_flag(hint.heard_flag())
    Sfx.play("meow", global_position + Vector3.UP * 0.3, -2.0, 0.05)
    await Dialogue.say(Array(hint.lines))
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
