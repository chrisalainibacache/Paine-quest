extends Control
## Electrocardiograma de la mochila: el pulso y el color cambian con el estado
## de Cony (verde = Bien, amarillo = Precaución, rojo = Peligro).

const COLORS := {
    "Bien": Color(0.35, 0.9, 0.4),
    "Precaución": Color(0.95, 0.75, 0.2),
    "Peligro": Color(0.95, 0.22, 0.18),
}
const BEATS_PER_SECOND := {"Bien": 1.1, "Precaución": 1.6, "Peligro": 2.3}

var condition := "Bien"
var _time := 0.0


func _process(delta: float) -> void:
    _time += delta
    queue_redraw()


func _draw() -> void:
    var color: Color = COLORS.get(condition, Color.WHITE)
    draw_rect(Rect2(Vector2.ZERO, size), Color(0.0, 0.05, 0.02, 0.8))
    var points := PackedVector2Array()
    var steps := 90
    var head := fmod(_time * 0.6, 1.0)
    for i in steps + 1:
        var u := float(i) / steps
        var beat := fmod(u * 3.0 - _time * BEATS_PER_SECOND[condition] * 0.3, 1.0)
        if beat < 0.0:
            beat += 1.0
        var y := 0.0
        if beat > 0.40 and beat < 0.44:
            y = -0.15
        elif beat >= 0.44 and beat < 0.48:
            y = 0.85
        elif beat >= 0.48 and beat < 0.52:
            y = -0.45
        elif beat > 0.62 and beat < 0.72:
            y = 0.15 * sin((beat - 0.62) / 0.1 * PI)
        points.append(Vector2(u * size.x, size.y * (0.55 - y * 0.4)))
    draw_polyline(points, Color(color, 0.35), 5.0)
    draw_polyline(points, color, 2.0)
    draw_line(Vector2(head * size.x, 0), Vector2(head * size.x, size.y), Color(color, 0.12), 6.0)
