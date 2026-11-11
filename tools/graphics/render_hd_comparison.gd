extends SceneTree

const OUTPUT := "artifacts/hd_stage1/comparacion_hd.png"
const MATERIALS := [
    {"name": "CONCRETO", "source_texture": "res://assets/environment/textures/concrete.png", "albedo": "artifacts/hd_stage1/concrete_hd_2x.png"},
    {"name": "LADRILLO", "source_texture": "res://assets/environment/textures/bricks_old.png", "albedo": "artifacts/hd_stage1/bricks_old_hd_2x.png"},
    {"name": "ASFALTO", "source_texture": "res://assets/environment/textures/asphalt_cracked.png", "albedo": "artifacts/hd_stage1/asphalt_cracked_hd_2x.png"}
]

func _initialize() -> void:
    call_deferred("_render_preview")

func _render_preview() -> void:
    var scene_root := Node3D.new()
    scene_root.name = "HDMaterialComparison"
    root.add_child(scene_root)

    var camera := Camera3D.new()
    camera.position = Vector3(0.0, 0.0, 13.0)
    camera.projection = Camera3D.PROJECTION_ORTHOGONAL
    camera.size = 8.2
    camera.current = true
    scene_root.add_child(camera)

    var environment := WorldEnvironment.new()
    var env := Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = Color(0.055, 0.06, 0.07)
    environment.environment = env
    scene_root.add_child(environment)

    var label_material := StandardMaterial3D.new()
    label_material.albedo_color = Color(0.92, 0.88, 0.76)
    label_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

    for index in range(MATERIALS.size()):
        var entry: Dictionary = MATERIALS[index]
        var x := (float(index) - 1.0) * 4.1
        _add_label(scene_root, str(entry.name) + "\\nORIGINAL", Vector3(x - 0.82, 1.55, 0.0), label_material)
        _add_label(scene_root, str(entry.name) + "\\nHD PILOTO", Vector3(x + 0.82, -1.55, 0.0), label_material)

        var original_texture := load(str(entry.source_texture)) as Texture2D
        assert(original_texture != null, "Textura original no encontrada: " + str(entry.source_texture))
        _add_panel(scene_root, Vector3(x - 0.82, 0.0, 0.0), original_texture)

        var hd_image := Image.load_from_file(str(entry.albedo))
        assert(not hd_image.is_empty(), "Albedo HD no encontrado: " + str(entry.albedo))
        var hd_texture := ImageTexture.create_from_image(hd_image)
        _add_panel(scene_root, Vector3(x + 0.82, 0.0, 0.0), hd_texture)

    await process_frame
    await process_frame
    await process_frame
    var image: Image = root.get_texture().get_image()
    var error: Error = image.save_png(OUTPUT)
    assert(error == OK, "No se pudo guardar la comparacion: " + str(error))
    print("HD_VISUAL_PREVIEW: " + OUTPUT)
    print("HD_VISUAL_PREVIEW_SIZE: " + str(image.get_width()) + "x" + str(image.get_height()))
    quit(0)

func _add_panel(parent: Node3D, position: Vector3, texture: Texture2D) -> void:
    var panel := MeshInstance3D.new()
    var box := BoxMesh.new()
    box.size = Vector3(1.55, 2.05, 0.06)
    panel.mesh = box
    var material := StandardMaterial3D.new()
    material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    material.albedo_texture = texture
    material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
    material.cull_mode = BaseMaterial3D.CULL_DISABLED
    panel.material_override = material
    panel.position = position
    parent.add_child(panel)

func _add_label(parent: Node3D, value: String, position: Vector3, material: StandardMaterial3D) -> void:
    var label := Label3D.new()
    label.text = value
    label.font_size = 32
    label.pixel_size = 0.0035
    label.modulate = Color(0.95, 0.9, 0.78)
    label.position = position
    label.billboard = BaseMaterial3D.BILLBOARD_DISABLED
    label.material_override = material
    parent.add_child(label)
