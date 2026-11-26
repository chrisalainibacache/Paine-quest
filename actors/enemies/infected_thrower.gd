extends Node
## Infectado que lanza objetos que trae consigo (botellas, ladrillos). Vive como hijo del infectado:
## lleva el objeto en la mano derecha, decide cuándo lanzar y lo suelta en el momento del gesto.

const OBJECT := preload("res://actors/enemies/thrown_object.gd")
## Segundo del gesto en que el objeto sale de la mano (la animación Zombie_Throw dura ~1 s).
const RELEASE_TIME := 0.5

var ammo := 0
var _owner_body: Node3D
var _data: EnemyData
var _skeleton: Skeleton3D
var _prop: Node3D
var _cooldown := 0.0


func setup(body: Node3D, data: EnemyData, skeleton: Skeleton3D) -> void:
    _owner_body = body
    _data = data
    _skeleton = skeleton
    ammo = data.throw_ammo
    _cooldown = randf_range(1.0, data.throw_cooldown)
    if skeleton != null and skeleton.find_bone("RightHand") >= 0:
        var attachment := BoneAttachment3D.new()
        attachment.bone_name = "RightHand"
        skeleton.add_child(attachment)
        _prop = OBJECT.make_visual(data.throw_kind)
        _prop.position = Vector3(0, 0.07, 0)
        _prop.rotation_degrees = Vector3(80, 0, 0)
        attachment.add_child(_prop)


func _physics_process(delta: float) -> void:
    _cooldown = maxf(_cooldown - delta, 0.0)


## ¿Conviene lanzar ahora? Hay munición, ya pasó la espera y Isabella está a media distancia.
func wants_throw(distance: float) -> bool:
    return ammo > 0 and _cooldown <= 0.0 and distance >= _data.throw_min_range and distance <= _data.throw_max_range


## Suelta el objeto hacia el objetivo (lo llama el infectado en el momento del gesto).
func release(target: Node3D) -> void:
    if ammo <= 0 or target == null:
        return
    ammo -= 1
    _cooldown = _data.throw_cooldown * randf_range(0.8, 1.3)
    var from := _hand_position()
    OBJECT.launch(_owner_body.get_parent(), _data.throw_kind, from, target, _data.throw_damage)
    Sfx.play("throw_whoosh", from, -4.0, 0.1)
    if _prop != null:
        _prop.visible = ammo > 0


func _hand_position() -> Vector3:
    if _skeleton != null and _skeleton.find_bone("RightHand") >= 0:
        var pose := _skeleton.get_bone_global_pose(_skeleton.find_bone("RightHand"))
        return _skeleton.global_transform * pose.origin + Vector3(0, 0.1, 0)
    return _owner_body.global_position + Vector3(0, 1.4, 0)
