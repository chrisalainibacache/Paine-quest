class_name Player
extends CharacterBody3D
## Isabella. Movimiento relativo a la cámara fija activa, al estilo de los RE
## modernos con cámaras fijas. Al cortar la cámara, la dirección anterior se
## mantiene mientras el stick siga apuntando más o menos igual (así Isabella no da
## media vuelta); apenas el jugador corrige el stick, manda la cámara nueva.
## El arma vive en el nodo hijo Combat (player_combat.gd).

signal health_changed(health: int, max_health: int)
signal damaged(amount: int)
signal died

const WALK_SPEED := 1.5
const JOG_SPEED := 2.5
## Velocidad a la que avanza la animación de trote (Mixamo) a ritmo normal:
## se usa para que los pies no patinen.
const JOG_NATURAL_SPEED := 1.45
## Velocidad a la que está hecha la animación de caminar (medida con los pies apoyados: ~1,0 m/s). Con
## anim.speed_scale = velocidad / este valor los pies no patinan sobre el suelo.
const WALK_NATURAL_SPEED := 1.0
## Arranque y frenada: la velocidad sube y baja en vez de saltar (se ve más natural y evita el patinaje).
const ACCELERATION := 9.0
const DECELERATION := 14.0
## En "Peligro" Isabella cojea: todo más lento.
const DANGER_SPEED_FACTOR := 0.7
## Bajo este empuje del stick camina; sobre él, trota.
const JOG_THRESHOLD := 0.75
## Cuánto hay que girar el stick tras un corte para tomar la cámara nueva.
const RELOCK_ANGLE := deg_to_rad(30.0)
const TURN_SPEED := 10.0
const AIM_STICK_TURN_SPEED := 3.5
const GRAVITY := 18.0
const ANIM_BLEND := 0.2
const MAX_HEALTH := 100
const HURT_TIME := 0.55
const INVULNERABLE_TIME := 0.9
const ANIMATIONS := preload("res://actors/player/cony_animations.res")
## Modelo de Ignacia (misma biblioteca de animaciones: ambos esqueletos son humanoides de Godot).
const IGNACIA_MODEL := preload("res://assets/characters/ignacia/ignacia.glb")

@onready var model: Node3D = $Model
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var combat: PlayerCombat = $Combat
@onready var interaction: PlayerInteraction = $Interaction

var health := MAX_HEALTH
## Bloquea los controles (puertas, menús, mensajes).
var controls_locked := false
var _camera: Camera3D
## Base de referencia congelada mientras el stick está empujado.
var _reference: Basis = Basis.IDENTITY
var _reference_locked := false
## Stick en el momento del último corte de cámara (mientras se mantiene).
var _input_at_cut := Vector2.ZERO
var _cut_pending := false
var _last_input := Vector2.ZERO
var _current_anim := ""
## Animación de acción en curso (disparo, recarga, golpe) y cuánto le queda.
var _action_anim := ""
var _action_time := 0.0
var _hurt_time := 0.0
var _invulnerable_time := 0.0
var _danger_breath_timer := 0.0
## Velocidad real actual y dirección en la que se mueve (para frenar suave al soltar el stick).
var _speed := 0.0
var _move_direction := Vector3.ZERO
var _wants_jog := false


func _enter_tree() -> void:
    # Antes de _ready, para que el arma y las animaciones se monten sobre el modelo definitivo.
    if GameSettings.get_character() == "ignacia":
        var old := get_node_or_null("Model") as Node3D
        if old != null:
            var fresh := IGNACIA_MODEL.instantiate() as Node3D
            fresh.name = "NewModel"
            fresh.transform = old.transform
            remove_child(old)
            old.free()
            add_child(fresh)
            fresh.name = "Model"


func _ready() -> void:
    add_to_group("player")
    collision_layer = 2
    collision_mask = 1 | 8
    anim.add_animation_library(&"cony", ANIMATIONS)
    _make_textures_crisp(model)
    _play("Idle")


