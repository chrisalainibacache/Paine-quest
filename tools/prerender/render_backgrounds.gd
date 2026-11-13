extends SceneTree
## Renderiza los fondos prerenderizados de una sala: una imagen por cámara fija,
## con el detalle extra (render_src/scenes/<sala>_detail.tscn) y efectos caros
## (iluminación global SDFGI, oclusión ambiental, niebla volumétrica, sombras en
## todas las luces) que el teléfono no podría dibujar en vivo.
##
## Necesita el renderer Forward+ (Vulkan). En el servidor sin GPU se usa lavapipe:
##   VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/lvp_icd.json xvfb-run -a -s "-screen 0 2560x1440x24" \
##     godot --path . --rendering-method forward_plus --rendering-driver vulkan --resolution 2520x1080 \
##     -s res://tools/prerender/render_backgrounds.gd -- <ruta_sala.tscn> [frames]
## Deja assets/backgrounds/<sala>/<Cámara>.png (1680x720, 21:9: cubre cualquier teléfono).

const OUT_SIZE := Vector2i(1680, 720)


func _init() -> void:
    _run.call_deferred()


func _run() -> void:
    var args := OS.get_cmdline_user_args()
    var room_path: String = args[0]
    var frames := int(args[1]) if args.size() > 1 else 90
    var room_name := room_path.get_file().get_basename()
    var out_dir := "res://assets/backgrounds/%s/" % room_name
    DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out_dir))

    SceneLoader.intros_enabled = false
    GraphicsSettings.set_modern(true)
    var room := (load(room_path) as PackedScene).instantiate() as Node3D
    root.add_child(room)
    var detail_path := "res://render_src/scenes/%s_detail.tscn" % room_name
    if ResourceLoader.exists(detail_path):
        room.add_child((load(detail_path) as PackedScene).instantiate())
    # Lo que se mueve o se recoge no va en la foto: queda en 3D en el juego.
    for group_name in ["Enemies", "Interactables", "Spawns"]:
        var group := room.get_node_or_null(group_name) as Node3D
        if group:
            group.visible = false
    await process_frame
    GraphicsSettings.apply(room)
    _upgrade_for_render(room)

    var viewport := root.get_viewport()
    viewport.use_taa = true
    viewport.msaa_3d = Viewport.MSAA_4X
    viewport.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
    # Tercer argumento opcional: solo esas cámaras (p. ej. "Cam6,Cam2").
    var only: PackedStringArray = args[2].split(",") if args.size() > 2 else PackedStringArray()
    for zone: Node in room.find_children("*", "CameraZone", true, false):
        if not only.is_empty() and not (zone.name in only):
            continue
        var camera := zone.get_node("Camera") as Camera3D
        camera.make_current()
        for i in frames:
            await process_frame
        var image := viewport.get_texture().get_image()
        image.resize(OUT_SIZE.x, OUT_SIZE.y, Image.INTERPOLATE_LANCZOS)
        var file := out_dir + zone.name + ".png"
        image.save_png(ProjectSettings.globalize_path(file))
        print("fondo: ", file)
    quit()


## Ambiente y luces de calidad "película" (solo para el render).
func _upgrade_for_render(room: Node3D) -> void:
    for world_env: WorldEnvironment in room.find_children("*", "WorldEnvironment", true, false):
        var env := world_env.environment.duplicate() as Environment
        env.tonemap_mode = Environment.TONE_MAPPER_ACES
        env.tonemap_exposure = 1.1
        env.ssao_enabled = true
        env.ssao_radius = 1.2
        env.ssao_intensity = 2.2
        env.ssil_enabled = true
        env.sdfgi_enabled = true
        env.sdfgi_use_occlusion = true
        env.sdfgi_energy = 1.2
        env.glow_enabled = true
        env.glow_intensity = 0.6
        env.glow_bloom = 0.05
        env.volumetric_fog_enabled = true
        env.volumetric_fog_density = 0.025
        env.volumetric_fog_albedo = Color(0.55, 0.58, 0.68)
        env.volumetric_fog_emission = env.fog_light_color * 0.15
        env.adjustment_enabled = true
        env.adjustment_brightness = 1.0
        env.adjustment_contrast = 1.06
        env.adjustment_saturation = 1.05
        world_env.environment = env
    for light: Light3D in room.find_children("*", "Light3D", true, false):
        light.shadow_enabled = true
        light.light_volumetric_fog_energy = 1.5
        if light is OmniLight3D:
            (light as OmniLight3D).omni_shadow_mode = OmniLight3D.SHADOW_CUBE
        if light is DirectionalLight3D:
            (light as DirectionalLight3D).directional_shadow_max_distance = 40.0
