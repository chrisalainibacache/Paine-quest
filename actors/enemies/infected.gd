class_name Infected
extends CharacterBody3D
## Infectado. Lento y persistente: camina hacia Cony, la ataca de cerca y se
## tambalea con los disparos. Puede empezar de pie, comiendo o tirado en el
## suelo haciéndose el muerto. "corpse" es un cadáver de verdad (decorado).

signal died(infected: Infected)

enum State { IDLE, FEEDING, LYING, RISING, CHASE, ATTACK, STAGGER, DEAD }

const ANIMATIONS := preload("res://actors/enemies/infected_animations.res")
const STAIN_SCENE := preload("res://levels/kit/props/stain.tscn")
const GRAVITY := 18.0
## Velocidad a la que avanza la animación de caminar a ritmo normal.
const WALK_ANIM_SPEED := 0.9
## Correspondencia entre los nombres UAL de las animaciones y el perfil humanoide
## usado por los modelos Mixamo de infectados.
const UAL_TO_HUMANOID_BONES := {
    "pelvis": "Hips",
    "spine_01": "Spine",
    "spine_02": "Chest",
    "spine_03": "UpperChest",
    "neck_01": "Neck",
    "Head": "Head",
    "clavicle_l": "LeftShoulder",
    "upperarm_l": "LeftUpperArm",
    "lowerarm_l": "LeftLowerArm",
    "hand_l": "LeftHand",
    "thigh_l": "LeftUpperLeg",
    "calf_l": "LeftLowerLeg",
    "foot_l": "LeftFoot",
    "ball_l": "LeftToes",
    "thumb_01_l": "LeftThumbMetacarpal",
    "thumb_02_l": "LeftThumbProximal",
    "thumb_03_l": "LeftThumbDistal",
    "index_01_l": "LeftIndexProximal",
    "index_02_l": "LeftIndexIntermediate",
    "index_03_l": "LeftIndexDistal",
    "middle_01_l": "LeftMiddleProximal",
    "middle_02_l": "LeftMiddleIntermediate",
    "middle_03_l": "LeftMiddleDistal",
    "ring_01_l": "LeftRingProximal",
    "ring_02_l": "LeftRingIntermediate",
    "ring_03_l": "LeftRingDistal",
    "pinky_01_l": "LeftLittleProximal",
    "pinky_02_l": "LeftLittleIntermediate",
    "pinky_03_l": "LeftLittleDistal",
    "clavicle_r": "RightShoulder",
    "upperarm_r": "RightUpperArm",
    "lowerarm_r": "RightLowerArm",
    "hand_r": "RightHand",
    "thigh_r": "RightUpperLeg",
    "calf_r": "RightLowerLeg",
    "foot_r": "RightFoot",
    "ball_r": "RightToes",
    "thumb_01_r": "RightThumbMetacarpal",
    "thumb_02_r": "RightThumbProximal",
    "thumb_03_r": "RightThumbDistal",
    "index_01_r": "RightIndexProximal",
    "index_02_r": "RightIndexIntermediate",
    "index_03_r": "RightIndexDistal",
    "middle_01_r": "RightMiddleProximal",
    "middle_02_r": "RightMiddleIntermediate",
    "middle_03_r": "RightMiddleDistal",
    "ring_01_r": "RightRingProximal",
    "ring_02_r": "RightRingIntermediate",
    "ring_03_r": "RightRingDistal",
    "pinky_01_r": "RightLittleProximal",
    "pinky_02_r": "RightLittleIntermediate",
    "pinky_03_r": "RightLittleDistal",
}
## Distancia a la que se levanta si estaba tirado.
const LYING_WAKE_RANGE := 3.2
## Distancia a la que deja de comer.
const FEEDING_WAKE_RANGE := 4.0

@export var data: EnemyData = preload("res://data/enemies/infected.tres")
@export_enum("idle", "feeding", "lying", "corpse") var start_state: String = "idle"
## Solo aparece si esta bandera de GameState ya existe (p. ej. "found:pistol").
@export var requires_flag: String = ""

var health := 1
var state := State.IDLE
var target: Node3D
var model: Node3D
var _anim: AnimationPlayer
var _state_time := 0.0
var _cooldown := 0.0
var _attack_landed := false
var _groan_timer := 0.0
var _sprinting := false
var _sprint_timer := 0.0


