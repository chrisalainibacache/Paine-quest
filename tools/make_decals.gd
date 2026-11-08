extends SceneTree
## Genera las texturas de calcomanías (sangre, hoyos, grietas, impactos de bala,
## huellas, manchas de piso) en assets/environment/decals/. Son procedurales:
## volver a correrlo da las mismas imágenes (semillas fijas).
## Uso: godot --headless --path . -s res://tools/make_decals.gd

const OUT := "res://assets/environment/decals/"

var rng := RandomNumberGenerator.new()
var noise := FastNoiseLite.new()


func _init() -> void:
    DirAccess.make_dir_recursive_absolute(OUT)
    _save("blood_splatter_a", _blood_splatter(1, 256))
    _save("blood_splatter_b", _blood_splatter(2, 256))
    _save("blood_splatter_c", _blood_splatter(3, 256))
    _save("blood_handprint", _handprint(4))
    _save("blood_smear", _smear(5))
    _save("blood_pool", _pool(6))
    _save("blood_drag", _drag(7))
    _save("blood_footprints", _footprints(8))
    _save("wall_hole_a", _hole(9, 1.0))
    _save("wall_hole_b", _hole(10, 0.7))
    _save("bullet_holes", _bullet_holes(11))
    _save("cracks", _cracks(12))
    _save("oil_stain", _oil(13))
    _save("damp_stain", _damp(14))
    _save("debris", _debris(15))
    quit()


func _save(name: String, img: Image) -> void:
    img.save_png(OUT + name + ".png")
    print("calcomanía: ", name)


func _new(w: int, h: int, seed_value: int) -> Image:
    rng.seed = seed_value
    noise.seed = seed_value
    noise.frequency = 0.06
    noise.fractal_octaves = 3
    var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
    img.fill(Color(0, 0, 0, 0))
    return img


## Mezcla un color sobre la imagen (alfa "encima").
func _paint(img: Image, x: int, y: int, color: Color) -> void:
    if x < 0 or y < 0 or x >= img.get_width() or y >= img.get_height() or color.a <= 0.0:
        return
    var under := img.get_pixel(x, y)
    var a := color.a + under.a * (1.0 - color.a)
    if a <= 0.0:
        return
    var rgb := (Color(color.r, color.g, color.b) * color.a + Color(under.r, under.g, under.b) * under.a * (1.0 - color.a)) / a
    img.set_pixel(x, y, Color(rgb.r, rgb.g, rgb.b, a))


## Mancha de borde orgánico. `lobes` controla cuán ondulado es el contorno.
func _blob(img: Image, center: Vector2, radius: float, color: Color, roughness := 0.45, edge := 0.15, lobes := 5.0) -> void:
    var r := int(radius * (1.0 + roughness)) + 2
    for y in range(int(center.y) - r, int(center.y) + r):
        for x in range(int(center.x) - r, int(center.x) + r):
            var p := Vector2(x, y) - center
            var angle := p.angle()
            var wobble := noise.get_noise_2d(cos(angle) * lobes + center.x * 0.37, sin(angle) * lobes + center.y * 0.37) * roughness * 1.6
            var limit := radius * (1.0 + wobble)
            var d := p.length() / maxf(limit, 0.1)
            if d >= 1.0:
                continue
            var a := clampf((1.0 - d) / edge, 0.0, 1.0)
            _paint(img, x, y, Color(color, color.a * a))


func _line(img: Image, from: Vector2, to: Vector2, width_from: float, width_to: float, color: Color) -> void:
    var steps := int(from.distance_to(to)) + 1
    for i in steps:
        var t := float(i) / steps
        var p := from.lerp(to, t)
        var w := lerpf(width_from, width_to, t)
        for y in range(int(p.y - w), int(p.y + w) + 1):
            for x in range(int(p.x - w), int(p.x + w) + 1):
                if Vector2(x, y).distance_to(p) <= w:
                    _paint(img, x, y, color)


func _blood(dark := 0.0) -> Color:
    return Color(rng.randf_range(0.30, 0.42) * (1.0 - dark), rng.randf_range(0.01, 0.04), rng.randf_range(0.01, 0.03), 0.95)


