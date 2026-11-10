extends SceneTree

const OUTPUT := "artifacts/hd_stage1/comparacion_hd.png"
const MATERIALS := [
    {"name": "CONCRETO", "source": "res://levels/kit/materials/concrete_wall.tres", "albedo": "artifacts/hd_stage1/concrete_hd_2x.png", "normal": "artifacts/hd_stage1/concrete_normal_512.png"},
    {"name": "LADRILLO", "source": "res://levels/kit/materials/old_bricks_wall.tres", "albedo": "artifacts/hd_stage1/bricks_old_hd_2x.png", "normal": "artifacts/hd_stage1/bricks_old_normal_512.png"},
    {"name": "ASFALTO", "source": "res://levels/kit/materials/asphalt.tres", "albedo": "artifacts/hd_stage1/asphalt_cracked_hd_2x.png", "normal": "artifacts/hd_stage1/asphalt_cracked_normal_512.png"}
]

func _initialize() -> void:
    call_deferred("_render_preview")

func _render_preview() -> void:
    var root_3d := Node3D.new()
    root_3d.name = "HDMaterialComparison"
    root.add_child(root_3d)

    var camera := Camera3D.new()
    camera.position = Vector3(0.0, 0.0, 13.0)
    camera.projection = Camera3D.PROJECTION_ORTHOGONAL
    camera.size = 8.2
    camera.current = true
    root_3d.add_child(camera)

    var light := DirectionalLight3D.new()
    light.rotation_degrees = Vector3(-22.0, -18.0, 0.0)
    light.light_energy = 1.15
    root_3d.add_child(light)

    var environment := WorldEnvironment.new()
    var env := Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = Color(0.055, 0.06, 0.07)
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.55, 0.55, 0.55)
    env.ambient_light_energy = 0.55
    environment.environment = env
    root_3d.add_child(environment)

    var font_material := StandardMaterial3D.new()
    font_material.albedo_color = Color(0.92, 0.88, 0.76)
    var hd_shader := load("res://shaders/ps1_surface_hd_pilot.gdshader") as Shader
    assert(hd_shader != null, "No se pudo cargar el shader HD")

    for index in range(MATERIALS.size()):
        var entry: Dictionary = MATERIALS[index]
        var x := (float(index) - 1.0) * 4.1
        _add_label(root_3d, str(entry.name) + "\nORIGINAL", Vector3(x - 0.82, 1.55, 0.0), font_material)
        _add_label(root_3d, str(entry.name) + "\nHD PILOTO", Vector3(x + 0.82, -1.55, 0.0), font_material)
        var original := load(str(entry.source)) as Material
        assert(original != null, "Material original no encontrado: " + str(entry.source))
        _add_panel(root_3d, Vector3(x - 0.82, 0.0, 0.0), original)

        var albedo_image := Image.load_from_file(str(entry.albedo))
        var normal_image := Image.load_from_file(str(entry.normal))
        assert(not albedo_image.is_empty(), "Albedo HD no encontrado: " + str(entry.albedo))
        assert(not normal_image.is_empty(), "Normal HD no encontrado: " + str(entry.normal))
        var hd_material := ShaderMaterial.new()
        hd_material.shader = hd_shader
        var source_material := original as ShaderMaterial
        hd_material.set_shader_parameter("albedo_tex", ImageTexture.create_from_image(albedo_image))
        hd_material.set_shader_parameter("normal_tex", ImageTexture.create_from_image(normal_image))
        for parameter in ["tint", "tile_meters", "grime_strength", "macro_strength"]:
            hd_material.set_shader_parameter(parameter, source_material.get_shader_parameter(parameter))
        hd_material.set_shader_parameter("normal_strength", 0.35)
        hd_material.set_shader_parameter("detail_mix", 0.3)
        _add_panel(root_3d, Vector3(x + 0.82, 0.0, 0.0), hd_material)

    await process_frame
    await process_frame
    var image := root.get_root().get_texture().get_image()
    var error := image.save_png(OUTPUT)
    assert(error == OK, "No se pudo guardar la comparacion: " + str(error))
    print("HD_VISUAL_PREVIEW: " + OUTPUT)
    print("HD_VISUAL_PREVIEW_SIZE: " + str(image.get_width()) + "x" + str(image.get_height()))
    quit(0)

func _add_panel(parent: Node3D, position: Vector3, material: Material) -> void:
    var panel := MeshInstance3D.new()
    var plane := PlaneMesh.new()
    plane.size = Vector2(1.55, 2.05)
    panel.mesh = plane
    panel.rotation_degrees.x = -90.0
    panel.position = position
    panel.material_override = material
    parent.add_child(panel)

func _add_label(parent: Node3D, value: String, position: Vector3, material: Material) -> void:
    var label := Label3D.new()
    label.text = value
    label.font_size = 32
    label.pixel_size = 0.0035
    label.modulate = Color(0.95, 0.9, 0.78)
    label.position = position
    label.billboard = BaseMaterial3D.BILLBOARD_DISABLED
    parent.add_child(label)
