@tool
extends MeshInstance3D
## Calcomanía en un muro o en el piso (grafiti, sangre, hoyo, grieta, mancha).
## El plano mira hacia +Z local: en un muro, se gira para que +Z apunte hacia
## la sala; en el piso, se inclina -90° en X.

const SHADER := preload("res://shaders/decal.gdshader")

@export var texture: Texture2D:
    set(value):
        texture = value
        _apply()
@export var size: Vector2 = Vector2.ONE:
    set(value):
        size = value
        _apply()
@export var tint: Color = Color.WHITE:
    set(value):
        tint = value
        _apply()
@export_range(0.0, 1.0) var opacity: float = 1.0:
    set(value):
        opacity = value
        _apply()
## Cuánto se gastó la pintura (0 = nueva).
@export_range(0.0, 1.0) var wear: float = 0.0:
    set(value):
        wear = value
        _apply()


func _ready() -> void:
    cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    _apply()


func _apply() -> void:
    if not is_inside_tree() and not Engine.is_editor_hint():
        return
    var quad := mesh as QuadMesh
    if quad == null:
        quad = QuadMesh.new()
        mesh = quad
    quad.size = size
    var material := material_override as ShaderMaterial
    if material == null:
        material = ShaderMaterial.new()
        material.shader = SHADER
        material_override = material
    material.set_shader_parameter("albedo_tex", texture)
    material.set_shader_parameter("tint", tint)
    material.set_shader_parameter("opacity", opacity)
    material.set_shader_parameter("wear", wear)
    material.set_shader_parameter("seed", float(hash(name)) / 4294967296.0 * 100.0)
