class_name GameState
extends RefCounted
## Progreso de la partida: mochila, notas leídas, banderas (ítems recogidos,
## infectados muertos, puertas abiertas), salud, munición y sala actual.
## Fuente única de verdad: las salas consultan aquí qué ya pasó.
## Todo es estático para poder usarlo desde cualquier script (y desde las
## pruebas headless, que no ven los autoloads al compilar).

const START_ROOM := "res://levels/station/platform.tscn"
const START_SPAWN := "start"
const PISTOL := preload("res://data/items/pistol.tres")
const AMMO_9MM := preload("res://data/items/ammo_9mm.tres")
## Lo que lleva Cony al empezar: [ítem, cantidad]. 7 armas + 5 tipos de munición.
const STARTING_LOADOUT := [
    ["res://data/items/pistol.tres", 1],
    ["res://data/items/mauser.tres", 1],
    ["res://data/items/shotgun.tres", 1],
    ["res://data/items/assault_rifle.tres", 1],
    ["res://data/items/sniper_rifle.tres", 1],
    ["res://data/items/grenade_launcher.tres", 1],
    ["res://data/items/bazooka.tres", 1],
    ["res://data/items/ammo_9mm.tres", 30],
    ["res://data/items/ammo_shells.tres", 10],
    ["res://data/items/ammo_rifle.tres", 45],
    ["res://data/items/ammo_grenades.tres", 6],
    ["res://data/items/ammo_rockets.tres", 2],
]

static var inventory := Inventory.new()
## Arma equipada (null = sin arma).
static var equipped: ItemData
## Rutas de los DocumentData leídos, en orden.
static var documents: Array[String] = []
## Banderas de progreso: "taken:<sala>:<nodo>", "dead:...", "unlocked:<id>"...
static var flags: Dictionary = {}
## true cuando ya hay una partida en curso (nueva o cargada).
static var started := false
static var health := 100
static var clip := 0
## Balas que quedaron en el cargador de cada arma guardada (id del ítem → balas).
static var clips: Dictionary = {}
static var room_path := START_ROOM
static var spawn_id := START_SPAWN
## Al cargar una partida, Cony aparece exactamente donde guardó.
static var spawn_transform: Transform3D
static var use_spawn_transform := false
## Segundos jugados (se muestra en la máquina de escribir).
static var play_time := 0.0


static func new_game() -> void:
    inventory.clear()
    documents.clear()
    flags.clear()
    health = 100
    room_path = START_ROOM
    spawn_id = START_SPAWN
    use_spawn_transform = false
    play_time = 0.0
    started = true
    clips.clear()
    # Cony empieza con su arsenal en la mochila (todas las armas cargadas).
    for entry in STARTING_LOADOUT:
        inventory.add(load(entry[0]) as ItemData, entry[1])
    equipped = PISTOL
    clip = PISTOL.weapon.clip_size


## Asegura la pistola equipada y balas extra (pruebas y capturas).
static func give_pistol(ammo: int = 20) -> void:
    if not inventory.has_id(PISTOL.id):
        inventory.add(PISTOL)
    inventory.add(AMMO_9MM, ammo)
    equip(PISTOL)
    clip = PISTOL.weapon.clip_size
    set_flag("found:pistol")


## Cambia el arma equipada guardando las balas que quedaron en el cargador.
static func equip(item: ItemData) -> void:
    if equipped and equipped != item:
        clips[equipped.id] = clip
    equipped = item
    if item and item.weapon:
        clip = int(clips.get(item.id, item.weapon.clip_size))


static func set_flag(flag: String, value: Variant = true) -> void:
    flags[flag] = value


static func has_flag(flag: String) -> bool:
    return flags.has(flag)


static func get_flag(flag: String, default: Variant = null) -> Variant:
    return flags.get(flag, default)


## Identificador estable de un nodo dentro de su sala (para banderas).
static func node_key(node: Node) -> String:
    var room: Node = node
    while room and not room is Room:
        room = room.get_parent()
    if room == null:
        return str(node.get_path())
    return "%s:%s" % [room.scene_file_path.get_file().get_basename(), room.get_path_to(node)]


static func add_document(document: DocumentData) -> bool:
    if documents.has(document.resource_path):
        return false
    documents.append(document.resource_path)
    return true


static func to_data() -> Dictionary:
    return {
        "version": 1,
        "inventory": inventory.to_data(),
        "equipped": equipped.resource_path if equipped else "",
        "documents": documents.duplicate(),
        "flags": flags.duplicate(),
        "health": health,
        "clip": clip,
        "clips": clips.duplicate(),
        "room_path": room_path,
        "spawn_transform": var_to_str(spawn_transform),
        "play_time": play_time,
    }


static func from_data(data: Dictionary) -> void:
    inventory.from_data(data.get("inventory", []))
    var equipped_path: String = data.get("equipped", "")
    equipped = load(equipped_path) as ItemData if ResourceLoader.exists(equipped_path) else null
    documents.clear()
    for path: String in data.get("documents", []):
        documents.append(path)
    flags = (data.get("flags", {}) as Dictionary).duplicate()
    health = int(data.get("health", 100))
    clip = int(data.get("clip", 0))
    clips = (data.get("clips", {}) as Dictionary).duplicate()
    room_path = data.get("room_path", START_ROOM)
    spawn_id = START_SPAWN
    spawn_transform = str_to_var(data.get("spawn_transform", "Transform3D()"))
    use_spawn_transform = true
    play_time = float(data.get("play_time", 0.0))
    started = true
