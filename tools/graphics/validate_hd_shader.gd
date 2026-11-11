extends SceneTree

const FACE_TESTS := [
    {"name": "+Y", "rotation": Vector3.ZERO},
    {"name": "-Y", "rotation": Vector3(0.0, 0.0, PI)},
    {"name": "+X", "rotation": Vector3(0.0, 0.0, -PI * 0.5)},
    {"name": "-X", "rotation": Vector3(0.0, 0.0, PI * 0.5)},
    {"name": "+Z", "rotation": Vector3(PI * 0.5, 0.0, 0.0)},
    {"name": "-Z", "rotation": Vector3(-PI * 0.5, 0.0, 0.0)}
]

func _initialize() -> void:
    call_deferred("_run_validation")

func _run_validation() -> void:
    var shader := load("res://shaders/ps1_surface_hd_pilot.gdshader") as Shader
    assert(shader != null, "No se pudo cargar el shader HD piloto")

    var material := ShaderMaterial.new()
    material.shader = shader

    var albedo_texture := load("res://assets/environment/textures/concrete.png") as Texture2D
    assert(albedo_texture != null, "No se pudo cargar la textura de concreto")
    material.set_shader_parameter("albedo_tex", albedo_texture)

    var normal_image := Image.load_from_file("artifacts/hd_stage1/concrete_normal_512.png")
    assert(not normal_image.is_empty(), "No se pudo cargar la normal HD de prueba")
    assert(normal_image.get_width() == 512 and normal_image.get_height() == 512,
        "La normal de prueba debe medir 512x512")
    material.set_shader_parameter("normal_tex", ImageTexture.create_from_image(normal_image))
    material.set_shader_parameter("normal_strength", 0.35)

    var scene := Node3D.new()
    root.add_child(scene)

    var camera := Camera3D.new()
    camera.position = Vector3(0.0, 3.8, 11.5)
    camera.look_at(Vector3.ZERO)
    camera.current = true
    camera.fov = 48.0
    scene.add_child(camera)

    var light := DirectionalLight3D.new()
    light.rotation_degrees = Vector3(-48.0, -28.0, 0.0)
    light.light_energy = 1.25
    scene.add_child(light)

    var environment_node := WorldEnvironment.new()
    var environment := Environment.new()
    environment.background_mode = Environment.BG_COLOR
    environment.background_color = Color(0.045, 0.05, 0.06)
    environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    environment.ambient_light_color = Color(0.55, 0.55, 0.55)
    environment.ambient_light_energy = 0.65
    environment_node.environment = environment
    scene.add_child(environment_node)

    # Caja rotada y con escala no uniforme: detecta errores de matriz normal.
    var box := MeshInstance3D.new()
    box.mesh = BoxMesh.new()
    box.rotation_degrees = Vector3(17.0, 31.0, -9.0)
    box.scale = Vector3(1.7, 0.8, 1.2)
    box.material_override = material
    box.position = Vector3(0.0, 0.0, -2.0)
    scene.add_child(box)

    # Seis planos comprueban las proyecciones y las caras con normal invertida.
    for index in range(FACE_TESTS.size()):
        var face: Dictionary = FACE_TESTS[index]
        var plane := MeshInstance3D.new()
        var plane_mesh := PlaneMesh.new()
        plane_mesh.size = Vector2(1.5, 1.5)
        plane.mesh = plane_mesh
        plane.rotation = face.rotation
        plane.scale = Vector3(1.2, 0.8, 1.0)
        plane.material_override = material
        plane.position = Vector3((float(index) - 2.5) * 1.8, 0.0, 1.5)
        scene.add_child(plane)

    await process_frame
    await process_frame
    await process_frame
    var preview := root.get_texture().get_image()
    assert(not preview.is_empty(), "El viewport no produjo imagen para validar")
    var save_error := preview.save_png("artifacts/hd_stage1/shader_orientaciones.png")
    assert(save_error == OK, "No se pudo guardar shader_orientaciones.png")
    print("HD_SHADER_PILOT: PREVIEW=artifacts/hd_stage1/shader_orientaciones.png")
    print("HD_SHADER_PILOT: PREVIEW_SIZE=" + str(preview.get_width()) + "x" + str(preview.get_height()))
    print("HD_SHADER_PILOT: RESOURCE_AND_MATERIAL_OK")
    print("HD_SHADER_PILOT: ROTATED_NON_UNIFORM_BOX_CONFIGURED")
    print("HD_SHADER_PILOT: SIX_ORIENTED_PLANES_CONFIGURED")
    print("HD_SHADER_PILOT: POSITIVE_AND_NEGATIVE_AXES_CONFIGURED")
    quit(0)
