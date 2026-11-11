extends SceneTree

const OUTPUT := "artifacts/hd_stage1/comparacion_normales_luz.png"
const ENTRIES := [
    {"name": "CONCRETO", "albedo": "res://assets/environment/textures/concrete.png", "normal": "artifacts/hd_stage1/concrete_normal_512.png"},
    {"name": "MAMPOSTERÍA", "albedo": "res://assets/environment/textures/bricks_old.png", "normal": "artifacts/hd_stage1/old_bricks_normal_512.png"},
    {"name": "ASFALTO", "albedo": "res://assets/environment/textures/asphalt_cracked.png", "normal": "artifacts/hd_stage1/asphalt_cracked_normal_512.png"}
]

func _initialize() -> void:
    call_deferred("_render")

func _render() -> void:
    var scene := Node3D.new()
    root.add_child(scene)

    var camera := Camera3D.new()
    camera.position = Vector3(0.0, 3.2, 13.0)
    camera.look_at(Vector3.ZERO)
    camera.current = true
    camera.fov = 44.0
    scene.add_child(camera)

    var light := DirectionalLight3D.new()
    light.rotation_degrees = Vector3(-42.0, -28.0, 0.0)
    light.light_energy = 1.35
    light.shadow_enabled = true
    scene.add_child(light)

    var fill := OmniLight3D.new()
    fill.position = Vector3(0.0, 3.0, 4.0)
    fill.light_energy = 0.35
    fill.omni_range = 12.0
    scene.add_child(fill)

    var environment_node := WorldEnvironment.new()
    var environment := Environment.new()
    environment.background_mode = Environment.BG_COLOR
    environment.background_color = Color(0.045, 0.05, 0.06)
    environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    environment.ambient_light_color = Color(0.48, 0.48, 0.48)
    environment.ambient_light_energy = 0.55
    environment_node.environment = environment
    scene.add_child(environment_node)

    for index in range(ENTRIES.size()):
        var entry: Dictionary = ENTRIES[index]
        var albedo := load(str(entry.albedo)) as Texture2D
        var normal_image := Image.load_from_file(str(entry.normal))
        assert(albedo != null, "Albedo faltante: " + str(entry.name))
        assert(not normal_image.is_empty(), "Mapa normal faltante: " + str(entry.normal))
        assert(normal_image.get_width() == 512 and normal_image.get_height() == 512,
            "Mapa normal debe ser 512x512: " + str(entry.normal))
        var normal_texture := ImageTexture.create_from_image(normal_image)

        # Par A/B: mismo albedo e iluminación; solo cambia la intensidad de normales.
        for side in range(2):
            var material := ShaderMaterial.new()
            material.shader = load("res://shaders/ps1_surface_hd_pilot.gdshader") as Shader
            material.set_shader_parameter("albedo_tex", albedo)
            material.set_shader_parameter("normal_tex", normal_texture)
            material.set_shader_parameter("normal_strength", 0.0 if side == 0 else 0.55)
            material.set_shader_parameter("tile_meters", 1.5)
            material.set_shader_parameter("detail_mix", 0.0)
            material.set_shader_parameter("macro_strength", 0.0)
            material.set_shader_parameter("grime_strength", 0.0)

            var cube := MeshInstance3D.new()
            var mesh := BoxMesh.new()
            mesh.size = Vector3(1.35, 1.35, 1.35)
            cube.mesh = mesh
            cube.material_override = material
            var x := (float(index * 2 + side) - 2.5) * 1.9
            cube.position = Vector3(x, 0.0, 0.0)
            scene.add_child(cube)

            var label := Label3D.new()
            label.text = str(entry.name) + ("\\nSIN NORMAL" if side == 0 else "\\nNORMAL 0.55")
            label.position = cube.position + Vector3(0.0, 1.0, 0.0)
            label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
            label.font_size = 22
            label.pixel_size = 0.004
            label.modulate = Color(0.92, 0.88, 0.76)
            label.outline_size = 5
            scene.add_child(label)

    await process_frame
    await process_frame
    await process_frame
    var image: Image = root.get_texture().get_image()
    var error: Error = image.save_png(OUTPUT)
    assert(error == OK, "No se pudo guardar el render de normales")
    print("HD_NORMAL_LIGHT_PREVIEW: " + OUTPUT)
    print("HD_NORMAL_LIGHT_SIZE: " + str(image.get_width()) + "x" + str(image.get_height()))
    quit(0)
