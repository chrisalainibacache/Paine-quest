class_name Diag
## Diagnóstico en el teléfono: guarda los últimos eventos del juego (toques en ACCIÓN,
## diálogos, errores) para verlos en la pantalla DIAG de la mochila. Cada línea también
## va al registro del motor (user://logs/godot.log).

const MAX_LINES := 70

static var lines := PackedStringArray()


static func log(message: String) -> void:
    var line := "%7.2f  %s" % [Time.get_ticks_msec() / 1000.0, message]
    lines.append(line)
    if lines.size() > MAX_LINES:
        lines.remove_at(0)
    printerr("[diag] ", line)


## Datos del aparato y de la pantalla (para saber en qué teléfono pasa).
static func device_info() -> String:
    var viewport := Engine.get_main_loop() as SceneTree
    var visible_size := viewport.root.get_visible_rect().size if viewport else Vector2.ZERO
    return "Paine %s · %s %s · %s\nVentana %s · área visible %s · FPS %d\nGráficos: %s · brillo %d" % [
        str(ProjectSettings.get_setting("application/config/version", "?")), OS.get_name(), OS.get_version(),
        OS.get_model_name(), DisplayServer.window_get_size(), visible_size, Engine.get_frames_per_second(),
        "moderno" if GraphicsSettings.is_modern() else "retro", GraphicsSettings.brightness_level()]


## Últimas líneas de error o aviso del registro del motor (errores de script incluidos).
static func engine_errors(count := 14) -> PackedStringArray:
    var found := PackedStringArray()
    var path := "user://logs/godot.log"
    if not FileAccess.file_exists(path):
        return PackedStringArray(["(no hay registro del motor)"])
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        return PackedStringArray(["(no se pudo abrir el registro)"])
    var length := file.get_length()
    file.seek(maxi(length - 20000, 0))
    for line in file.get_as_text().split("\n"):
        if ("ERROR" in line or "SCRIPT" in line or "WARNING" in line or "Parse" in line) and not "[diag]" in line:
            found.append(line.strip_edges().left(150))
    return found.slice(maxi(found.size() - count, 0))
