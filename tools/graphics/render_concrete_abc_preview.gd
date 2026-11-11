extends SceneTree

## A/B/C de la pared lateral de concreto real.
## A = original; B = candidato sutil; C = microdetalle reforzado.
## Cada variante usa una copia aislada del ShaderMaterial. No se modifica producción.
const SCENE_PATH := "res://levels/station/platform.tscn"
const OUTPUT_DIR := "artifacts/hd_stage1"
const CAMERAS := ["West", "East"]
const TARGET_NODE := "Walls/WestWall/Mesh"
const VARIANTS := [
    {"key": "original", "texture": ""},
    {"key": "subtle", "texture": "concrete_hd_2x.png"},
    {"key": "artdirected", "texture": "concrete_hd_2x_artdirected.png"},
]

func _initialize() -> void:
    call_deferred("_render_abc")


func _capture(camera: Camera3D, label: String) -> void:
    camera.make_current()
    for frame in range(5):
        await process_frame
    assert(camera.current, "La cámara no quedó activa: " + label)
    var image := root.get_texture().get_image()
    assert(not image.is_empty(), "Captura vacía: " + label)
    assert(image.get_width() >= 640 and image.get_height() >= 360,
        "Resolución insuficiente: " + str(image.get_size()))
    var path := "%s/concrete_abc_%s.png" % [OUTPUT_DIR, label]
    var error := image.save_png(path)
    assert(error == OK, "No se pudo guardar " + path + ": " + str(error))
    print("CONCRETE_ABC_CAPTURE: " + path)


func _render_abc() -> void:
    var packed := load(SCENE_PATH) as PackedScene
    assert(packed != null, "No se pudo cargar " + SCENE_PATH)
    var station := packed.instantiate()
    assert(station != null, "No se pudo instanciar la estación")
    root.add_child(station)

    var mesh := station.get_node_or_null(TARGET_NODE) as MeshInstance3D
    assert(mesh != null, "No se encontró " + TARGET_NODE)
    var original_material := mesh.material_override as ShaderMaterial
    assert(original_material != null, "Material original no compatible")

    var materials: Array[ShaderMaterial] = []
    for variant in VARIANTS:
        if variant.texture == "":
            materials.append(original_material)
            continue
        var texture_path := "res://%s/%s" % [OUTPUT_DIR, variant.texture]
        var candidate_image := Image.load_from_file(texture_path)
        assert(candidate_image != null and not candidate_image.is_empty(),
            "No se pudo cargar " + texture_path)
        assert(candidate_image.get_width() == 512 and candidate_image.get_height() == 512,
            "Textura candidata no es 512x512: " + texture_path)
        var candidate_material := original_material.duplicate(true) as ShaderMaterial
        assert(candidate_material != null, "No se pudo duplicar el material")
        candidate_material.set_shader_parameter(
            "albedo_tex", ImageTexture.create_from_image(candidate_image)
        )
        materials.append(candidate_material)

    for camera_name in CAMERAS:
        var camera_path := "Cameras/%s/Camera" % camera_name
        var camera := station.get_node_or_null(camera_path) as Camera3D
        assert(camera != null, "No se encontró " + camera_path)
        for index in range(VARIANTS.size()):
            mesh.material_override = materials[index]
            await _capture(camera, "%s_%s" % [camera_name.to_lower(), VARIANTS[index].key])
        mesh.material_override = original_material

    # Diagnóstico adicional: primer plano frontal de la pared de concreto.
    # No modifica la escena ni las cámaras de producción.
    var close_camera := Camera3D.new()
    close_camera.name = "ConcreteDiagnosticCamera"
    close_camera.position = Vector3(-3.6, 2.2, 0.0)
    close_camera.fov = 50.0
    station.add_child(close_camera)
    close_camera.look_at(Vector3(-7.0, 1.3, 0.0), Vector3.UP)
    for index in range(VARIANTS.size()):
        mesh.material_override = materials[index]
        await _capture(close_camera, "closeup_%s" % VARIANTS[index].key)
    mesh.material_override = original_material

    quit(0)
