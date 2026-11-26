extends Node
## Embestida de Skull: se prepara con un rugido, corre en línea recta y, si choca con una pared o un vagón,
## queda aturdido (y recibe doble daño) unos segundos. Si alcanza a Isabella, le pega fuerte.

const WINDUP := 0.9
const DASH_TIME := 1.1
const DASH_SPEED := 6.5
const COOLDOWN := 7.0
const STUN_TIME := 3.0
const MIN_RANGE := 3.5
const MAX_RANGE := 11.0
const HIT_BONUS := 10

var direction := Vector3.ZERO
var _cooldown := 3.0


func _physics_process(delta: float) -> void:
    _cooldown = maxf(_cooldown - delta, 0.0)


func wants_charge(distance: float) -> bool:
    return _cooldown <= 0.0 and distance >= MIN_RANGE and distance <= MAX_RANGE


## Fija la dirección de la embestida al inicio del rugido (se puede esquivar apartándose).
func begin(from: Vector3, to: Vector3) -> void:
    direction = to - from
    direction.y = 0.0
    direction = direction.normalized()
    _cooldown = COOLDOWN
