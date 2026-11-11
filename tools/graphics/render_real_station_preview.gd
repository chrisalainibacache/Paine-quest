extends SceneTree

## Captura el andén norte real desde sus dos cámaras fijas de producción.
## No modifica escenas, materiales ni recursos del juego.
const SCENE_PATH := "res://levels/station/platform.tscn"
const OUTPUT_DIR := "artifacts/hd_stage1"
const CAMERA_NAMES := ["West", "East"]

func _initialize() -> void:
    call_deferred("_render_station")


func _render_station() -> void:
    var packed := load(SCENE_PATH) as PackedScene
    assert(packed != null, "No se pudo cargar el escenario real: " + SCENE_PATH)

    var station := packed.instantiate()
    assert(station != null, "No se pudo instanciar el andén norte")
    root.add_child(station)

    for camera_name in CAMERA_NAMES:
        var camera_path := "Cameras/%s/Camera" % camera_name
        var camera := station.get_node_or_null(camera_path) as Camera3D
        assert(camera != null, "No se encontró la cámara fija: " + camera_path)

        camera.make_current()
        for frame in range(4):
            await process_frame

        assert(camera.current, "La cámara no quedó activa: " + camera_name)
        var image := root.get_texture().get_image()
        assert(not image.is_empty(), "La captura quedó vacía: " + camera_name)
        assert(image.get_width() >= 640 and image.get_height() >= 360,
            "Resolución insuficiente: " + str(image.get_size()))

        var output := "%s/anden_real_camara_%s.png" % [OUTPUT_DIR, camera_name.to_lower()]
        var error := image.save_png(output)
        assert(error == OK, "No se pudo guardar " + output + ": " + str(error))

        print("HD_REAL_STATION_PREVIEW: " + output)
        print("HD_REAL_STATION_PREVIEW_SIZE: " + str(image.get_width()) + "x" + str(image.get_height()))

    quit(0)
