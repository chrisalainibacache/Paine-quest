extends SceneTree
## Captura el lanzamiento de un objeto (revisión de arte). Uso: xvfb-run godot --path . --rendering-driver opengl3 -s res://tools/capture_throw.gd -- infected_pale
## Guarda /tmp/th_<tipo>_<n>.png
    _run.call_deferred()
func _run() -> void:
    var kind: String = OS.get_cmdline_user_args()[0]
    GameState.new_game()
    GraphicsSettings.set_modern(true)
    var room := Node3D.new()
    root.add_child(room)
    var ground := StaticBody3D.new()
    ground.collision_layer = 1
    var cs := CollisionShape3D.new(); var box := BoxShape3D.new(); box.size = Vector3(40, 1, 40); cs.shape = box; cs.position = Vector3(0, -0.5, 0)
    ground.add_child(cs); room.add_child(ground)
    var floor := MeshInstance3D.new(); floor.mesh = PlaneMesh.new(); floor.mesh.size = Vector2(40, 40); room.add_child(floor)
    var wall := StaticBody3D.new(); wall.collision_layer = 1
    var wcs := CollisionShape3D.new(); var wb := BoxShape3D.new(); wb.size = Vector3(40, 4, 1); wcs.shape = wb; wcs.position = Vector3(0, 2, -4.5)
    wall.add_child(wcs); room.add_child(wall)
    var we := WorldEnvironment.new(); we.environment = Environment.new()
    we.environment.background_mode = Environment.BG_COLOR; we.environment.background_color = Color(0.12, 0.12, 0.14)
    we.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR; we.environment.ambient_light_color = Color(0.6, 0.6, 0.65)
    room.add_child(we)
    var player: Node3D = (load("res://actors/player/player.tscn") as PackedScene).instantiate()
    room.add_child(player)
    player.global_position = Vector3(0, 0.05, -3.0)
    var inf: Infected = (load("res://actors/enemies/infected.tscn") as PackedScene).instantiate()
    inf.data = load("res://data/enemies/%s.tres" % kind)
    room.add_child(inf)
    inf.global_position = Vector3(0, 0.05, 2.5)
    inf.model.rotation.y = PI
    inf._thrower._cooldown = 0.0
    var camera := Camera3D.new(); room.add_child(camera)
    camera.global_position = Vector3(5.5, 1.6, -0.2); camera.look_at(Vector3(0, 1.1, -0.2)); camera.fov = 55; camera.make_current()
    var light := OmniLight3D.new(); room.add_child(light); light.global_position = Vector3(2, 3.5, 0); light.omni_range = 14.0; light.light_energy = 1.8
    GraphicsSettings.apply(room)
    var hp0: int = player.health
    var n := 0
    var t0 := Time.get_ticks_msec()
    var shots := [0.0]
    for i in 30:
        await create_timer(0.07).timeout
        var st := inf.state
        print("T ", i, " estado=", st, " vida=", player.health)
        if i in [2, 4, 5, 6, 7, 8, 10, 12]:
            root.get_viewport().get_texture().get_image().save_png("/tmp/th_%s_%d.png" % [kind, i])
    print("RESULT daño=", hp0 - player.health, " municion=", inf._thrower.ammo)
    quit()
