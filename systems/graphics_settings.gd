class_name GraphicsSettings
## Modo gráfico: Retro (PS1: texturas pixeladas, filtro de pantalla) o Moderno
## (texturas HD con relieve, luz con brillos, sombras, sin filtro). La
## jugabilidad no cambia. El modo se guarda en user:// y se aplica al cargar
## cada sala y al tocar el botón GRÁFICOS.

const PATH := "user://ajustes.cfg"
const RETRO_SHADER := preload("res://shaders/ps1_surface.gdshader")
const MODERN_SHADER := preload("res://shaders/modern_surface.gdshader")
const MODERN_TEX := "res://assets/environment/textures_modern/"
## Luces con sombra en modo Moderno (además de la luna). Más es caro en el teléfono.
const SHADOW_LIGHTS := 1
const PRERENDERED := preload("res://systems/prerendered_background.gd")

static var _modern := false
## Brillo elegido (índice en BRIGHTNESS_LEVELS); se ajusta a cada teléfono.
const BRIGHTNESS_LEVELS := [0.9, 1.05, 1.2, 1.4, 1.65]
const DEFAULT_BRIGHTNESS := 2
static var _brightness := DEFAULT_BRIGHTNESS
static var _loaded := false
## Material retro -> su versión moderna (se crea una sola vez).
static var _modern_of := {}
static var _env_of := {}


static func is_modern() -> bool:
    _load()
    return _modern


static func set_modern(value: bool) -> void:
    _load()
    _modern = value
    _save()


## Nivel de brillo: 1 a BRIGHTNESS_LEVELS.size() (para mostrar en el botón).
static func brightness_level() -> int:
    _load()
    return _brightness + 1


## Pasa al siguiente nivel de brillo (vuelve al primero después del último).
static func cycle_brightness(tree: SceneTree) -> void:
    _load()
    _brightness = (_brightness + 1) % BRIGHTNESS_LEVELS.size()
    _save()
    apply(tree.root)


static func _save() -> void:
    var cfg := ConfigFile.new()
    cfg.set_value("graficos", "modo", "moderno" if _modern else "retro")
    cfg.set_value("graficos", "brillo", _brightness)
    cfg.save(PATH)


## Cambia de modo y lo aplica a todo lo que está en pantalla.
static func toggle(tree: SceneTree) -> void:
    set_modern(not is_modern())
    apply(tree.root)


static func _load() -> void:
    if _loaded:
        return
    _loaded = true
    var cfg := ConfigFile.new()
    if cfg.load(PATH) == OK:
        _modern = cfg.get_value("graficos", "modo", "retro") == "moderno"
        _brightness = clampi(int(cfg.get_value("graficos", "brillo", DEFAULT_BRIGHTNESS)), 0, BRIGHTNESS_LEVELS.size() - 1)


## Recorre el árbol (incluidos los hijos internos, como la malla de KitBlock)
## y deja materiales, luces, ambiente y filtro según el modo actual.
static func apply(root: Node) -> void:
    var modern := is_modern()
    # Fondos prerenderizados: se quitan antes de recorrer la sala y se vuelven a
    # poner después (si el modo es Moderno y la sala tiene imágenes).
    var rooms: Array[Room] = []
    if root is Room:
        rooms.append(root as Room)
    for node in root.find_children("*", "Room", true, false):
        rooms.append(node as Room)
    for room in rooms:
        PRERENDERED.sync(room, false, 1.0)
    var lights: Array[OmniLight3D] = []
    _walk(root, modern, lights)
    _set_shadows(lights, modern)
    for room in rooms:
        PRERENDERED.sync(room, modern, BRIGHTNESS_LEVELS[_brightness])
    var viewport := root.get_viewport()
    if viewport:
        # MSAA es casi gratis en GPUs de celular (Mali) y quita los serruchos.
        viewport.msaa_3d = Viewport.MSAA_4X if modern else Viewport.MSAA_DISABLED


static func _walk(node: Node, modern: bool, lights: Array[OmniLight3D]) -> void:
    if node is GeometryInstance3D:
        _apply_geometry(node as GeometryInstance3D, modern)
    elif node is WorldEnvironment:
        var world_env := node as WorldEnvironment
        world_env.environment = _environment(world_env.environment, modern)
        if world_env.environment:
            world_env.environment.adjustment_enabled = true
            world_env.environment.adjustment_brightness = BRIGHTNESS_LEVELS[_brightness]
    elif node is DirectionalLight3D:
        # La luna es débil: su sombra casi no se ve y cuesta un pase entero.
        (node as DirectionalLight3D).shadow_enabled = false
    elif node is OmniLight3D:
        lights.append(node as OmniLight3D)
    elif node is CanvasLayer and node.is_in_group("ps1_filter"):
        (node as CanvasLayer).visible = not modern
    for i in node.get_child_count(true):
        _walk(node.get_child(i, true), modern, lights)