## Variación oscura/seca dentro de la sangre (más creíble que un rojo plano).
func _age(img: Image, amount: float) -> void:
    for y in img.get_height():
        for x in img.get_width():
            var c := img.get_pixel(x, y)
            if c.a <= 0.0:
                continue
            var n := noise.get_noise_2d(x * 2.0, y * 2.0) * 0.5 + 0.5
            c = c.darkened(n * amount)
            img.set_pixel(x, y, c)


func _blood_splatter(seed_value: int, size: int) -> Image:
    var img := _new(size, size, seed_value)
    var center := Vector2(size * 0.5, size * 0.42)
    _blob(img, center, size * 0.16, _blood(), 0.55)
    # Puntas y gotas alrededor.
    for i in 26:
        var dir := Vector2.from_angle(rng.randf() * TAU)
        var dist := rng.randf_range(size * 0.15, size * 0.42)
        var tip := center + dir * dist
        if i % 3 == 0:
            _line(img, center + dir * size * 0.1, tip, rng.randf_range(2.0, 4.0), 0.8, _blood(0.1))
        _blob(img, tip, rng.randf_range(1.5, 5.0), _blood(), 0.3, 0.4)
    # Chorreado hacia abajo.
    for i in rng.randi_range(3, 6):
        var start := center + Vector2(rng.randf_range(-size * 0.14, size * 0.14), rng.randf_range(0, size * 0.08))
        var length := rng.randf_range(size * 0.15, size * 0.5)
        var end := start + Vector2(rng.randf_range(-2, 2), length)
        _line(img, start, end, rng.randf_range(2.0, 3.5), 1.2, _blood(0.15))
        _blob(img, end, 2.6, _blood(0.2), 0.2, 0.5)
    _age(img, 0.45)
    return img


func _handprint(seed_value: int) -> Image:
    var img := _new(256, 256, seed_value)
    var color := _blood()
    var palm := Vector2(128, 160)
    _blob(img, palm, 34, color, 0.18, 0.3)
    var fingers := [[-24.0, 44.0, 7.5], [-8.0, 58.0, 8.0], [9.0, 60.0, 8.0], [25.0, 48.0, 7.5]]
    for f in fingers:
        var base: Vector2 = palm + Vector2(f[0], -24.0)
        var tip: Vector2 = base + Vector2(f[0] * 0.3, -f[1])
        _line(img, base, tip, f[2], f[2] * 0.85, color)
    # Pulgar: sale del costado de la palma, abierto.
    _line(img, palm + Vector2(-26, 6), palm + Vector2(-58, -24), 8.5, 7.0, color)
    # Se resbaló: arrastre hacia abajo.
    for i in 4:
        var x := 104.0 + i * 15.0 + rng.randf_range(-3, 3)
        _line(img, Vector2(x, 180), Vector2(x + rng.randf_range(-4, 4), 180 + rng.randf_range(30, 70)), 5.0, 1.0, Color(color, 0.7))
    _age(img, 0.4)
    _erode(img, 0.25)
    return img


func _smear(seed_value: int) -> Image:
    var img := _new(256, 128, seed_value)
    for i in 6:
        var y := 30.0 + i * 13.0 + rng.randf_range(-4, 4)
        var length := rng.randf_range(120, 220)
        _line(img, Vector2(20, y), Vector2(20 + length, y + rng.randf_range(-10, 10)), rng.randf_range(4, 7), 0.8, _blood(0.1))
    _blob(img, Vector2(30, 64), 26, _blood(), 0.4)
    _age(img, 0.4)
    _erode(img, 0.35)
    return img


func _pool(seed_value: int) -> Image:
    var img := _new(256, 256, seed_value)
    _blob(img, Vector2(128, 128), 70, _blood(0.25), 0.5, 0.08)
    for i in 8:
        _blob(img, Vector2(128, 128) + Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(60, 95), rng.randf_range(10, 24), _blood(0.2), 0.5, 0.1)
    # Borde más oscuro y seco, centro brillante y húmedo.
    for y in 256:
        for x in 256:
            var c := img.get_pixel(x, y)
            if c.a > 0.0:
                var d := Vector2(x, y).distance_to(Vector2(128, 128)) / 110.0
                img.set_pixel(x, y, c.darkened(clampf(d * 0.6, 0.0, 0.5)).lightened(clampf(0.25 - d, 0.0, 0.15)))
    return img