func set_camera(camera: Camera3D) -> void:
    _camera = camera
    if _reference_locked:
        _input_at_cut = _last_input
        _cut_pending = true


## Olvida la referencia de cámara (al entrar a otra sala).
func reset_motion() -> void:
    _reference_locked = false
    _cut_pending = false
    _action_anim = ""


## Linterna para salas a oscuras (apagón).
func set_flashlight(on: bool) -> void:
    var light := model.get_node_or_null("Flashlight") as SpotLight3D
    if light == null:
        if not on:
            return
        light = SpotLight3D.new()
        light.name = "Flashlight"
        light.position = Vector3(0.15, 1.3, 0.25)
        # El SpotLight alumbra hacia -Z; el modelo mira hacia +Z.
        light.rotation = Vector3(-0.12, PI, 0)
        light.light_color = Color(1.0, 0.95, 0.82)
        light.light_energy = 4.5
        light.spot_range = 13.0
        light.spot_angle = 38.0
        light.spot_attenuation = 0.8
        model.add_child(light)
    light.visible = on


func is_alive() -> bool:
    return health > 0


func is_hurt() -> bool:
    return _hurt_time > 0.0


## "Bien", "Precaución" o "Peligro" (como el electrocardiograma de RE).
func get_condition() -> String:
    if health > 60:
        return "Bien"
    if health > 25:
        return "Precaución"
    return "Peligro"


func take_damage(amount: int, from_position: Vector3) -> void:
    if not is_alive() or _invulnerable_time > 0.0:
        return
    health = maxi(health - amount, 0)
    GameState.health = health
    _invulnerable_time = INVULNERABLE_TIME
    _play_hurt_sound()
    if get_condition() == "Peligro":
        _danger_breath_timer = 2.5
    Input.vibrate_handheld(180)
    face_direction(from_position - global_position, 1.0)
    health_changed.emit(health, MAX_HEALTH)
    damaged.emit(amount)
    if health <= 0:
        _action_anim = ""
        _play("Death01")
        Sfx.play("fall", global_position, -2.0)
        died.emit()
    else:
        _hurt_time = HURT_TIME
        play_action("Hit_Chest", HURT_TIME)


func _play_hurt_sound() -> void:
    Sfx.play("hurt_low" if get_condition() == "Peligro" else "hurt", null, -2.0)


func _update_danger_breath(delta: float) -> void:
    if not is_alive() or controls_locked or get_condition() != "Peligro":
        _danger_breath_timer = 0.0
        return
    _danger_breath_timer -= delta
    if _danger_breath_timer <= 0.0:
        _danger_breath_timer = 5.5
        Sfx.play("breath_low", global_position, -12.0, 0.03)


func heal(amount: int) -> void:
    health = mini(health + amount, MAX_HEALTH)
    GameState.health = health
    health_changed.emit(health, MAX_HEALTH)


## Animación de una acción (disparar, recargar, recibir golpe) por encima del
## movimiento; al terminar se vuelve sola a la pose que corresponda.
func play_action(anim_name: String, duration: float) -> void:
    _action_anim = anim_name
    _action_time = duration
    _current_anim = ""
    _play(anim_name)


## Gira a Isabella hacia una dirección (weight 1 = de golpe).
func face_direction(direction: Vector3, weight: float) -> void:
    direction.y = 0.0
    if direction.length() < 0.01:
        return
    model.rotation.y = lerp_angle(model.rotation.y, atan2(direction.x, direction.z), clampf(weight, 0.0, 1.0))


## Hacia dónde mira Isabella (horizontal).
func get_forward() -> Vector3:
    return Vector3(sin(model.rotation.y), 0.0, cos(model.rotation.y))


