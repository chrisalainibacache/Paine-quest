extends RefCounted
## Reorienta las animaciones del zombi (hechas sobre un esqueleto en pose T) al esqueleto
## de cada modelo de infectado, que puede tener otra pose de reposo (A, brazos caídos…).
## Sin esto los brazos terminan detrás del cuerpo y cruzados.
## Método: se calcula cuánto gira cada hueso respecto a SU reposo en el espacio del modelo
## y se aplica ese mismo giro sobre el reposo del modelo destino.

const SOURCE_SCENE := "res://assets/characters/animations/ual2_zombie.glb"
const FPS := 30.0
## Animaciones en las que los brazos del clip original cuelgan hacia ATRÁS (se ven "con las manos cruzadas atrás").
## Se les adelanta el brazo: dirección del brazo (x se invierte en el lado derecho) y cuánto del vaivén original se conserva.
const ARM_FIX_ANIMS: Array[String] = ["Zombie_Walk_Fwd", "Zombie_Idle", "Zombie_Scratch"]
const ARM_REACH := Vector3(0.30, -0.45, 0.84)
const FOREARM_REACH := Vector3(0.05, -0.10, 0.99)
const ARM_SWAY := 0.35
const THROW_LENGTH := 1.0
## Teclas del brazo derecho al lanzar: [segundo, dirección del brazo, dirección del antebrazo] (x<0 = lado derecho).
const THROW_KEYS := [
    [0.0, Vector3(-0.30, -0.45, 0.84), Vector3(-0.05, -0.10, 0.99)],
    [0.30, Vector3(-0.35, 0.80, -0.50), Vector3(-0.15, 0.95, -0.25)],
    [0.45, Vector3(-0.20, 0.45, 0.87), Vector3(-0.08, 0.40, 0.91)],
    [0.55, Vector3(-0.10, 0.05, 0.99), Vector3(-0.05, 0.05, 0.99)],
    [1.00, Vector3(-0.25, -0.55, 0.80), Vector3(-0.05, -0.30, 0.95)],
]

## Reposo del esqueleto fuente: nombre -> {parent, local, global (Quaternion), frame (Basis)}.
static var _source: Dictionary = {}
static var _source_order: Array[String] = []
static var _source_frame := Basis.IDENTITY


static func _load_source() -> void:
    if not _source.is_empty():
        return
    var scene := (load(SOURCE_SCENE) as PackedScene).instantiate() as Node3D
    var skeleton: Skeleton3D = scene.find_children("*", "Skeleton3D", true, false)[0]
    _source_frame = _frame_of(skeleton, scene)
    for i in skeleton.get_bone_count():
        var bone_name := skeleton.get_bone_name(i)
        var parent := skeleton.get_bone_parent(i)
        _source[bone_name] = {
            "parent": skeleton.get_bone_name(parent) if parent >= 0 else "",
            "local": skeleton.get_bone_rest(i).basis.orthonormalized().get_rotation_quaternion(),
            "global": skeleton.get_bone_global_rest(i).basis.orthonormalized().get_rotation_quaternion(),
        }
        _source_order.append(bone_name)
    scene.free()


## Giro del nodo esqueleto respecto a la raíz del modelo (los FBX traen armaduras giradas).
static func _frame_of(skeleton: Node3D, root: Node3D) -> Basis:
    var basis := Basis.IDENTITY
    var node: Node3D = skeleton
    while node != null and node != root:
        basis = node.transform.basis.orthonormalized() * basis
        node = node.get_parent() as Node3D
    return basis


## Convierte la biblioteca (pistas ya con nombres humanoides) al esqueleto destino.
static func apply(library: AnimationLibrary, skeleton: Skeleton3D, model: Node3D, skeleton_path: String) -> void:
    _load_source()
    var target_frame := _frame_of(skeleton, model)
    # Giro que lleva del espacio del esqueleto fuente al del destino.
    var to_target := (target_frame.inverse() * _source_frame)
    var to_target_q := to_target.get_rotation_quaternion()
    var target_rest: Dictionary = {}
    for i in skeleton.get_bone_count():
        target_rest[skeleton.get_bone_name(i)] = i
    # Gesto de lanzar: parte de la pose de reposo (Zombie_Idle) y se sobrescribe el brazo derecho.
    if library.has_animation("Zombie_Idle") and not library.has_animation("Zombie_Throw"):
        var throw := library.get_animation("Zombie_Idle").duplicate(true) as Animation
        throw.loop_mode = Animation.LOOP_NONE
        throw.length = THROW_LENGTH
        library.add_animation("Zombie_Throw", throw)
    for anim_name: StringName in library.get_animation_list():
        _convert(anim_name, library.get_animation(anim_name), skeleton, target_rest, to_target_q, skeleton_path)


