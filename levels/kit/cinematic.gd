class_name Cinematic
extends Node3D
## Cinemática breve en vivo: la amenaza solo se percibe por sus efectos.

signal finished

const DURATION := 10.0

var _camera: Camera3D
var _door_panel: Node3D
var _fluorescent: OmniLight3D
var _lamp_material: StandardMaterial3D
var _shadow: MeshInstance3D
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
    _camera = Camera3D.new()
    _camera.name = "Camera"
    _camera.position = Vector3(0.0, 3.0, 8.2)
    _camera.rotation = Vector3(-0.1099, 0.0, 0.0)
    _camera.fov = 48.0
    add_child(_camera)

    var metal := load("res://levels/kit/materials/metal.tres") as Material
    var wall := load("res://levels/kit/materials/concrete_wall.tres") as Material
    var floor := load("res://levels/kit/materials/concrete_floor.tres") as Material
    var paint := load("res://levels/kit/materials/rust.tres") as Material
    _lamp_material = load("res://levels/kit/materials/window_glow.tres").duplicate() as StandardMaterial3D
    _lamp_material.emission = Color(0.4, 0.58, 0.78)
    _lamp_material.emission_energy_multiplier = 1.6

    _add_box("Floor", Vector3(0, -0.15, -1), Vector3(8, 0.3, 20), floor)
    var floor_body := StaticBody3D.new()
    floor_body.position = Vector3(0, -0.15, -1)
    var floor_collision := CollisionShape3D.new()
    var floor_shape := BoxShape3D.new()
    floor_shape.size = Vector3(8, 0.3, 20)
    floor_collision.shape = floor_shape
    floor_body.add_child(floor_collision)
    add_child(floor_body)
    _add_box("Ceiling", Vector3(0, 5, -1), Vector3(8, 0.25, 20), wall)
    _add_box("LeftWall", Vector3(-4, 2.4, -1), Vector3(0.25, 5, 20), wall)
    _add_box("RightWall", Vector3(4, 2.4, -1), Vector3(0.25, 5, 20), wall)
    _add_box("BackWall", Vector3(0, 2.4, -7.5), Vector3(8, 5, 0.3), wall)
    _add_box("FluorescentTube", Vector3(0, 4.82, -3.0), Vector3(1.2, 0.035, 0.12), _lamp_material)

    _add_box("FrameLeft", Vector3(-1.05, 1.35, -5.45), Vector3(0.16, 2.8, 0.32), metal)
    _add_box("FrameRight", Vector3(1.05, 1.35, -5.45), Vector3(0.16, 2.8, 0.32), metal)
    _add_box("FrameTop", Vector3(0, 2.72, -5.45), Vector3(2.25, 0.16, 0.32), metal)
    _door_panel = Node3D.new()
    _door_panel.name = "DoorPanel"
    _door_panel.position = Vector3(0, 0, -5.34)
    add_child(_door_panel)
    _add_child_box(_door_panel, "DoorLeaf", Vector3(0, 1.3, 0), Vector3(1.9, 2.55, 0.12), paint)
    for i in 4:
        var x := -0.62 + float(i) * 0.42
        _add_child_box(_door_panel, "DoorRib%d" % i, Vector3(x, 1.3, 0.08), Vector3(0.035, 2.35, 0.035), metal)

    var shard_positions := [Vector3(-0.65, 0.62, -5.25), Vector3(-0.2, 0.62, -5.25),
        Vector3(0.25, 0.62, -5.25), Vector3(0.68, 0.62, -5.25),
        Vector3(-0.42, 1.85, -5.25), Vector3(0.35, 1.85, -5.25)]
    for i in shard_positions.size():
        var size := Vector3(0.58, 0.92, 0.14) if i < 4 else Vector3(0.82, 0.48, 0.14)
        var shard := RigidBody3D.new()
        shard.name = "Shard%d" % i
        shard.position = shard_positions[i]
        shard.mass = 0.7
        shard.gravity_scale = 1.0
        shard.linear_damp = 0.45
        shard.angular_damp = 0.5
        var mesh_instance := MeshInstance3D.new()
        var shard_mesh := BoxMesh.new()
        shard_mesh.size = size
        mesh_instance.mesh = shard_mesh
        mesh_instance.material_override = metal
        shard.add_child(mesh_instance)
        var collision := CollisionShape3D.new()
        var shape := BoxShape3D.new()
        shape.size = size
        collision.shape = shape
        shard.add_child(collision)
        add_child(shard)
        _shards.append(shard)

    _shadow = MeshInstance3D.new()
    _shadow.name = "UnseenShadow"
    _shadow.position = Vector3(0, 1.65, -6.55)
    var silhouette := CapsuleMesh.new()
    silhouette.radius = 0.72
    silhouette.height = 3.35
    silhouette.radial_segments = 8
    silhouette.rings = 4
    _shadow.mesh = silhouette
    _shadow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
    add_child(_shadow)

    var spot := SpotLight3D.new()
    spot.name = "HallSpot"
    spot.position = Vector3(0, 4.1, 1.2)
    spot.rotation = Vector3(-0.311, 0.0, 0.0)
    spot.light_color = Color(0.72, 0.78, 0.84)
    spot.light_energy = 2.0
    spot.spot_range = 22.0
    spot.spot_angle = 58.0
    spot.shadow_enabled = true
    add_child(spot)

    _fluorescent = OmniLight3D.new()
    _fluorescent.name = "Fluorescent"
    _fluorescent.position = Vector3(0, 4, -3)
    _fluorescent.light_color = Color(0.62, 0.72, 0.8)
    _fluorescent.light_energy = 0.85
    _fluorescent.omni_range = 7.0
    add_child(_fluorescent)

    _dust = CPUParticles3D.new()
    _dust.name = "Dust"
    _dust.position = Vector3(0, 1.3, -5.1)
    _dust.amount = 42
    _dust.lifetime = 1.6
    _dust.one_shot = true
    _dust.emitting = false
    _dust.explosiveness = 0.92
    _dust.direction = Vector3(0, 0.7, 1)
    _dust.spread = 68.0
    _dust.gravity = Vector3(0, -1.8, 0)
    _dust.initial_velocity_min = 1.2
    _dust.initial_velocity_max = 3.8
    _dust.scale_amount_min = 0.35
    _dust.scale_amount_max = 1.2
    _dust.color = Color(0.42, 0.4, 0.34)
    var dust_mesh := SphereMesh.new()
    dust_mesh.radius = 0.07
    dust_mesh.height = 0.14
    dust_mesh.radial_segments = 5
    dust_mesh.rings = 3
    _dust.draw_pass_1 = dust_mesh
    add_child(_dust)

    var overlay := CanvasLayer.new()
    overlay.name = "Overlay"
    overlay.layer = 100
    add_child(overlay)
    var top_bar := ColorRect.new()
    top_bar.name = "TopBar"
    top_bar.anchor_right = 1.0
    top_bar.anchor_bottom = 0.12
    top_bar.color = Color.BLACK
    top_bar.mouse_filter = Control.MOUSE_FILTER_STOP
    overlay.add_child(top_bar)
    var bottom_bar := ColorRect.new()
    bottom_bar.name = "BottomBar"
    bottom_bar.anchor_top = 0.88
    bottom_bar.anchor_right = 1.0
    bottom_bar.anchor_bottom = 1.0
    bottom_bar.color = Color.BLACK
    bottom_bar.mouse_filter = Control.MOUSE_FILTER_STOP
    overlay.add_child(bottom_bar)
    _fade = ColorRect.new()
    _fade.name = "Fade"
    _fade.anchor_right = 1.0
    _fade.anchor_bottom = 1.0
    _fade.color = Color.BLACK
    _fade.mouse_filter = Control.MOUSE_FILTER_STOP
    overlay.add_child(_fade)


func _add_box(node_name: String, position: Vector3, size: Vector3, material: Material) -> void:
    var mesh_instance := MeshInstance3D.new()
    mesh_instance.name = node_name
    mesh_instance.position = position
    var mesh := BoxMesh.new()
    mesh.size = size
    mesh_instance.mesh = mesh
    mesh_instance.material_override = material
    add_child(mesh_instance)


func _add_child_box(parent: Node3D, node_name: String, position: Vector3, size: Vector3, material: Material) -> void:
    var mesh_instance := MeshInstance3D.new()
    mesh_instance.name = node_name
    mesh_instance.position = position
    var mesh := BoxMesh.new()
    mesh.size = size
    mesh_instance.mesh = mesh
    mesh_instance.material_override = material
    parent.add_child(mesh_instance)


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
