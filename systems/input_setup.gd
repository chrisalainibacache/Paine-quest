extends Node
## Autoload: registra las acciones de entrada del juego (teclado, mando y las
## que alimentan los controles táctiles). Un solo lugar para cambiar teclas.

const KEYS := {
    &"move_left": [KEY_A, KEY_LEFT],
    &"move_right": [KEY_D, KEY_RIGHT],
    &"move_forward": [KEY_W, KEY_UP],
    &"move_back": [KEY_S, KEY_DOWN],
}
const AXES := {
    &"move_left": [JOY_AXIS_LEFT_X, -1.0],
    &"move_right": [JOY_AXIS_LEFT_X, 1.0],
    &"move_forward": [JOY_AXIS_LEFT_Y, -1.0],
    &"move_back": [JOY_AXIS_LEFT_Y, 1.0],
}


func _enter_tree() -> void:
    for action: StringName in KEYS:
        if InputMap.has_action(action):
            continue
        InputMap.add_action(action, 0.15)
        for key: Key in KEYS[action]:
            var event := InputEventKey.new()
            event.physical_keycode = key
            InputMap.action_add_event(action, event)
        var axis := InputEventJoypadMotion.new()
        axis.axis = AXES[action][0]
        axis.axis_value = AXES[action][1]
        InputMap.action_add_event(action, axis)
