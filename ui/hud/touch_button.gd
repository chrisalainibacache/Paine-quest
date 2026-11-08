extends Control
## Botón táctil redondo que mantiene presionada una acción de entrada mientras
## el dedo está encima (multitáctil: funciona a la vez que el stick).

@export var action: StringName = &"fire"
@export var label: String = "DISPARAR"
@export var radius: float = 70.0
@export var color: Color = Color(0.85, 0.82, 0.75)

var _touch_index := -1


func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    custom_minimum_size = Vector2(radius, radius) * 2.0
    size = custom_minimum_size


func _input(event: InputEvent) -> void:
    if not is_visible_in_tree():
        if _touch_index != -1:
            _release()
        return
    if event is InputEventScreenTouch:
        var touch := event as InputEventScreenTouch
        if touch.pressed and _touch_index == -1 and _contains(touch.position):
            _touch_index = touch.index
            Input.action_press(action)
            queue_redraw()
            get_viewport().set_input_as_handled()
        elif not touch.pressed and touch.index == _touch_index:
            _release()


func is_pressed() -> bool:
    return _touch_index != -1


func _release() -> void:
    _touch_index = -1
    Input.action_release(action)
    queue_redraw()


func _contains(screen_position: Vector2) -> bool:
    var center := get_global_rect().get_center()
    return screen_position.distance_to(center) <= radius * 1.15


func _draw() -> void:
    var center := size * 0.5
    var pressed := _touch_index != -1
    draw_circle(center, radius, Color(color, 0.32 if pressed else 0.14))
    draw_arc(center, radius, 0.0, TAU, 48, Color(color, 0.7), 3.0)
    var font := get_theme_default_font()
    var font_size := int(clampf(radius * 0.3, 14.0, 22.0))
    var text_size := font.get_string_size(label, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
    draw_string(font, center + Vector2(-text_size.x * 0.5, text_size.y * 0.3), label,
        HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, Color(color, 0.9))
