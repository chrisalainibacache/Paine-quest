class_name Projectile
extends Node3D
## Granada o cohete en vuelo: va en línea recta del arma al punto de impacto y
## ahí llama a `on_impact`. Deja una estela de humo.


static func launch(parent: Node, from: Vector3, to: Vector3, speed: float, is_rocket: bool, on_impact: Callable) -> void:
    var projectile := Projectile.new()
    parent.add_child(projectile)
    projectile.global_position = from
    projectile._fly(to, speed, is_rocket, on_impact)


func _fly(to: Vector3, speed: float, is_rocket: bool, on_impact: Callable) -> void:
    var body := MeshInstance3D.new()
    var mesh := CapsuleMesh.new()
    mesh.radius = 0.04 if is_rocket else 0.035
    mesh.height = 0.3 if is_rocket else 0.1
    body.mesh = mesh
    var material := StandardMaterial3D.new()
    material.albedo_color = Color(0.35, 0.4, 0.25) if is_rocket else Color(0.25, 0.28, 0.2)
    body.material_override = material
    body.rotation.x = PI / 2.0
    add_child(body)
    if global_position.distance_to(to) > 0.05:
        look_at(to)
    var trail := CPUParticles3D.new()
    trail.amount = 24
    trail.lifetime = 0.5
    trail.gravity = Vector3(0, 0.4, 0)
    trail.initial_velocity_max = 0.2
    var quad := QuadMesh.new()
    quad.size = Vector2(0.12, 0.12)
    var smoke := StandardMaterial3D.new()
    smoke.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    smoke.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
    smoke.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    smoke.albedo_color = Color(0.7, 0.68, 0.65, 0.5) if is_rocket else Color(0.5, 0.5, 0.5, 0.35)
    smoke.albedo_texture = Explosion.soft_dot()
    quad.material = smoke
    trail.mesh = quad
    trail.local_coords = false
    add_child(trail)
    var duration := maxf(global_position.distance_to(to) / maxf(speed, 1.0), 0.05)
    var tween := create_tween()
    tween.tween_property(self, "global_position", to, duration)
    await tween.finished
    on_impact.call(to)
    body.visible = false
    trail.emitting = false
    get_tree().create_timer(0.6).timeout.connect(queue_free)
