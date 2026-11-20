class_name VideoCinematic
extends CanvasLayer
## Cinemática de video (Ogg Theora) a pantalla completa, con título opcional al final.
## Uso: await VideoCinematic.play(self, "res://assets/video/intro.ogv", "PAINE", "Viernes · 23:40")
## Si el archivo no existe o no se puede leer, no hace nada (el juego sigue). Se salta con un toque
## después de SKIP_AFTER segundos.

signal finished

const SKIP_AFTER := 1.0
const TITLE_FADE := 0.9
const TITLE_HOLD := 1.8

var _stream: VideoStream
var _title := ""
var _subtitle := ""
var _player: VideoStreamPlayer
var _veil: ColorRect
var _title_label: Label
var _subtitle_label: Label
var _elapsed := 0.0
var _done := false
var _titled := false


## Reproduce la cinemática y espera a que termine (o la salten).
static func play(host: Node, path: String, title := "", subtitle := "") -> void:
    if not ResourceLoader.exists(path):
        return
    var stream := load(path) as VideoStream
    if stream == null:
        push_warning("VideoCinematic: no se pudo leer %s" % path)
        return
    var node := VideoCinematic.new()
    node._stream = stream
    node._title = title
    node._subtitle = subtitle
    host.add_child(node)
    await node.finished
    node.queue_free()


func _ready() -> void:
    layer = 50
    process_mode = Node.PROCESS_MODE_ALWAYS
    var black := ColorRect.new()
    black.color = Color.BLACK
    black.set_anchors_preset(Control.PRESET_FULL_RECT)
    add_child(black)
    _player = VideoStreamPlayer.new()
    _player.stream = _stream
    _player.expand = true
    _player.bus = &"Sfx"
    _player.finished.connect(_on_video_finished)
    add_child(_player)
    _cover()
    get_viewport().size_changed.connect(_cover)
    _veil = ColorRect.new()
    _veil.color = Color(0, 0, 0, 0)
    _veil.set_anchors_preset(Control.PRESET_FULL_RECT)
    _veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(_veil)
    _title_label = _make_label(_title, 110, 0.0)
    _subtitle_label = _make_label(_subtitle, 30, 90.0)
    _player.play()


## Escala el video para cubrir la pantalla sin deformarlo (se recortan un poco los costados).
func _cover() -> void:
    if _stream == null or _player == null:
        return
    var screen := get_viewport().get_visible_rect().size
    var video_aspect := 1280.0 / 544.0
    var height := screen.y
    var width := height * video_aspect
    if width < screen.x:
        width = screen.x
        height = width / video_aspect
    _player.size = Vector2(width, height)
    _player.position = (screen - _player.size) * 0.5


func _make_label(text: String, font_size: int, y_offset: float) -> Label:
    var label := Label.new()
    label.text = text
    label.set_anchors_preset(Control.PRESET_FULL_RECT)
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    label.position.y = y_offset
    label.add_theme_font_size_override("font_size", font_size)
    label.add_theme_color_override("font_color", Color(0.93, 0.88, 0.75))
    label.add_theme_color_override("font_outline_color", Color(0.02, 0.02, 0.02))
    label.add_theme_constant_override("outline_size", 10)
    label.modulate.a = 0.0
    label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(label)
    return label


func _process(delta: float) -> void:
    _elapsed += delta


func _input(event: InputEvent) -> void:
    if _done or _elapsed < SKIP_AFTER:
        return
    if (event is InputEventScreenTouch and event.pressed) or (event is InputEventMouseButton and event.pressed) \
            or (event is InputEventKey and event.pressed):
        get_viewport().set_input_as_handled()
        _end_video()


func _on_video_finished() -> void:
    _end_video()


func _end_video() -> void:
    if _titled:
        return
    _titled = true
    _player.stop()
    # Título sobre negro y salida.
    _veil.color.a = 1.0
    var tween := create_tween()
    tween.tween_property(_title_label, "modulate:a", 1.0, TITLE_FADE)
    tween.parallel().tween_property(_subtitle_label, "modulate:a", 0.85, TITLE_FADE)
    tween.tween_interval(TITLE_HOLD)
    tween.tween_property(_title_label, "modulate:a", 0.0, 0.7)
    tween.parallel().tween_property(_subtitle_label, "modulate:a", 0.0, 0.7)
    tween.tween_callback(func() -> void:
        _done = true
        finished.emit())
