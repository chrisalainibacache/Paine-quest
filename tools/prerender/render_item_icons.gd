extends SceneTree
## Renderiza los íconos HD de la mochila (256×256, fondo transparente) a partir del modelo 3D de cada ítem de data/items/:
## vista de tres cuartos, luz cálida de frente, luz fría de contraluz y relleno suave. Salida: assets/ui/icons/<id>.png
## Necesita Forward+ (ver tools/prerender/render_cinematic.gd para el comando con lavapipe, con --resolution 256x256).
##   VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/lvp_icd.json xvfb-run -a -s "-screen 0 800x800x24" godot --path . \
##     --rendering-method forward_plus --rendering-driver vulkan --resolution 256x256 -s res://tools/prerender/render_item_icons.gd
const OUT := "res://assets/ui/icons/"
const SIZE := 256


func _init() -> void:
    _run.call_deferred()


func _run() -> void:
    DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
    root.transparent_bg = true
    root.msaa_3d = Viewport.MSAA_4X
    root.size = Vector2i(SIZE, SIZE)
    var world := Node3D.new()
    root.add_child(world)
    var env := Environment.new()
    env.background_mode = Environment.BG_CLEAR_COLOR
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.5, 0.52, 0.58)
    env.ambient_light_energy = 1.15
    env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    env.adjustment_enabled = true
    env.adjustment_contrast = 1.08
    var we := WorldEnvironment.new()
    we.environment = env
    world.add_child(we)
    var cam := Camera3D.new()
    cam.projection = Camera3D.PROJECTION_ORTHOGONAL
    cam.size = 1.25
    cam.position = Vector3(0, 0, 3.0)
    world.add_child(cam)
    cam.make_current()
    var key := DirectionalLight3D.new()
    key.rotation = Vector3(-0.7, 0.55, 0.0)
    key.light_energy = 2.3
    key.light_color = Color(1.0, 0.92, 0.8)
    key.shadow_enabled = true
    world.add_child(key)
    var rim := DirectionalLight3D.new()
    rim.rotation = Vector3(-0.35, -2.5, 0.0)
    rim.light_energy = 1.9
    rim.light_color = Color(0.62, 0.74, 1.0)
    world.add_child(rim)
    var fill := DirectionalLight3D.new()
    fill.rotation = Vector3(0.4, 2.2, 0.0)
    fill.light_energy = 0.7
    world.add_child(fill)
    var count := 0
    for file in DirAccess.get_files_at("res://data/items/"):
        if not file.ends_with(".tres"):
            continue
        var item := load("res://data/items/" + file) as ItemData
        if item == null or item.model == null:
            continue
        var pivot := Node3D.new()
        world.add_child(pivot)
        var model := item.model.instantiate() as Node3D
        pivot.add_child(model)
        await process_frame
        var box := _bounds(model)
        var extent := maxf(box.size.x, maxf(box.size.y, box.size.z))
        var fit := 1.0 / maxf(extent, 0.001)
        model.scale = Vector3.ONE * fit
        model.position = -box.get_center() * fit
        # Armas y objetos largos: tres cuartos (de lado, ligeramente desde arriba); llaves y comida: más de frente.
        pivot.rotation = Vector3(0.38, -0.7 if item.kind == ItemData.Kind.WEAPON else -0.5, 0.0)
        for k in 4:
            await process_frame
        var img := root.get_texture().get_image()
        # Segunda pasada: se encuadra el ícono (84 % del cuadro, centrado) usando el recuadro real de lo dibujado.
        var used := img.get_used_rect()
        if used.size.x > 0 and used.size.y > 0:
            var s2 := 0.84 * SIZE / float(maxi(used.size.x, used.size.y))
            var center_px := Vector2(used.position) + Vector2(used.size) / 2.0 - Vector2(SIZE, SIZE) / 2.0
            var per_px := cam.size / float(SIZE)
            model.scale *= s2
            model.position = (model.position * s2) - pivot.basis.inverse() * Vector3(center_px.x * per_px, -center_px.y * per_px, 0.0) * 1.0
            for k in 4:
                await process_frame
            img = root.get_texture().get_image()
        img.save_png(ProjectSettings.globalize_path(OUT + item.id + ".png"))
        print("ícono ", item.id, " (", int(extent * 100), " cm)")
        pivot.queue_free()
        count += 1
    print("íconos: ", count)
    quit()


func _bounds(node: Node3D) -> AABB:
    var box := AABB()
    var first := true
    for mi: MeshInstance3D in node.find_children("*", "MeshInstance3D", true, false):
        var a: AABB = mi.global_transform * mi.get_aabb()
        box = a if first else box.merge(a)
        first = false
    return box
