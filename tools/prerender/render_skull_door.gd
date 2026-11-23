extends SceneTree
## Renderiza la cinemática de Skull («la puerta que revienta») a cuadros PNG con calidad de render (Forward+: niebla volumétrica,
## sombras, reflejos, bloom). Se codifica luego a video (ver tools/prerender/skull_door_video.sh) y el juego lo reproduce igual que la
## intro. La criatura NUNCA se ve: solo la sombra enorme que proyecta hacia el pasillo la luz roja de detrás de la puerta.
## La línea de tiempo es la de levels/kit/cinematic.gd (golpes 1,0 / 1,85 / 2,7 s; la puerta cede de 4,0 a 4,6 s y revienta; la sombra cruza de 5,0 a 7,1 s).
##   VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/lvp_icd.json xvfb-run -a -s "-screen 0 1400x700x24" godot --path . \
##     --rendering-method forward_plus --rendering-driver vulkan --resolution 1280x544 -s res://tools/prerender/render_skull_door.gd \
##     -- <carpeta_salida> [fps] [segundos] [t_unico]
const PH := "res://render_src/polyhaven/%s/%s_1k.gltf"
const SKULL_BODY := preload("res://levels/kit/skull_body.gd")
const FAR_Z := -9.0                      # plano de la puerta

var _cam: Camera3D
var _lamp: OmniLight3D
var _env: Environment
var _lamp_mesh: MeshInstance3D
var _red: OmniLight3D
var _leaf_l: Node3D
var _leaf_r: Node3D
var _skull: Node3D
var _backdrop: MeshInstance3D
var _shards: Array[Node3D] = []
var _dust: Array[MeshInstance3D] = []
var _door_fog: FogVolume
var _rng := RandomNumberGenerator.new()


func _init() -> void:
    _run.call_deferred()


func _tex_mat(file: String, scale := 0.45, rough := 0.85, tint := Color.WHITE) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_texture = load("res://assets/environment/textures/%s.png" % file)
    m.albedo_color = tint
    m.uv1_triplanar = true
    m.uv1_scale = Vector3.ONE * scale
    m.roughness = rough
    return m


func _box(root: Node3D, pos: Vector3, size: Vector3, mat: Material, rot := Vector3.ZERO) -> MeshInstance3D:
    var mi := MeshInstance3D.new()
    var b := BoxMesh.new()
    b.size = size
    mi.mesh = b
    mi.material_override = mat
    mi.position = pos
    mi.rotation = rot
    root.add_child(mi)
    return mi


func _prop(root: Node3D, name: String, pos: Vector3, yaw := 0.0, sc := 1.0, rot := Vector3.ZERO) -> Node3D:
    var path := PH % [name, name]
    if not ResourceLoader.exists(path):
        return null
    var n := (load(path) as PackedScene).instantiate() as Node3D
    n.position = pos
    n.rotation = Vector3(rot.x, yaw, rot.z)
    n.scale = Vector3.ONE * sc
    root.add_child(n)
    return n


func _run() -> void:
    var args := OS.get_cmdline_user_args()
    var out_dir: String = args[0]
    var fps: int = int(args[1]) if args.size() > 1 else 15
    var seconds: float = float(args[2]) if args.size() > 2 else 10.0
    var single: float = float(args[3]) if args.size() > 3 else -1.0
    DirAccess.make_dir_recursive_absolute(out_dir)
    _rng.seed = 91
    var world := Node3D.new()
    root.add_child(world)
    _build_world(world)
    _build_door(world)
    await process_frame
    var viewport := root.get_viewport()
    viewport.msaa_3d = Viewport.MSAA_4X
    if single >= 0.0:
        await _frame(single, out_dir, 0, 3)
        quit()
        return
    var total := int(round(fps * seconds))
    for i in total:
        await _frame(float(i) / fps, out_dir, i, 2)
        if i % 10 == 0:
            print("cuadro ", i, "/", total)
    quit()


func _frame(t: float, out_dir: String, index: int, waits: int) -> void:
    _apply(t)
    for k in waits:
        await process_frame
    root.get_viewport().get_texture().get_image().save_png("%s/%04d.png" % [out_dir, index])


