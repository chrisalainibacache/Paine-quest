class_name PlayerCombat
extends Node
## Arma de Cony: apuntar (mantener), disparar, munición y recarga.
## Como en RE: mientras apunta no camina; el auto-apuntado elige al infectado
## más cercano frente a ella que esté a la vista. El arma equipada y las balas
## de reserva vienen de la mochila (GameState).

signal ammo_changed(clip: int, reserve: int)
signal aiming_changed(aiming: bool)
signal target_changed(target: Node3D)

const PISTOL_SCENE := preload("res://actors/player/pistol.tscn")
const AIM_TURN_SPEED := 9.0
const RETARGET_INTERVAL := 0.2

## Arma equipada (null = Cony no tiene arma y no puede apuntar).
var weapon: WeaponData
var clip := 0
## Balas de reserva: las que hay en la mochila.
var reserve: int:
    get:
        if weapon == null or weapon.ammo_item == null:
            return 0
        return GameState.inventory.count_of(weapon.ammo_item)
var aiming := false
var target: Node3D
var reloading := false

@onready var player: Player = get_parent()
var _pistol: Node3D
var _fire_timer := 0.0
var _reload_timer := 0.0
var _retarget_timer := 0.0


func _ready() -> void:
    GameState.inventory.changed.connect(_emit_ammo)
    sync_from_state()
    _attach_pistol.call_deferred()


## Toma el arma equipada y la munición del cargador desde GameState.
func sync_from_state() -> void:
    var item := GameState.equipped
    weapon = item.weapon if item else null
    clip = GameState.clip if weapon else 0
    _emit_ammo()


func has_weapon() -> bool:
    return weapon != null


func _emit_ammo() -> void:
    ammo_changed.emit(clip, reserve)


func _attach_pistol() -> void:
    var skeleton := player.model.find_child("GeneralSkeleton", true, false) as Skeleton3D
    var hand := BoneAttachment3D.new()
    hand.bone_name = "RightHand"
    skeleton.add_child(hand)
    _pistol = PISTOL_SCENE.instantiate()
    hand.add_child(_pistol)
    _pistol.visible = false


func _physics_process(delta: float) -> void:
    _fire_timer = maxf(_fire_timer - delta, 0.0)
    var can_act := weapon != null and player.is_alive() and not player.is_hurt() and not player.controls_locked

    if reloading:
        _reload_timer -= delta
        if _reload_timer <= 0.0:
            _finish_reload()

    var want_aim := can_act and Input.is_action_pressed(&"aim")
    if want_aim != aiming:
        aiming = want_aim
        if not aiming:
            _set_target(null)
        aiming_changed.emit(aiming)
    if _pistol:
        _pistol.visible = aiming or reloading

    if not aiming:
        return
    _retarget_timer -= delta
    if _retarget_timer <= 0.0 or (target and not target.is_alive()):
        _retarget_timer = RETARGET_INTERVAL
        _set_target(_find_target())
    if target:
        var to_target := target.global_position - player.global_position
        player.face_direction(to_target, AIM_TURN_SPEED * delta)

    if Input.is_action_just_pressed(&"fire") and _fire_timer <= 0.0 and not reloading:
        _fire()


func _fire() -> void:
    _fire_timer = weapon.fire_interval
    if clip <= 0:
        if reserve > 0:
            _start_reload()
        else:
            Sfx.play("click", null, -4.0)
        return
    clip -= 1
    GameState.clip = clip
    _emit_ammo()
    Sfx.play("shot", player.global_position + Vector3.UP * 1.3, 2.0)
    player.play_action("Pistol_Shoot", 0.35)
    if _pistol and _pistol.has_method("flash"):
        _pistol.flash()

    var origin := player.global_position + Vector3.UP * 1.35
    if target and _has_line_of_sight(origin, target.get_aim_point()):
        var point: Vector3 = target.get_aim_point() + Vector3(randf_range(-0.1, 0.1), randf_range(-0.15, 0.1), randf_range(-0.1, 0.1))
        target.take_hit(weapon.damage, origin, point, weapon.stagger_chance)
    if clip == 0 and reserve > 0:
        get_tree().create_timer(0.35).timeout.connect(_start_reload)


func _start_reload() -> void:
    if reloading or reserve <= 0 or clip == weapon.clip_size or not player.is_alive():
        return
    reloading = true
    _reload_timer = weapon.reload_time
    Sfx.play("reload", null, -3.0)
    player.play_action("Pistol_Reload", weapon.reload_time)


func _finish_reload() -> void:
    reloading = false
    var needed := weapon.clip_size - clip
    clip += GameState.inventory.take(weapon.ammo_item, needed)
    GameState.clip = clip
    _emit_ammo()


func _set_target(new_target: Node3D) -> void:
    if new_target == target:
        return
    target = new_target
    target_changed.emit(target)


## El infectado vivo más cercano frente a Cony, a la vista y a distancia de tiro.
func _find_target() -> Node3D:
    var best: Node3D = null
    var best_score := INF
    var forward := player.get_forward()
    var origin := player.global_position + Vector3.UP * 1.35
    for enemy: Node3D in get_tree().get_nodes_in_group("enemies"):
        if not enemy.is_alive():
            continue
        var to_enemy := enemy.global_position - player.global_position
        to_enemy.y = 0.0
        var distance := to_enemy.length()
        if distance > weapon.max_range or distance < 0.01:
            continue
        var angle := rad_to_deg(forward.angle_to(to_enemy))
        # Al empezar a apuntar se acepta cualquier dirección (Cony se gira hacia
        # él); ya apuntando, sólo cambia a otro dentro del cono frontal.
        if target != null and angle > weapon.aim_cone_degrees:
            continue
        if not _has_line_of_sight(origin, enemy.get_aim_point()):
            continue
        var score := distance + angle * 0.03
        if score < best_score:
            best_score = score
            best = enemy
    return best


func _has_line_of_sight(from: Vector3, to: Vector3) -> bool:
    var query := PhysicsRayQueryParameters3D.create(from, to)
    query.collision_mask = 1
    return player.get_world_3d().direct_space_state.intersect_ray(query).is_empty()