static func _apply_geometry(geo: GeometryInstance3D, modern: bool) -> void:
    if geo.material_override:
        geo.material_override = _material(geo.material_override, modern)
    var mesh_instance := geo as MeshInstance3D
    if mesh_instance == null or mesh_instance.mesh == null:
        return
    for i in mesh_instance.get_surface_override_material_count():
        var override := mesh_instance.get_surface_override_material(i)
        if override:
            mesh_instance.set_surface_override_material(i, _material(override, modern))
        else:
            var own := mesh_instance.mesh.surface_get_material(i)
            if own:
                _material(own, modern)


## Devuelve el material que corresponde al modo (puede ser el mismo, ajustado).
static func _material(mat: Material, modern: bool) -> Material:
    if mat is ShaderMaterial:
        var shader_mat := mat as ShaderMaterial
        if modern and shader_mat.shader == RETRO_SHADER:
            if not _modern_of.has(shader_mat):
                _modern_of[shader_mat] = _make_modern(shader_mat)
            return _modern_of[shader_mat]
        if not modern and shader_mat.has_meta("retro_source"):
            return shader_mat.get_meta("retro_source")
    elif mat is BaseMaterial3D:
        # Personajes, objetos y manchas: pixelado en Retro, suave en Moderno.
        var base := mat as BaseMaterial3D
        if not base.has_meta("retro_filter"):
            base.set_meta("retro_filter", base.texture_filter)
        base.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC if modern else base.get_meta("retro_filter")
    return mat


static func _make_modern(retro: ShaderMaterial) -> ShaderMaterial:
    var mat := ShaderMaterial.new()
    mat.shader = MODERN_SHADER
    mat.render_priority = retro.render_priority
    for uniform: Dictionary in RETRO_SHADER.get_shader_uniform_list():
        var uname: String = uniform["name"]
        var value: Variant = retro.get_shader_parameter(uname)
        if value != null:
            mat.set_shader_parameter(uname, value)
    var albedo := retro.get_shader_parameter("albedo_tex") as Texture2D
    if albedo:
        var tex_name := albedo.resource_path.get_file().get_basename()
        var color_path := MODERN_TEX + tex_name + "_color.jpg"
        if ResourceLoader.exists(color_path):
            mat.set_shader_parameter("albedo_tex", load(color_path))
            mat.set_shader_parameter("normal_tex", load(MODERN_TEX + tex_name + "_normal.jpg"))
            mat.set_shader_parameter("rough_tex", load(MODERN_TEX + tex_name + "_rough.jpg"))
    mat.set_meta("retro_source", retro)
    return mat


static func _environment(env: Environment, modern: bool) -> Environment:
    if env == null:
        return env
    if not modern:
        return env.get_meta("retro_source") if env.has_meta("retro_source") else env
    if env.has_meta("retro_source"):
        return env
    if not _env_of.has(env):
        var hd := env.duplicate() as Environment
        hd.tonemap_mode = Environment.TONE_MAPPER_FILMIC
        hd.tonemap_exposure = 1.0
        hd.tonemap_white = 6.0
        # Las luces y sombras pesan más: algo menos de luz ambiente.
        hd.ambient_light_energy = env.ambient_light_energy * 0.8
        hd.glow_enabled = true
        hd.glow_intensity = 0.7
        hd.glow_bloom = 0.04
        hd.glow_hdr_threshold = 0.9
        hd.adjustment_enabled = true
        hd.adjustment_contrast = 1.08
        hd.adjustment_saturation = 1.06
        hd.set_meta("retro_source", env)
        _env_of[env] = hd
    return _env_of[env]


## Sombras solo en las luces más fuertes de la sala (presupuesto del teléfono).
static func _set_shadows(lights: Array[OmniLight3D], modern: bool) -> void:
    lights.sort_custom(func(a: OmniLight3D, b: OmniLight3D) -> bool:
        return a.light_energy * a.omni_range > b.light_energy * b.omni_range)
    for i in lights.size():
        var light := lights[i]
        light.shadow_enabled = modern and i < SHADOW_LIGHTS
        light.omni_shadow_mode = OmniLight3D.SHADOW_CUBE
        light.shadow_bias = 0.08
