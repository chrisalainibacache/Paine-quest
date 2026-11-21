class_name GameSettings
extends RefCounted
## Guarda y aplica los volúmenes sin alterar el nivel base de cada bus.

const SETTINGS_PATH := "user://ajustes.cfg"
const DEFAULT_BUS_DB := {"Sfx": 0.0, "Music": -8.0, "Ambience": -10.0}
static var _config := ConfigFile.new()
static var _loaded := false


static func load_and_apply() -> void:
    _ensure_loaded()
    for bus_name: String in DEFAULT_BUS_DB:
        _apply_bus(bus_name)


static func get_volume_percent(bus_name: String) -> float:
    _ensure_loaded()
    return float(_config.get_value("audio", bus_name, 100.0))


static func set_volume_percent(bus_name: String, percent: float) -> void:
    if not DEFAULT_BUS_DB.has(bus_name):
        return
    _ensure_loaded()
    _config.set_value("audio", bus_name, clampf(percent, 0.0, 100.0))
    var error := _config.save(SETTINGS_PATH)
    if error != OK:
        push_warning("No se pudieron guardar los ajustes de audio: %s" % error)
    _apply_bus(bus_name)


static func _ensure_loaded() -> void:
    if _loaded:
        return
    _config = ConfigFile.new()
    _config.load(SETTINGS_PATH)
    _loaded = true


static func _apply_bus(bus_name: String) -> void:
    var index := AudioServer.get_bus_index(bus_name)
    if index < 0:
        return
    var percent := get_volume_percent(bus_name)
    var adjustment := -80.0 if percent <= 0.0 else linear_to_db(percent / 100.0)
    AudioServer.set_bus_volume_db(index, DEFAULT_BUS_DB[bus_name] + adjustment)
