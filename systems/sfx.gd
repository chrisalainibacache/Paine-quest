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
    _streams["hiss"] = _make(0.7, _hiss)
    _streams["meow"] = _make(0.62, _meow)
    _streams["bark"] = _make(0.3, _bark)
    _streams["bark_deep"] = _make(0.42, _bark_deep)
    _streams["shotgun"] = _make(0.55, _shotgun)
    _streams["rifle"] = _make(0.28, _rifle)
    _streams["launcher"] = _make(0.4, _launcher)
    _streams["explosion"] = _make(1.6, _explosion)
    _streams["door"] = _make(0.9, _door)
    _streams["locked"] = _make(0.3, _locked)
    _streams["unlock"] = _make(0.35, _unlock)
    _streams["pickup"] = _make(0.3, _pickup)
    _streams["menu"] = _make(0.07, _menu)
    _streams["page"] = _make(0.3, _page)
    _streams["typewriter"] = _make(1.1, _typewriter)
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


func _hiss(t: float, length: float, prev: float) -> float:
    # Bufido de gata: ruido agudo con ataque rápido y cola larga.
    var noise := randf_range(-1.0, 1.0) - prev * 0.6
    var envelope := minf(t / 0.03, 1.0) * pow(1.0 - t / length, 1.5)
    return noise * envelope * 0.45


func _door(t: float, _length: float, prev: float) -> float:
    # Chirrido de bisagra + golpe de la puerta al cerrarse.
    var creak_f := 240.0 + sin(TAU * 7.0 * t) * 60.0
    var creak := signf(sin(TAU * creak_f * t)) * 0.12 * exp(-t * 3.0) * (1.0 if t < 0.6 else 0.0)
    var t2 := maxf(t - 0.62, 0.0)
    var thud := (lerpf(prev, randf_range(-1.0, 1.0), 0.15) * 1.5 + sin(TAU * 60.0 * t2) * 0.7) * exp(-t2 * 14.0) * (1.0 if t > 0.62 else 0.0)
    return creak + thud


func _locked(t: float, _length: float, prev: float) -> float:
    # Manilla que no gira: dos golpecitos metálicos secos.
    var a := sin(TAU * 900.0 * t) * exp(-t * 70.0)
    var t2 := maxf(t - 0.12, 0.0)
    var b := sin(TAU * 820.0 * t2) * exp(-t2 * 70.0) * (1.0 if t > 0.12 else 0.0)
    return (a + b) * 0.4 + lerpf(prev, randf_range(-1.0, 1.0), 0.3) * exp(-t * 40.0) * 0.3


func _unlock(t: float, _length: float, _prev: float) -> float:
    var a := sin(TAU * 1500.0 * t) * exp(-t * 60.0)
    var t2 := maxf(t - 0.16, 0.0)
    var b := sin(TAU * 1100.0 * t2) * exp(-t2 * 40.0) * (1.0 if t > 0.16 else 0.0)
    return (a * 0.5 + b * 0.6) * 0.6


func _pickup(t: float, length: float, _prev: float) -> float:
    var f := 660.0 if t < length * 0.4 else 990.0
    return sin(TAU * f * t) * exp(-fmod(t, length * 0.4) * 12.0) * 0.3


func _menu(t: float, _length: float, _prev: float) -> float:
    return sin(TAU * 1200.0 * t) * exp(-t * 60.0) * 0.35


func _page(t: float, length: float, prev: float) -> float:
    var noise := lerpf(prev, randf_range(-1.0, 1.0), 0.6)
    return noise * sin(PI * t / length) * 0.35


func _typewriter(t: float, _length: float, prev: float) -> float:
    # Teclazos irregulares y la campanita al final.
    var beat := fmod(t * 9.0, 1.0)
    var keys := lerpf(prev, randf_range(-1.0, 1.0), 0.7) * exp(-beat * 18.0) * (1.0 if t < 0.8 else 0.0)
    var t2 := maxf(t - 0.85, 0.0)
    var bell := sin(TAU * 2100.0 * t2) * exp(-t2 * 9.0) * (1.0 if t > 0.85 else 0.0)
    return keys * 0.6 + bell * 0.3


func _shotgun(t: float, _length: float, prev: float) -> float:
    # Estampido más grave y largo que la pistola.
    var noise := randf_range(-1.0, 1.0)
    var body := lerpf(prev, noise, 0.22)
    var thump := sin(TAU * 52.0 * t) * exp(-t * 9.0)
    return (body * 1.8 + thump * 1.1 + noise * exp(-t * 70.0) * 0.7) * exp(-t * 6.5)


func _rifle(t: float, _length: float, prev: float) -> float:
    # Seco y agudo.
    var noise := randf_range(-1.0, 1.0)
    return (lerpf(prev, noise, 0.5) * 1.3 + noise * exp(-t * 120.0)) * exp(-t * 16.0)


func _launcher(t: float, _length: float, prev: float) -> float:
    # "Plop" del tubo más soplido.
    var pop := sin(TAU * lerpf(160.0, 60.0, t * 3.0) * t) * exp(-t * 14.0)
    var hiss := lerpf(prev, randf_range(-1.0, 1.0), 0.6) * exp(-t * 6.0) * 0.5
    return pop * 1.2 + hiss


func _explosion(t: float, _length: float, prev: float) -> float:
    var noise := randf_range(-1.0, 1.0)
    var rumble := lerpf(prev, noise, 0.06)
    var boom := sin(TAU * lerpf(70.0, 30.0, t) * t) * exp(-t * 3.5)
    return (rumble * 3.2 + boom * 1.2 + noise * exp(-t * 30.0) * 0.8) * exp(-t * 2.2)


## Maullido corto: tono que sube y baja ("miau"), con armónicos y un poco de aire.
func _meow(t: float, length: float, prev: float) -> float:
    var base := 560.0
    var bend := 420.0
    var phase := TAU * (base * t + bend * length / PI * (1.0 - cos(PI * t / length)))
    var tone := sin(phase) + 0.55 * sin(phase * 2.0) + 0.3 * sin(phase * 3.0) + 0.12 * sin(phase * 4.0)
    var envelope := minf(t / 0.05, 1.0) * pow(1.0 - t / length, 1.4)
    # "m" inicial: más apagado al principio.
    var open := smoothstep(0.0, 0.12, t)
    var breath := lerpf(prev, randf_range(-1.0, 1.0), 0.3) * 0.08
    return (tone * 0.32 * lerpf(0.4, 1.0, open) + breath) * envelope


## Ladrido: golpe de tono que baja rápido, con ruido de garganta.
func _bark(t: float, length: float, prev: float) -> float:
    return _bark_voice(t, length, prev, 520.0)


## Ladrido grave (Kiara, perra grande).
func _bark_deep(t: float, length: float, prev: float) -> float:
    return _bark_voice(t, length, prev, 300.0)


func _bark_voice(t: float, length: float, prev: float, pitch: float) -> float:
    var f := pitch * (1.0 + 0.6 * exp(-t * 18.0))
    var phase := TAU * f * t
    var tone := sin(phase) + 0.6 * sin(phase * 2.0) + 0.35 * sin(phase * 3.0)
    var growl := lerpf(prev, randf_range(-1.0, 1.0), 0.5) * 0.35
    var envelope := minf(t / 0.012, 1.0) * exp(-t * 9.0 / length)
    return (tone * 0.4 + growl) * envelope