func _physics_process(delta: float) -> void:
    _hurt_time = maxf(_hurt_time - delta, 0.0)
    _invulnerable_time = maxf(_invulnerable_time - delta, 0.0)
    _action_time = maxf(_action_time - delta, 0.0)
    _update_danger_breath(delta)
    if _action_time <= 0.0:
        _action_anim = ""

    var input := Input.get_vector(&"move_left", &"move_right", &"move_forward", &"move_back")
    var strength := minf(input.length(), 1.0)
    if not is_alive() or is_hurt() or controls_locked:
        input = Vector2.ZERO
        strength = 0.0
    _update_reference(input, strength)

    var direction := Vector3.ZERO
    if strength >= 0.15:
        direction = (_reference.x * input.x + _reference.z * input.y).normalized()

    var target_speed := 0.0
    _wants_jog = false
    var aiming := combat.aiming or combat.reloading
    if aiming:
        # Apuntando no camina: el stick sólo la gira (si no hay blanco).
        if direction != Vector3.ZERO and combat.target == null:
            face_direction(direction, AIM_STICK_TURN_SPEED * delta)
    elif strength >= 0.15:
        _wants_jog = strength >= JOG_THRESHOLD
        target_speed = JOG_SPEED if _wants_jog else WALK_SPEED
        if get_condition() == "Peligro":
            target_speed *= DANGER_SPEED_FACTOR
        face_direction(direction, TURN_SPEED * delta)

    if direction != Vector3.ZERO:
        _move_direction = direction
    _speed = move_toward(_speed, target_speed, (ACCELERATION if target_speed > _speed else DECELERATION) * delta)
    velocity.x = _move_direction.x * _speed
    velocity.z = _move_direction.z * _speed
    velocity.y = 0.0 if is_on_floor() else velocity.y - GRAVITY * delta
    move_and_slide()
    _update_animation(_speed, aiming)


func _update_reference(input: Vector2, strength: float) -> void:
    if strength < 0.15:
        _reference_locked = false
        _cut_pending = false
    elif not _reference_locked and _camera:
        _reference = _flat_basis(_camera.global_basis)
        _reference_locked = true
    elif _cut_pending and absf(input.angle_to(_input_at_cut)) > RELOCK_ANGLE:
        # El jugador corrigió el stick: ahora manda la cámara nueva.
        _reference = _flat_basis(_camera.global_basis)
        _cut_pending = false
    _last_input = input


func _update_animation(speed: float, aiming: bool) -> void:
    if not is_alive() or _action_anim != "":
        return
    if aiming:
        _play("Pistol_Aim_Neutral")
    elif speed < 0.05:
        _play("Idle")
    elif _wants_jog and speed > WALK_SPEED * 0.9:
        _play("Jog", speed / JOG_NATURAL_SPEED)
    else:
        # La velocidad de la animación sigue a la velocidad real: los pies no patinan.
        _play("Walk", maxf(speed / WALK_NATURAL_SPEED, 0.5))


func get_current_animation() -> String:
    return _current_anim


func _play(anim_name: String, speed_scale: float = 1.0) -> void:
    anim.speed_scale = speed_scale
    if _current_anim == anim_name:
        return
    _current_anim = anim_name
    anim.play("cony/" + anim_name, ANIM_BLEND)


## Base horizontal de la cámara (sin inclinación): adelante = hacia donde mira.
static func _flat_basis(camera_basis: Basis) -> Basis:
    var forward := -camera_basis.z
    forward.y = 0.0
    if forward.length() < 0.01:
        forward = camera_basis.y
        forward.y = 0.0
    forward = forward.normalized()
    var right := Vector3(-forward.z, 0.0, forward.x)
    # Stick hacia abajo (+y) = hacia la cámara.
    return Basis(right, Vector3.UP, -forward)


## Texturas pixeladas (PS1): sin filtro bilineal.
static func _make_textures_crisp(root: Node) -> void:
    for mesh_instance: MeshInstance3D in root.find_children("*", "MeshInstance3D", true, false):
        for i in mesh_instance.mesh.get_surface_count():
            var material := mesh_instance.mesh.surface_get_material(i) as BaseMaterial3D
            if material:
                material = material.duplicate() as BaseMaterial3D
                material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
                material.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
                mesh_instance.set_surface_override_material(i, material)
