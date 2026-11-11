extends SceneTree
func _init() -> void:
    var a := OS.get_cmdline_user_args()
    var dir: String = a[0]
    var names := a.slice(2)
    var out := Image.create(1280, 360 * ((names.size() + 1) / 2), false, Image.FORMAT_RGBA8)
    for i in names.size():
        var img := Image.load_from_file(dir + "/" + names[i] + ".png")
        img.convert(Image.FORMAT_RGBA8)
        img.resize(640, 360)
        out.blit_rect(img, Rect2i(0, 0, 640, 360), Vector2i((i % 2) * 640, (i / 2) * 360))
    out.save_png(dir + "/" + a[1])
    quit()
