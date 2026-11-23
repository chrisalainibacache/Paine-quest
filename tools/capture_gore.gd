extends SceneTree
## Revisión de arte de la violencia de los infectados: sin heridas / con heridas / tiro a la cabeza / escopeta / explosivo.
## Uso: xvfb-run godot --path . --rendering-driver opengl3 --resolution 1600x720 -s res://tools/capture_gore.gd -- <carpeta>
const TYPES := ["infected", "infected_worker", "infected_pale", "infected_heavy", "infected_burnt"]


func _init() -> void:
    _run.call_deferred()


func _run() -> void:
    var out: String = OS.get_cmdline_user_args()[0]
    DirAccess.make_dir_recursive_absolute(out)
    GameState.new_game()
    GraphicsSettings.set_modern(true)
    var room := Node3D.new()
    root.add_child(room)
    var ground := MeshInstance3D.new()
    ground.mesh = PlaneMesh.new()
    ground.mesh.size = Vector2(30, 30)
    room.add_child(ground)
    var body := StaticBody3D.new()
    body.collision_layer = 1
    var cs := CollisionShape3D.new()
    var box := BoxShape3D.new()
    box.size = Vector3(40, 1, 40)
    cs.shape = box
    cs.position = Vector3(0, -0.5, 0)
    body.add_child(cs)
    room.add_child(body)
    var env := WorldEnvironment.new()
    env.environment = Environment.new()
    env.environment.background_mode = Environment.BG_COLOR
    env.environment.background_color = Color(0.12, 0.12, 0.14)
    env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.environment.ambient_light_color = Color(0.6, 0.6, 0.64)
    room.add_child(env)
    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-40, 30, 0)
    room.add_child(sun)
    var camera := Camera3D.new()
    camera.position = Vector3(0, 1.5, 5.6)
    camera.fov = 42.0
    room.add_child(camera)
    camera.look_at(Vector3(0, 1.0, 0))
    camera.make_current()
    var zs: Array[Infected] = []
    for i in TYPES.size():
        var z: Infected = (load("res://actors/enemies/infected.tscn") as PackedScene).instantiate()
        z.data = load("res://data/enemies/%s.tres" % TYPES[i])
        room.add_child(z)
        z.global_position = Vector3(-3.4 + i * 1.7, 0.0, 0.0)
        z.set_physics_process(false)
        z.model.rotation.y = PI
        z._play("Zombie_Walk_Fwd", 0.0)
        zs.append(z)
    await create_timer(0.6).timeout
    root.get_viewport().get_texture().get_image().save_png(out + "/1_nuevos.png")
    # Disparos al pecho (heridas visibles).
    for z in zs:
        z.health = 99
        for k in 3:
            z.take_hit(1, z.global_position + Vector3(randf_range(-1, 1), 1.2, 4.0), z.global_position + Vector3(randf_range(-0.2, 0.2), randf_range(0.8, 1.35), 0.2), 0.0)
    await create_timer(0.8).timeout
    root.get_viewport().get_texture().get_image().save_png(out + "/2_heridas.png")
    # Muertes distintas: tiro a la cabeza, escopeta, explosivo, escopeta baja, tiro común.
    var plan := [[1, 1.7], [6, 1.4], [14, 1.1], [5, 0.6], [2, 1.0]]
    for i in zs.size():
        zs[i].health = 1
        zs[i].take_hit(plan[i][0], zs[i].global_position + Vector3(0.3, 1.2, 4.0), zs[i].global_position + Vector3(0, plan[i][1], 0.2), 0.0)
    await create_timer(0.35).timeout
    root.get_viewport().get_texture().get_image().save_png(out + "/3_muertes_a.png")
    await create_timer(1.2).timeout
    root.get_viewport().get_texture().get_image().save_png(out + "/4_muertes_b.png")
    quit()
