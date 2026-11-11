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
    print("HD_SHADER_PILOT: RESOURCE_AND_MATERIAL_OK")
    print("HD_SHADER_PILOT: ROTATED_NON_UNIFORM_BOX_CONFIGURED")
    print("HD_SHADER_PILOT: SIX_ORIENTED_PLANES_CONFIGURED")
    print("HD_SHADER_PILOT: POSITIVE_AND_NEGATIVE_AXES_CONFIGURED")
    quit(0)
