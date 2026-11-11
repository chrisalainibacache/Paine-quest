class_name Explosion
extends Node3D
## Explosión de granada o cohete: bola de fuego, humo, esquirlas, destello de
## luz, sonido y una mancha quemada en el piso. Se borra sola.
## El daño lo aplica quien la dispara (ver PlayerCombat._explode).

const SCORCH := preload("res://assets/environment/decals/oil_stain.png")
const DECAL := preload("res://levels/kit/props/decal.tscn")


static var _soft: GradientTexture2D


## Punto redondo y difuso para humo y fuego (sin él las partículas son cuadrados).
static func soft_dot() -> GradientTexture2D:
    if _soft == null:
        var gradient := Gradient.new()
        gradient.set_color(0, Color(1, 1, 1, 1))
        gradient.set_color(1, Color(1, 1, 1, 0))
        _soft = GradientTexture2D.new()
        _soft.gradient = gradient
        _soft.fill = GradientTexture2D.FILL_RADIAL
        _soft.fill_from = Vector2(0.5, 0.5)
        _soft.fill_to = Vector2(0.5, 0.0)
        _soft.width = 32
        _soft.height = 32
    return _soft


static func spawn(parent: Node, at: Vector3, radius: float) -> void:
    var explosion := Explosion.new()
    parent.add_child(explosion)
    explosion.global_position = at
    explosion._boom(radius)


func _boom(radius: float) -> void:
    Sfx.play("explosion", global_position, 4.0, 0.08)
    Input.vibrate_handheld(220)
    add_child(_particles(28, Color(1.0, 0.55, 0.12), 0.45, 0.55, radius * 2.6, Vector3(0, 1.5, 0), true))
    add_child(_particles(18, Color(0.12, 0.11, 0.1), 1.4, 0.8, radius * 1.1, Vector3(0, 1.4, 0), false))
    add_child(_particles(24, Color(0.25, 0.2, 0.15), 0.9, 0.08, radius * 4.0, Vector3(0, -9.0, 0), false))
    var light := OmniLight3D.new()
    light.light_color = Color(1.0, 0.55, 0.2)
    light.light_energy = 6.0
    light.omni_range = radius * 3.0
    light.position = Vector3(0, 0.6, 0)
    add_child(light)
    create_tween().tween_property(light, "light_energy", 0.0, 0.45)
    # Mancha quemada en el piso.
    var scorch := DECAL.instantiate() as Node3D
    scorch.set("texture", SCORCH)
    scorch.set("size", Vector2.ONE * radius * 1.4)
    scorch.set("tint", Color(0.35, 0.3, 0.28))
    get_parent().add_child(scorch)
    scorch.global_position = Vector3(global_position.x, 0.02, global_position.z)
    scorch.rotation = Vector3(-PI / 2.0, randf() * TAU, 0)
    get_tree().create_timer(2.0).timeout.connect(queue_free)


func _particles(amount: int, color: Color, lifetime_s: float, size: float, speed: float, gravity_v: Vector3, glow: bool) -> CPUParticles3D:
    var p := CPUParticles3D.new()
    p.one_shot = true
    p.explosiveness = 0.95
    p.amount = amount
    p.lifetime = lifetime_s
    p.direction = Vector3.UP
    p.spread = 180.0
    p.initial_velocity_min = speed * 0.4
    p.initial_velocity_max = speed
    p.gravity = gravity_v
    p.damping_min = 2.0
    p.damping_max = 4.0
    p.scale_amount_min = 0.6
    p.scale_amount_max = 1.5
    var quad := QuadMesh.new()
    quad.size = Vector2(size, size)
    var material := StandardMaterial3D.new()
    material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
    material.billboard_keep_scale = true
    material.vertex_color_use_as_albedo = true
    if glow:
        material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
    material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    material.albedo_texture = soft_dot()
    quad.material = material
    p.mesh = quad
    var ramp := Gradient.new()
    ramp.set_color(0, Color(color, 1.0))
    ramp.set_color(1, Color(color.darkened(0.5), 0.0))
    p.color_ramp = ramp
    p.emitting = true
    return p
