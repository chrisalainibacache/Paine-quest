extends SceneTree
## Texturas de detalle de la estación: afiche turístico de Paine (cordillera,
## campos, cielo) y follaje para los maceteros. Procedurales y reproducibles.
## Uso: godot --headless --path . -s res://tools/make_station_textures.gd

const OUT := "res://assets/environment/station/"

var rng := RandomNumberGenerator.new()
var noise := FastNoiseLite.new()


func _init() -> void:
    DirAccess.make_dir_recursive_absolute(OUT)
    _poster().save_png(OUT + "poster_paine.png")
    _foliage().save_png(OUT + "foliage.png")
    print("texturas de estación listas")
    quit()


func _poster() -> Image:
    rng.seed = 21
    noise.seed = 21
    noise.frequency = 0.03
    var w := 128
    var h := 192
    var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
    for y in h:
        for x in w:
            var t := float(y) / h
            # Cielo: celeste arriba, más claro hacia el horizonte.
            var c := Color(0.42, 0.6, 0.82).lerp(Color(0.86, 0.88, 0.85), clampf(t / 0.55, 0.0, 1.0))
            img.set_pixel(x, y, c)
    # Cordillera: dos capas de cerros con nieve en las cumbres.
    for layer in 2:
        var base := 0.52 + layer * 0.08
        var amp := 0.18 - layer * 0.06
        var color := Color(0.42, 0.36, 0.55) if layer == 0 else Color(0.32, 0.3, 0.45)
        for x in w:
            var ridge := noise.get_noise_1d(x * (1.5 + layer) + layer * 100.0) * 0.5 + 0.5
            var peak := absf(sin(x * 0.045 + layer)) * 0.6 + ridge * 0.4
            var top := int((base - peak * amp) * h)
            for y in range(top, int(0.72 * h)):
                var snow := y < top + 6 + int(ridge * 6) and layer == 0
                img.set_pixel(x, y, Color(0.95, 0.95, 0.98) if snow else color.darkened((y - top) * 0.004))
    # Campos verdes y una hilera de álamos.
    for y in range(int(0.72 * h), h):
        for x in w:
            var band := int((y - 0.72 * h) / 7.0) % 2
            var field := Color(0.36, 0.55, 0.22) if band == 0 else Color(0.48, 0.62, 0.26)
            img.set_pixel(x, y, field.darkened(noise.get_noise_2d(x * 3.0, y * 3.0) * 0.1))
    for i in 9:
        var px := 6 + i * 14 + rng.randi_range(-2, 2)
        for y in range(int(0.6 * h), int(0.74 * h)):
            for dx in range(-2, 3):
                if absf(dx) <= 2.0 - (int(0.74 * h) - y) * 0.03:
                    img.set_pixel(clampi(px + dx, 0, w - 1), y, Color(0.18, 0.32, 0.14))
    # Marco crema y franja para el nombre (el texto va con Label3D encima).
    for y in h:
        for x in w:
            if x < 4 or x >= w - 4 or y < 4 or y >= h - 4:
                img.set_pixel(x, y, Color(0.9, 0.88, 0.8))
            elif y >= 10 and y < 42:
                img.set_pixel(x, y, img.get_pixel(x, y).lerp(Color(0.95, 0.94, 0.9), 0.85))
    # Desgaste del papel.
    for y in h:
        for x in w:
            var n := noise.get_noise_2d(x * 5.0, y * 5.0)
            img.set_pixel(x, y, img.get_pixel(x, y).darkened(maxf(n, 0.0) * 0.25))
    return img


func _foliage() -> Image:
    rng.seed = 7
    var size := 128
    var img := Image.create(size, size, false, Image.FORMAT_RGBA8)
    img.fill(Color(0, 0, 0, 0))
    for i in 90:
        var center := Vector2(rng.randf_range(16, 112), rng.randf_range(10, 120))
        var angle := rng.randf_range(-PI, PI)
        var length := rng.randf_range(9, 16)
        var shade := rng.randf_range(0.0, 0.35)
        var color := Color(0.25, 0.45, 0.18).darkened(shade)
        var dir := Vector2.from_angle(angle)
        for t in range(int(-length), int(length)):
            var width := (1.0 - absf(t) / length) * 4.0
            for s in range(int(-width), int(width) + 1):
                var p := center + dir * t + dir.orthogonal() * s
                if p.x >= 0 and p.y >= 0 and p.x < size and p.y < size:
                    img.set_pixel(int(p.x), int(p.y), color.lightened(0.1 if s == 0 else 0.0))
    return img
