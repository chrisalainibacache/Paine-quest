class_name ZoneMapData
extends Resource

const NOTE_SCRIPT := preload("res://levels/kit/interact/note.gd")
## Grafo navegable de una zona. Las puertas conservan el lock_id y la llave
## real del generador; el estado de cada sala se calcula desde la partida.

enum RoomState { NOT_VISITED, VISITED, PENDING }

@export var id: String = ""
@export var display_name: String = ""
@export var map_item_id: String = ""
@export var grid_size: Vector2i = Vector2i(1, 1)
@export var rooms: Array[Dictionary] = []


func is_valid() -> bool:
    if id.is_empty() or display_name.is_empty() or map_item_id.is_empty() or rooms.is_empty():
        return false
    if grid_size.x < 1 or grid_size.y < 1:
        return false
    var seen: Dictionary = {}
    var occupied: Dictionary = {}
    for room: Dictionary in rooms:
        var room_id := String(room.get("id", ""))
        if room_id.is_empty() or seen.has(room_id):
            return false
        seen[room_id] = true
        if not room.has("grid_position") or not room.has("scene_path"):
            return false
        var grid: Vector2i = room.get("grid_position", Vector2i(-1, -1))
        if grid.x < 0 or grid.y < 0 or grid.x >= grid_size.x or grid.y >= grid_size.y:
            return false
        var cell_key := "%d:%d" % [grid.x, grid.y]
        if occupied.has(cell_key):
            return false
        occupied[cell_key] = true
    for room: Dictionary in rooms:
        for connection_id: String in room.get("connections", PackedStringArray()):
            if not seen.has(connection_id):
                return false
        for door: Dictionary in room.get("doors", []):
            var door_target := String(door.get("target", ""))
            if not door_target.is_empty() and not seen.has(door_target):
                return false
    return true


func room_for(room_id: String) -> Dictionary:
    for room: Dictionary in rooms:
        if String(room.get("id", "")) == room_id:
            return room
    return {}


func is_room_visited(room_id: String) -> bool:
    return GameState.has_flag("visited:" + room_id)


func room_state(room_id: String) -> RoomState:
    if not is_room_visited(room_id):
        return RoomState.NOT_VISITED
    return RoomState.PENDING if is_room_pending(room_id) else RoomState.VISITED


func is_room_pending(room_id: String) -> bool:
    var room_data := room_for(room_id)
    if room_data.is_empty():
        return false
    var scene_path := String(room_data.get("scene_path", ""))
    if scene_path.is_empty() or not ResourceLoader.exists(scene_path):
        return false
    var packed := load(scene_path) as PackedScene
    if packed == null:
        return false
    var instance := packed.instantiate() as Room
    if instance == null:
        return false

    var pending := false
    for pickup: Pickup in instance.find_children("*", "Pickup", true, false):
        var flag_key := "left:" + GameState.node_key(pickup)
        if int(GameState.get_flag(flag_key, pickup.count)) > 0:
            pending = true
            break
    if not pending:
        for note_node: Node in instance.find_children("*", "Interactable", true, false):
            if note_node.get_script() != NOTE_SCRIPT:
                continue
            var document := note_node.get("document") as DocumentData
            if document != null and not GameState.has_flag("read:" + document.id):
                pending = true
                break
    if not pending:
        for code_lock: CodeLock in instance.find_children("*", "CodeLock", true, false):
            if code_lock.puzzle != null and not PuzzleState.is_code_solved(code_lock.puzzle.id):
                pending = true
                break
    if not pending:
        for fuse_box: FuseBox in instance.find_children("*", "FuseBox", true, false):
            if fuse_box.puzzle != null and not GameState.has_flag("puzzle:" + fuse_box.puzzle.id + ":fuse_solved"):
                pending = true
                break
    if not pending:
        for lever_sequence: LeverSequence in instance.find_children("*", "LeverSequence", true, false):
            if lever_sequence.puzzle != null and not LeverSequence.is_solved(lever_sequence.puzzle):
                pending = true
                break
    if not pending:
        for container: SearchContainer in instance.find_children("*", "SearchContainer", true, false):
            if container.puzzle != null and not PuzzleState.is_container_searched(container.puzzle.id):
                pending = true
                break

    instance.free()
    return pending


func has_locked_door(room_id: String) -> bool:
    var room_data := room_for(room_id)
    for door: Dictionary in room_data.get("doors", []):
        var lock_id := String(door.get("lock_id", ""))
        if bool(door.get("one_way", false)) and not bool(door.get("origin", true)) \
                and not GameState.has_flag("one_way_open:" + lock_id):
            return true
        var requires_flag: bool = bool(door.get("requires_flag", false))
        if requires_flag and not GameState.has_flag("unlocked:" + lock_id):
            return true
        var key_item_id: String = String(door.get("key_item_id", ""))
        if not key_item_id.is_empty() and not GameState.has_flag("unlocked:" + lock_id) \
                and not GameState.inventory.has_id(key_item_id):
            return true
    return false


func locked_key_item_id(room_id: String) -> String:
    var room_data := room_for(room_id)
    for door: Dictionary in room_data.get("doors", []):
        var lock_id := String(door.get("lock_id", ""))
        if bool(door.get("one_way", false)) and not bool(door.get("origin", true)) \
                and not GameState.has_flag("one_way_open:" + lock_id):
            return String(door.get("key_item_id", ""))
        var requires_flag: bool = bool(door.get("requires_flag", false))
        if requires_flag and not GameState.has_flag("unlocked:" + lock_id):
            return ""
        var key_item_id: String = String(door.get("key_item_id", ""))
        if not key_item_id.is_empty() and not GameState.has_flag("unlocked:" + lock_id) \
                and not GameState.inventory.has_id(key_item_id):
            return key_item_id
    return ""
