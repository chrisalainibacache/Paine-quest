extends SceneTree
## Renderiza el fondo de la pantalla de título: un bosque de pinos de noche, con niebla y la vía
## del tren perdiéndose entre los árboles. Necesita Forward+ (ver render_cinematic.gd para lavapipe).
## Uso: godot --path . --rendering-method forward_plus --rendering-driver vulkan --resolution 1920x816 \
##        -s res://tools/prerender/render_title.gd -- /ruta/salida.png [semilla]

const SKULL_BODY := preload("res://levels/kit/skull_body.gd")
var _rng := RandomNumberGenerator.new()


func _init() -> void:
    _run.call_deferred()


func _mat(color: Color, tex: String = "", rough := 1.0, scale := 1.0) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = color
    m.roughness = rough
    if tex != "":
        m.albedo_texture = load(tex) as Texture2D
        m.uv1_triplanar = true
        m.uv1_scale = Vector3(scale, scale, scale)
    return m


func _mesh(parent: Node3D, mesh: Mesh, pos: Vector3, mat: Material, rot := Vector3.ZERO) -> MeshInstance3D:
    var mi := MeshInstance3D.new()
    mi.mesh = mesh
    mi.position = pos
    mi.rotation_degrees = rot
    mi.material_override = mat
    parent.add_child(mi)
    return mi


func _pine(world: Node3D, pos: Vector3, height: float, bark: Material, needles: Material) -> void:
    var tree := Node3D.new()
    tree.position = pos
    tree.rotation_degrees = Vector3(_rng.randf_range(-2.5, 2.5), _rng.randf() * 360.0, _rng.randf_range(-2.5, 2.5))
    world.add_child(tree)
    var trunk := CylinderMesh.new()
    trunk.top_radius = 0.10 * height / 9.0
    trunk.bottom_radius = 0.30 * height / 9.0
    trunk.height = height
    trunk.radial_segments = 8
    _mesh(tree, trunk, Vector3(0, height * 0.5, 0), bark)
    # Copa: conos apilados, más angostos hacia arriba; sin copa en el tercio bajo (se ven los troncos).
    var layers := 6
    for i in layers:
        var t := float(i) / float(layers - 1)
        var cone := CylinderMesh.new()
        cone.top_radius = 0.0
        cone.bottom_radius = lerpf(1.35, 0.45, t) * height / 9.0 * _rng.randf_range(0.85, 1.15)
        cone.height = height * 0.26
        cone.radial_segments = 7
        _mesh(tree, cone, Vector3(0, lerpf(height * 0.42, height * 0.94, t), 0), needles, Vector3(0, _rng.randf() * 90, 0))


