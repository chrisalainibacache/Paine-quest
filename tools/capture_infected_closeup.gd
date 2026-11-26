extends SceneTree
## Primer plano de un tipo de infectado desde 3 ángulos. Uso: PAINE_GRAFICOS=moderno xvfb-run godot --path . --rendering-driver opengl3 -s res://tools/capture_infected_closeup.gd -- <salida.png> <tipo>
func _init() -> void:
    _run.call_deferred()
func _run() -> void:
    var out: String = OS.get_cmdline_user_args()[0]
    var kind: String = OS.get_cmdline_user_args()[1]
    GameState.new_game()
    var mode := OS.get_environment("PAINE_GRAFICOS")
    if mode != "":
        GraphicsSettings.set_modern(mode == "moderno")
    var room := Node3D.new(); root.add_child(room)
    var floor := MeshInstance3D.new(); floor.mesh = PlaneMesh.new(); floor.mesh.size = Vector2(30, 30); room.add_child(floor)
    var we := WorldEnvironment.new(); we.environment = Environment.new()
    we.environment.background_mode = Environment.BG_COLOR; we.environment.background_color = Color(0.15, 0.15, 0.17)
    we.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR; we.environment.ambient_light_color = Color(0.55, 0.55, 0.6)
    room.add_child(we)
    var angles := [0.0, PI * 0.5, PI]
    for i in 3:
        var inf: Infected = (load("res://actors/enemies/infected.tscn") as PackedScene).instantiate()
        inf.data = load("res://data/enemies/%s.tres" % kind)
        room.add_child(inf)
        inf.global_position = Vector3(-1.4 + i * 1.4, 0.05, 0.0)
        inf.set_physics_process(false)
        inf.model.rotation.y = angles[i]
        inf._play("Zombie_Idle", 0.0)
        inf._anim.seek(0.4, true)
    var cam := Camera3D.new(); room.add_child(cam)
    cam.global_position = Vector3(0, 1.8, 6.2); cam.look_at(Vector3(0, 1.2, 0)); cam.fov = 45; cam.make_current()
    var l := OmniLight3D.new(); room.add_child(l); l.global_position = Vector3(0, 3, 3); l.omni_range = 12; l.light_energy = 1.7
    GraphicsSettings.apply(room)
    await create_timer(1.4).timeout
    root.get_viewport().get_texture().get_image().save_png(out)
    quit()
