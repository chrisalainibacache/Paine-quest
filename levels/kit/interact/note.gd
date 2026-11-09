extends Interactable
## Nota o documento legible. Al leerla queda guardada en NOTAS de la mochila.
## Se reconoce por proximidad y tiene un destello pulsante compartido por todos los documentos.

@export var document: DocumentData

var _glint: MeshInstance3D
var _time := randf() * TAU


func _init() -> void:
    prompt = "LEER"
    reach = 1.4
    requires_facing = false


func _ready() -> void:
    super()
    _glint = _make_glint()
    add_child(_glint)


func _process(delta: float) -> void:
    _time += delta
    var pulse := pow(maxf(sin(_time * 2.2), 0.0), 6.0)
    _glint.scale = Vector3.ONE * (0.4 + pulse * 0.8)
    _glint.visible = pulse > 0.02


func interact(_player: Player) -> void:
    if document == null or document.pages.is_empty():
        push_warning("La nota %s no tiene contenido." % name)
        return
    Sfx.play("page", null, -6.0)
    var added := GameState.add_document(document)
    await Dialogue.read(document)
    if added:
        await Dialogue.say(["«%s» quedó guardada en NOTAS." % document.title])


func _make_glint() -> MeshInstance3D:
    var quad := QuadMesh.new()
    quad.size = Vector2(0.22, 0.22)
    var gradient := Gradient.new()
    gradient.set_color(0, Color(1.0, 0.95, 0.75, 1.0))
    gradient.set_color(1, Color(1.0, 0.9, 0.6, 0.0))
    var texture := GradientTexture2D.new()
    texture.gradient = gradient
    texture.fill = GradientTexture2D.FILL_RADIAL
    texture.fill_from = Vector2(0.5, 0.5)
    texture.fill_to = Vector2(0.5, 0.0)
    texture.width = 32
    texture.height = 32
    var material := StandardMaterial3D.new()
    material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
    material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
    material.no_depth_test = true
    material.albedo_texture = texture
    var glint := MeshInstance3D.new()
    glint.mesh = quad
    glint.material_override = material
    glint.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    glint.position = Vector3(0, 0.08, 0)
    return glint