func _ready() -> void:
    if not requires_flag.is_empty() and not GameState.has_flag(requires_flag):
        queue_free()
        return
    add_to_group("enemies")
    collision_layer = 8
    collision_mask = 1 | 2
    health = data.health
    var modern := GraphicsSettings.is_modern() and data.modern_model_scene != null
    model = (data.modern_model_scene if modern else data.model_scene).instantiate() as Node3D
    model.name = "Model"
    # El giro con que se colocó en la sala pasa al modelo: así el cuerpo queda
    # sin rotar y "hacia adelante" del modelo coincide con el avance global
    # (si no, un infectado girado en el editor camina de espaldas).
    model.rotation.y = global_rotation.y
    global_rotation = Vector3.ZERO
    add_child(model)
    Player._make_textures_crisp(model)
    if modern:
        _enable_specular()
    _vary_look()
    if data.helmet:
        _add_helmet()
    _anim = AnimationPlayer.new()
    _anim.name = "AnimationPlayer"
    add_child(_anim)
    _anim.root_node = _anim.get_path_to(model)
    var skeleton := _find_model_skeleton(model)
    if skeleton:
        _anim.add_animation_library(&"z", _retarget_animation_library(skeleton))
    else:
        var model_nodes: Array[String] = []
        for child: Node in model.find_children("*", "", true, false):
            model_nodes.append("%s (%s)" % [str(model.get_path_to(child)), child.get_class()])
        push_warning("El modelo %s no contiene Skeleton3D. Jerarquía: %s" % [data.display_name, str(model_nodes)])
        _anim.add_animation_library(&"z", ANIMATIONS)
    _groan_timer = randf_range(2.0, 6.0)
    if start_state == "corpse" or GameState.has_flag(_dead_flag()):
        _lie_dead()
        return
    match start_state:
        "feeding": _enter(State.FEEDING)
        "lying": _enter(State.LYING)
        _: _enter(State.IDLE)


## Cada infectado se ve un poco distinto: tono, brillo y estatura al azar.

## Busca cualquier esqueleto, aunque el importador cambie el nombre del nodo.
func _find_model_skeleton(root_node: Node) -> Skeleton3D:
    if root_node is Skeleton3D:
        return root_node as Skeleton3D
    for child: Node in root_node.get_children():
        var found := _find_model_skeleton(child)
        if found:
            return found
    return null


## Reasigna las pistas de huesos a la ruta real del esqueleto del modelo.
## Los clips UAL llegan desde otra escena: no se asume que su ruta Armature
## coincida con el nodo Skeleton3D del modelo Mixamo instanciado.
func _retarget_animation_library(skeleton: Skeleton3D) -> AnimationLibrary:
    var library := ANIMATIONS.duplicate(true) as AnimationLibrary
    var skeleton_path := str(model.get_path_to(skeleton))
    var mapped_tracks := 0
    for anim_name: StringName in library.get_animation_list():
        var animation := library.get_animation(anim_name)
        for track in animation.get_track_count():
            var source_path := animation.track_get_path(track)
            if source_path.get_subname_count() == 0:
                continue
            var source_bone := String(source_path.get_subname(0))
            # El root de movimiento no existe en los esqueletos Mixamo: la
            # traslación del enemigo la resuelve CharacterBody3D.
            if source_bone.to_lower() == "root":
                continue
            var target_bone: String = UAL_TO_HUMANOID_BONES.get(source_bone, source_bone)
            if skeleton.find_bone(target_bone) < 0:
                # Algunos modelos no incluyen falanges opcionales; se omiten.
                continue
            var target_path := NodePath("%s:%s" % [skeleton_path, target_bone])
            animation.track_set_path(track, target_path)
            mapped_tracks += 1
    if mapped_tracks == 0:
        push_warning("No se encontraron pistas de huesos para las animaciones de %s." % data.display_name)
    return library


## Casco militar pegado al hueso de la cabeza.
func _add_helmet() -> void:
    var skeleton := _find_model_skeleton(model)
    if skeleton == null or skeleton.find_bone("Head") < 0:
        return
    var attachment := BoneAttachment3D.new()
    attachment.bone_name = "Head"
    skeleton.add_child(attachment)
    var olive := preload("res://levels/kit/materials/olive.tres")
    var shell := MeshInstance3D.new()
    var dome := SphereMesh.new()
    dome.radius = 0.14
    dome.height = 0.14
    dome.is_hemisphere = true
    dome.radial_segments = 12
    dome.rings = 4
    shell.mesh = dome
    shell.material_override = olive
    shell.position = Vector3(0, 0.12, 0.0)
    attachment.add_child(shell)
    var brim := MeshInstance3D.new()
    var ring := CylinderMesh.new()
    ring.top_radius = 0.16
    ring.bottom_radius = 0.16
    ring.height = 0.015
    ring.radial_segments = 12
    brim.mesh = ring
    brim.material_override = olive
    brim.position = Vector3(0, 0.12, 0.0)
    attachment.add_child(brim)


