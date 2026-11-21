extends SceneTree
## Revisión de arte de Ignacia: tres vistas (frente, lado, espalda) con animación de caminar/trote junto a Isabella.
## Uso: xvfb-run godot --path . --rendering-driver opengl3 --resolution 1600x720 -s res://tools/capture_ignacia.gd -- <archivo.png> [anim]


func _init() -> void:
    _run.call_deferred()


func _run() -> void:
    var args := OS.get_cmdline_user_args()
    var out: String = args[0]
    var anim_name: String = args[1] if args.size() > 1 else "Idle"
    GameState.new_game()
    GraphicsSettings.set_modern(true)
    var room := Node3D.new()
    root.add_child(room)
    var ground := MeshInstance3D.new()
    ground.mesh = PlaneMesh.new()
    ground.mesh.size = Vector2(20, 20)
    room.add_child(ground)
    var env := WorldEnvironment.new()
    env.environment = Environment.new()
    env.environment.background_mode = Environment.BG_COLOR
    env.environment.background_color = Color(0.16, 0.16, 0.19)
    env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.environment.ambient_light_color = Color(0.6, 0.6, 0.64)
    room.add_child(env)
    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-40, 30, 0)
    room.add_child(sun)
    var lib := load("res://actors/player/cony_animations.res") as AnimationLibrary
    var models: Array[Node3D] = []
    for i in 5:
        var holder := Node3D.new()
        var ignacia := i < 4
        var model := (load("res://assets/characters/ignacia/ignacia.glb") if ignacia else load("res://assets/characters/cony/cony.glb")).instantiate() as Node3D
        holder.add_child(model)
        var ap := AnimationPlayer.new()
        holder.add_child(ap)
        ap.root_node = ap.get_path_to(model)
        ap.add_animation_library(&"cony", lib)
        room.add_child(holder)
        holder.position = Vector3(-3.0 + i * 1.5, 0.0, 0.0)
        holder.rotation.y = [0.0, PI / 2, PI, 0.5, 0.0][i]
        ap.play("cony/" + anim_name)
        ap.advance(0.6)
        models.append(holder)
    var camera := Camera3D.new()
    camera.position = Vector3(0.0, 1.1, 5.4)
    camera.fov = 40.0
    room.add_child(camera)
    camera.look_at(Vector3(0.0, 0.9, 0.0))
    camera.make_current()
    for i in 6:
        await process_frame
    root.get_viewport().get_texture().get_image().save_png(out)
    print("guardado ", out)
    quit()
