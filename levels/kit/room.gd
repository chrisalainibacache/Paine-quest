class_name Room
extends Node3D
## Raíz de cada sala. Administra sus cámaras fijas y los puntos de aparición.
## Una sala = una escena en levels/<zona>/.

signal camera_changed(camera: Camera3D)

@export var room_name: String = ""

var _inside: Array[CameraZone] = []
var _active: CameraZone


func _ready() -> void:
    for zone: CameraZone in find_children("*", "CameraZone", true, false):
        zone.player_entered.connect(_on_zone_entered)
        zone.player_exited.connect(_on_zone_exited)


## Posición y orientación donde aparece Cony (Marker3D hijo de "Spawns").
func get_spawn(spawn_id: String) -> Transform3D:
    var marker := get_node_or_null("Spawns/" + spawn_id) as Node3D
    if marker == null:
        push_warning("Sala %s: no existe el spawn '%s'" % [name, spawn_id])
        return Transform3D.IDENTITY
    return marker.global_transform


## Elige la cámara inicial según dónde quedó Cony (se llama tras ubicarla).
func pick_camera_for(body: Node3D) -> void:
    _inside.clear()
    for zone: CameraZone in find_children("*", "CameraZone", true, false):
        if zone.overlaps_body(body):
            _inside.append(zone)
    _refresh()


func get_active_camera() -> Camera3D:
    return _active.get_camera() if _active else null


func _on_zone_entered(zone: CameraZone) -> void:
    _inside.erase(zone)
    _inside.append(zone)
    _refresh()


func _on_zone_exited(zone: CameraZone) -> void:
    _inside.erase(zone)
    # Si Cony salió de todas las zonas, se mantiene la última cámara.
    if not _inside.is_empty():
        _refresh()


func _refresh() -> void:
    if _inside.is_empty():
        return
    # La más reciente gana; a igualdad, la de mayor prioridad.
    var best: CameraZone = _inside[-1]
    for zone in _inside:
        if zone.camera_priority > best.camera_priority:
            best = zone
    if best == _active:
        return
    _active = best
    var camera := best.get_camera()
    if camera:
        camera.make_current()
        camera_changed.emit(camera)