static func _convert(animation_name: StringName, animation: Animation, skeleton: Skeleton3D, target_index: Dictionary, to_target: Quaternion, skeleton_path: String) -> void:
    # Pista de rotación de cada hueso fuente.
    var tracks: Dictionary = {}
    for t in animation.get_track_count():
        if animation.track_get_type(t) != Animation.TYPE_ROTATION_3D:
            continue
        var path := animation.track_get_path(t)
        if path.get_subname_count() == 0:
            continue
        tracks[String(path.get_subname(0))] = t
    if tracks.is_empty():
        return
    var steps := maxi(int(ceil(animation.length * FPS)), 1)
    var times: Array[float] = []
    for s in steps + 1:
        times.append(minf(float(s) / FPS, animation.length))
    # Rotación local de salida por hueso destino y por instante.
    var output: Dictionary = {}
    var frames: Array[Array] = []
    for bone_name: String in target_index:
        output[bone_name] = []
    for time in times:
        # Rotación global (espacio del esqueleto fuente) animada de cada hueso fuente.
        var source_global: Dictionary = {}
        for bone_name in _source_order:
            var info: Dictionary = _source[bone_name]
            var local: Quaternion = info["local"]
            if tracks.has(bone_name):
                local = animation.rotation_track_interpolate(int(tracks[bone_name]), time)
            var parent: String = info["parent"]
            source_global[bone_name] = (source_global[parent] * local) if parent != "" else local
        # Giro de cada hueso respecto a su reposo, en el espacio del modelo destino.
        var delta: Dictionary = {}
        for bone_name in _source_order:
            var info: Dictionary = _source[bone_name]
            var rest_global: Quaternion = info["global"]
            var sk_delta: Quaternion = (source_global[bone_name] as Quaternion) * rest_global.inverse()
            delta[bone_name] = to_target * sk_delta * to_target.inverse()
        # Orientación global animada del destino, recorriendo la jerarquía destino.
        var target_global: Array[Quaternion] = []
        target_global.resize(skeleton.get_bone_count())
        for i in skeleton.get_bone_count():
            var bone_name := skeleton.get_bone_name(i)
            var rest_global := skeleton.get_bone_global_rest(i).basis.orthonormalized().get_rotation_quaternion()
            var d: Quaternion = Quaternion.IDENTITY
            if delta.has(bone_name):
                d = delta[bone_name]
            else:
                # Hueso sin equivalente (twist, extras): sigue a su padre.
                var p := skeleton.get_bone_parent(i)
                while p >= 0 and not delta.has(skeleton.get_bone_name(p)):
                    p = skeleton.get_bone_parent(p)
                if p >= 0:
                    d = delta[skeleton.get_bone_name(p)]
            target_global[i] = d * rest_global
        frames.append(target_global)
    if String(animation_name) == "Zombie_Throw":
        _reach_arm(skeleton, frames, "Left")
        _aim_keyed(skeleton, frames, "RightUpperArm", "RightLowerArm", 1)
        _aim_keyed(skeleton, frames, "RightLowerArm", "RightHand", 2)
    elif String(animation_name) in ARM_FIX_ANIMS:
        for side in ["Left", "Right"]:
            _reach_arm(skeleton, frames, side)
    for frame: Array[Quaternion] in frames:
        for i in skeleton.get_bone_count():
            var parent := skeleton.get_bone_parent(i)
            var local_q: Quaternion = frame[i]
            if parent >= 0:
                local_q = frame[parent].inverse() * local_q
            (output[skeleton.get_bone_name(i)] as Array).append(local_q.normalized())
    # Reescribe las pistas de rotación con los valores calculados.
    for t in range(animation.get_track_count() - 1, -1, -1):
        if animation.track_get_type(t) == Animation.TYPE_ROTATION_3D and animation.track_get_path(t).get_subname_count() > 0:
            animation.remove_track(t)
    for i in skeleton.get_bone_count():
        var bone_name := skeleton.get_bone_name(i)
        if not tracks.has(bone_name) and not _source.has(bone_name):
            continue
        var track := animation.add_track(Animation.TYPE_ROTATION_3D)
        animation.track_set_path(track, NodePath("%s:%s" % [skeleton_path, bone_name]))
        var values: Array = output[bone_name]
        for s in times.size():
            animation.rotation_track_insert_key(track, times[s], values[s])


