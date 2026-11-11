extends SceneTree

## Comparación A/B del pavimento en el escenario real.
## A = material original. B = mismo shader/parámetros con textura 2x Lanczos.
## No modifica ni guarda recursos de producción.
const SCENE_PATH := "res://levels/station/platform.tscn"
const CANDIDATE_PATH := "res://artifacts/hd_stage1/paving_hd_2x.png"
const OUTPUT_DIR := "artifacts/hd_stage1"
const CAMERA_NAMES := ["West", "East"]

func _initialize() -> void:
    call_deferred("_render_ab")


func _capture(camera: Camera3D, label: String) -> void:
    camera.make_current()
    for frame in range(5):
        await process_frame
    assert(camera.current, "La cámara no quedó activa: " + label)
    var image := root.get_texture().get_image()
    assert(not image.is_empty(), "Captura vacía: " + label)
    assert(image.get_width() >= 640 and image.get_height() >= 360,
        "Resolución insuficiente: " + str(image.get_size()))
    var path := "%s/paving_ab_%s.png" % [OUTPUT_DIR, label]
    var error := image.save_png(path)
    assert(error == OK, "No se pudo guardar " + path + ": " + str(error))
    print("PAVING_AB_CAPTURE: " + path)


func _render_ab() -> void:
    var packed := load(SCENE_PATH) as PackedScene
    assert(packed != null, "No se pudo cargar " + SCENE_PATH)
    var station := packed.instantiate()
    assert(station != null, "No se pudo instanciar la estación")
    root.add_child(station)

    var mesh := station.get_node_or_null("Ground/PlatformSlab/Mesh") as MeshInstance3D
    assert(mesh != null, "No se encontró Ground/PlatformSlab/Mesh")
    var original_material := mesh.material_override as ShaderMaterial
    assert(original_material != null, "El pavimento no usa ShaderMaterial en material_override")

    var candidate_image := Image.load_from_file(CANDIDATE_PATH)
    assert(candidate_image != null and not candidate_image.is_empty(),
        "No se pudo cargar el candidato " + CANDIDATE_PATH)
    assert(candidate_image.get_width() == 512 and candidate_image.get_height() == 512,
        "El candidato de pavimento debe ser 512x512")
    var candidate_texture := ImageTexture.create_from_image(candidate_image)
    var candidate_material := original_material.duplicate(true) as ShaderMaterial
    assert(candidate_material != null, "No se pudo duplicar el material")
    candidate_material.set_shader_parameter("albedo_tex", candidate_texture)

    for camera_name in CAMERA_NAMES:
        var camera_path := "Cameras/%s/Camera" % camera_name
        var camera := station.get_node_or_null(camera_path) as Camera3D
        assert(camera != null, "No se encontró " + camera_path)

        mesh.material_override = original_material
        await _capture(camera, camera_name.to_lower() + "_original")
        mesh.material_override = candidate_material
        await _capture(camera, camera_name.to_lower() + "_candidate")

    mesh.material_override = original_material
    quit(0)
