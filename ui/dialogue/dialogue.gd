class_name Dialogue
extends CanvasLayer
## Mensajes en pantalla (caja de texto abajo), preguntas con opciones y lector
## de documentos. Mientras está abierto, el juego queda en pausa.
## Uso desde cualquier script: await Dialogue.say([...]),
## var opcion := await Dialogue.ask("¿...?", ["SÍ", "NO"]), await Dialogue.read(doc).

signal _advanced
signal _chosen(index: int)
signal _reader_closed

const CHARS_PER_SECOND := 55.0
## Tiempo en que se ignoran toques (evita saltarse un mensaje con el mismo toque que lo abrió).
const INPUT_GRACE := 0.18

static var _instance: Dialogue

@onready var blocker: Control = $Blocker
@onready var box: Control = $Box
@onready var text: Label = $Box/Margin/Text
@onready var next_mark: Label = $Box/Next
@onready var speaker: Label = $Box/Speaker
@onready var choices: VBoxContainer = $Choices
@onready var reader: Control = $Reader
@onready var reader_title: Label = $Reader/Paper/Title
@onready var reader_body: Label = $Reader/Paper/Body
@onready var reader_page: Label = $Reader/Paper/Page
@onready var reader_previous: Button = $Reader/Paper/Previous
@onready var reader_next: Button = $Reader/Paper/Next
@onready var reader_close: Button = $Reader/Paper/Close

var _depth := 0
var _paused_before := false
var _grace := 0.0
var _asking := false
var _reveal := 0.0
var _reader_document: DocumentData
## Páginas ya ajustadas al papel (una página larga se parte en varias).
var _reader_pages := PackedStringArray()
var _reader_page_index := 0


func _ready() -> void:
    _instance = self
    process_mode = Node.PROCESS_MODE_ALWAYS
    box.visible = false
    choices.visible = false
    reader.visible = false
    reader_previous.pressed.connect(_previous_reader_page)
    reader_next.pressed.connect(_next_reader_page)
    reader_close.pressed.connect(_close_reader)
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
    if document == null or document.pages.is_empty():
        push_warning("Se intentó abrir una nota sin contenido.")
        return
    _begin()
    _reader_document = document
    _reader_pages = fit_pages(document.pages)
    _reader_page_index = 0
    _grace = INPUT_GRACE
    _refresh_reader_page()
    reader.visible = true
    await _reader_closed
    reader.visible = false
    _reader_document = null
    _end()


func _refresh_reader_page() -> void:
    if _reader_document == null:
        return
    var total := _reader_pages.size()
    reader_title.text = _reader_document.title
    reader_body.text = _reader_pages[_reader_page_index]
    reader_page.text = "%d / %d" % [_reader_page_index + 1, total] if total > 1 else ""
    reader_previous.disabled = _reader_page_index == 0
    # En la última página queda solo CERRAR (antes salían dos).
    reader_next.visible = _reader_page_index < total - 1


## Reparte el texto en páginas que caben en el papel, cortando entre párrafos.
func fit_pages(pages: PackedStringArray) -> PackedStringArray:
    var fitted := PackedStringArray()
    for page in pages:
        var current := ""
        for paragraph in page.split("\n\n"):
            var candidate := paragraph if current.is_empty() else current + "\n\n" + paragraph
            if current.is_empty() or _fits_on_paper(candidate):
                current = candidate
            else:
                fitted.append(current)
                current = paragraph
        fitted.append(current)
    return fitted


func _fits_on_paper(body: String) -> bool:
    var font := reader_body.get_theme_font("font")
    var font_size := reader_body.get_theme_font_size("font_size")
    var line_height := font.get_height(font_size) + reader_body.get_theme_constant("line_spacing")
    var lines := 0
    for line in body.split("\n"):
        var width := font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
        lines += maxi(1, ceili(width / (reader_body.size.x * 0.9)))
    return lines * line_height <= reader_body.size.y


