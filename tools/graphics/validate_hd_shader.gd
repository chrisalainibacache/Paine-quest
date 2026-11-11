extends SceneTree

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
    material.set_shader_parameter("normal_tex", ImageTexture.create_from_image(normal_image))
    material.set_shader_parameter("normal_strength", 0.35)

    var instance := MeshInstance3D.new()
    instance.mesh = BoxMesh.new()
    instance.rotation_degrees = Vector3(17.0, 31.0, -9.0)
    instance.scale = Vector3(1.7, 0.8, 1.2)
    instance.material_override = material

    var scene := Node3D.new()
    scene.add_child(instance)
    root.add_child(scene)

    await process_frame
    await process_frame
    print("HD_SHADER_PILOT: RESOURCE_AND_MATERIAL_OK")
    print("HD_SHADER_PILOT: ROTATED_NON_UNIFORM_BOX_CONFIGURED")
    quit(0)
