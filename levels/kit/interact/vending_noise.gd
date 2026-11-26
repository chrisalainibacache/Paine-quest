class_name VendingNoise
extends Interactable
## Máquina de bebidas que produce un zumbido continuo. La bandera queda como
## gancho para Noise.make: cuando P14 integra el oído, el zumbido atenúa pasos.

const NOISE_FLAG: String = "noise:station_vending"
const SAMPLE_RATE: float = 22050.0

var _active: bool = false
var _phase: float = 0.0
var _generator: AudioStreamGenerator
var _player: AudioStreamPlayer3D
var _playback: AudioStreamGeneratorPlayback


func _init() -> void:
    prompt = "ACTIVAR MÁQUINA"
    reach = 1.3


func _ready() -> void:
    _generator = AudioStreamGenerator.new()
    _generator.mix_rate = int(SAMPLE_RATE)
    _generator.buffer_length = 0.35
    _player = AudioStreamPlayer3D.new()
    _player.name = "VendingHum"
    _player.stream = _generator
    _player.volume_db = -18.0
    _player.unit_size = 3.0
    _player.max_distance = 14.0
    add_child(_player)


func can_interact() -> bool:
    return true


func interact(_player_actor: Player) -> void:
    if _active:
        _active = false
        GameState.flags.erase(NOISE_FLAG)
        if _player != null:
            _player.stop()
        prompt = "ACTIVAR MÁQUINA"
        await Dialogue.say(["Apagué la máquina. El zumbido se detuvo."])
        return

    _active = true
    GameState.set_flag(NOISE_FLAG)
    if _player != null:
        _player.play()
        _playback = _player.get_stream_playback() as AudioStreamGeneratorPlayback
        _fill_buffer()
    prompt = "APAGAR MÁQUINA"
    Sfx.play("unlock", global_position, -8.0)
    await Dialogue.say(["La máquina quedó zumbando. El ruido constante puede cubrir mis pasos mientras esté encendida."])


func _process(_delta: float) -> void:
    if _active and _playback != null:
        _fill_buffer()


func _fill_buffer() -> void:
    if _playback == null:
        return
    var frames_available: int = _playback.get_frames_available()
    for frame_index in range(frames_available):
        _phase += TAU * 60.0 / SAMPLE_RATE
        if _phase > TAU:
            _phase -= TAU
        var hum: float = sin(_phase) * 0.075 + sin(_phase * 2.0) * 0.025
        hum += randf_range(-0.008, 0.008)
        _playback.push_frame(Vector2(hum, hum))


func _exit_tree() -> void:
    GameState.flags.erase(NOISE_FLAG)
    if _player != null:
        _player.stop()
