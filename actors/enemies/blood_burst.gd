class_name BloodBurst
extends CPUParticles3D
## Salpicadura de sangre al recibir un disparo: partículas pequeñas y oscuras
## (estilo PS1) que caen y desaparecen. Se crea, salpica y se borra sola.

static var _material: StandardMaterial3D


static func spawn(parent: Node, at: Vector3, direction: Vector3, amount_scale: float = 1.0) -> void:
    var burst := BloodBurst.new()
    burst.amount = int(18 * amount_scale)
    parent.add_child(burst)
    burst.global_position = at
    if direction.length() > 0.01:
        burst.direction = direction.normalized()
    burst.emitting = true
    burst.get_tree().create_timer(1.2).timeout.connect(burst.queue_free)


func _init() -> void:
    one_shot = true
    explosiveness = 0.95
    lifetime = 0.7
    spread = 35.0
    initial_velocity_min = 1.2
    initial_velocity_max = 3.0
    gravity = Vector3(0, -9.0, 0)
    scale_amount_min = 0.6
    scale_amount_max = 1.4
    var quad := QuadMesh.new()
    quad.size = Vector2(0.06, 0.06)
    if _material == null:
        _material = StandardMaterial3D.new()
        _material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
        _material.albedo_color = Color(0.32, 0.02, 0.02)
        _material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
        _material.billboard_keep_scale = true
    quad.material = _material
    mesh = quad