func _build_world(world: Node3D) -> void:
    var env := Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = Color.BLACK
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.2, 0.23, 0.29)
    env.ambient_light_energy = 0.55
    env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    env.tonemap_exposure = 1.15
    env.glow_enabled = true
    env.glow_intensity = 0.7
    env.glow_bloom = 0.1
    env.ssao_enabled = true
    env.ssao_intensity = 2.2
    env.ssr_enabled = true
    env.ssr_max_steps = 48
    env.volumetric_fog_enabled = true
    env.volumetric_fog_density = 0.055
    env.volumetric_fog_albedo = Color(0.5, 0.54, 0.6)
    env.volumetric_fog_length = 30.0
    env.volumetric_fog_temporal_reprojection_enabled = false
    env.adjustment_enabled = true
    env.adjustment_contrast = 1.1
    env.adjustment_saturation = 0.85
    _env = env
    var we := WorldEnvironment.new()
    we.environment = env
    world.add_child(we)
    _cam = Camera3D.new()
    _cam.fov = 52.0
    _cam.near = 0.05
    _cam.far = 60.0
    world.add_child(_cam)
    _cam.make_current()
    # Pasillo de servicio: piso, muros de ladrillo, techo y vigas.
    var floor_mat := _tex_mat("concrete", 0.35, 0.5, Color(0.55, 0.55, 0.57))
    var wall_mat := _tex_mat("bricks_old", 0.4, 0.9, Color(0.62, 0.6, 0.58))
    var top_mat := _tex_mat("plaster", 0.4, 0.95, Color(0.5, 0.5, 0.5))
    var metal := _tex_mat("metal", 0.5, 0.45, Color(0.45, 0.45, 0.47))
    _box(world, Vector3(0, -0.1, -2), Vector3(5.2, 0.2, 24), floor_mat)
    _box(world, Vector3(0, 3.7, -2), Vector3(5.2, 0.2, 24), top_mat)
    _box(world, Vector3(-2.7, 1.8, -2), Vector3(0.2, 3.8, 24), wall_mat)
    _box(world, Vector3(2.7, 1.8, -2), Vector3(0.2, 3.8, 24), wall_mat)
    _box(world, Vector3(0, 1.8, 11.2), Vector3(5.2, 3.8, 0.2), wall_mat)
    for z in [6.0, 2.0, -2.0, -6.0]:
        _box(world, Vector3(0, 3.45, z), Vector3(5.2, 0.32, 0.4), metal)
    # Charcos: reflejan la lámpara.
    var puddle := StandardMaterial3D.new()
    puddle.albedo_color = Color(0.02, 0.025, 0.03)
    puddle.roughness = 0.04
    puddle.metallic_specular = 1.0
    for p in [Vector3(-0.8, 0.012, 1.5), Vector3(0.9, 0.012, -2.8), Vector3(-0.2, 0.012, -6.2), Vector3(1.2, 0.012, 4.0)]:
        var plane := MeshInstance3D.new()
        var pm := PlaneMesh.new()
        pm.size = Vector2(_rng.randf_range(1.2, 2.4), _rng.randf_range(1.0, 2.0))
        plane.mesh = pm
        plane.material_override = puddle
        plane.position = p
        world.add_child(plane)
    # Utilería real (Poly Haven, CC0): tuberías, cables, cajas, carro, silla de ruedas, generador.
    for z in [4.8, 0.6, -3.4]:
        _prop(world, "modular_industrial_pipes_01", Vector3(-2.52, 2.2, z), PI / 2, 1.5)
    _prop(world, "modular_pipes", Vector3(2.55, 1.4, 0.0), -PI / 2, 1.3)
    _prop(world, "modular_electric_cables", Vector3(2.55, 2.8, -4.5), -PI / 2, 2.0)
    _prop(world, "old_military_crate", Vector3(-1.9, 0.0, 2.6), 0.3, 1.5)
    _prop(world, "old_military_crate", Vector3(-1.9, 0.36 * 1.5, 2.6), -0.2, 1.5)
    _prop(world, "barrel_03", Vector3(2.0, 0.0, -1.0), 0.0, 1.4)
    _prop(world, "barrel_03", Vector3(2.15, 0.0, -2.1), 1.0, 1.4)
    _prop(world, "wheelchair_01", Vector3(-1.4, 0.0, -4.8), 2.4, 1.1)
    _prop(world, "portable_generator", Vector3(1.9, 0.0, 3.6), -0.5, 1.3)
    _prop(world, "tool_cart", Vector3(-1.7, 0.0, -1.6), 1.6, 1.0)
    _prop(world, "fire_alarm", Vector3(2.58, 1.5, 3.0), -PI / 2, 2.0)
    _prop(world, "security_camera_01", Vector3(2.4, 3.3, -5.0), -PI / 2, 2.2, Vector3(0.3, 0.0, 0.0))
    # Lámpara con jaula (parpadea) y luz roja de emergencia tras la puerta.
    _prop(world, "caged_hanging_light", Vector3(0, 3.65, -1.0), 0.0, 1.6, Vector3(PI, 0.0, 0.0))
    _lamp = OmniLight3D.new()
    _lamp.position = Vector3(0, 3.2, -1.0)
    _lamp.light_color = Color(0.7, 0.8, 0.9)
    _lamp.omni_range = 13.0
    _lamp.shadow_enabled = true
    _lamp.light_volumetric_fog_energy = 1.6
    world.add_child(_lamp)
    _lamp_mesh = MeshInstance3D.new()
    var bulb := SphereMesh.new()
    bulb.radius = 0.12
    bulb.height = 0.24
    _lamp_mesh.mesh = bulb
    _lamp_mesh.position = Vector3(0, 3.18, -1.0)
    world.add_child(_lamp_mesh)
    var fill := OmniLight3D.new()
    fill.position = Vector3(0, 2.6, 6.0)
    fill.light_color = Color(0.45, 0.55, 0.7)
    fill.light_energy = 0.55
    fill.omni_range = 10.0
    world.add_child(fill)
    # Detrás de la puerta: oscuridad, una luz roja (apagada hasta el golpe) y la criatura (solo su sombra).
    _red = OmniLight3D.new()
    _red.position = Vector3(0, 1.6, FAR_Z - 3.2)
    _red.light_color = Color(1.0, 0.16, 0.08)
    _red.omni_range = 20.0
    _red.shadow_enabled = true
    _red.light_volumetric_fog_energy = 4.0
    _red.light_energy = 0.0
    world.add_child(_red)
    # Un fondo rojo emisivo tras la criatura: así se lee su silueta contra el resplandor (sin detalles: nunca se ve).
    var glow := StandardMaterial3D.new()
    glow.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    glow.albedo_color = Color(1.0, 0.16, 0.08)
    var backdrop := _box(world, Vector3(0, 1.8, FAR_Z - 5.0), Vector3(6.0, 4.0, 0.1), glow)
    backdrop.visible = false
    _backdrop = backdrop
    _skull = SKULL_BODY.build()
    _skull.position = Vector3(0, 0.0, FAR_Z - 1.4)
    _skull.rotation.y = PI / 2.0
    _skull.scale = Vector3.ONE * 1.3
    var black := StandardMaterial3D.new()
    black.albedo_color = Color(0.01, 0.01, 0.012)
    black.roughness = 1.0
    for mesh_node: Node in _skull.find_children("*", "MeshInstance3D", true, false):
        (mesh_node as MeshInstance3D).material_override = black
    _skull.visible = false
    world.add_child(_skull)
    # Polvo de la explosión (esferas translúcidas animadas por fórmula) y niebla densa ante la puerta.
    var dust_mat := StandardMaterial3D.new()
    dust_mat.albedo_color = Color(0.32, 0.27, 0.25, 0.16)
    dust_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    for i in 90:
        var d := MeshInstance3D.new()
        var sm := SphereMesh.new()
        sm.radius = _rng.randf_range(0.12, 0.38)
        sm.height = sm.radius * 2.0
        sm.radial_segments = 8
        sm.rings = 4
        d.mesh = sm
        d.material_override = dust_mat
        d.visible = false
        d.set_meta("v", Vector3(_rng.randf_range(-1.8, 1.8), _rng.randf_range(0.3, 2.2), _rng.randf_range(0.8, 4.5)))
        world.add_child(d)
        _dust.append(d)
    _door_fog = FogVolume.new()
    _door_fog.position = Vector3(0, 1.6, FAR_Z + 1.5)
    _door_fog.size = Vector3(4.6, 3.4, 4.0)
    var fog_mat := FogMaterial.new()
    fog_mat.density = 0.0
    fog_mat.albedo = Color(0.6, 0.4, 0.35)
    _door_fog.material = fog_mat
    world.add_child(_door_fog)