func _drag(seed_value: int) -> Image:
    var img := _new(256, 128, seed_value)
    # Rastro de algo arrastrado: franja que serpentea, se adelgaza y se corta.
    for i in 12:
        var offset := rng.randf_range(-24, 24)
        var width := rng.randf_range(2.0, 6.0)
        var color := _blood(rng.randf_range(0.0, 0.35))
        var x := rng.randf_range(4, 30)
        var end_x := rng.randf_range(150, 250)
        var prev := Vector2(x, 64 + offset)
        while x < end_x:
            x += rng.randf_range(4, 9)
            var t := x / 256.0
            var y := 64.0 + offset * (1.0 - t * 0.6) + noise.get_noise_2d(x * 0.8, offset * 5.0) * 10.0
            var next := Vector2(x, y)
            if rng.randf() > 0.12:
                _line(img, prev, next, width * (1.0 - t * 0.7), width * (1.0 - t * 0.7), Color(color, color.a * (1.0 - t * 0.5)))
            prev = next
    _blob(img, Vector2(26, 64), 30, _blood(0.15), 0.5, 0.2)
    _age(img, 0.5)
    _erode(img, 0.3)
    return img


func _footprints(seed_value: int) -> Image:
    var img := _new(256, 128, seed_value)
    for i in 5:
        var x := 24.0 + i * 50.0
        var y := 44.0 if i % 2 == 0 else 84.0
        var fade := 1.0 - i * 0.17
        var color := Color(_blood(0.1), 0.9 * fade)
        _blob(img, Vector2(x + 9, y), 15, Color(color, color.a), 0.12, 0.35)
        _blob(img, Vector2(x + 2, y), 12, color, 0.1, 0.35)
        _blob(img, Vector2(x - 15, y), 10, color, 0.1, 0.35)
    _erode(img, 0.3)
    return img


func _hole(seed_value: int, scale: float) -> Image:
    var img := _new(256, 256, seed_value)
    var center := Vector2(128, 128)
    var outer := 90.0 * scale
    # Revoque descascarado (anillo claro), ladrillo expuesto y centro oscuro.
    _blob(img, center, outer, Color(0.72, 0.68, 0.6, 0.95), 0.5, 0.05)
    for y in 256:
        for x in 256:
            var c := img.get_pixel(x, y)
            if c.a <= 0.0:
                continue
            var d := Vector2(x, y).distance_to(center) / outer
            if d < 0.78:
                var row := int(y / 14.0)
                var mortar := (y % 14) < 2 or ((x + row * 13) % 30) < 2
                var brick := Color(0.42, 0.2, 0.14) if not mortar else Color(0.55, 0.52, 0.48)
                brick = brick.darkened(noise.get_noise_2d(x * 3.0, y * 3.0) * 0.3 + 0.15)
                img.set_pixel(x, y, Color(brick, 1.0))
            if d < 0.4:
                var depth := clampf(1.0 - d / 0.4, 0.0, 1.0)
                img.set_pixel(x, y, img.get_pixel(x, y).darkened(0.4 + depth * 0.5))
    _cracks_from(img, center, outer * 0.9, 7, Color(0.08, 0.07, 0.06, 0.9))
    return img


func _bullet_holes(seed_value: int) -> Image:
    var img := _new(256, 256, seed_value)
    for i in 9:
        var p := Vector2(rng.randf_range(40, 216), rng.randf_range(40, 216))
        _blob(img, p, rng.randf_range(10, 15), Color(0.74, 0.7, 0.62, 0.9), 0.4, 0.2)
        _blob(img, p, rng.randf_range(4.5, 6.5), Color(0.04, 0.035, 0.03, 1.0), 0.2, 0.25)
        _cracks_from(img, p, 12.0, 3, Color(0.12, 0.11, 0.1, 0.7))
    return img


