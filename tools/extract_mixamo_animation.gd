extends SceneTree
## Extrae una animación Mixamo (FBX importado con el mapa de huesos Mixamo,
## así sus pistas ya usan nombres humanoides) y la guarda como recurso.
## Quita el avance de la cadera (in-place) para que el juego controle el
## desplazamiento, pero conserva el balanceo vertical y lateral.
## Uso: godot --headless --path . -s res://tools/extract_mixamo_animation.gd -- <fbx> <destino.res>

func _init() -> void:
    var args := OS.get_cmdline_user_args()
    var scene := (load(args[0]) as PackedScene).instantiate()
    var player: AnimationPlayer = scene.find_children("*", "AnimationPlayer", true, false)[0]
    var animation := player.get_animation(&"mixamo_com").duplicate(true) as Animation
    var hips := animation.find_track(NodePath("%GeneralSkeleton:Hips"), Animation.TYPE_POSITION_3D)
    var count := animation.track_get_key_count(hips)
    var first: Vector3 = animation.track_get_key_value(hips, 0)
    var last: Vector3 = animation.track_get_key_value(hips, count - 1)
    var drift := last - first
    for i in count:
        var t := animation.track_get_key_time(hips, i) / animation.length
        var value: Vector3 = animation.track_get_key_value(hips, i)
        value.x -= drift.x * t
        value.z -= drift.z * t
        animation.track_set_key_value(hips, i, value)
    # Algunas tomas Mixamo vienen giradas: se endereza la cadera según su
    # orientación promedio (mirando hacia +Z, como el resto de animaciones).
    var hips_rot := animation.find_track(NodePath("%GeneralSkeleton:Hips"), Animation.TYPE_ROTATION_3D)
    var heading := Vector2.ZERO
    for i in animation.track_get_key_count(hips_rot):
        var forward: Vector3 = (animation.track_get_key_value(hips_rot, i) as Quaternion) * Vector3.BACK
        heading += Vector2(forward.x, forward.z)
    var yaw := atan2(heading.x, heading.y)
    var fix := Quaternion(Vector3.UP, -yaw)
    for i in animation.track_get_key_count(hips_rot):
        animation.track_set_key_value(hips_rot, i, fix * (animation.track_get_key_value(hips_rot, i) as Quaternion))
    for i in count:
        animation.track_set_key_value(hips, i, fix * (animation.track_get_key_value(hips, i) as Vector3))
    print("extract: giro corregido %.1f grados" % rad_to_deg(yaw))
    animation.loop_mode = Animation.LOOP_LINEAR
    var err := ResourceSaver.save(animation, args[1], ResourceSaver.FLAG_COMPRESS)
    print("extract: ", args[1], " len=", animation.length, " avance quitado=", drift, " (", error_string(err), ")")
    scene.free()
    quit(0 if err == OK else 1)