## Adelanta un brazo: conserva el vaivén del clip pero centrado en una pose con la mano al frente.
static func _reach_arm(skeleton: Skeleton3D, frames: Array[Array], side: String) -> void:
    var sign := 1.0 if side == "Left" else -1.0
    _aim(skeleton, frames, side + "UpperArm", side + "LowerArm", Vector3(ARM_REACH.x * sign, ARM_REACH.y, ARM_REACH.z), ARM_SWAY)
    _aim(skeleton, frames, side + "LowerArm", side + "Hand", Vector3(FOREARM_REACH.x * sign, FOREARM_REACH.y, FOREARM_REACH.z), ARM_SWAY)


## Gira `bone` (y todo lo que cuelga de él) para que apunte hacia `reach`, conservando `sway` del movimiento original.
static func _aim(skeleton: Skeleton3D, frames: Array[Array], bone_name: String, child_name: String, reach: Vector3, sway: float) -> void:
    var bone := skeleton.find_bone(bone_name)
    var child := skeleton.find_bone(child_name)
    if bone < 0 or child < 0:
        return
    var axis_local := skeleton.get_bone_rest(child).origin.normalized()
    var dirs: Array[Vector3] = []
    var mean := Vector3.ZERO
    for frame: Array[Quaternion] in frames:
        var dir: Vector3 = frame[bone] * axis_local
        dirs.append(dir)
        mean += dir
    mean = (mean / float(frames.size())).normalized()
    var subtree: Array[int] = []
    for i in skeleton.get_bone_count():
        var p := i
        while p >= 0 and p != bone:
            p = skeleton.get_bone_parent(p)
        if p == bone:
            subtree.append(i)
    reach = reach.normalized()
    for f in frames.size():
        var wanted := (reach + (dirs[f] - mean) * sway).normalized()
        var extra := Quaternion(dirs[f].normalized(), wanted)
        for i in subtree:
            frames[f][i] = extra * frames[f][i]


## Como _aim, pero la dirección sale de las teclas THROW_KEYS (columna `column`: 1 brazo, 2 antebrazo) según el segundo.
static func _aim_keyed(skeleton: Skeleton3D, frames: Array[Array], bone_name: String, child_name: String, column: int) -> void:
    var bone := skeleton.find_bone(bone_name)
    var child := skeleton.find_bone(child_name)
    if bone < 0 or child < 0:
        return
    var axis_local := skeleton.get_bone_rest(child).origin.normalized()
    var subtree: Array[int] = []
    for i in skeleton.get_bone_count():
        var p := i
        while p >= 0 and p != bone:
            p = skeleton.get_bone_parent(p)
        if p == bone:
            subtree.append(i)
    for f in frames.size():
        var time := minf(float(f) / FPS, THROW_LENGTH)
        var wanted: Vector3 = (THROW_KEYS[0][column] as Vector3)
        for k in range(1, THROW_KEYS.size()):
            var a: Array = THROW_KEYS[k - 1]
            var b: Array = THROW_KEYS[k]
            if time <= float(b[0]):
                var u := smoothstep(0.0, 1.0, inverse_lerp(float(a[0]), float(b[0]), time))
                wanted = (a[column] as Vector3).lerp(b[column] as Vector3, u)
                break
            wanted = b[column] as Vector3
        var current: Vector3 = frames[f][bone] * axis_local
        var extra := Quaternion(current.normalized(), wanted.normalized())
        for i in subtree:
            frames[f][i] = extra * frames[f][i]