func _previous_reader_page() -> void:
    if not reader.visible or _reader_document == null or _reader_page_index <= 0:
        return
    _reader_page_index -= 1
    _refresh_reader_page()
    Sfx.play("page", null, -10.0)


func _next_reader_page() -> void:
    if not reader.visible or _reader_document == null:
        return
    if _reader_page_index >= _reader_pages.size() - 1:
        _close_reader()
        return
    _reader_page_index += 1
    _refresh_reader_page()
    Sfx.play("page", null, -10.0)


func _close_reader() -> void:
    if not reader.visible:
        return
    reader.visible = false
    _reader_closed.emit()


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


## Una línea que empieza con "Nombre: " la dice ese personaje: sale con su nombre
## arriba y en su color (Leo en verde).
const SPEAKERS := {
    "Leo": Color(0.72, 0.93, 0.6),
    "Rosa": Color(0.95, 0.78, 0.6),
    "Javiera": Color(0.65, 0.8, 1.0),
    "Kiara": Color(1.0, 0.68, 0.35),
    "Nala": Color(0.85, 0.72, 0.6),
}
const TEXT_COLOR := Color(0.92, 0.9, 0.84)


func _show_text(line: String) -> void:
    var color := TEXT_COLOR
    speaker.visible = false
    for who: String in SPEAKERS:
        if line.begins_with(who + ": "):
            color = SPEAKERS[who]
            speaker.text = who.to_upper()
            speaker.add_theme_color_override("font_color", color)
            speaker.visible = true
            line = line.substr(who.length() + 2)
            break
    text.add_theme_color_override("font_color", color)
    text.text = line
    text.visible_ratio = 0.0
    _reveal = 0.0
    _grace = INPUT_GRACE
    next_mark.visible = false


## Si hay un diálogo "abierto" pero no se ve nada (error a medio camino), tras este
## tiempo se suelta la pausa en vez de dejar el juego congelado y sin cuadro.
const INVISIBLE_LIMIT := 1.2
var _invisible_time := 0.0


func _process(delta: float) -> void:
    _watch_invisible(delta)
    _grace = maxf(_grace - delta, 0.0)
    if box.visible and _reveal < 1.0:
        var length := maxi(text.text.length(), 1)
        _reveal = minf(_reveal + delta * CHARS_PER_SECOND / length, 1.0)
        text.visible_ratio = _reveal
    next_mark.visible = box.visible and _reveal >= 1.0 and not _asking and fmod(Time.get_ticks_msec() / 400.0, 2.0) < 1.4
    if _depth > 0 and (Input.is_action_just_pressed(&"interact") or Input.is_action_just_pressed(&"ui_accept")):
        _advance(false)


func _watch_invisible(delta: float) -> void:
    if _depth > 0 and not (box.visible or reader.visible or choices.visible):
        _invisible_time += delta
        if _invisible_time > INVISIBLE_LIMIT:
            push_warning("Dialogue: diálogo abierto sin nada visible; se libera la pausa.")
            _depth = 0
            _asking = false
            get_tree().paused = _paused_before
            blocker.visible = false
            _invisible_time = 0.0
    else:
        _invisible_time = 0.0


func _input(event: InputEvent) -> void:
    # Los mensajes aceptan toque en pantalla; el lector usa botones propios.
    # Así el manejador global no consume el evento antes de que llegue al botón.
    if _depth > 0 and box.visible and not _asking and event is InputEventScreenTouch and event.pressed:
        _advance(false)
        get_viewport().set_input_as_handled()


func _advance(forced: bool) -> void:
    if _asking or _depth == 0 or (_grace > 0.0 and not forced):
        return
    if reader.visible:
        _next_reader_page()
        return
    if box.visible and _reveal < 1.0:
        # Primer toque: muestra el texto completo.
        _reveal = 1.0
        text.visible_ratio = 1.0
        _grace = INPUT_GRACE
        return
    _advanced.emit()
