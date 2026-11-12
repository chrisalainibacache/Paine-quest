extends Node3D
## Perra de una escena (Kiara o Nala): corre, se lanza contra un infectado y
## ladra. La maneja una escena guionada (levels/kit/rescue_scene.gd).

## Sonido del ladrido ("bark" o "bark_deep" para Kiara, que es más grande).
@export var bark_sound: String = "bark"

@onready var model: Node3D = $Model

var _anim: AnimationPlayer


func _ready() -> void:
    # El pelaje va pintado por vértice (el GLB no guarda esa opción del material).
    for mesh_instance: MeshInstance3D in model.find_children("*", "MeshInstance3D", true, false):
        for i in mesh_instance.mesh.get_surface_count():
            var material := mesh_instance.mesh.surface_get_material(i) as BaseMaterial3D
            if material:
                material.vertex_color_use_as_albedo = true
                material.vertex_color_is_srgb = true
    _anim = model.find_children("*", "AnimationPlayer", true, false)[0]
    for anim_name in ["Idle", "Walk"]:
        if _anim.has_animation(anim_name):
            _anim.get_animation(anim_name).loop_mode = Animation.LOOP_LINEAR
    _anim.play("Idle")


func face(point: Vector3) -> void:
    var to := point - global_position
    if Vector2(to.x, to.z).length() > 0.01:
        rotation.y = atan2(to.x, to.z)


## Corre hasta el punto (se puede esperar con await).
func run_to(point: Vector3, speed: float = 6.5) -> void:
    point.y = global_position.y
    var distance := global_position.distance_to(point)
    if distance < 0.05:
        return
    face(point)
    _anim.speed_scale = 2.6
    _anim.play("Walk", 0.1)
    var tween := create_tween()
    tween.tween_property(self, "global_position", point, distance / speed)
    await tween.finished
    _anim.speed_scale = 1.0
    _anim.play("Idle", 0.2)


## Se lanza contra el infectado y lo derriba.
func attack(enemy: Node3D) -> void:
    if not is_instance_valid(enemy):
        return
    var to := enemy.global_position - global_position
    to.y = 0.0
    var stop := enemy.global_position - to.normalized() * 0.7
    await run_to(stop, 7.5)
    if not is_instance_valid(enemy):
        return
    face(enemy.global_position)
    bark()
    var lunge := create_tween()
    lunge.tween_property(self, "global_position", global_position + to.normalized() * 0.45, 0.12)
    lunge.tween_property(self, "global_position", global_position, 0.18)
    if enemy.has_method("take_hit"):
        enemy.take_hit(99, global_position, enemy.global_position + Vector3.UP * 1.1, 1.0)
    await lunge.finished


func bark() -> void:
    Sfx.play(bark_sound, global_position + Vector3.UP * 0.5, 0.0, 0.08)
