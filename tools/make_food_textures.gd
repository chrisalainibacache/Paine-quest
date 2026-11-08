extends SceneTree
## Texturas de la comida (sushi y handroll al estilo chileno: salmón, palta y
## queso crema). Procedurales y reproducibles; quedan en assets/items/food/.
## Uso: godot --headless --path . -s res://tools/make_food_textures.gd

const OUT := "res://assets/items/food/"
const NORI := Color(0.06, 0.09, 0.06)
const RICE := Color(0.95, 0.94, 0.9)
const SALMON := Color(0.98, 0.47, 0.25)
const CHEESE := Color(0.98, 0.97, 0.92)
const AVOCADO := Color(0.6, 0.74, 0.27)
const AVOCADO_DARK := Color(0.25, 0.4, 0.12)

var rng := RandomNumberGenerator.new()
var noise := FastNoiseLite.new()


func _init() -> void:
    DirAccess.make_dir_recursive_absolute(OUT)
    _save("maki_section", _section(1, false))
    _save("uramaki_section", _section(2, true))
    _save("nori", _nori(3))
    _save("avocado_wrap", _avocado_wrap(4))
    _save("tempura", _tempura(5))
    _save("rice", _rice_tile(6))
    _save("salmon", _salmon(7))
    _save("handroll_top", _handroll_top(8))
    _save("paper_sleeve", _paper(9))
    quit()


func _save(name: String, img: Image) -> void:
    img.save_png(OUT + name + ".png")
    print("textura: ", name)


func _new(size: int, seed_value: int, fill := Color(0, 0, 0, 0)) -> Image:
    rng.seed = seed_value
    noise.seed = seed_value
    noise.frequency = 0.08
    var img := Image.create(size, size, false, Image.FORMAT_RGBA8)
    img.fill(fill)
    return img


func _disc(img: Image, center: Vector2, radius: float, color: Color) -> void:
    for y in range(int(center.y - radius) - 1, int(center.y + radius) + 2):
        for x in range(int(center.x - radius) - 1, int(center.x + radius) + 2):
            if x >= 0 and y >= 0 and x < img.get_width() and y < img.get_height() and Vector2(x, y).distance_to(center) <= radius:
                img.set_pixel(x, y, color)


func _grain(img: Image, center: Vector2, color: Color) -> void:
    # Un grano de arroz: elipse chica con sombra.
    var angle := rng.randf() * PI
    var dir := Vector2.from_angle(angle)
    for t in range(-3, 4):
        var p := center + dir * t * 0.7
        _disc(img, p, 1.3, color.darkened(0.12 if t > 1 else 0.0))


func _rice_fill(img: Image, center: Vector2, inner: float, outer: float) -> void:
    for y in img.get_height():
        for x in img.get_width():
            var d := Vector2(x, y).distance_to(center)
            if d >= inner and d <= outer:
                img.set_pixel(x, y, RICE.darkened(0.12 + noise.get_noise_2d(x * 3.0, y * 3.0) * 0.06))
    for i in int(outer * outer * 0.35):
        var p := center + Vector2.from_angle(rng.randf() * TAU) * sqrt(rng.randf_range(inner * inner, outer * outer))
        _grain(img, p, RICE.darkened(rng.randf_range(0.0, 0.08)))


## Corte de un rollo: alga por fuera (maki) o arroz con sésamo por fuera (uramaki).
func _section(seed_value: int, inside_out: bool) -> Image:
    var img := _new(128, seed_value)
    var c := Vector2(64, 64)
    if inside_out:
        _rice_fill(img, c, 26, 61)
        for i in 70:
            var p := c + Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(44, 60)
            _disc(img, p, 1.2, Color(0.9, 0.82, 0.6) if i % 3 else Color(0.12, 0.1, 0.08))
        for y in 128:
            for x in 128:
                var d := Vector2(x, y).distance_to(c)
                if d > 24 and d < 27:
                    img.set_pixel(x, y, NORI)
    else:
        _rice_fill(img, c, 0, 56)
        for y in 128:
            for x in 128:
                var d := Vector2(x, y).distance_to(c)
                if d > 55 and d < 62:
                    img.set_pixel(x, y, NORI.lightened(noise.get_noise_2d(x * 4.0, y * 4.0) * 0.1))
    # Relleno: salmón, queso crema y palta.
    var r := 22.0 if inside_out else 26.0
    _fill_block(img, c + Vector2(-r * 0.35, -r * 0.2), Vector2(r * 0.8, r * 0.75), SALMON, true)
    _fill_block(img, c + Vector2(r * 0.4, -r * 0.25), Vector2(r * 0.55, r * 0.6), CHEESE, false)
    _fill_block(img, c + Vector2(0, r * 0.45), Vector2(r * 1.0, r * 0.4), AVOCADO, false)
    return img


