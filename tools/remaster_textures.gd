extends SceneTree
## Remaster de texturas: rehace las texturas del escenario desde los originales
## de ambientCG (CC0) con el mismo tratamiento PS1 de tools/ps1_textures.gd
## (menos saturación, tinte cálido sucio, contraste, color de 15 bits), pero a
## 512 px. Así el detalle es real (no un reescalado de las de 256) y la
## identidad visual es la misma.
## Uso: godot --headless --path . -s res://tools/remaster_textures.gd -- <carpeta con *_Color.jpg> <destino> [tamaño]

const NAMES := {
    "Concrete034": "concrete", "Plaster001": "plaster", "Tiles101": "tiles",
    "Bricks074": "bricks_red", "Bricks075A": "bricks_old", "Gravel022": "gravel",
    "Metal032": "metal", "Rust004": "rust", "Wood049": "wood", "Planks012": "planks",
    "PavingStones070": "paving", "Asphalt012": "asphalt", "Asphalt025C": "asphalt_cracked",
    "RoofingTiles006": "roof_tiles",
}


func _init() -> void:
    var args := OS.get_cmdline_user_args()
    var src: String = args[0]
    var dst: String = args[1]
    var size := int(args[2]) if args.size() > 2 else 512
    DirAccess.make_dir_recursive_absolute(dst)
    var done := 0
    for dir in DirAccess.get_directories_at(src):
        if not NAMES.has(dir):
            continue
        var color_file := ""
        for f in DirAccess.get_files_at(src.path_join(dir)):
            if f.ends_with("_Color.jpg") or f.ends_with("_Color.png"):
                color_file = src.path_join(dir).path_join(f)
        if color_file.is_empty():
            push_warning("Sin mapa de color: %s" % dir)
            continue
        var im := Image.load_from_file(color_file)
        im.convert(Image.FORMAT_RGB8)
        im.resize(size, size, Image.INTERPOLATE_LANCZOS)
        for y in size:
            for x in size:
                var c := im.get_pixel(x, y)
                var l := c.get_luminance()
                c = c.lerp(Color(l, l, l), 0.25)          # menos saturado
                c = Color(c.r * 1.04, c.g, c.b * 0.9)      # tinte cálido sucio
                c = (c - Color(0.5, 0.5, 0.5)) * 1.1 + Color(0.5, 0.5, 0.5)
                c.r = floor(clampf(c.r, 0, 1) * 31.0 + 0.5) / 31.0   # 15 bits
                c.g = floor(clampf(c.g, 0, 1) * 31.0 + 0.5) / 31.0
                c.b = floor(clampf(c.b, 0, 1) * 31.0 + 0.5) / 31.0
                im.set_pixel(x, y, c)
        im.save_png(dst.path_join(NAMES[dir] + ".png"))
        done += 1
    print("texturas remasterizadas: ", done, " a ", size, " px")
    quit()
