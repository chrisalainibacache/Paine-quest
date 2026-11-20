class_name AudioDirector
extends Node
## Música y ambiente globales. Los archivos OGG son opcionales: sin ellos hay silencio
## ambiental/musical, mientras Sfx conserva su respaldo sintetizado.

static var _instance: AudioDirector
static var enabled := true

const MUSIC_DIR := "res://assets/audio/music/"
const AMBIENCE_DIR := "res://assets/audio/ambience/"
const MUSIC_DB := -8.0
const AMBIENCE_DB := -10.0

var _music: AudioStreamPlayer
var _ambience: AudioStreamPlayer
var _music_track := ""
var _ambience_track := ""
var _chapter_track := "explore_night"
var _tension_time := 0.0
var _was_chasing := false
var _dialogue_was_open := false
var _inventory_was_open := false
var _dead := false


func _ready() -> void:
    _instance = self
    process_mode = Node.PROCESS_MODE_ALWAYS
    _music = AudioStreamPlayer.new()
    _music.name = "MusicPlayer"
    _music.bus = "Music"
    add_child(_music)
    _ambience = AudioStreamPlayer.new()
    _ambience.name = "AmbiencePlayer"
    _ambience.bus = "Ambience"
    add_child(_ambience)
    var loader := get_parent().get_node_or_null("SceneLoader") as SceneLoader
    if loader:
        loader.room_changed.connect(_on_room_changed)


func _process(delta: float) -> void:
    if not enabled:
        _stop_all()
        return
    if _dead:
        return
    var player := get_parent().get_node_or_null("World/Player") as Player
    if player and not player.is_alive():
        _on_player_died()
        return
    var chasing := _has_pursuit()
    if chasing:
        _tension_time = 0.0
        _was_chasing = true
        _set_music("tension")
    elif _was_chasing:
        _tension_time += delta
        if _tension_time >= 6.0:
            _was_chasing = false
            _set_music(_chapter_track)

    var dialogue_open := Dialogue.is_open()
    if dialogue_open != _dialogue_was_open:
        _dialogue_was_open = dialogue_open
        _update_music_volume()
    var menu := get_parent().get_node_or_null("InventoryMenu")
    var inventory_open := menu != null and menu.visible
    if inventory_open and not _inventory_was_open:
        _inventory_was_open = true
        _music.stop()
    elif not inventory_open and _inventory_was_open:
        _inventory_was_open = false
        if not _was_chasing:
            _set_music(_chapter_track)


func _on_room_changed(room: Room) -> void:
    if not enabled or room == null:
        return
    var path := room.scene_file_path
    _chapter_track = "explore_day" if "/buin/" in path else "explore_night"
    _set_music(_chapter_track)
    _set_ambience(_room_ambience(room))


## T8 añade esta propiedad exportada a Room; T7 ya entiende el contrato.
func _room_ambience(room: Room) -> String:
    for property: Dictionary in room.get_property_list():
        if String(property.name) == "ambience":
            return String(room.get("ambience"))
    return ""


func _has_pursuit() -> bool:
    for node: Node in get_tree().get_nodes_in_group("enemies"):
        var infected := node as Infected
        if infected and (infected.state == Infected.State.CHASE or infected.state == Infected.State.ATTACK):
            return true
    return false


func _set_music(track: String) -> void:
    if track == _music_track:
        return
    _music_track = track
    var path := MUSIC_DIR + track + ".ogg"
    if not ResourceLoader.exists(path):
        _music.stop()
        _music.stream = null
        return
    var stream := load(path) as AudioStream
    if stream == null:
        _music.stop()
        return
    if stream is AudioStreamOggVorbis:
        (stream as AudioStreamOggVorbis).loop = true
    _music.stream = stream
    _music.volume_db = -60.0
    _music.play()
    _music.create_tween().tween_property(_music, "volume_db", _music_target_db(), 1.5)


func _set_ambience(track: String) -> void:
    if track == _ambience_track:
        return
    _ambience_track = track
    if track.is_empty() or not ResourceLoader.exists(AMBIENCE_DIR + track + ".ogg"):
        _ambience.stop()
        _ambience.stream = null
        return
    var stream := load(AMBIENCE_DIR + track + ".ogg") as AudioStream
    if stream == null:
        _ambience.stop()
        return
    if stream is AudioStreamOggVorbis:
        (stream as AudioStreamOggVorbis).loop = true
    _ambience.stream = stream
    _ambience.volume_db = -60.0
    _ambience.play()
    _ambience.create_tween().tween_property(_ambience, "volume_db", AMBIENCE_DB, 1.5)


func _music_target_db() -> float:
    return MUSIC_DB - (6.0 if _dialogue_was_open else 0.0)


func _update_music_volume() -> void:
    if _music.playing:
        _music.create_tween().tween_property(_music, "volume_db", _music_target_db(), 0.2)


func _on_player_died() -> void:
    _dead = true
    _fade_stop(_music)
    _fade_stop(_ambience)


func _fade_stop(player: AudioStreamPlayer) -> void:
    if not player.playing:
        return
    var tween := create_tween()
    tween.tween_property(player, "volume_db", -60.0, 0.6)
    tween.tween_callback(player.stop)


func _stop_all() -> void:
    _music.stop()
    _ambience.stop()
