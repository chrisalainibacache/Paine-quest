class_name SaveSystem
extends RefCounted
## Guarda y carga la partida en el teléfono (user://). Una sola ranura, como
## una libreta: la máquina de escribir sobrescribe la anterior.

static var save_path := "user://partida.json"


static func has_save() -> bool:
    return FileAccess.file_exists(save_path)


static func save_game() -> bool:
    var file := FileAccess.open(save_path, FileAccess.WRITE)
    if file == null:
        push_error("No se pudo guardar en %s" % save_path)
        return false
    file.store_string(JSON.stringify(GameState.to_data(), "  "))
    return true


static func load_game() -> bool:
    if not has_save():
        return false
    var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(save_path))
    if not data is Dictionary:
        push_error("Partida guardada dañada: %s" % save_path)
        return false
    GameState.from_data(data)
    return true


static func delete_save() -> void:
    if has_save():
        DirAccess.remove_absolute(save_path)