func _build_door(world: Node3D) -> void:
    var rust := _tex_mat("rust", 0.6, 0.7, Color(0.62, 0.42, 0.34))
    var metal := _tex_mat("metal", 0.5, 0.4, Color(0.4, 0.4, 0.43))
    var hazard := StandardMaterial3D.new()
    hazard.albedo_color = Color(0.75, 0.6, 0.12)
    hazard.roughness = 0.7
    # Muro del fondo con el hueco de la puerta doble.
    var wall := _tex_mat("bricks_old", 0.4, 0.9, Color(0.58, 0.56, 0.54))
    _box(world, Vector3(-1.9, 1.8, FAR_Z - 0.1), Vector3(1.6, 3.8, 0.5), wall)
    _box(world, Vector3(1.9, 1.8, FAR_Z - 0.1), Vector3(1.6, 3.8, 0.5), wall)
    _box(world, Vector3(0, 3.35, FAR_Z - 0.1), Vector3(2.3, 0.9, 0.5), wall)
    _box(world, Vector3(0, 0.0, FAR_Z - 3.0), Vector3(2.4, 0.2, 6.0), _tex_mat("concrete", 0.35, 0.6, Color(0.3, 0.3, 0.32)))
    for x in [-1.12, 1.12]:
        _box(world, Vector3(x, 1.45, FAR_Z + 0.1), Vector3(0.18, 2.9, 0.34), metal)
    _box(world, Vector3(0, 2.92, FAR_Z + 0.1), Vector3(2.46, 0.18, 0.34), metal)
    # Franja de peligro sobre el dintel.
    for i in 8:
        _box(world, Vector3(-1.05 + i * 0.3, 3.16, FAR_Z + 0.3), Vector3(0.14, 0.16, 0.03), hazard if i % 2 == 0 else metal, Vector3(0, 0, 0.6))
    var door_root := Node3D.new()
    world.add_child(door_root)
    _leaf_l = Node3D.new()
    _leaf_l.position = Vector3(-1.03, 0.0, FAR_Z + 0.02)
    door_root.add_child(_leaf_l)
    _leaf_r = Node3D.new()
    _leaf_r.position = Vector3(1.03, 0.0, FAR_Z + 0.02)
    door_root.add_child(_leaf_r)
    for leaf: Node3D in [_leaf_l, _leaf_r]:
        var sgn := 1.0 if leaf == _leaf_l else -1.0
        _box(leaf, Vector3(sgn * 0.5, 1.4, 0.0), Vector3(1.0, 2.8, 0.1), rust)
        for k in 3:
            _box(leaf, Vector3(sgn * (0.2 + k * 0.3), 1.4, 0.07), Vector3(0.05, 2.6, 0.05), metal)
        _box(leaf, Vector3(sgn * 0.5, 0.35, 0.07), Vector3(0.9, 0.12, 0.05), metal)
        _box(leaf, Vector3(sgn * 0.5, 2.2, 0.07), Vector3(0.9, 0.12, 0.05), metal)
    # Cadena y candado que cruzan las dos hojas.
    var chain := _box(door_root, Vector3(0, 1.1, FAR_Z + 0.12), Vector3(2.0, 0.07, 0.07), metal)
    chain.name = "Chain"
    _box(door_root, Vector3(0, 1.0, FAR_Z + 0.14), Vector3(0.18, 0.22, 0.1), hazard)
    # Fragmentos que saldrán disparados.
    for i in 8:
        var s := _box(world, Vector3(0, 1.0, FAR_Z + 0.05), Vector3(_rng.randf_range(0.3, 0.7), _rng.randf_range(0.2, 0.8), 0.08), rust)
        s.visible = false
        s.set_meta("v", Vector3(-1.9 + i * 0.5, 1.8 + (i % 3) * 0.55, 3.4 + (i % 2) * 1.0))
        s.set_meta("w", Vector3(_rng.randf_range(-4, 4), _rng.randf_range(-4, 4), _rng.randf_range(-4, 4)))
        _shards.append(s)