func _run() -> void:
    var args := OS.get_cmdline_user_args()
    var out_path: String = args[0] if args.size() > 0 else "/tmp/title_forest.png"
    _rng.seed = int(args[1]) if args.size() > 1 else 7
    var world := Node3D.new()
    root.add_child(world)

    var env := Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = Color(0.015, 0.02, 0.035)
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.16, 0.20, 0.30)
    env.ambient_light_energy = 1.0
    env.fog_enabled = true
    env.fog_light_color = Color(0.07, 0.09, 0.13)
    env.fog_density = 0.035
    env.volumetric_fog_enabled = true
    env.volumetric_fog_density = 0.03
    env.volumetric_fog_albedo = Color(0.45, 0.52, 0.65)
    env.volumetric_fog_length = 70.0
    env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    env.adjustment_enabled = true
    env.adjustment_saturation = 0.85
    env.glow_enabled = true
    env.glow_intensity = 0.6
    var we := WorldEnvironment.new()
    we.environment = env
    world.add_child(we)

    # Luna: luz direccional fría que entra entre los troncos, desde atrás.
    var moon := DirectionalLight3D.new()
    moon.light_color = Color(0.55, 0.68, 1.0)
    moon.light_energy = 1.5
    moon.shadow_enabled = true
    moon.directional_shadow_max_distance = 60.0
    moon.light_volumetric_fog_energy = 0.9
    moon.rotation_degrees = Vector3(-24, 160, 0)
    world.add_child(moon)

    # Suelo.
    var ground := PlaneMesh.new()
    ground.size = Vector2(120, 120)
    _mesh(world, ground, Vector3.ZERO, _mat(Color(0.20, 0.18, 0.15), "res://assets/environment/textures/gravel.png", 1.0, 0.25))

    # Vía: balasto, durmientes y dos rieles que se pierden hacia el fondo (-Z).
    var bed := BoxMesh.new()
    bed.size = Vector2(2.6, 0.18).x * Vector3(1, 0, 0) + Vector3(0, 0.18, 70)
    _mesh(world, bed, Vector3(0, 0.09, -30), _mat(Color(0.16, 0.15, 0.14), "res://assets/environment/textures/gravel.png", 1.0, 0.6))
    var wood := _mat(Color(0.12, 0.09, 0.07), "res://assets/environment/textures/wood.png", 1.0, 0.8)
    wood.emission_enabled = true
    wood.emission = Color(0.20, 0.13, 0.09)
    wood.emission_energy_multiplier = 0.1
    var rail := _mat(Color(0.30, 0.20, 0.15), "res://assets/environment/textures/rust.png", 0.6, 0.8)
    rail.emission_enabled = true
    rail.emission = Color(0.25, 0.32, 0.45)
    rail.emission_energy_multiplier = 0.18
    for i in 70:
        var tie := BoxMesh.new()
        tie.size = Vector3(2.3, 0.12, 0.28)
        _mesh(world, tie, Vector3(0, 0.22, 4.0 - i * 0.62), wood)
    for s in [-0.72, 0.72]:
        var r := BoxMesh.new()
        r.size = Vector3(0.05, 0.14, 70)
        _mesh(world, r, Vector3(s, 0.34, -30), rail)

    # Bosque: pinos a ambos lados, cada vez más densos hacia el fondo; el centro queda libre (la vía).
    var bark := _mat(Color(0.13, 0.095, 0.07), "res://assets/environment/textures/wood.png", 1.0, 0.5)
    var needles := _mat(Color(0.025, 0.05, 0.04), "", 1.0)
    for i in 190:
        var z := -_rng.randf_range(3.0, 70.0)
        var side := -1.0 if _rng.randf() < 0.5 else 1.0
        var x := side * (3.4 + _rng.randf_range(0.0, 1.0) * (5.0 + absf(z) * 0.5))
        _pine(world, Vector3(x, 0, z), _rng.randf_range(8.0, 15.0), bark, needles)

    # Un farol/ventana lejana al final de la vía (la estación) y una lámpara cálida baja a un lado.
    var far := OmniLight3D.new()
    far.light_color = Color(1.0, 0.62, 0.28)
    far.light_energy = 9.0
    far.omni_range = 22.0
    far.light_volumetric_fog_energy = 3.0
    far.position = Vector3(0.5, 1.8, -40)
    world.add_child(far)
    var bulb := SphereMesh.new()
    bulb.radius = 0.16
    bulb.height = 0.32
    var bm := StandardMaterial3D.new()
    bm.albedo_color = Color(1.0, 0.7, 0.35)
    bm.emission_enabled = true
    bm.emission = Color(1.0, 0.65, 0.3)
    bm.emission_energy_multiplier = 6.0
    _mesh(world, bulb, far.position, bm)

    # Una silueta alta entre la niebla, muy lejos, de pie sobre la vía. Casi no se distingue.
    var skull: Node3D = SKULL_BODY.build()
    skull.position = Vector3(-0.2, 0, -27)
    skull.rotation_degrees = Vector3(0, 0, 0)
    for m in skull.find_children("*", "MeshInstance3D", true, false):
        (m as MeshInstance3D).material_override = _mat(Color(0.005, 0.006, 0.008))
    world.add_child(skull)

    var cam := Camera3D.new()
    cam.fov = 58.0
    cam.near = 0.05
    cam.far = 90.0
    cam.position = Vector3(0.1, 1.3, 5.5)
    world.add_child(cam)
    cam.look_at(Vector3(-6.5, 0.2, -20.0))  # la vía se pierde hacia la derecha; a la izquierda queda sitio para el menú
    cam.make_current()

    var vp := root.get_viewport()
    vp.use_taa = true
    vp.msaa_3d = Viewport.MSAA_4X
    for i in 12:
        await process_frame
    vp.get_texture().get_image().save_png(out_path)
    print("título guardado en ", out_path)
    quit()