## El modelo moderno tiene relieve y rugosidad: necesita brillos.
func _enable_specular() -> void:
    for mesh_instance: MeshInstance3D in model.find_children("*", "MeshInstance3D", true, false):
        for i in mesh_instance.get_surface_override_material_count():
            var material := mesh_instance.get_surface_override_material(i) as BaseMaterial3D
            if material:
                material.specular_mode = BaseMaterial3D.SPECULAR_SCHLICK_GGX


func _vary_look() -> void:
    var shade := randf_range(0.85, 1.08)
    var tint := data.tint * Color(shade * randf_range(0.95, 1.05), shade, shade * randf_range(0.92, 1.02))
    for mesh_instance: MeshInstance3D in model.find_children("*", "MeshInstance3D", true, false):
        for i in mesh_instance.mesh.get_surface_count():
            var material := mesh_instance.get_surface_override_material(i) as BaseMaterial3D
            if material:
                material.albedo_color = material.albedo_color * tint
    model.scale *= randf_range(0.94, 1.06)


func is_alive() -> bool:
    return state != State.DEAD


## Punto al que apunta Cony (pecho).
func get_aim_point() -> Vector3:
    return global_position + Vector3(0, 1.25 if state != State.LYING else 0.3, 0)


func take_hit(damage: int, from_position: Vector3, hit_point: Vector3, stagger_chance: float) -> void:
    if state == State.DEAD:
        return
    health -= damage
    BloodBurst.spawn(get_parent(), hit_point, hit_point - from_position)
    Sfx.play("hit", hit_point, -2.0)
    if health <= 0:
        _die()
        return
    match state:
        State.LYING:
            _enter(State.RISING)
        State.IDLE, State.FEEDING:
            _enter(State.CHASE)
        State.CHASE, State.ATTACK:
            if randf() < stagger_chance:
                _enter(State.STAGGER)


func _physics_process(delta: float) -> void:
    if target == null:
        target = get_tree().get_first_node_in_group("player") as Node3D
    _state_time += delta
    _cooldown = maxf(_cooldown - delta, 0.0)
    var to_target := Vector3.ZERO
    var distance := INF
    if target and is_instance_valid(target):
        to_target = target.global_position - global_position
        to_target.y = 0.0
        distance = to_target.length()
    var target_alive: bool = target != null and target.has_method("is_alive") and target.is_alive()

    var move := Vector3.ZERO
    match state:
        State.IDLE:
            if target_alive and distance < data.notice_range and _can_see_target():
                _enter(State.CHASE)
        State.FEEDING:
            if target_alive and distance < FEEDING_WAKE_RANGE:
                _enter(State.CHASE)
        State.LYING:
            if target_alive and distance < LYING_WAKE_RANGE:
                _enter(State.RISING)
        State.RISING:
            if _state_time > _anim_length("LayToIdle") * 0.95:
                _enter(State.CHASE)
        State.CHASE:
            if not target_alive:
                _enter(State.IDLE)
            else:
                _face(to_target, delta)
                if distance <= data.attack_range and _cooldown <= 0.0:
                    _enter(State.ATTACK)
                elif distance > data.attack_range * 0.8:
                    move = _forward() * _chase_speed(delta)
        State.ATTACK:
            _face(to_target, delta * 0.5)
            var length := _anim_length("Zombie_Scratch")
            if not _attack_landed and _state_time > length * 0.45:
                _attack_landed = true
                if target_alive and distance < data.attack_range + 0.35 and target.has_method("take_damage"):
                    target.take_damage(data.attack_damage, global_position)
                    Sfx.play("bite", target.global_position + Vector3.UP * 1.4)
            if _state_time > length:
                _cooldown = data.attack_cooldown
                _enter(State.CHASE)
        State.STAGGER:
            if _state_time > _anim_length("Hit_Chest") * 0.9:
                _enter(State.CHASE)
        State.DEAD:
            pass

    velocity.x = move.x
    velocity.z = move.z
    velocity.y = 0.0 if is_on_floor() else velocity.y - GRAVITY * delta
    move_and_slide()

    if state in [State.CHASE, State.IDLE, State.FEEDING]:
        _groan_timer -= delta
        if _groan_timer <= 0.0:
            _groan_timer = randf_range(4.0, 9.0)
            Sfx.play("groan" if randf() < 0.5 else "groan_short", global_position + Vector3.UP * 1.5, -6.0, 0.15)


