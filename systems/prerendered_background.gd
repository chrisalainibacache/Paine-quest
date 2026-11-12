extends Node
## Fondos prerenderizados (modo Moderno): si existen imágenes en
## assets/backgrounds/<sala>/<Cámara>.png, la sala se muestra como en RE3:
## una "foto" por cámara fija y los personajes en 3D encima. La geometría de la
## sala sigue ahí (choques y oclusión) pero se pinta con la imagen (shader de
## proyección). Se instala como hijo de la sala y se quita al volver a Retro.

const SHADER := preload("res://shaders/prerendered_projection.gdshader")
const DIR := "res://assets/backgrounds/%s/"
const IMAGE_ASPECT := 1680.0 / 720.0

var room: Room
var _material: ShaderMaterial
var _textures := {}
var _saved_overrides := {}
var _hidden := []
var _shadow_lights := []
var _env_node: WorldEnvironment
var _saved_env: Environment
var _canvas: CanvasLayer
var _backdrop: TextureRect


## Deja la sala con o sin fondo prerenderizado según el modo.
static func sync(target: Room, modern: bool, brightness: float) -> void:
    var existing := target.get_node_or_null("PrerenderedBackground")
    if existing:
        existing.teardown()
        target.remove_child(existing)
        existing.free()
    if not modern or not has_backgrounds(target):
        return
    var node: Node = load("res://systems/prerendered_background.gd").new()
    node.name = "PrerenderedBackground"
    target.add_child(node)
    node.setup(target, brightness)


static func has_backgrounds(target: Room) -> bool:
    var dir := DIR % target.scene_file_path.get_file().get_basename()
    for zone: Node in target.find_children("*", "CameraZone", true, false):
        if ResourceLoader.exists(dir + zone.name + ".png"):
            return true
    return false


func setup(target: Room, brightness: float) -> void:
    room = target
    var dir := DIR % room.scene_file_path.get_file().get_basename()
    for zone: Node in room.find_children("*", "CameraZone", true, false):
        if ResourceLoader.exists(dir + zone.name + ".png"):
            _textures[zone.name] = load(dir + zone.name + ".png")
    _material = ShaderMaterial.new()
    _material.shader = SHADER
    _material.set_shader_parameter("image_aspect", IMAGE_ASPECT)
    _project_geometry(room)
    # Luces: solo iluminan a los personajes; sin sombras (no se verían).
    for light: Light3D in room.find_children("*", "Light3D", true, false):
        if light.shadow_enabled:
            _shadow_lights.append(light)
            light.shadow_enabled = false
    # Ambiente neutro: la imagen ya trae su tono final.
    _env_node = room.get_node_or_null("Environment") as WorldEnvironment
    if _env_node:
        _saved_env = _env_node.environment
        var env := _saved_env.duplicate() as Environment
        env.tonemap_mode = Environment.TONE_MAPPER_LINEAR
        env.tonemap_exposure = 1.0
        env.glow_enabled = false
        env.adjustment_enabled = true
        env.adjustment_brightness = brightness
        env.adjustment_contrast = 1.0
        env.adjustment_saturation = 1.0
        env.background_mode = Environment.BG_CANVAS
        env.background_canvas_max_layer = -1
        _env_node.environment = env
    _canvas = CanvasLayer.new()
    _canvas.layer = -1
    _backdrop = TextureRect.new()
    _backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
    _backdrop.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    _backdrop.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
    _backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _canvas.add_child(_backdrop)
    add_child(_canvas)
    room.camera_changed.connect(_on_camera_changed)
    get_viewport().size_changed.connect(_update_aspect)
    _update_aspect()
    var camera := get_viewport().get_camera_3d()
    if camera:
        _on_camera_changed(camera)


func teardown() -> void:
    for node: GeometryInstance3D in _saved_overrides:
        if is_instance_valid(node):
            node.material_override = _saved_overrides[node]
    _saved_overrides.clear()
    for node: Node3D in _hidden:
        if is_instance_valid(node):
            node.visible = true
    _hidden.clear()
    for light: Light3D in _shadow_lights:
        if is_instance_valid(light):
            light.shadow_enabled = true
    _shadow_lights.clear()
    if _env_node and is_instance_valid(_env_node) and _saved_env:
        _env_node.environment = _saved_env
    if room and room.camera_changed.is_connected(_on_camera_changed):
        room.camera_changed.disconnect(_on_camera_changed)
    if get_viewport() and get_viewport().size_changed.is_connected(_update_aspect):
        get_viewport().size_changed.disconnect(_update_aspect)


## Todo lo fijo de la sala pasa a mostrar la imagen; lo que se mueve o se
## recoge (infectados, ítems, fuego) sigue en 3D normal.
func _project_geometry(node: Node) -> void:
    if node.name in ["Enemies", "Interactables"] or node is GPUParticles3D or node is CPUParticles3D:
        return
    if node is Label3D or node is Sprite3D:
        if (node as Node3D).visible:
            (node as Node3D).visible = false
            _hidden.append(node)
    elif node is GeometryInstance3D:
        var geo := node as GeometryInstance3D
        _saved_overrides[geo] = geo.material_override
        geo.material_override = _material
    for i in node.get_child_count(true):
        _project_geometry(node.get_child(i, true))


func _on_camera_changed(camera: Camera3D) -> void:
    var zone_name := String(camera.get_parent().name) if camera.get_parent() else ""
    var texture: Texture2D = _textures.get(zone_name)
    if texture == null:
        return
    _material.set_shader_parameter("background", texture)
    _backdrop.texture = texture


func _update_aspect() -> void:
    var size := get_viewport().get_visible_rect().size
    if size.y > 0.0:
        _material.set_shader_parameter("screen_aspect", size.x / size.y)
