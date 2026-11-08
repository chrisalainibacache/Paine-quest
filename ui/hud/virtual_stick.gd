extends Control
## Stick virtual flotante: se toca en cualquier parte de la mitad izquierda de
## la pantalla y el centro aparece bajo el dedo. Empujar poco = caminar,
## empujar a fondo = trotar.

const RADIUS := 110.0
const DEAD_ZONE := 0.12
const RING_COLOR := Color(0.85, 0.82, 0.75, 0.35)
const KNOB_COLOR := Color(0.9, 0.86, 0.78, 0.55)

var _touch_index := -1
var _center := Vector2.ZERO
var _knob := Vector2.ZERO
var _vector := Vector2.ZERO


func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    set_anchors_preset(Control.PRESET_FULL_RECT)


func _input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        var touch := event as InputEventScreenTouch
        if touch.pressed and _touch_index == -1 and touch.position.x < get_viewport_rect().size.x * 0.5:
            _touch_index = touch.index
            _center = touch.position
            _set_knob(touch.position)
        elif not touch.pressed and touch.index == _touch_index:
            _release()
    elif event is InputEventScreenDrag:
        var drag := event as InputEventScreenDrag
        if drag.index == _touch_index:
            _set_knob(drag.position)


func get_vector() -> Vector2:
    return _vector


func _set_knob(position_on_screen: Vector2) -> void:
    var offset := (position_on_screen - _center).limit_length(RADIUS)
    _knob = _center + offset
    var value := offset / RADIUS
    _vector = value if value.length() > DEAD_ZONE else Vector2.ZERO
    _apply(&"move_left", maxf(-_vector.x, 0.0))
    _apply(&"move_right", maxf(_vector.x, 0.0))
    _apply(&"move_forward", maxf(-_vector.y, 0.0))
    _apply(&"move_back", maxf(_vector.y, 0.0))
    queue_redraw()


func _release() -> void:
    _touch_index = -1
    _vector = Vector2.ZERO
    for action in [&"move_left", &"move_right", &"move_forward", &"move_back"]:
        Input.action_release(action)
    queue_redraw()


func _apply(action: StringName, strength: float) -> void:
    if strength > 0.0:
        Input.action_press(action, strength)
    else:
        Input.action_release(action)


func _draw() -> void:
    var size_px := get_viewport_rect().size
    var center := _center if _touch_index != -1 else Vector2(RADIUS + 70.0, size_px.y - RADIUS - 60.0)
    var knob := _knob if _touch_index != -1 else center
    var alpha := 1.0 if _touch_index != -1 else 0.5
    draw_arc(center, RADIUS, 0.0, TAU, 48, RING_COLOR * Color(1, 1, 1, alpha), 3.0)
    draw_circle(knob, 42.0, KNOB_COLOR * Color(1, 1, 1, alpha))
