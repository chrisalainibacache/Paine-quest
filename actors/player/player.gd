class_name Player
extends CharacterBody3D
## Cony. Movimiento relativo a la cámara fija activa, al estilo de los RE
## modernos con cámaras fijas. Al cortar la cámara, la dirección anterior se
## mantiene mientras el stick siga apuntando más o menos igual (así Cony no da
## media vuelta); apenas el jugador corrige el stick, manda la cámara nueva.

const WALK_SPEED := 1.5
const JOG_SPEED := 2.5
## Velocidad a la que avanza la animación de trote (Mixamo) a ritmo normal:
## se usa para que los pies no patinen.
const JOG_NATURAL_SPEED := 1.9
## Bajo este empuje del stick camina; sobre él, trota.
const JOG_THRESHOLD := 0.75
## Cuánto hay que girar el stick tras un corte para tomar la cámara nueva.
const RELOCK_ANGLE := deg_to_rad(30.0)
const TURN_SPEED := 10.0
const GRAVITY := 18.0
const ANIM_BLEND := 0.2
const ANIMATIONS := preload("res://actors/player/cony_animations.res")

@onready var model: Node3D = $Model
@onready var anim: AnimationPlayer = $AnimationPlayer

var _camera: Camera3D
## Base de referencia congelada mientras el stick está empujado.
var _reference: Basis = Basis.IDENTITY
var _reference_locked := false
## Stick en el momento del último corte de cámara (mientras se mantiene).
var _input_at_cut := Vector2.ZERO
var _cut_pending := false
var _last_input := Vector2.ZERO
var _current_anim := ""


func _ready() -> void:
    add_to_group("player")
    collision_layer = 2
    collision_mask = 1
    anim.add_animation_library(&"cony", ANIMATIONS)
    _make_textures_crisp(model)
    _play("Idle")


func set_camera(camera: Camera3D) -> void:
    _camera = camera
    if _reference_locked:
        _input_at_cut = _last_input
        _cut_pending = true


func _physics_process(delta: float) -> void:
    var input := Input.get_vector(&"move_left", &"move_right", &"move_forward", &"move_back")
    var strength := minf(input.length(), 1.0)

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

    var direction := Vector3.ZERO
    if strength >= 0.15:
        direction = (_reference.x * input.x + _reference.z * input.y).normalized()

    var speed := 0.0
    if strength >= 0.15:
        speed = JOG_SPEED if strength >= JOG_THRESHOLD else WALK_SPEED
    velocity.x = direction.x * speed
    velocity.z = direction.z * speed
    velocity.y = 0.0 if is_on_floor() else velocity.y - GRAVITY * delta
    move_and_slide()

    if direction != Vector3.ZERO:
        var target := atan2(direction.x, direction.z)
        model.rotation.y = lerp_angle(model.rotation.y, target, minf(TURN_SPEED * delta, 1.0))

    if speed == 0.0:
        _play("Idle")
    elif speed == WALK_SPEED:
        _play("Walk", clampf(strength / JOG_THRESHOLD, 0.6, 1.0))
    else:
        _play("Jog", JOG_SPEED / JOG_NATURAL_SPEED)


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
