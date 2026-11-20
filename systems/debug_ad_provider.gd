class_name DebugAdProvider
extends AdProvider
## Proveedor local para probar el flujo sin SDK ni conexión publicitaria.

var _active := false
var _overlay: CanvasLayer
var _countdown_label: Label
var _callback: Callable


func is_ready() -> bool:
    return not _active and Engine.get_main_loop() is SceneTree


func show(placement: StringName, on_done: Callable) -> void:
    var tree := Engine.get_main_loop() as SceneTree
    if tree == null or not is_ready():
        if on_done.is_valid():
            on_done.call(false)
        return

    _active = true
    _callback = on_done
    _overlay = CanvasLayer.new()
    _overlay.name = "DebugRewardedAd"
    _overlay.layer = 90
    _overlay.process_mode = Node.PROCESS_MODE_ALWAYS
    tree.root.add_child(_overlay)

    var shade := ColorRect.new()
    shade.color = Color(0.0, 0.0, 0.0, 0.92)
    shade.set_anchors_preset(Control.PRESET_FULL_RECT)
    shade.mouse_filter = Control.MOUSE_FILTER_STOP
    _overlay.add_child(shade)

    var panel := PanelContainer.new()
    panel.anchor_left = 0.5
    panel.anchor_top = 0.5
    panel.anchor_right = 0.5
    panel.anchor_bottom = 0.5
    panel.offset_left = -300.0
    panel.offset_top = -145.0
    panel.offset_right = 300.0
    panel.offset_bottom = 145.0
    _overlay.add_child(panel)

    var layout := VBoxContainer.new()
    layout.add_theme_constant_override("separation", 18)
    panel.add_child(layout)

    var title := Label.new()
    title.text = "ANUNCIO DE PRUEBA"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 32)
    title.custom_minimum_size = Vector2(0, 58)
    layout.add_child(title)

    _countdown_label = Label.new()
    _countdown_label.text = "Preparando anuncio…"
    _countdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _countdown_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    _countdown_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    _countdown_label.custom_minimum_size = Vector2(0, 64)
    _countdown_label.add_theme_font_size_override("font_size", 24)
    layout.add_child(_countdown_label)

    var skip := Button.new()
    skip.text = "SALTAR"
    skip.custom_minimum_size = Vector2(0, 72)
    skip.add_theme_font_size_override("font_size", 26)
    skip.pressed.connect(_finish.bind(false))
    layout.add_child(skip)

    _countdown.call_deferred(placement)


func _countdown(placement: StringName) -> void:
    var tree := Engine.get_main_loop() as SceneTree
    if tree == null:
        _finish(false)
        return
    for seconds_left in range(3, 0, -1):
        if not _active:
            return
        _countdown_label.text = "Ubicación: %s\nLa recompensa estará lista en %d s" % [String(placement), seconds_left]
        await tree.create_timer(1.0, true).timeout
    _finish(true)


func _finish(rewarded: bool) -> void:
    if not _active:
        return
    _active = false
    var callback := _callback
    _callback = Callable()
    if is_instance_valid(_overlay):
        _overlay.queue_free()
    if callback.is_valid():
        callback.call(rewarded)
