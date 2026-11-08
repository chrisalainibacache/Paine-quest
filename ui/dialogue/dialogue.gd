class_name Dialogue
extends CanvasLayer
## Mensajes en pantalla (caja de texto abajo), preguntas con opciones y lector
## de documentos. Mientras está abierto, el juego queda en pausa.
## Uso desde cualquier script: await Dialogue.say([...]),
## var opcion := await Dialogue.ask("¿...?", ["SÍ", "NO"]), await Dialogue.read(doc).

signal _advanced
signal _chosen(index: int)

const CHARS_PER_SECOND := 55.0
## Tiempo en que se ignoran toques (evita saltarse un mensaje con el mismo toque que lo abrió).
const INPUT_GRACE := 0.18

static var _instance: Dialogue

@onready var blocker: Control = $Blocker
@onready var box: Control = $Box
@onready var text: Label = $Box/Margin/Text
@onready var next_mark: Label = $Box/Next
@onready var choices: VBoxContainer = $Choices
@onready var reader: Control = $Reader
@onready var reader_title: Label = $Reader/Paper/Title
@onready var reader_body: Label = $Reader/Paper/Body
@onready var reader_page: Label = $Reader/Paper/Page

var _depth := 0
var _paused_before := false
var _grace := 0.0
var _asking := false
var _reveal := 0.0


func _ready() -> void:
    _instance = self
    process_mode = Node.PROCESS_MODE_ALWAYS
    box.visible = false
    choices.visible = false
    reader.visible = false
    blocker.visible = false


static func is_open() -> bool:
    return _instance != null and _instance._depth > 0


static func say(lines: Variant) -> void:
    if _instance:
        await _instance._say(lines)


static func ask(question: String, options: Array) -> int:
    if _instance == null:
        return -1
    return await _instance._ask(question, options)


static func read(document: DocumentData) -> void:
    if _instance:
        await _instance._read(document)


## Para las pruebas: avanzar el mensaje o elegir una opción sin tocar la pantalla.
static func advance() -> void:
    if _instance:
        _instance._advance(true)


static func choose(index: int) -> void:
    if _instance and _instance._asking:
        _instance._chosen.emit(index)


func _say(lines: Variant) -> void:
    _begin()
    box.visible = true
    for line: String in lines:
        _show_text(line)
        await _advanced
    box.visible = false
    _end()


func _ask(question: String, options: Array) -> int:
    _begin()
    box.visible = true
    _show_text(question)
    _reveal = 1.0
    text.visible_ratio = 1.0
    for child in choices.get_children():
        child.queue_free()
    for i in options.size():
        var button := Button.new()
        button.text = options[i]
        button.custom_minimum_size = Vector2(240, 70)
        button.add_theme_font_size_override("font_size", 28)
        button.pressed.connect(func() -> void: _chosen.emit(i))
        choices.add_child(button)
    choices.visible = true
    _asking = true
    var index: int = await _chosen
    _asking = false
    Sfx.play("menu", null, -8.0)
    choices.visible = false
    box.visible = false
    _end()
    return index


func _read(document: DocumentData) -> void:
    _begin()
    reader.visible = true
    reader_title.text = document.title
    var total := document.pages.size()
    for i in total:
        reader_body.text = document.pages[i]
        reader_page.text = "%d / %d" % [i + 1, total] if total > 1 else ""
        _grace = INPUT_GRACE
        await _advanced
        Sfx.play("page", null, -10.0)
    reader.visible = false
    _end()


func _begin() -> void:
    if _depth == 0:
        _paused_before = get_tree().paused
        get_tree().paused = true
    _depth += 1
    blocker.visible = true


func _end() -> void:
    _depth -= 1
    if _depth == 0:
        get_tree().paused = _paused_before
        # Un cuadro después: el toque que cerró la nota no debe llegar a la mochila.
        _hide_blocker.call_deferred()


func _hide_blocker() -> void:
    await get_tree().process_frame
    if _depth == 0:
        blocker.visible = false


func _show_text(line: String) -> void:
    text.text = line
    text.visible_ratio = 0.0
    _reveal = 0.0
    _grace = INPUT_GRACE
    next_mark.visible = false


func _process(delta: float) -> void:
    _grace = maxf(_grace - delta, 0.0)
    if box.visible and _reveal < 1.0:
        var length := maxi(text.text.length(), 1)
        _reveal = minf(_reveal + delta * CHARS_PER_SECOND / length, 1.0)
        text.visible_ratio = _reveal
    next_mark.visible = box.visible and _reveal >= 1.0 and not _asking and fmod(Time.get_ticks_msec() / 400.0, 2.0) < 1.4
    if _depth > 0 and (Input.is_action_just_pressed(&"interact") or Input.is_action_just_pressed(&"ui_accept")):
        _advance(false)


func _input(event: InputEvent) -> void:
    if _depth > 0 and not _asking and event is InputEventScreenTouch and event.pressed:
        _advance(false)
        get_viewport().set_input_as_handled()


func _advance(forced: bool) -> void:
    if _asking or _depth == 0 or (_grace > 0.0 and not forced):
        return
    if box.visible and _reveal < 1.0:
        # Primer toque: muestra el texto completo.
        _reveal = 1.0
        text.visible_ratio = 1.0
        _grace = INPUT_GRACE
        return
    _advanced.emit()