## Estado de toda la escena en el instante t (segundos).
func _apply(t: float) -> void:
    # Lámpara: mismo parpadeo que la cinemática en vivo; a 4,6 s un destello y se apaga.
    var energy := 0.0
    if t < 4.6:
        energy = 0.82 + 0.12 * sin(t * 19.0) + 0.06 * sin(t * 47.0)
        if t > 3.0 and int(t * 8.0) % 5 == 0:
            energy *= 0.28
        energy = maxf(energy, 0.12)
    elif t < 4.72:
        energy = 2.4
    _lamp.light_energy = energy * 3.2
    var bulb := StandardMaterial3D.new()
    bulb.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    bulb.albedo_color = Color(0.85, 0.92, 1.0) * clampf(energy, 0.05, 1.2)
    _lamp_mesh.material_override = bulb
    # Cámara: avance lento y temblor durante el golpe.
    var push := lerpf(0.0, 2.2, t / 10.0)
    var shake := 0.0
    if t >= 4.0 and t < 5.2:
        shake = 0.045 if t < 4.6 else 0.085
    _cam.position = Vector3(sin(t * 74.0) * shake, 1.65 + cos(t * 61.0) * shake, 6.4 - push)
    _cam.look_at(Vector3(0, 1.45, FAR_Z))
    # Puerta: cede entre 4,0 y 4,6 s; revienta a los 4,6 s.
    var hit := smoothstep(4.0, 4.6, t)
    var leaf_angle := 0.0
    if t >= 4.6:
        leaf_angle = minf((t - 4.6) * 6.0, 1.0) * 1.35
    _leaf_l.rotation = Vector3(0, leaf_angle, 0)
    _leaf_r.rotation = Vector3(0, -leaf_angle, 0)
    _leaf_l.position.z = FAR_Z + 0.02 + 0.2 * hit
    _leaf_r.position.z = FAR_Z + 0.02 + 0.2 * hit
    _leaf_l.rotation.x = -0.07 * hit
    _leaf_r.rotation.x = -0.07 * hit
    # Luz roja y niebla tras el golpe (el ambiente sube un poco para que se lea la sala).
    _env.ambient_light_energy = 0.55 + 0.5 * clampf((t - 4.6) / 0.5, 0.0, 1.0)
    var burst := clampf((t - 4.6) / 0.25, 0.0, 1.0)
    _red.light_energy = 10.0 * burst * (0.85 + 0.15 * sin(t * 9.0)) if t >= 4.6 else 0.0
    (_door_fog.material as FogMaterial).density = 2.2 * burst * (1.0 - clampf((t - 6.5) / 3.0, 0.0, 0.5))
    # Fragmentos y polvo (movimiento balístico).
    var dt := maxf(t - 4.6, 0.0)
    for s in _shards:
        s.visible = t >= 4.6 and dt < 3.5
        if s.visible:
            var v: Vector3 = s.get_meta("v")
            var w: Vector3 = s.get_meta("w")
            var p := Vector3(0, 1.0, FAR_Z + 0.05) + v * dt + Vector3(0, -4.9 * dt * dt, 0)
            p.y = maxf(p.y, 0.1)
            s.position = p
            s.rotation = w * minf(dt, 1.2)
    for d in _dust:
        d.visible = t >= 4.6 and dt < 3.0
        if d.visible:
            var v: Vector3 = d.get_meta("v")
            d.position = Vector3(0, 1.2, FAR_Z + 0.3) + v * (1.0 - exp(-dt * 1.6)) + Vector3(0, 0.25 * dt, 0)
            d.scale = Vector3.ONE * (0.6 + dt * 0.9)
    # La sombra de la criatura cruza de 5,0 a 7,1 s (se proyecta hacia el pasillo con la luz roja).
    var visible_skull := t >= 5.0 and t < 7.1
    _skull.visible = visible_skull
    _backdrop.visible = t >= 4.6 and t < 7.8
    if _skull.visible:
        _skull.position.x = lerpf(-1.5, 1.5, clampf((t - 5.0) / 2.1, 0.0, 1.0))
