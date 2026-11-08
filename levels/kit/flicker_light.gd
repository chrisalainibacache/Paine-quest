extends OmniLight3D
## Ampolleta que parpadea de vez en cuando (pasillos, bodegas).

@export var min_interval: float = 1.5
@export var max_interval: float = 5.0

var _base_energy := 1.0
var _timer := 0.0


func _ready() -> void:
    _base_energy = light_energy
    _timer = randf_range(min_interval, max_interval)


func _process(delta: float) -> void:
    _timer -= delta
    if _timer > 0.0:
        return
    _timer = randf_range(min_interval, max_interval)
    # Dos o tres cortes rápidos.
    var tween := create_tween()
    for i in randi_range(2, 3):
        tween.tween_property(self, "light_energy", _base_energy * randf_range(0.0, 0.25), 0.04)
        tween.tween_interval(randf_range(0.03, 0.09))
        tween.tween_property(self, "light_energy", _base_energy, 0.03)
        tween.tween_interval(randf_range(0.05, 0.12))
