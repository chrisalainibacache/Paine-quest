class_name OptionsMenu
extends Control
## Ajustes de audio, créditos y acceso a la política de privacidad.

const CREDITS_SCENE := preload("res://ui/title/credits_screen.tscn")
const STORE_LINKS_PATH := "res://data/store_links.tres"

@onready var sfx_slider: HSlider = $Panel/Layout/SfxRow/Slider
@onready var music_slider: HSlider = $Panel/Layout/MusicRow/Slider
@onready var ambience_slider: HSlider = $Panel/Layout/AmbienceRow/Slider
@onready var message: Label = $Panel/Layout/Message

var _syncing := false
var _credits_screen: Control


func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    visible = false
    _sync_sliders()
    sfx_slider.value_changed.connect(_set_sfx_volume)
    music_slider.value_changed.connect(_set_music_volume)
    ambience_slider.value_changed.connect(_set_ambience_volume)
    $Panel/Layout/Buttons/Credits.pressed.connect(_show_credits)
    $Panel/Layout/Buttons/Privacy.pressed.connect(_open_privacy)
    $Panel/Layout/Buttons/Close.pressed.connect(close)


func open() -> void:
    _sync_sliders()
    message.text = ""
    visible = true
    Sfx.play("menu", null, -6.0)


func close() -> void:
    visible = false
    Sfx.play("menu", null, -8.0)


func _sync_sliders() -> void:
    _syncing = true
    sfx_slider.value = GameSettings.get_volume_percent("Sfx")
    music_slider.value = GameSettings.get_volume_percent("Music")
    ambience_slider.value = GameSettings.get_volume_percent("Ambience")
    _syncing = false


func _set_sfx_volume(value: float) -> void:
    if not _syncing:
        GameSettings.set_volume_percent("Sfx", value)


func _set_music_volume(value: float) -> void:
    if not _syncing:
        GameSettings.set_volume_percent("Music", value)


func _set_ambience_volume(value: float) -> void:
    if not _syncing:
        GameSettings.set_volume_percent("Ambience", value)


func _show_credits() -> void:
    if _credits_screen == null:
        _credits_screen = CREDITS_SCENE.instantiate() as Control
        _credits_screen.set("embedded", true)
        add_child(_credits_screen)
        _credits_screen.connect("closed", _on_credits_closed)
    _credits_screen.visible = true
    Sfx.play("menu", null, -6.0)


func _on_credits_closed() -> void:
    Sfx.play("menu", null, -8.0)


func _open_privacy() -> void:
    var links := load(STORE_LINKS_PATH) as StoreLinks
    if links == null or not (links.privacy_policy_url.begins_with("https://") or links.privacy_policy_url.begins_with("http://")):
        message.text = "La URL de la política de privacidad está pendiente de confirmar."
        return
    var error := OS.shell_open(links.privacy_policy_url)
    if error != OK:
        message.text = "No se pudo abrir la política de privacidad."
