extends Node3D
## Objeto que lanza un infectado (botella, ladrillo). Vuela en arco; si toca a Isabella le hace daño,
## y al chocar con el mundo se rompe con sus efectos (esquirlas de vidrio, polvo, sonido).

const GRAVITY := 14.0
const HIT_RADIUS := 0.5
const SPEED := 9.0
const KINDS := {
    "bottle": {"color": Color(0.16, 0.34, 0.2, 0.8), "break_sound": "glass_break", "shards": 26, "dust": Color(0.75, 0.9, 0.8)},
    "brick": {"color": Color(0.5, 0.22, 0.16), "break_sound": "brick_thud", "shards": 14, "dust": Color(0.55, 0.5, 0.46)},
}

var kind := "bottle"
var damage := 8
var _velocity := Vector3.ZERO
var _spin := Vector3.ZERO
var _life := 4.0
var _origin := Vector3.ZERO
var _target: Node3D


## Lanza un objeto desde `from` hacia `target` (apunta al pecho, con un poco de adelanto).
static func launch(parent: Node, object_kind: String, from: Vector3, target: Node3D, hit_damage: int) -> Node3D:
    var object := (load("res://actors/enemies/thrown_object.gd") as GDScript).new() as Node3D
    object.kind = object_kind
    object.damage = hit_damage
    parent.add_child(object)
    object.global_position = from
    object._origin = from
    object._target = target
    object.add_child(make_visual(object_kind))
    var aim := target.global_position + Vector3(0, 1.05, 0)
    if target is CharacterBody3D:
        aim += (target as CharacterBody3D).velocity * 0.25
    var flight := clampf(from.distance_to(aim) / SPEED, 0.35, 1.2)
    var delta := aim - from
    object._velocity = delta / flight + Vector3(0, 0.5 * GRAVITY * flight, 0)
    object._spin = Vector3(randf_range(-9.0, 9.0), randf_range(-4.0, 4.0), randf_range(8.0, 14.0))
    return object


## Aspecto del objeto (también el que lleva el infectado en la mano).
static func make_visual(object_kind: String) -> Node3D:
    var root := Node3D.new()
    root.scale = Vector3.ONE * (0.85 if object_kind == "bottle" else 1.0)
    var info: Dictionary = KINDS.get(object_kind, KINDS["bottle"])
    var material := StandardMaterial3D.new()
    material.albedo_color = info["color"]
    material.roughness = 0.55 if object_kind == "bottle" else 0.9
    if object_kind == "bottle":
        material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
        material.metallic_specular = 0.3
        var body := MeshInstance3D.new()
        var cylinder := CylinderMesh.new()
        cylinder.top_radius = 0.038
        cylinder.bottom_radius = 0.04
        cylinder.height = 0.17
        cylinder.radial_segments = 10
        body.mesh = cylinder
        body.material_override = material
        root.add_child(body)
        var neck := MeshInstance3D.new()
        var narrow := CylinderMesh.new()
        narrow.top_radius = 0.013
        narrow.bottom_radius = 0.025
        narrow.height = 0.09
        narrow.radial_segments = 8
        neck.mesh = narrow
        neck.material_override = material
        neck.position = Vector3(0, 0.125, 0)
        root.add_child(neck)
    else:
        var block := MeshInstance3D.new()
        var box := BoxMesh.new()
        box.size = Vector3(0.2, 0.06, 0.1)
        block.mesh = box
        block.material_override = material
        root.add_child(block)
    return root


func _physics_process(delta: float) -> void:
    _life -= delta
    if _life <= 0.0:
        queue_free()
        return
    var from := global_position
    _velocity.y -= GRAVITY * delta
    var to := from + _velocity * delta
    rotation += _spin * delta
    # Isabella: el punto más cercano del tramo al pecho.
    if _target != null and is_instance_valid(_target) and _target.has_method("take_damage"):
        var chest := _target.global_position + Vector3(0, 1.0, 0)
        if Geometry3D.get_closest_point_to_segment(chest, from, to).distance_to(chest) < HIT_RADIUS:
            _impact(chest, true)
            return
    # Mundo: pared, suelo, caja.
    var query := PhysicsRayQueryParameters3D.create(from, to, 1)
    var hit := get_world_3d().direct_space_state.intersect_ray(query)
    if not hit.is_empty():
        _impact(hit["position"] as Vector3, false)
        return
    global_position = to


func _impact(at: Vector3, hit_player: bool) -> void:
    var info: Dictionary = KINDS.get(kind, KINDS["bottle"])
    var parent := get_parent()
    Sfx.play(info["break_sound"], at, 0.0)
    _burst(parent, at, info["color"], int(info["shards"]), 0.04 if kind == "bottle" else 0.06, kind == "bottle")
    _burst(parent, at, info["dust"], 8, 0.1, false, 0.8)
    if hit_player:
        Sfx.play("thrown_hit", at, -1.0)
        BloodBurst.spawn(parent, at, (at - _origin).normalized(), 0.8)
        _target.take_damage(damage, _origin)
    queue_free()


## Salpicadura de partículas (esquirlas brillantes de vidrio, trozos de ladrillo o polvo).
static func _burst(parent: Node, at: Vector3, color: Color, amount: int, size: float, glow: bool, speed_scale: float = 1.0) -> void:
    var particles := CPUParticles3D.new()
    particles.one_shot = true
    particles.explosiveness = 0.95
    particles.amount = amount
    particles.lifetime = 0.8
    particles.spread = 80.0
    particles.direction = Vector3.UP
    particles.initial_velocity_min = 1.0 * speed_scale
    particles.initial_velocity_max = 3.6 * speed_scale
    particles.gravity = Vector3(0, -9.5, 0)
    particles.scale_amount_min = 0.5
    particles.scale_amount_max = 1.3
    var quad := QuadMesh.new()
    quad.size = Vector2(size, size)
    var material := StandardMaterial3D.new()
    material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    material.albedo_color = color.lightened(0.15) if glow else color
    material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
    material.billboard_keep_scale = true
    quad.material = material
    particles.mesh = quad
    parent.add_child(particles)
    particles.global_position = at
    particles.emitting = true
    particles.get_tree().create_timer(1.3).timeout.connect(particles.queue_free)
