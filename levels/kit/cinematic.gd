class_name Cinematic
extends Node3D
## Cinemática breve en vivo: la amenaza solo se percibe por sus efectos.

signal finished

const DURATION := 10.0
const SCENE_BUILDER := preload("res://levels/kit/cinematic_scene_builder.gd")

var _camera: Camera3D
var _door_panel: Node3D
var _fluorescent: OmniLight3D
var _lamp_material: StandardMaterial3D
var _shadow: Node3D
var _dust: CPUParticles3D
var _fade: ColorRect
var _shards: Array[RigidBody3D] = []
var _elapsed := 0.0
var _active := false
var _step_count := 0
var _first_impact := false
var _second_impact := false
var _breath_played := false
var _roar_played := false


func _ready() -> void:
    add_to_group("cinematics")
    _build_scene()
    _camera.make_current()
    _fade.color.a = 1.0
    _shadow.visible = false
    for shard in _shards:
        shard.freeze = true
        shard.visible = false


func _build_scene() -> void:
    SCENE_BUILDER.build(self)


## Se completa al llegar a diez segundos o al recibir un único toque.
func play() -> void:
    _elapsed = 0.0
    _active = true
    _update_scene()
    await finished


func skip() -> void:
    if not _active:
        return
    _elapsed = DURATION
    _update_scene()
    _complete()


func _input(event: InputEvent) -> void:
    if not _active:
        return
    var tapped := event is InputEventScreenTouch and (event as InputEventScreenTouch).pressed
    var clicked := event is InputEventMouseButton and (event as InputEventMouseButton).pressed
    if tapped or clicked:
        get_viewport().set_input_as_handled()
        skip()


func _process(delta: float) -> void:
    if not _active:
        return
    _elapsed = minf(_elapsed + delta, DURATION)
    _update_scene()
    if _elapsed >= DURATION:
        _complete()


func _update_scene() -> void:
    var t := _elapsed
    _fade.color.a = 1.0 - smoothstep(0.0, 1.0, t) if t < 1.0 else 1.0 if t >= 8.0 else 0.0
    if t < 4.6:
        var flicker := 0.82 + 0.12 * sin(t * 19.0) + 0.06 * sin(t * 47.0)
        if t > 3.0 and int(t * 8.0) % 5 == 0:
            flicker *= 0.28
        _fluorescent.light_energy = maxf(flicker, 0.12)
        _lamp_material.emission_energy_multiplier = maxf(flicker, 0.12)
    elif t < 4.72:
        _fluorescent.light_energy = 2.4
        _lamp_material.emission_energy_multiplier = 2.4
    else:
        _fluorescent.light_energy = 0.0
        _lamp_material.emission_energy_multiplier = 0.0

    if t >= 4.0 and t < 5.2:
        var shake := 0.045 if t < 4.6 else 0.085
        _camera.position = Vector3(sin(t * 74.0) * shake, 3.0 + cos(t * 61.0) * shake, 8.2)
    else:
        _camera.position = Vector3(0.0, 3.0, 8.2)

    while _step_count < 3 and t >= 1.0 + float(_step_count) * 0.85:
        var volume := -12.0 + float(_step_count) * 3.0
        Sfx.play("creature_step_far", Vector3(0.0, 0.1, -7.0), volume, 0.02)
        _step_count += 1

    if t >= 4.0 and not _first_impact:
        _first_impact = true
        Sfx.play("creature_door_smash", Vector3(0.0, 1.2, -5.3), -5.0, 0.02)
    if t >= 4.0 and t < 4.6:
        var hit := smoothstep(4.0, 4.6, t)
        _door_panel.position.z = -5.34 + 0.24 * hit
        _door_panel.rotation.x = -0.08 * hit
    elif t >= 4.6:
        _door_panel.visible = false

    if t >= 4.6 and not _second_impact:
        _second_impact = true
        Sfx.play("creature_door_smash", Vector3(0.0, 1.2, -5.3), 0.0, 0.02)
        _dust.restart()
        for i in _shards.size():
            var shard := _shards[i]
            shard.visible = true
            shard.freeze = false
            var impulse := Vector3(-1.35 + float(i) * 0.52, 1.6 + float(i % 3) * 0.45, 2.4 + float(i % 2) * 0.8)
            shard.apply_impulse(impulse)
            shard.apply_torque_impulse(Vector3(0.8 * (i % 2 * 2 - 1), 1.1, 0.7))
        get_tree().create_timer(2.6).timeout.connect(_clear_debris)

    if t >= 5.0 and t < 7.1:
        _shadow.visible = true
        _shadow.position.x = lerpf(-1.8, 1.8, clampf((t - 5.0) / 2.1, 0.0, 1.0))
    elif t >= 7.1:
        _shadow.visible = false

    if t >= 5.2 and not _breath_played:
        _breath_played = true
        Sfx.play("creature_roar_far", Vector3(0.0, 0.0, -7.0), -15.0, 0.01)
    if t >= 7.0 and not _roar_played:
        _roar_played = true
        Sfx.play("creature_roar_far", Vector3(0.0, 0.0, -7.0), -4.0, 0.02)


func _clear_debris() -> void:
    for shard in _shards:
        if is_instance_valid(shard):
            shard.queue_free()


func _complete() -> void:
    if not _active:
        return
    _active = false
    _fade.color.a = 1.0
    finished.emit()
