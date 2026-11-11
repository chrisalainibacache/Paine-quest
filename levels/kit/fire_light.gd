extends OmniLight3D
## Luz de fuego: cambia de intensidad sin parar, como las llamas.

var _base := 1.0
var _time := 0.0


func _ready() -> void:
    _base = light_energy
    _time = randf() * 10.0


func _process(delta: float) -> void:
    _time += delta
    light_energy = _base * (0.75 + 0.18 * sin(_time * 9.0) + 0.12 * sin(_time * 23.0 + 1.3) + randf_range(-0.05, 0.05))
