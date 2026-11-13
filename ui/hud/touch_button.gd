extends Control
## Botón táctil redondo que mantiene presionada una acción de entrada mientras
## el dedo está encima (multitáctil: funciona a la vez que el stick).

@export var action: StringName = &"fire"
@export var label: String = "DISPARAR"
@export var radius: float = 70.0
@export var color: Color = Color(0.85, 0.82, 0.75)
## Aunque el dedo suba antes, la acción queda presionada al menos esto (segundos):
## en un celular lento un toque corto puede empezar y terminar entre dos cuadros.
const MIN_HOLD := 0.16

## Al tocar el botón (no depende de que el motor revise la acción a tiempo).
signal tapped

var _touch_index := -1
var _pressed_at := 0.0
var _release_token := 0


func _ready() -> void:
    # Sigue recibiendo toques en pausa para soltar la acción al levantar el
    # dedo (si no, quedaría "presionada" al cerrar un menú).
    process_mode = Node.PROCESS_MODE_ALWAYS
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
        if touch.pressed and _touch_index == -1 and not get_tree().paused and _contains(touch.position):
            _touch_index = touch.index
            _pressed_at = Time.get_ticks_msec() / 1000.0
            _release_token += 1
            Input.action_press(action)
            queue_redraw()
            tapped.emit()
            get_viewport().set_input_as_handled()
        elif not touch.pressed and touch.index == _touch_index:
            _release()


func is_pressed() -> bool:
    return _touch_index != -1


func _release() -> void:
    _touch_index = -1
    queue_redraw()
    var held := Time.get_ticks_msec() / 1000.0 - _pressed_at
    if held >= MIN_HOLD:
        Input.action_release(action)
        return
    # Toque corto: mantiene la acción lo que falta (a menos que lo vuelvan a tocar).
    _release_token += 1
    var token := _release_token
    await get_tree().create_timer(MIN_HOLD - held, true, false, true).timeout
    if token == _release_token and _touch_index == -1:
        Input.action_release(action)


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
