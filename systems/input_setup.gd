extends Node
## Autoload: registra las acciones de entrada del juego (teclado, mando y las
## que alimentan los controles táctiles). Un solo lugar para cambiar teclas.

const KEYS := {
    &"move_left": [KEY_A, KEY_LEFT],
    &"move_right": [KEY_D, KEY_RIGHT],
    &"move_forward": [KEY_W, KEY_UP],
    &"move_back": [KEY_S, KEY_DOWN],
    &"aim": [KEY_K, KEY_SHIFT],
    &"fire": [KEY_J, KEY_SPACE],
    &"interact": [KEY_E, KEY_ENTER],
    &"inventory": [KEY_I, KEY_TAB],
}
const BUTTONS := {
    &"aim": JOY_BUTTON_LEFT_SHOULDER,
    &"fire": JOY_BUTTON_RIGHT_SHOULDER,
    &"interact": JOY_BUTTON_A,
    &"inventory": JOY_BUTTON_Y,
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
        if AXES.has(action):
            var axis := InputEventJoypadMotion.new()
            axis.axis = AXES[action][0]
            axis.axis_value = AXES[action][1]
            InputMap.action_add_event(action, axis)
        if BUTTONS.has(action):
            var button := InputEventJoypadButton.new()
            button.button_index = BUTTONS[action]
            InputMap.action_add_event(action, button)
