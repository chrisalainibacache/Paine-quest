extends SceneTree
## Renderiza una cinemática de cámara móvil (sin personajes) sobre una sala, a cuadros PNG.
## Necesita Forward+ (Vulkan). En el servidor sin GPU se usa lavapipe:
##   VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/lvp_icd.json xvfb-run -a -s "-screen 0 1400x700x24" \
##     godot --path . --rendering-method forward_plus --rendering-driver vulkan --resolution 1280x544 \
##     -s res://tools/prerender/render_cinematic.gd -- <carpeta_salida> [fps] [segundos]
## La cámara sigue la ruta de PATH (posición y punto de mira); la luz de sodio parpadea.

const ROOM := "res://levels/station/platform.tscn"
## Ruta de la cámara: [tiempo 0..1, posición, punto de mira, fov]
const PATH := [
    [0.00, Vector3(-6.4, 0.5, -0.5), Vector3(-1.0, 1.3, 2.4), 56.0],
    [0.35, Vector3(-3.6, 0.8, 1.3), Vector3(1.5, 1.6, 3.4), 54.0],
    [0.70, Vector3(-1.4, 1.1, 0.4), Vector3(3.0, 1.5, 5.2), 52.0],
    [1.00, Vector3(-0.4, 1.4, 0.7), Vector3(3.0, 1.45, 5.25), 50.0],
]

var _lamps: Array[OmniLight3D] = []
var _base_energy := {}


func _init() -> void:
    _run.call_deferred()


func _run() -> void:
    var args := OS.get_cmdline_user_args()
    var out_dir: String = args[0]
    var fps: int = int(args[1]) if args.size() > 1 else 15
    var seconds: float = float(args[2]) if args.size() > 2 else 7.5
    DirAccess.make_dir_recursive_absolute(out_dir)
    SceneLoader.intros_enabled = false
    SceneLoader.cinematics_enabled = false
    GraphicsSettings.set_modern(true)
    var room := (load(ROOM) as PackedScene).instantiate() as Node3D
    root.add_child(room)
    var detail_path := "res://render_src/scenes/platform_detail.tscn"
    if ResourceLoader.exists(detail_path):
        room.add_child((load(detail_path) as PackedScene).instantiate())
    for group_name in ["Enemies", "Interactables", "Spawns"]:
        var group := room.get_node_or_null(group_name) as Node3D
        if group:
            group.visible = false
    await process_frame
    GraphicsSettings.apply(room)
    _upgrade(room)
    # La cámara de la cinemática (las de la sala no se usan).
    var camera := Camera3D.new()
    camera.near = 0.05
    camera.far = 60.0
    room.add_child(camera)
    camera.make_current()
    var viewport := root.get_viewport()
    viewport.use_taa = true
    viewport.msaa_3d = Viewport.MSAA_4X
    for light: OmniLight3D in room.find_children("*", "OmniLight3D", true, false):
        _lamps.append(light)
        _base_energy[light] = light.light_energy
    var total := int(round(fps * seconds))
    var rng := RandomNumberGenerator.new()
    rng.seed = 7
    for i in total:
        var u := float(i) / float(total - 1)
        _place(camera, u)
        _flicker(float(i) / fps, rng)
        for k in 3:
            await process_frame
        var image := viewport.get_texture().get_image()
        image.save_png("%s/f%04d.png" % [out_dir, i])
        if i % 10 == 0:
            print("cuadro %d de %d" % [i + 1, total])
    print("LISTO ", total)
    quit()


## Posición de la cámara en el instante u (0..1), con suavizado de arranque y llegada.
func _place(camera: Camera3D, u: float) -> void:
    var s := u * u * (3.0 - 2.0 * u)
    var a: Array = PATH[0]
    var b: Array = PATH[PATH.size() - 1]
    for i in PATH.size() - 1:
        if s >= PATH[i][0] and s <= PATH[i + 1][0]:
            a = PATH[i]
            b = PATH[i + 1]
            break
    var t: float = inverse_lerp(a[0] as float, b[0] as float, s)
    t = t * t * (3.0 - 2.0 * t)
    var pos: Vector3 = (a[1] as Vector3).lerp(b[1], t)
    var target: Vector3 = (a[2] as Vector3).lerp(b[2], t)
    camera.fov = lerpf(a[3] as float, b[3] as float, t)
    # Un temblor casi imperceptible: se siente cámara en mano.
    var tremor := Vector3(sin(u * 37.0), sin(u * 29.0 + 1.0), sin(u * 41.0 + 2.0)) * 0.006
    camera.global_position = pos + tremor
    camera.look_at(target + tremor * 0.5, Vector3.UP)


## La luz de sodio titila de verdad: tramos normales, caídas y un apagón breve.
func _flicker(time: float, rng: RandomNumberGenerator) -> void:
    for light in _lamps:
        var base: float = _base_energy[light]
        var wobble := 0.85 + 0.15 * sin(time * 9.0 + light.global_position.x)
        var drop := 1.0
        if int(time * 4.0) % 7 == 3:
            drop = 0.25 + rng.randf() * 0.5
        light.light_energy = base * wobble * drop


func _upgrade(room: Node3D) -> void:
    for world_env: WorldEnvironment in room.find_children("*", "WorldEnvironment", true, false):
        var env := world_env.environment.duplicate() as Environment
        env.tonemap_mode = Environment.TONE_MAPPER_ACES
        env.tonemap_exposure = 0.82
        env.ssao_enabled = true
        env.ssao_radius = 1.2
        env.ssao_intensity = 2.2
        env.glow_enabled = true
        env.glow_intensity = 0.7
        env.glow_bloom = 0.06
        env.volumetric_fog_enabled = true
        env.volumetric_fog_density = 0.05
        env.volumetric_fog_albedo = Color(0.55, 0.58, 0.68)
        env.volumetric_fog_emission = env.fog_light_color * 0.08
        env.adjustment_enabled = true
        env.adjustment_contrast = 1.16
        env.adjustment_saturation = 0.95
        world_env.environment = env
    for light: Light3D in room.find_children("*", "Light3D", true, false):
        light.shadow_enabled = true
        light.light_volumetric_fog_energy = 1.6
        if light is OmniLight3D:
            (light as OmniLight3D).omni_shadow_mode = OmniLight3D.SHADOW_CUBE
        if light is DirectionalLight3D:
            (light as DirectionalLight3D).directional_shadow_max_distance = 40.0
