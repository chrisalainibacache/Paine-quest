extends Control
## Pantalla de título: nueva partida o continuar desde la última máquina de escribir.

const GAME_SCENE := "res://main.tscn"
const CREDITS_SCENE := "res://ui/title/credits_screen.tscn"

@onready var continue_button: Button = $Menu/Continue
@onready var credits_button: Button = $CreditsButton
@onready var options_button: Button = $OptionsButton
@onready var options_menu: OptionsMenu = $OptionsMenu


func _ready() -> void:
    GameSettings.load_and_apply()
    continue_button.disabled = not SaveSystem.has_save()
    $Menu/NewGame.pressed.connect(_new_game)
    continue_button.pressed.connect(_continue)
    credits_button.pressed.connect(_show_credits)
    options_button.pressed.connect(options_menu.open)
    var title := $Title as Label
    title.modulate.a = 0.0
    create_tween().tween_property(title, "modulate:a", 1.0, 2.0)


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


func _show_credits() -> void:
    Sfx.play("menu", null, -6.0)
    get_tree().change_scene_to_file(CREDITS_SCENE)