func _fill_block(img: Image, center: Vector2, size: Vector2, color: Color, stripes: bool) -> void:
    for y in range(int(center.y - size.y / 2), int(center.y + size.y / 2)):
        for x in range(int(center.x - size.x / 2), int(center.x + size.x / 2)):
            var col := color.darkened(noise.get_noise_2d(x * 2.0, y * 2.0) * 0.08 + 0.04)
            if stripes and int(x + y * 0.6) % 7 == 0:
                col = col.lightened(0.45)  # vetas blancas del salmón
            if color == AVOCADO and y > center.y + size.y * 0.25:
                col = AVOCADO_DARK
            img.set_pixel(x, y, col)


func _nori(seed_value: int) -> Image:
    var img := _new(64, seed_value, NORI)
    for y in 64:
        for x in 64:
            var fiber := noise.get_noise_2d(x * 2.0, y * 0.4) * 0.5 + 0.5
            img.set_pixel(x, y, NORI.lightened(fiber * 0.12).darkened(rng.randf() * 0.05))
    return img


func _avocado_wrap(seed_value: int) -> Image:
    # Láminas de palta superpuestas: verde claro adentro, piel oscura en el borde.
    var img := _new(64, seed_value)
    for x in 64:
        var slice := fmod(float(x), 10.0) / 10.0
        for y in 64:
            var col := AVOCADO.lerp(Color(0.78, 0.84, 0.4), 1.0 - slice).darkened(0.05)
            if slice > 0.85:
                col = AVOCADO_DARK
            img.set_pixel(x, y, col.darkened(noise.get_noise_2d(x * 3.0, y * 3.0) * 0.06))
    return img


func _tempura(seed_value: int) -> Image:
    # Apanado dorado (panko): grumos claros y oscuros.
    var img := _new(64, seed_value, Color(0.82, 0.58, 0.24))
    for i in 380:
        var p := Vector2(rng.randf_range(0, 64), rng.randf_range(0, 64))
        var shade := rng.randf_range(-0.25, 0.3)
        _disc(img, p, rng.randf_range(0.8, 2.2), Color(0.86, 0.62, 0.26).lightened(maxf(shade, 0.0)).darkened(maxf(-shade, 0.0)))
    return img


func _rice_tile(seed_value: int) -> Image:
    var img := _new(64, seed_value, RICE.darkened(0.15))
    for i in 260:
        _grain(img, Vector2(rng.randf_range(0, 64), rng.randf_range(0, 64)), RICE.darkened(rng.randf_range(0.0, 0.08)))
    return img


func _salmon(seed_value: int) -> Image:
    var img := _new(64, seed_value, SALMON)
    for y in 64:
        for x in 64:
            var col := SALMON.darkened(noise.get_noise_2d(x * 2.0, y * 2.0) * 0.06 + 0.03)
            if int(x * 0.8 + y * 0.5) % 9 < 1:
                col = col.lightened(0.5)
            img.set_pixel(x, y, col)
    return img


## Boca del handroll vista desde arriba: arroz alrededor y el relleno asomando.
func _handroll_top(seed_value: int) -> Image:
    var img := _new(128, seed_value)
    var c := Vector2(64, 64)
    _rice_fill(img, c, 0, 60)
    _fill_block(img, c + Vector2(-14, -6), Vector2(36, 26), SALMON, true)
    _fill_block(img, c + Vector2(16, 4), Vector2(18, 30), CHEESE, false)
    _fill_block(img, c + Vector2(-6, 22), Vector2(44, 12), AVOCADO, false)
    return img


func _paper(seed_value: int) -> Image:
    # Papel blanco del handroll con una franja roja impresa.
    var img := _new(64, seed_value, Color(0.93, 0.92, 0.88))
    for y in 64:
        for x in 64:
            var col := Color(0.93, 0.92, 0.88).darkened(noise.get_noise_2d(x * 3.0, y * 3.0) * 0.04)
            if (y > 14 and y < 24) or (y > 40 and y < 46):
                col = Color(0.72, 0.1, 0.08)
            img.set_pixel(x, y, col)
    return img