func _cracks(seed_value: int) -> Image:
    var img := _new(256, 256, seed_value)
    _cracks_from(img, Vector2(128, 110), 120.0, 6, Color(0.07, 0.06, 0.05, 0.9))
    return img


func _cracks_from(img: Image, center: Vector2, length: float, count: int, color: Color) -> void:
    for i in count:
        var p := center
        var angle := rng.randf() * TAU
        var remaining := length * rng.randf_range(0.5, 1.0)
        var width := 1.6
        while remaining > 0.0:
            var step := rng.randf_range(6, 14)
            angle += rng.randf_range(-0.6, 0.6)
            var next := p + Vector2.from_angle(angle) * step
            _line(img, p, next, width, width * 0.85, color)
            if rng.randf() < 0.18:
                _cracks_branch(img, next, angle + rng.randf_range(-1.2, 1.2), remaining * 0.4, width * 0.7, color)
            width = maxf(width * 0.9, 0.6)
            remaining -= step
            p = next


func _cracks_branch(img: Image, start: Vector2, angle: float, length: float, width: float, color: Color) -> void:
    var p := start
    while length > 0.0:
        var step := rng.randf_range(5, 10)
        angle += rng.randf_range(-0.5, 0.5)
        var next := p + Vector2.from_angle(angle) * step
        _line(img, p, next, width, width * 0.8, color)
        p = next
        length -= step


func _oil(seed_value: int) -> Image:
    var img := _new(256, 256, seed_value)
    _blob(img, Vector2(128, 128), 80, Color(0.03, 0.035, 0.04, 0.8), 0.6, 0.12)
    for i in 4:
        _blob(img, Vector2(128, 128) + Vector2(rng.randf_range(-40, 40), rng.randf_range(-40, 40)), rng.randf_range(20, 40),
            Color(0.02, 0.02, 0.025, 0.5), 0.5, 0.3)
    return img


func _damp(seed_value: int) -> Image:
    var img := _new(256, 256, seed_value)
    _blob(img, Vector2(128, 128), 95, Color(0.05, 0.06, 0.05, 0.45), 0.7, 0.5)
    # Borde marcado (como cuando el agua se seca).
    _blob(img, Vector2(128, 128), 92, Color(0.18, 0.16, 0.1, 0.0), 0.7, 0.5)
    for y in 256:
        for x in 256:
            var c := img.get_pixel(x, y)
            if c.a > 0.0 and c.a < 0.2:
                img.set_pixel(x, y, Color(0.12, 0.1, 0.06, 0.45))
    return img


func _debris(seed_value: int) -> Image:
    var img := _new(256, 256, seed_value)
    for i in 140:
        var p := Vector2(rng.randf_range(10, 246), rng.randf_range(10, 246))
        if p.distance_to(Vector2(128, 128)) > 120:
            continue
        var shade := rng.randf_range(0.2, 0.6)
        var size := rng.randf_range(1.0, 4.5)
        _blob(img, p, size, Color(shade, shade * 0.95, shade * 0.88, 0.95), 0.6, 0.5)
    # Papeles sueltos.
    for i in 5:
        var p := Vector2(rng.randf_range(50, 206), rng.randf_range(50, 206))
        var w := rng.randf_range(10, 22)
        var h := rng.randf_range(7, 14)
        for y in range(int(p.y), int(p.y + h)):
            for x in range(int(p.x), int(p.x + w)):
                _paint(img, x, y, Color(0.78, 0.75, 0.66, 0.95))
    return img


## Gasta los bordes con ruido (pintura o sangre seca que se descascara).
func _erode(img: Image, amount: float) -> void:
    for y in img.get_height():
        for x in img.get_width():
            var c := img.get_pixel(x, y)
            if c.a <= 0.0:
                continue
            var n := noise.get_noise_2d(x * 4.0, y * 4.0) * 0.5 + 0.5
            if n < amount:
                c.a *= clampf(n / amount, 0.0, 1.0)
                img.set_pixel(x, y, c)
