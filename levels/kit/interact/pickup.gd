class_name Pickup
extends Interactable
## Ítem en el suelo o sobre un mueble. Muestra el modelo del ítem con un brillo
## que pulsa (para que se note en la cámara fija) y desaparece al recogerlo.
## Lo recogido queda anotado en GameState y no vuelve a aparecer.

@export var item: ItemData
@export var count: int = 1
## Giro del modelo sobre la superficie.
@export var model_rotation: Vector3 = Vector3.ZERO
## Bandera que se anota al recogerlo (p. ej. "found:pistol" hace aparecer infectados).
@export var sets_flag: String = ""

var _glint: MeshInstance3D
var _time := randf() * TAU


func _init() -> void:
    prompt = "RECOGER"
    reach = 1.2


func _ready() -> void:
    super()
    var left := int(GameState.get_flag(_flag_key(), count))
    if left <= 0:
        queue_free()
        return
    count = left
    if item and item.model:
        var model := item.model.instantiate() as Node3D
        model.rotation = model_rotation
        add_child(model)
    _glint = _make_glint()
    add_child(_glint)


func _process(delta: float) -> void:
    _time += delta
    var pulse := pow(maxf(sin(_time * 2.2), 0.0), 6.0)
    _glint.scale = Vector3.ONE * (0.4 + pulse * 0.8)
    _glint.visible = pulse > 0.02


func interact(player: Player) -> void:
    var space := GameState.inventory.space_for(item)
    if space <= 0:
        await Dialogue.say(["Es: %s." % _describe(count), "No me cabe nada más en la mochila."])
        return
    var taken := mini(count, space)
    GameState.inventory.add(item, taken)
    count -= taken
    GameState.set_flag(_flag_key(), count)
    Sfx.play("pickup", null, -4.0)
    if not sets_flag.is_empty():
        GameState.set_flag(sets_flag)
    var lines := ["Recogí: %s." % _describe(taken)]
    if item.kind == ItemData.Kind.WEAPON and GameState.equipped == null:
        # El arma encontrada viene cargada y queda lista para usar.
        GameState.equipped = item
        GameState.clip = item.weapon.clip_size
        player.combat.sync_from_state()
        lines.append("Está cargada. La llevo lista: mantén APUNTAR y toca DISPARAR.")
    if count > 0:
        lines.append("No me cabe el resto en la mochila.")
    else:
        visible = false
    await Dialogue.say(lines)
    if count <= 0:
        queue_free()


func _describe(amount: int) -> String:
    return item.display_name + (" (%d)" % amount if item.is_stackable() else "")


func _flag_key() -> String:
    return "left:" + GameState.node_key(self)


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
