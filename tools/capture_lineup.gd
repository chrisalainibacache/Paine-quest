extends SceneTree
## Captura los tipos de infectado lado a lado (revisión de arte).
## Uso: xvfb-run godot --path . --rendering-driver opengl3 -s res://tools/capture_lineup.gd -- <archivo.png>

const TYPES := ["infected", "infected_pale", "infected_worker", "infected_burnt", "infected_heavy"]


func _init() -> void:
    _run.call_deferred()


func _run() -> void:
    var out: String = OS.get_cmdline_user_args()[0]
    GameState.new_game()
    var room := Node3D.new()
    root.add_child(room)
    var floor := MeshInstance3D.new()
    floor.mesh = PlaneMesh.new()
    floor.mesh.size = Vector2(20, 20)
    room.add_child(floor)
    var environment := WorldEnvironment.new()
    environment.environment = Environment.new()
    environment.environment.background_mode = Environment.BG_COLOR
    environment.environment.background_color = Color(0.12, 0.12, 0.14)
    environment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    environment.environment.ambient_light_color = Color(0.5, 0.5, 0.55)
    room.add_child(environment)
    for i in TYPES.size():
        var infected: Infected = (load("res://actors/enemies/infected.tscn") as PackedScene).instantiate()
        infected.data = load("res://data/enemies/%s.tres" % TYPES[i])
        room.add_child(infected)
        infected.global_position = Vector3(-2.4 + i * 1.2, 0.05, 1.8)
        infected.set_physics_process(false)
        infected.model.rotation.y = 0.0
        infected._play("Zombie_Walk_Fwd", 0.0)
    var camera := Camera3D.new()
    room.add_child(camera)
    camera.global_position = Vector3(0.0, 1.3, 5.2)
    camera.look_at(Vector3(0.0, 0.9, 1.8))
    camera.fov = 50
    camera.make_current()
    var light := OmniLight3D.new()
    room.add_child(light)
    light.global_position = Vector3(0, 2.4, 3.6)
    light.omni_range = 6.0
    light.light_energy = 1.4
    await create_timer(1.3).timeout
    root.get_viewport().get_texture().get_image().save_png(out)
    quit()
