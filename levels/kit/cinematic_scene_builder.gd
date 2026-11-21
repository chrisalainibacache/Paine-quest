extends RefCounted
## Construye la geometría y los elementos visuales de la cinemática.
## La lógica temporal permanece en Cinematic para separar presentación y control.

const SKULL_BODY := preload("res://levels/kit/skull_body.gd")

func build(owner: Cinematic) -> void:
    owner._camera = Camera3D.new()
    owner._camera.name = "Camera"
    owner._camera.position = Vector3(0.0, 3.0, 8.2)
    owner._camera.rotation = Vector3(-0.1099, 0.0, 0.0)
    owner._camera.fov = 48.0
    owner.add_child(owner._camera)

    var metal := load("res://levels/kit/materials/metal.tres") as Material
    var wall := load("res://levels/kit/materials/concrete_wall.tres") as Material
    var floor := load("res://levels/kit/materials/concrete_floor.tres") as Material
    var paint := load("res://levels/kit/materials/rust.tres") as Material
    owner._lamp_material = load("res://levels/kit/materials/window_glow.tres").duplicate() as StandardMaterial3D
    owner._lamp_material.emission = Color(0.4, 0.58, 0.78)
    owner._lamp_material.emission_energy_multiplier = 1.6

    _add_box(owner, "Floor", Vector3(0, -0.15, -1), Vector3(8, 0.3, 20), floor)
    var floor_body := StaticBody3D.new()
    floor_body.position = Vector3(0, -0.15, -1)
    var floor_collision := CollisionShape3D.new()
    var floor_shape := BoxShape3D.new()
    floor_shape.size = Vector3(8, 0.3, 20)
    floor_collision.shape = floor_shape
    floor_body.owner.add_child(floor_collision)
    owner.add_child(floor_body)
    _add_box(owner, "Ceiling", Vector3(0, 5, -1), Vector3(8, 0.25, 20), wall)
    _add_box(owner, "LeftWall", Vector3(-4, 2.4, -1), Vector3(0.25, 5, 20), wall)
    _add_box(owner, "RightWall", Vector3(4, 2.4, -1), Vector3(0.25, 5, 20), wall)
    _add_box(owner, "BackWall", Vector3(0, 2.4, -7.5), Vector3(8, 5, 0.3), wall)
    _add_box(owner, "FluorescentTube", Vector3(0, 4.82, -3.0), Vector3(1.2, 0.035, 0.12), owner._lamp_material)

    _add_box(owner, "FrameLeft", Vector3(-1.05, 1.35, -5.45), Vector3(0.16, 2.8, 0.32), metal)
    _add_box(owner, "FrameRight", Vector3(1.05, 1.35, -5.45), Vector3(0.16, 2.8, 0.32), metal)
    _add_box(owner, "FrameTop", Vector3(0, 2.72, -5.45), Vector3(2.25, 0.16, 0.32), metal)
    owner._door_panel = Node3D.new()
    owner._door_panel.name = "DoorPanel"
    owner._door_panel.position = Vector3(0, 0, -5.34)
    owner.add_child(owner._door_panel)
    _add_child_box(owner._door_panel, "DoorLeaf", Vector3(0, 1.3, 0), Vector3(1.9, 2.55, 0.12), paint)
    for i in 4:
        var x := -0.62 + float(i) * 0.42
        _add_child_box(owner._door_panel, "DoorRib%d" % i, Vector3(x, 1.3, 0.08), Vector3(0.035, 2.35, 0.035), metal)

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
        shard.owner.add_child(mesh_instance)
        var collision := CollisionShape3D.new()
        var shape := BoxShape3D.new()
        shape.size = size
        collision.shape = shape
        shard.owner.add_child(collision)
        owner.add_child(shard)
        owner._shards.append(shard)

    # La criatura nunca se ve: solo su sombra sobre el muro del fondo (cuerpo armado en skull_body.gd).
    owner._shadow = SKULL_BODY.build()
    owner._shadow.name = "UnseenShadow"
    owner._shadow.position = Vector3(0, 0.0, -5.2)
    owner._shadow.rotation.y = PI / 2.0
    owner._shadow.scale = Vector3.ONE * 1.25
    for mesh_node: Node in owner._shadow.find_children("*", "MeshInstance3D", true, false):
        (mesh_node as MeshInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
    owner.add_child(owner._shadow)

    var spot := SpotLight3D.new()
    spot.name = "HallSpot"
    spot.position = Vector3(0, 4.1, 1.2)
    spot.rotation = Vector3(-0.311, 0.0, 0.0)
    spot.light_color = Color(0.72, 0.78, 0.84)
    spot.light_energy = 2.0
    spot.spot_range = 22.0
    spot.spot_angle = 58.0
    spot.shadow_enabled = true
    owner.add_child(spot)

    owner._fluorescent = OmniLight3D.new()
    owner._fluorescent.name = "Fluorescent"
    owner._fluorescent.position = Vector3(0, 4, -3)
    owner._fluorescent.light_color = Color(0.62, 0.72, 0.8)
    owner._fluorescent.light_energy = 0.85
    owner._fluorescent.omni_range = 7.0
    owner.add_child(owner._fluorescent)

    owner._dust = CPUParticles3D.new()
    owner._dust.name = "Dust"
    owner._dust.position = Vector3(0, 1.3, -5.1)
    owner._dust.amount = 42
    owner._dust.lifetime = 1.6
    owner._dust.one_shot = true
    owner._dust.emitting = false
    owner._dust.explosiveness = 0.92
    owner._dust.direction = Vector3(0, 0.7, 1)
    owner._dust.spread = 68.0
    owner._dust.gravity = Vector3(0, -1.8, 0)
    owner._dust.initial_velocity_min = 1.2
    owner._dust.initial_velocity_max = 3.8
    owner._dust.scale_amount_min = 0.35
    owner._dust.scale_amount_max = 1.2
    owner._dust.color = Color(0.42, 0.4, 0.34)
    var dust_mesh := SphereMesh.new()
    dust_mesh.radius = 0.07
    dust_mesh.height = 0.14
    dust_mesh.radial_segments = 5
    dust_mesh.rings = 3
    owner._dust.mesh = dust_mesh
    owner.add_child(owner._dust)

    var overlay := CanvasLayer.new()
    overlay.name = "Overlay"
    overlay.layer = 100
    owner.add_child(overlay)
    var top_bar := ColorRect.new()
    top_bar.name = "TopBar"
    top_bar.anchor_right = 1.0
    top_bar.anchor_bottom = 0.12
    top_bar.color = Color.BLACK
    top_bar.mouse_filter = Control.MOUSE_FILTER_STOP
    overlay.owner.add_child(top_bar)
    var bottom_bar := ColorRect.new()
    bottom_bar.name = "BottomBar"
    bottom_bar.anchor_top = 0.88
    bottom_bar.anchor_right = 1.0
    bottom_bar.anchor_bottom = 1.0
    bottom_bar.color = Color.BLACK
    bottom_bar.mouse_filter = Control.MOUSE_FILTER_STOP
    overlay.owner.add_child(bottom_bar)
    _fade = ColorRect.new()
    _fade.name = "Fade"
    _fade.anchor_right = 1.0
    _fade.anchor_bottom = 1.0
    _fade.color = Color.BLACK
    _fade.mouse_filter = Control.MOUSE_FILTER_STOP
    overlay.owner.add_child(_fade)


func _add_box(owner: Cinematic, node_name: String, position: Vector3, size: Vector3, material: Material) -> void:
    var mesh_instance := MeshInstance3D.new()
    mesh_instance.name = node_name
    mesh_instance.position = position
    var mesh := BoxMesh.new()
    mesh.size = size
    mesh_instance.mesh = mesh
    mesh_instance.material_override = material
    owner.add_child(mesh_instance)


func _add_child_box(parent: Node3D, node_name: String, position: Vector3, size: Vector3, material: Material) -> void:
    var mesh_instance := MeshInstance3D.new()
    mesh_instance.name = node_name
    mesh_instance.position = position
    var mesh := BoxMesh.new()
    mesh.size = size
    mesh_instance.mesh = mesh
    mesh_instance.material_override = material
    parent.add_child(mesh_instance)