## Velocidad de persecución. Los rápidos alternan carreras cortas y pausas.
func _chase_speed(delta: float) -> float:
    if data.sprint_speed <= 0.0:
        return data.walk_speed
    _sprint_timer -= delta
    if _sprint_timer <= 0.0:
        _sprinting = not _sprinting
        _sprint_timer = data.sprint_time if _sprinting else data.rest_time * randf_range(0.7, 1.3)
        var speed := data.sprint_speed if _sprinting else data.walk_speed
        _anim.speed_scale = speed / WALK_ANIM_SPEED
        if _sprinting:
            Sfx.play("groan_short", global_position + Vector3.UP * 1.5, -2.0, 0.2)
    return data.sprint_speed if _sprinting else data.walk_speed


func _enter(new_state: State) -> void:
    state = new_state
    _state_time = 0.0
    match new_state:
        State.IDLE:
            _play("Zombie_Idle", 0.3)
        State.FEEDING:
            _play("Consume", 0.3)
        State.LYING:
            # Tirado en el suelo: primer cuadro de "levantarse", detenido.
            _anim.speed_scale = 1.0
            _anim.play("z/LayToIdle")
            _anim.seek(0.0, true)
            _anim.pause()
        State.RISING:
            _anim.speed_scale = 1.0
            _anim.play("z/LayToIdle", 0.1)
            Sfx.play("groan", global_position + Vector3.UP, -3.0)
        State.CHASE:
            _play("Zombie_Walk_Fwd", 0.35, data.walk_speed / WALK_ANIM_SPEED)
            if randf() < 0.5:
                Sfx.play("groan_short", global_position + Vector3.UP * 1.5, -4.0, 0.15)
        State.ATTACK:
            _attack_landed = false
            _play("Zombie_Scratch", 0.15)
        State.STAGGER:
            _play("Hit_Chest", 0.1)
        State.DEAD:
            _play("Death01", 0.15)


func _die() -> void:
    _enter(State.DEAD)
    remove_from_group("enemies")
    collision_layer = 0
    GameState.set_flag(_dead_flag())
    Sfx.play("fall", global_position, -2.0)
    died.emit(self)
    _spawn_stain()


## Ya había muerto antes (se volvió a la sala): queda tirado donde cayó.
func _lie_dead() -> void:
    state = State.DEAD
    remove_from_group("enemies")
    collision_layer = 0
    _anim.play("z/Death01")
    _anim.seek(_anim_length("Death01"), true)
    _anim.pause()
    _spawn_stain.call_deferred()


## Mancha de sangre que queda en el piso.
func _spawn_stain() -> void:
    var stain := STAIN_SCENE.instantiate() as Node3D
    get_parent().add_child(stain)
    stain.global_position = global_position + Vector3(0, 0.013, 0) + _forward() * -0.6
    stain.scale = Vector3(1.6, 1, 1.6)
    stain.rotation.y = randf() * TAU


func _dead_flag() -> String:
    return "dead:" + GameState.node_key(self)


func _can_see_target() -> bool:
    var space := get_world_3d().direct_space_state
    var query := PhysicsRayQueryParameters3D.create(global_position + Vector3.UP * 1.5, target.global_position + Vector3.UP * 1.2)
    query.collision_mask = 1
    return space.intersect_ray(query).is_empty()


func _face(direction: Vector3, delta: float) -> void:
    if direction.length() < 0.01:
        return
    var goal := atan2(direction.x, direction.z)
    model.rotation.y = lerp_angle(model.rotation.y, goal, minf(data.turn_speed * delta, 1.0))


func _forward() -> Vector3:
    return Vector3(sin(model.rotation.y), 0.0, cos(model.rotation.y))


func _play(anim_name: String, blend: float, speed: float = 1.0) -> void:
    _anim.speed_scale = speed
    _anim.play("z/" + anim_name, blend)


func _anim_length(anim_name: String) -> float:
    return _anim.get_animation("z/" + anim_name).length / maxf(_anim.speed_scale, 0.01)
