extends SubViewportContainer
## Muestra el modelo 3D de un ítem en su propio mundo pequeño: se usa como
## ícono en las casillas de la mochila y en grande al examinar (se gira con el dedo).

@export var spin_speed: float = 0.6
@export var draggable: bool = false
@export var tilt: float = -0.35

var _viewport: SubViewport
var _pivot: Node3D
var _dragging := false


func _ready() -> void:
    stretch = true
    mouse_filter = Control.MOUSE_FILTER_STOP if draggable else Control.MOUSE_FILTER_IGNORE
    _viewport = SubViewport.new()
    _viewport.own_world_3d = true
    _viewport.transparent_bg = true
    add_child(_viewport)

    var environment := Environment.new()
    environment.background_mode = Environment.BG_CLEAR_COLOR
    environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    environment.ambient_light_color = Color(0.55, 0.55, 0.6)
    environment.ambient_light_energy = 0.7
    var world_environment := WorldEnvironment.new()
    world_environment.environment = environment
    _viewport.add_child(world_environment)

    var camera := Camera3D.new()
    camera.position = Vector3(0, 0, 2.6)
    camera.fov = 30.0
    _viewport.add_child(camera)

    var key_light := DirectionalLight3D.new()
    key_light.rotation = Vector3(-0.8, 0.6, 0.0)
    key_light.light_energy = 1.2
    key_light.light_color = Color(1.0, 0.93, 0.82)
    _viewport.add_child(key_light)
    var fill_light := DirectionalLight3D.new()
    fill_light.rotation = Vector3(-0.2, -2.4, 0.0)
    fill_light.light_energy = 0.5
    fill_light.light_color = Color(0.7, 0.78, 1.0)
    _viewport.add_child(fill_light)

    _pivot = Node3D.new()
    # Tres cuartos: se ve el largo y el costado del objeto.
    _pivot.rotation = Vector3(-tilt, 0.65, 0.0)
    _viewport.add_child(_pivot)


func set_item(item: ItemData) -> void:
    for child in _pivot.get_children():
        child.queue_free()
    if item == null or item.model == null:
        return
    var fit := Node3D.new()
    _pivot.add_child(fit)
    var model := item.model.instantiate() as Node3D
    fit.add_child(model)
    _fit(fit, model)


## Centra y escala el modelo para que llene la vista, sea del tamaño que sea.
func _fit(fit: Node3D, model: Node3D) -> void:
    var bounds := AABB()
    var first := true
    var to_fit := fit.global_transform.affine_inverse()
    for mesh_instance: MeshInstance3D in model.find_children("*", "MeshInstance3D", true, false):
        if mesh_instance.mesh == null or not mesh_instance.visible:
            continue
        var box := (to_fit * mesh_instance.global_transform) * mesh_instance.get_aabb()
        bounds = box if first else bounds.merge(box)
        first = false
    if first:
        return
    # La diagonal (no el lado más largo): así no se corta al girarlo.
    var size := maxf(bounds.size.length(), 0.001)
    var scale_factor := 1.2 / size
    fit.scale = Vector3.ONE * scale_factor
    fit.position = -bounds.get_center() * scale_factor


func _process(delta: float) -> void:
    if not _dragging:
        _pivot.rotation.y += spin_speed * delta


func _gui_input(event: InputEvent) -> void:
    if not draggable:
        return
    if event is InputEventScreenTouch:
        _dragging = event.pressed
    elif event is InputEventScreenDrag:
        _pivot.rotation.y += event.relative.x * 0.012
        _pivot.rotation.x = clampf(_pivot.rotation.x + event.relative.y * 0.012, -1.4, 1.4)
