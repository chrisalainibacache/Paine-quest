extends SceneTree

## Captura el andén norte real con su cámara fija de producción.
## No modifica escenas, materiales ni recursos del juego.
const SCENE_PATH := "res://levels/station/platform.tscn"
const OUTPUT := "artifacts/hd_stage1/andén_real_camara_oeste.png"

func _initialize() -> void:
    call_deferred("_render_station")

func _render_station() -> void:
    var packed := load(SCENE_PATH) as PackedScene
    assert(packed != null, "No se pudo cargar el escenario real: " + SCENE_PATH)

    var station := packed.instantiate()
    assert(station != null, "No se pudo instanciar el andén norte")
    root.add_child(station)

    var camera := station.get_node_or_null("Cameras/West/Camera") as Camera3D
    assert(camera != null, "No se encontró la cámara fija oeste del andén")
    camera.make_current()

    # Espera a que _ready, los materiales y el render terminen de inicializarse.
    for frame in range(8):
        await process_frame

    var image := root.get_texture().get_image()
    assert(not image.is_empty(), "La captura del andén quedó vacía")
    var error := image.save_png(OUTPUT)
    assert(error == OK, "No se pudo guardar la captura: " + str(error))

    print("HD_REAL_STATION_PREVIEW: " + OUTPUT)
    print("HD_REAL_STATION_PREVIEW_SIZE: " + str(image.get_width()) + "x" + str(image.get_height()))
    quit(0)
