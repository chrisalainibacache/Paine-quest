extends Control
## Pantalla de título: nueva partida o continuar desde la última máquina de escribir.

const GAME_SCENE := "res://main.tscn"
const CREDITS_SCENE := "res://ui/title/credits_screen.tscn"
const COOP_SCENE := "res://ui/coop/coop_menu.tscn"
const TITLE_FONT := "res://assets/fonts/JosefinSans.ttf"
const GOLD := Color(0.93, 0.66, 0.25)
## Etiqueta OpenType "wght" (peso de la fuente variable) = 0x77676874.
const WEIGHT_TAG := 0x77676874

@onready var continue_button: Button = $Menu/Continue
@onready var credits_button: Button = $CreditsButton
@onready var options_button: Button = $OptionsButton
@onready var options_menu: OptionsMenu = $OptionsMenu

var _title_audio: AudioDirector


func _ready() -> void:
    GameSettings.load_and_apply()
    _title_audio = AudioDirector.new()
    _title_audio.name = "TitleAudioDirector"
    add_child(_title_audio)
    AudioDirector.play_music("title")
    continue_button.disabled = not SaveSystem.has_save()
    $Menu/NewGame.pressed.connect(_new_game)
    $Menu/CoopButton.pressed.connect(_open_coop)
    continue_button.pressed.connect(_continue)
    credits_button.pressed.connect(_show_credits)
    options_button.pressed.connect(options_menu.open)
    var title := $Title as Label
    title.modulate.a = 0.0
    create_tween().tween_property(title, "modulate:a", 1.0, 2.0)
    _style_title()
    _animate_background.call_deferred()


func _new_game() -> void:
    Sfx.play("menu", null, -6.0)
    GameState.new_game()
    get_tree().change_scene_to_file(GAME_SCENE)


func _continue() -> void:
    Sfx.play("menu", null, -6.0)
    if SaveSystem.load_game():
        get_tree().change_scene_to_file(GAME_SCENE)
    else:
        continue_button.disabled = true


func _open_coop() -> void:
    Sfx.play("menu", null, -6.0)
    get_tree().change_scene_to_file(COOP_SCENE)


func _show_credits() -> void:
    Sfx.play("menu", null, -6.0)
    get_tree().change_scene_to_file(CREDITS_SCENE)


## Acercamiento muy lento del bosque (sube y baja), para que la pantalla no se sienta congelada.
func _animate_background() -> void:
    var bg := $Background as Control
    bg.pivot_offset = bg.size * Vector2(0.74, 0.62)
    var tween := create_tween().set_loops()
    tween.tween_property(bg, "scale", Vector2(1.06, 1.06), 22.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    tween.tween_property(bg, "scale", Vector2.ONE, 22.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


## Tipografía fina para el título y botones con borde delgado (el principal, con acento dorado).
func _style_title() -> void:
    var font := FontVariation.new()
    font.base_font = load(TITLE_FONT) as Font
    font.variation_opentype = {WEIGHT_TAG: 400}
    for label_name: String in ["Title", "Subtitle"]:
        (get_node(label_name) as Label).add_theme_font_override("font", font)
    var button_font := FontVariation.new()
    button_font.base_font = load(TITLE_FONT) as Font
    button_font.variation_opentype = {WEIGHT_TAG: 600}
    for path: String in ["Menu/NewGame", "Menu/Continue", "Menu/CoopButton", "Menu/Graphics", "Menu/Brightness", "OptionsButton", "CreditsButton"]:
        var button := get_node(path) as Button
        button.add_theme_font_override("font", button_font)
        var accent := path == "Menu/NewGame"
        button.add_theme_stylebox_override("normal", _button_box(accent, false))
        button.add_theme_stylebox_override("hover", _button_box(true, true))
        button.add_theme_stylebox_override("pressed", _button_box(true, true))
        button.add_theme_stylebox_override("disabled", _button_box(false, false))
        button.add_theme_color_override("font_disabled_color", Color(0.68, 0.65, 0.6))


func _button_box(accent: bool, bright: bool) -> StyleBoxFlat:
    var box := StyleBoxFlat.new()
    box.bg_color = Color(0.02, 0.02, 0.025, 0.82 if bright else 0.68)
    var edge := GOLD if accent else Color(0.75, 0.7, 0.62, 0.7)
    box.set_border_width_all(1)
    box.border_color = edge
    if accent:
        box.border_width_left = 5
    box.set_content_margin_all(10)
    return box
