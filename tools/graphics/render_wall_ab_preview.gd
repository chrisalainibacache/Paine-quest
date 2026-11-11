extends SceneTree

## A/B de dos superficies de muro del andén real.
## A = material original. B = duplicado del mismo material con textura candidata 2x.
## Los recursos de producción nunca se modifican ni se guardan.
const SCENE_PATH := "res://levels/station/platform.tscn"
const OUTPUT_DIR := "artifacts/hd_stage1"
const CAMERAS := ["West", "East"]
const TESTS := [
    {"node": "Walls/RetainingWall/Mesh", "texture": "bricks_old_hd_2x.png", "label": "old_bricks"},
    {"node": "Walls/Facade/Mesh", "texture": "concrete_hd_2x.png", "label": "concrete"},
]

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
    var path := "%s/wall_ab_%s.png" % [OUTPUT_DIR, label]
    var error := image.save_png(path)
    assert(error == OK, "No se pudo guardar " + path + ": " + str(error))
    print("WALL_AB_CAPTURE: " + path)


func _render_ab() -> void:
    var packed := load(SCENE_PATH) as PackedScene
    assert(packed != null, "No se pudo cargar " + SCENE_PATH)
    var station := packed.instantiate()
    assert(station != null, "No se pudo instanciar la estación")
    root.add_child(station)

    for test in TESTS:
        var mesh := station.get_node_or_null(test.node) as MeshInstance3D
        assert(mesh != null, "No se encontró " + test.node)
        var original_material := mesh.material_override as ShaderMaterial
        assert(original_material != null, "Material no compatible en " + test.node)

        var texture_path := "res://%s/%s" % [OUTPUT_DIR, test.texture]
        var candidate_image := Image.load_from_file(texture_path)
        assert(candidate_image != null and not candidate_image.is_empty(),
            "No se pudo cargar " + texture_path)
        assert(candidate_image.get_width() == 512 and candidate_image.get_height() == 512,
            "La textura candidata debe ser 512x512: " + texture_path)
        var candidate_material := original_material.duplicate(true) as ShaderMaterial
        assert(candidate_material != null, "No se pudo duplicar " + test.node)
        candidate_material.set_shader_parameter(
            "albedo_tex", ImageTexture.create_from_image(candidate_image)
        )

        for camera_name in CAMERAS:
            var camera_path := "Cameras/%s/Camera" % camera_name
            var camera := station.get_node_or_null(camera_path) as Camera3D
            assert(camera != null, "No se encontró " + camera_path)
            mesh.material_override = original_material
            await _capture(camera, "%s_%s_original" % [test.label, camera_name.to_lower()])
            mesh.material_override = candidate_material
            await _capture(camera, "%s_%s_candidate" % [test.label, camera_name.to_lower()])
        mesh.material_override = original_material

    quit(0)
