class_name CodeLock
extends Interactable
## Cerradura numérica táctil. La solución y la bandera que abre se guardan
## en PuzzleState/GameState; no depende de que la sala siga cargada.

signal _pad_result(code: String)

@export var puzzle: PuzzleData
@export var unlock_id: String = ""
@export_multiline var solved_text: String = "La cerradura cedió."
@export_multiline var failed_text: String = "El código no es correcto."

var _entered_code := ""
var _display: Label
var _pad_layer: CanvasLayer
var _paused_before := false


func _init() -> void:
    prompt = "INTRODUCIR CÓDIGO"
    reach = 1.4


func can_interact() -> bool:
    return puzzle != null and puzzle.is_valid() and not PuzzleState.is_code_solved(puzzle.id)


func interact(_player: Player) -> void:
    if puzzle == null or not puzzle.is_valid():
        await Dialogue.say(["El teclado no responde."])
        return
    if PuzzleState.is_code_solved(puzzle.id):
        await Dialogue.say(["La cerradura ya está abierta."])
        return
    var code: String = await _open_pad()
    if code.is_empty():
        return
    if code != puzzle.code:
        Sfx.play("locked", global_position, -4.0)
        await Dialogue.say([failed_text])
        return
    PuzzleState.set_code_solved(puzzle.id)
    if not unlock_id.is_empty():
        GameState.set_flag("unlocked:" + unlock_id)
    Sfx.play("unlock", global_position, -4.0)
    await Dialogue.say([solved_text])


func _open_pad() -> String:
    _entered_code = ""
    _paused_before = get_tree().paused
    get_tree().paused = true
    _pad_layer = CanvasLayer.new()
    _pad_layer.name = "CodeLockPad"
    _pad_layer.layer = 70
    _pad_layer.process_mode = Node.PROCESS_MODE_ALWAYS
    get_tree().root.add_child(_pad_layer)

    var backdrop := ColorRect.new()
    backdrop.color = Color(0.015, 0.012, 0.01, 0.88)
    backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
    _pad_layer.add_child(backdrop)

    var center := CenterContainer.new()
    center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    _pad_layer.add_child(center)

    var panel := PanelContainer.new()
    panel.theme = preload("res://ui/theme/paine_theme.tres")
    panel.custom_minimum_size = Vector2(560, 500)
    center.add_child(panel)

    var margin := MarginContainer.new()
    margin.add_theme_constant_override("margin_left", 24)
    margin.add_theme_constant_override("margin_right", 24)
    margin.add_theme_constant_override("margin_top", 20)
    margin.add_theme_constant_override("margin_bottom", 20)
    panel.add_child(margin)

    var column := VBoxContainer.new()
    column.add_theme_constant_override("separation", 12)
    margin.add_child(column)

    var title := Label.new()
    title.text = "CERRADURA DE CÓDIGO"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 30)
    column.add_child(title)

    _display = Label.new()
    _display.text = "— — —"
    _display.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _display.add_theme_font_size_override("font_size", 38)
    column.add_child(_display)

    var grid := GridContainer.new()
    grid.columns = 3
    grid.add_theme_constant_override("h_separation", 10)
    grid.add_theme_constant_override("v_separation", 10)
    column.add_child(grid)
    for digit in ["1", "2", "3", "4", "5", "6", "7", "8", "9", "BORRAR", "0", "LIMPIAR"]:
        var button := Button.new()
        button.text = digit
        button.custom_minimum_size = Vector2(145, 66)
        button.add_theme_font_size_override("font_size", 26)
        grid.add_child(button)
        var selected_digit: String = digit
        button.pressed.connect(func() -> void: _on_pad_button(selected_digit))

    var actions := HBoxContainer.new()
    actions.add_theme_constant_override("separation", 12)
    column.add_child(actions)
    var accept := Button.new()
    accept.text = "ACEPTAR"
    accept.custom_minimum_size = Vector2(220, 68)
    accept.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    accept.pressed.connect(func() -> void: _pad_result.emit(_entered_code))
    actions.add_child(accept)
    var cancel := Button.new()
    cancel.text = "CANCELAR"
    cancel.custom_minimum_size = Vector2(180, 68)
    cancel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    cancel.pressed.connect(func() -> void: _pad_result.emit(""))
    actions.add_child(cancel)

    var result: String = await _pad_result
    _pad_layer.queue_free()
    _pad_layer = null
    _display = null
    get_tree().paused = _paused_before
    return result


func _on_pad_button(value: String) -> void:
    if value == "LIMPIAR":
        _entered_code = ""
    elif value == "BORRAR":
        if not _entered_code.is_empty():
            _entered_code = _entered_code.substr(0, _entered_code.length() - 1)
    elif _entered_code.length() < 6:
        _entered_code += value
    if _display:
        var spaced := ""
        for index in _entered_code.length():
            if index > 0:
                spaced += " "
            spaced += _entered_code.substr(index, 1)
        _display.text = spaced if not spaced.is_empty() else "— — —"
