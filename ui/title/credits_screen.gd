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
    var is_first_content_line := true
    for source_line in source.split("\n"):
        var line := source_line.strip_edges()
        if is_first_content_line and line.trim_prefix("#").strip_edges() == "Créditos":
            is_first_content_line = false
            continue
        if not line.is_empty():
            is_first_content_line = false
        while line.begins_with("#"):
            line = line.substr(1).strip_edges()
        var parts := line.split("`")
        for index in range(parts.size()):
            if index % 2 == 0:
                parts[index] = parts[index].replace("**", "")
            else:
                parts[index] = parts[index].replace("**", "*")
        line = "".join(parts)
        if line.begins_with("- ") or line.begins_with("* "):
            line = "• " + line.substr(2)
        lines.append(line)
    lines.append("")
    lines.append("Personaje simple PSX — JashiPSX (itch.io).")
    return "\n".join(lines)


func _go_back() -> void:
    Sfx.play("menu", null, -6.0)
    get_tree().change_scene_to_file(TITLE_SCENE)
