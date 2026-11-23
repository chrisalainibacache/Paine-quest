class_name Door
extends Interactable
## Puerta a otra sala. Puede pedir una llave (se abre una vez y queda abierta
## para siempre, de los dos lados si comparten `lock_id`). Sin `target_room`
## es una puerta que no se puede usar (solo muestra `locked_text`).

@export_file("*.tscn") var target_room: String = ""
@export var target_spawn: String = ""
## Llave necesaria (vacío = no tiene llave).
@export var key_item: ItemData
## Identificador compartido por los dos lados de la puerta.
@export var lock_id: String = ""
@export_multiline var locked_text: String = "Está cerrada con llave."
## Texto bajo la flecha (vacío = el nombre de la sala a la que lleva).
@export var marker_text: String = ""
## Tipo de material explícito para seleccionar sonidos; no se infiere del nombre.
@export var metal_door: bool = false

## Nombre de cada sala (para el letrero de las puertas).
const LABELS := {
    "platform": "ANDÉN NORTE", "waiting_room": "SALA DE ESPERA", "ticket_office": "BOLETERÍA",
    "service_corridor": "PASILLO DE SERVICIO", "storeroom": "BODEGA", "south_platform": "ANDÉN SUR",
    "track_north": "LA VÍA", "derailed_train": "TREN DESCARRILADO", "wagon_interior": "INTERIOR DEL VAGÓN",
    "convoy_side": "COSTADO DEL CONVOY", "underpass": "PASO BAJO NIVEL", "switch_house": "CASA DE CAMBIOS",
    "bridge": "PUENTE DEL MAIPO", "checkpoint": "CONTROL MILITAR", "field": "POTRERO",
    "station": "ESTACIÓN DE BUIN", "warehouse": "BODEGA AGRÍCOLA", "vineyard": "VIÑA", "shed": "GALPÓN",
    "maestranza_acceso": "ACCESO A LA MAESTRANZA", "maestranza_guardia": "PUESTO DE GUARDIA",
    "maestranza_enfermeria": "ENFERMERÍA", "maestranza_taller": "TALLER DE MANTENIMIENTO",
    "maestranza_vestuario": "VESTUARIO", "maestranza_pasillo_cuarentena": "PASILLO DE CUARENTENA",
    "maestranza_puesto_sanitario": "PUESTO SANITARIO",
}
const MARKER_COLOR := Color(1.0, 0.82, 0.35)
const LOCKED_COLOR := Color(0.95, 0.35, 0.3)

var _marker: Node3D
var _marker_label: Label3D
var _marker_arrow: Label3D


func _init() -> void:
    prompt = "ABRIR"


func _ready() -> void:
    super._ready()
    _build_marker()


## Nombre de la sala a la que lleva una ruta (vacío si no está en la lista).
static func label_for(room_path: String) -> String:
    return LABELS.get(room_path.get_file().get_basename(), "")


## Flecha que flota sobre la puerta y letrero con adónde lleva: así se ve a dónde ir
## (también a través de vagones y muros). Las puertas de vuelta no llevan flecha.
func _build_marker() -> void:
    if target_room.is_empty() or prompt == "VOLVER":
        return
    _marker = Node3D.new()
    _marker.name = "Marker"
    _marker.position = Vector3(0.0, 2.3, 0.0)
    add_child(_marker)
    # La flecha es un símbolo ▼ (siempre nítido, aunque la cámara mire desde arriba).
    _marker_arrow = Label3D.new()
    _marker_arrow.text = "▼"
    _marker_arrow.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    _marker_arrow.no_depth_test = true
    _marker_arrow.fixed_size = true
    _marker_arrow.pixel_size = 0.0011
    _marker_arrow.font_size = 64
    _marker_arrow.outline_size = 14
    _marker.add_child(_marker_arrow)
    _marker_label = Label3D.new()
    _marker_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    _marker_label.no_depth_test = true
    _marker_label.fixed_size = true
    _marker_label.pixel_size = 0.0011
    _marker_label.font_size = 34
    _marker_label.outline_size = 12
    _marker_label.position = Vector3(0.0, 0.4, 0.0)
    _marker.add_child(_marker_label)
    var bob := _marker.create_tween().set_loops()
    bob.tween_property(_marker, "position:y", 2.42, 0.6).set_trans(Tween.TRANS_SINE)
    bob.tween_property(_marker, "position:y", 2.18, 0.6).set_trans(Tween.TRANS_SINE)
    var timer := Timer.new()
    timer.wait_time = 0.4
    timer.autostart = true
    timer.timeout.connect(_refresh_marker)
    add_child(timer)
    _refresh_marker()


## Amarilla si se puede pasar; roja con "CON LLAVE" si falta la llave.
func _refresh_marker() -> void:
    if _marker == null:
        return
    var blocked := is_locked() and not GameState.inventory.has_id(key_item.id)
    var color := LOCKED_COLOR if blocked else MARKER_COLOR
    _marker_arrow.modulate = color
    _marker_arrow.outline_modulate = Color(0.05, 0.04, 0.03)
    _marker_label.modulate = color
    _marker_label.outline_modulate = Color(0.05, 0.04, 0.03)
    _marker_label.text = "CON LLAVE" if blocked else (marker_text if not marker_text.is_empty() else label_for(target_room))


func is_locked() -> bool:
    return key_item != null and not GameState.has_flag("unlocked:" + _lock_key())


func _is_metal_door() -> bool:
    return metal_door


func _play_locked_sound() -> void:
    Sfx.play("gate_chain" if _is_metal_door() else "locked", global_position, -3.0)


func _play_open_sound() -> void:
    Sfx.play("door_metal" if _is_metal_door() else "door", global_position, -2.0)


func interact(_player: Player) -> void:
    if is_locked():
        if GameState.inventory.has_id(key_item.id):
            GameState.set_flag("unlocked:" + _lock_key())
            Sfx.play("unlock", null, -3.0)
            if _all_key_locks_unlocked(key_item):
                GameState.inventory.take(key_item, 1)
                await Dialogue.say(["Usé: %s." % key_item.display_name, "Ya no necesito esta llave."])
            else:
                await Dialogue.say(["Usé: %s." % key_item.display_name])
        else:
            _play_locked_sound()
            await Dialogue.say([locked_text])
            return
    if target_room.is_empty():
        _play_locked_sound()
        await Dialogue.say([locked_text])
        return
    _play_open_sound()
    # Sin await: esta puerta se borra junto con la sala al cambiar.
    SceneLoader.go_to(target_room, target_spawn)


func _lock_key() -> String:
    return lock_id if not lock_id.is_empty() else GameState.node_key(self)



func _all_key_locks_unlocked(item: ItemData) -> bool:
    if item.lock_ids.is_empty():
        return false
    for required_lock: String in item.lock_ids:
        if not GameState.has_flag("unlocked:" + required_lock):
            return false
    return true
