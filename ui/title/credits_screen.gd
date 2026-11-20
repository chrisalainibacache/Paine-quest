extends Control
## Pantalla desplazable con las atribuciones de los recursos del juego.

const TITLE_SCENE := "res://ui/title/title_screen.tscn"
const CREDITS_PATH := "res://CREDITS.md"

@onready var content: RichTextLabel = $Panel/Layout/Scroll/Content
@onready var back_button: Button = $Panel/Layout/Back


func _ready() -> void:
    back_button.pressed.connect(_go_back)
    var file := FileAccess.open(CREDITS_PATH, FileAccess.READ)
    if file == null:
        content.text = "No se pudieron cargar los créditos."
        return
    content.text = _plain_text(file.get_as_text())


func _plain_text(source: String) -> String:
    var lines := PackedStringArray()
    for source_line in source.split("\n"):
        var line := source_line.strip_edges()
        while line.begins_with("#"):
            line = line.substr(1).strip_edges()
        line = line.replace("**", "").replace("*", "")
        if line.begins_with("- "):
            line = "• " + line.substr(2)
        lines.append(line)
    lines.append("")
    lines.append("Personaje simple PSX — JashiPSX (itch.io).")
    return "\n".join(lines)


func _go_back() -> void:
    Sfx.play("menu", null, -6.0)
    get_tree().change_scene_to_file(TITLE_SCENE)
