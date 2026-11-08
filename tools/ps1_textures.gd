# Herramienta de conversión de assets (se usó una vez; se guarda como registro).
# Se ejecuta en un proyecto temporal junto al archivo original, por ejemplo:
#   godot --headless -s ps1_textures.gd -- <origen> <destino>
# Los originales (FBX de 20 MB, texturas de 2048 px) no se suben al repositorio.
extends SceneTree
const NAMES := {
 "Concrete034": "concrete", "Plaster001": "plaster", "Tiles101": "tiles",
 "Bricks074": "bricks_red", "Bricks075A": "bricks_old", "Gravel022": "gravel",
 "Metal032": "metal", "Rust004": "rust", "Wood049": "wood", "Planks012": "planks",
 "PavingStones070": "paving", "Asphalt012": "asphalt", "Asphalt025C": "asphalt_cracked",
 "RoofingTiles006": "roof_tiles",
}
func _init():
    var args := OS.get_cmdline_user_args()
    var src: String = args[0]
    var dst: String = args[1]
    DirAccess.make_dir_recursive_absolute(dst)
    var imgs := []
    for f in DirAccess.get_files_at(src):
        var key := f.get_slice("_", 0)
        if not NAMES.has(key): continue
        var im := Image.load_from_file(src.path_join(f))
        im.convert(Image.FORMAT_RGB8)
        im.resize(256, 256, Image.INTERPOLATE_LANCZOS)
        for y in 256:
            for x in 256:
                var c := im.get_pixel(x, y)
                var l := c.get_luminance()
                c = c.lerp(Color(l, l, l), 0.25)          # menos saturado
                c = Color(c.r * 1.04, c.g, c.b * 0.9)      # tinte cálido sucio
                c = (c - Color(0.5, 0.5, 0.5)) * 1.1 + Color(0.5, 0.5, 0.5)
                c.r = floor(clampf(c.r, 0, 1) * 31.0 + 0.5) / 31.0   # 15 bits
                c.g = floor(clampf(c.g, 0, 1) * 31.0 + 0.5) / 31.0
                c.b = floor(clampf(c.b, 0, 1) * 31.0 + 0.5) / 31.0
                im.set_pixel(x, y, c)
        im.save_png(dst.path_join(NAMES[key] + ".png"))
        imgs.append(im)
    var cols := 5
    var rows := int(ceil(imgs.size() / float(cols)))
    var sheet := Image.create(256 * cols, 256 * rows, false, Image.FORMAT_RGB8)
    for i in imgs.size():
        sheet.blit_rect(imgs[i], Rect2i(0, 0, 256, 256), Vector2i((i % cols) * 256, (i / cols) * 256))
    sheet.save_png(dst.path_join("../texture_sheet.png"))
    print(imgs.size(), " texturas")
    quit()
