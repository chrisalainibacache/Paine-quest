class_name Sfx
extends Node
## Efectos de sonido generados por código (no hay archivos de audio todavía).
## Cada sonido se sintetiza una vez al iniciar y se reutiliza. El nodo vive como
## autoload ("SfxPlayer"); el juego llama a la función estática Sfx.play().
## Cuando tengamos muestras reales (.ogg) se reemplazan aquí sin tocar el juego.

const RATE := 22050
const POOL_SIZE := 8

static var _instance: Sfx

var _streams: Dictionary = {}
var _players_3d: Array[AudioStreamPlayer3D] = []
var _players_2d: Array[AudioStreamPlayer] = []
var _next_3d := 0
var _next_2d := 0


func _ready() -> void:
    _instance = self
    process_mode = Node.PROCESS_MODE_ALWAYS
    seed(1234)
    _streams["shot"] = _make(0.32, _shot)
    _streams["click"] = _make(0.06, _click)
    _streams["reload"] = _make(0.5, _reload)
    _streams["hit"] = _make(0.14, _hit)
    _streams["groan"] = _make(1.3, _groan)
    _streams["groan_short"] = _make(0.6, _groan)
    _streams["bite"] = _make(0.35, _bite)
    _streams["hurt"] = _make(0.3, _hurt)
    _streams["fall"] = _make(0.45, _fall)
    for i in POOL_SIZE:
        var p3 := AudioStreamPlayer3D.new()
        p3.unit_size = 4.0
        p3.max_distance = 30.0
        add_child(p3)
        _players_3d.append(p3)
        var p2 := AudioStreamPlayer.new()
        add_child(p2)
        _players_2d.append(p2)


## Reproduce un sonido. Con posición suena en 3D; sin ella, plano.
static func play(sound: String, at: Variant = null, volume_db: float = 0.0, pitch_jitter: float = 0.06) -> void:
    if _instance:
        _instance._play(sound, at, volume_db, pitch_jitter)


func _play(sound: String, at: Variant, volume_db: float, pitch_jitter: float) -> void:
    if not _streams.has(sound):
        return
    var pitch := 1.0 + randf_range(-pitch_jitter, pitch_jitter)
    if at is Vector3:
        var p3 := _players_3d[_next_3d]
        _next_3d = (_next_3d + 1) % POOL_SIZE
        p3.stream = _streams[sound]
        p3.global_position = at
        p3.volume_db = volume_db
        p3.pitch_scale = pitch
        p3.play()
    else:
        var p2 := _players_2d[_next_2d]
        _next_2d = (_next_2d + 1) % POOL_SIZE
        p2.stream = _streams[sound]
        p2.volume_db = volume_db
        p2.pitch_scale = pitch
        p2.play()


func _make(seconds: float, generator: Callable) -> AudioStreamWAV:
    var count := int(seconds * RATE)
    var data := PackedByteArray()
    data.resize(count * 2)
    var lowpass := 0.0
    for i in count:
        var t := float(i) / RATE
        var sample: float = generator.call(t, seconds, lowpass)
        lowpass = sample
        data.encode_s16(i * 2, int(clampf(sample, -1.0, 1.0) * 32000.0))
    var stream := AudioStreamWAV.new()
    stream.format = AudioStreamWAV.FORMAT_16_BITS
    stream.mix_rate = RATE
    stream.data = data
    return stream


# --- Recetas de sonido (t = segundos, length = duración, prev = muestra anterior)

func _shot(t: float, _length: float, prev: float) -> float:
    var noise := randf_range(-1.0, 1.0)
    var body := lerpf(prev, noise, 0.35)  # ruido filtrado: estampido grave
    var crack := noise * exp(-t * 90.0)
    var thump := sin(TAU * 70.0 * t) * exp(-t * 18.0)
    return (body * 1.4 + crack * 0.8 + thump * 0.9) * exp(-t * 11.0)


func _click(t: float, _length: float, _prev: float) -> float:
    return sin(TAU * 2400.0 * t) * exp(-t * 160.0) * 0.6


func _reload(t: float, _length: float, _prev: float) -> float:
    var a := sin(TAU * 1800.0 * t) * exp(-t * 120.0)
    var t2 := maxf(t - 0.28, 0.0)
    var b := sin(TAU * 1300.0 * t2) * exp(-t2 * 90.0) * (1.0 if t > 0.28 else 0.0)
    return (a + b) * 0.5


func _hit(t: float, _length: float, prev: float) -> float:
    var noise := lerpf(prev, randf_range(-1.0, 1.0), 0.25)
    return (noise * 1.6 + sin(TAU * 110.0 * t) * 0.5) * exp(-t * 28.0)


func _groan(t: float, length: float, prev: float) -> float:
    var wobble := 1.0 + sin(TAU * 3.1 * t) * 0.08 + sin(TAU * 0.7 * t) * 0.12
    var phase := fmod(t * 82.0 * wobble, 1.0)
    var saw := phase * 2.0 - 1.0
    var rasp := lerpf(prev, randf_range(-1.0, 1.0), 0.2) * 0.6
    var envelope := sin(PI * clampf(t / length, 0.0, 1.0))
    return lerpf(prev, saw * 0.6 + rasp, 0.18) * envelope * 1.6


func _bite(t: float, _length: float, prev: float) -> float:
    var noise := lerpf(prev, randf_range(-1.0, 1.0), 0.5)
    var crunch: float = noise * (0.6 + 0.4 * signf(sin(TAU * 34.0 * t)))
    return crunch * exp(-t * 8.0)


func _hurt(t: float, length: float, _prev: float) -> float:
    var f := lerpf(520.0, 330.0, t / length)
    return sin(TAU * f * t) * sin(PI * t / length) * 0.5


func _fall(t: float, _length: float, prev: float) -> float:
    var noise := lerpf(prev, randf_range(-1.0, 1.0), 0.12)
    return (noise * 2.2 + sin(TAU * 55.0 * t) * 0.6) * exp(-t * 9.0)
