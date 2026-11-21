class_name Ads
extends RefCounted
## Fachada estática de anuncios con recompensa. El proveedor real se integra después.

const CONFIG_PATH := "res://data/ads_config.tres"
const SETTINGS_PATH := "user://ajustes.cfg"

static var config: AdsConfig
static var _provider: AdProvider
static var _initialized := false
static var _settings_loaded := false
static var _removed := false
static var _showing := false
static var _last_shown_unix := 0.0
static var _last_play_time := 0.0
static var _chapter_id := 0
static var _chapter_count := 0

static var removed: bool:
    get:
        _ensure_settings()
        return _removed
    set(value):
        _ensure_settings()
        _removed = value
        _save_settings()


static func available() -> bool:
    _ensure_initialized()
    if _showing:
        return false
    if removed:
        return true
    if not _safe_to_reward():
        return false
    return _within_limits() and _provider != null and _provider.is_ready()


static func show_rewarded(placement: StringName, on_done: Callable) -> void:
    _ensure_initialized()
    if not on_done.is_valid():
        return
    if removed:
        on_done.call(true)
        return
    if _showing or not _safe_to_reward():
        on_done.call(false)
        return
    if not _within_limits() or _provider == null or not _provider.is_ready():
        on_done.call(false)
        return

    _record_impression()
    _showing = true
    _provider.show(placement, Ads._provider_finished.bind(on_done))


static func configure_provider(provider: AdProvider) -> void:
    _ensure_initialized()
    _provider = provider if provider != null else DebugAdProvider.new()


static func reset_for_tests() -> void:
    _ensure_initialized()
    _showing = false
    _last_shown_unix = 0.0
    _last_play_time = 0.0
    _chapter_id = _current_chapter()
    _chapter_count = 0
    _removed = false
    _save_settings()


static func _ensure_initialized() -> void:
    if _initialized:
        return
    config = load(CONFIG_PATH) as AdsConfig
    if config == null:
        config = AdsConfig.new()
    _ensure_settings()
    _provider = DebugAdProvider.new()
    _initialized = true


static func _ensure_settings() -> void:
    if _settings_loaded:
        return
    var saved := ConfigFile.new()
    saved.load(SETTINGS_PATH)
    _removed = bool(saved.get_value("ads", "removed", false))
    _last_shown_unix = float(saved.get_value("ads", "last_shown_unix", 0.0))
    _last_play_time = 0.0
    _chapter_id = int(saved.get_value("ads", "chapter_id", 0))
    _chapter_count = int(saved.get_value("ads", "chapter_count", 0))
    _settings_loaded = true


static func _safe_to_reward() -> bool:
    _ensure_settings()
    if not GameState.started or GameState.play_time < float(config.minimum_play_seconds):
        return false
    if Dialogue.is_open() or SceneLoader.is_busy():
        return false

    var tree := Engine.get_main_loop() as SceneTree
    if tree == null:
        return false
    if not tree.root.find_children("*", "VideoCinematic", true, false).is_empty():
        return false

    var player := tree.root.find_child("Player", true, false) as Player
    var player_dead := player != null and not player.is_alive()
    if player != null and not player_dead:
        if player.controls_locked or player.is_hurt():
            return false
        if player.combat.aiming or player.combat.reloading:
            return false

    # La pantalla de muerte ya no es combate: permite ofrecer CONTINUAR
    # aunque un infectado siga en estado de persecución.
    if not player_dead:
        for enemy: Node in tree.get_nodes_in_group("enemies"):
            if enemy is Infected and enemy.is_alive() \
                    and enemy.state in [Infected.State.CHASE, Infected.State.ATTACK]:
                return false
    return true


static func _within_limits() -> bool:
    var chapter := _current_chapter()
    if chapter != _chapter_id:
        _chapter_id = chapter
        _chapter_count = 0
    var now := Time.get_unix_time_from_system()
    if _last_shown_unix > 0.0 and now - _last_shown_unix < float(config.cooldown_seconds):
        return false
    if GameState.play_time - _last_play_time < float(config.minimum_play_seconds):
        return false
    return _chapter_count < config.max_per_chapter


static func _record_impression() -> void:
    _chapter_id = _current_chapter()
    _chapter_count += 1
    _last_shown_unix = Time.get_unix_time_from_system()
    _last_play_time = GameState.play_time
    _save_settings()


static func _provider_finished(rewarded: bool, on_done: Callable) -> void:
    _showing = false
    if on_done.is_valid():
        on_done.call(rewarded)


static func _current_chapter() -> int:
    var path := GameState.room_path
    if "/station/" in path:
        return 1
    if "/tracks/" in path:
        return 2
    if "/buin/" in path:
        return 3
    if "/maestranza/" in path:
        return 4
    if "/santiago/" in path or "/nos/" in path:
        return 5
    var latest := 1
    for key: Variant in GameState.flags.keys():
        var flag := String(key)
        if flag.begins_with("chapter_started:"):
            latest = maxi(latest, int(flag.get_slice(":", 1)))
    return latest


static func _save_settings() -> void:
    var saved := ConfigFile.new()
    saved.load(SETTINGS_PATH)
    saved.set_value("ads", "removed", _removed)
    saved.set_value("ads", "last_shown_unix", _last_shown_unix)
    saved.set_value("ads", "chapter_id", _chapter_id)
    saved.set_value("ads", "chapter_count", _chapter_count)
    var error := saved.save(SETTINGS_PATH)
    if error != OK:
        push_warning("No se pudieron guardar los ajustes de anuncios: %s" % error)
