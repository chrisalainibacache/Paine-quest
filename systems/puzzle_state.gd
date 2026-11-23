class_name PuzzleState
extends RefCounted
## Estado de puzzles por instancia. Las banderas se serializan junto con
## GameState, por lo que sobreviven a guardar, cargar y cambiar de sala.

const PREFIX := "puzzle:"


static func set_code_solved(puzzle_id: String, solved: bool = true) -> void:
    _set_or_erase(_key(puzzle_id, "code_solved"), solved)


static func is_code_solved(puzzle_id: String) -> bool:
    return bool(GameState.get_flag(_key(puzzle_id, "code_solved"), false))


static func set_fuse_installed(puzzle_id: String, fuse_id: String, installed: bool = true) -> void:
    if fuse_id.strip_edges().is_empty():
        return
    _set_or_erase(_key(puzzle_id, "fuse:" + fuse_id), installed)


static func is_fuse_installed(puzzle_id: String, fuse_id: String) -> bool:
    return bool(GameState.get_flag(_key(puzzle_id, "fuse:" + fuse_id), false))


static func installed_fuse_count(puzzle_id: String) -> int:
    var prefix := _key(puzzle_id, "fuse:")
    var total := 0
    for raw_key: Variant in GameState.flags.keys():
        var flag := str(raw_key)
        if flag.begins_with(prefix) and bool(GameState.flags[raw_key]):
            total += 1
    return total


static func set_lever_sequence_progress(puzzle_id: String, progress: int) -> void:
    if puzzle_id.strip_edges().is_empty():
        return
    GameState.set_flag(_key(puzzle_id, "lever_progress"), maxi(progress, 0))


static func get_lever_sequence_progress(puzzle_id: String) -> int:
    return int(GameState.get_flag(_key(puzzle_id, "lever_progress"), 0))


static func is_container_searched(puzzle_id: String) -> bool:
    return bool(GameState.get_flag(_key(puzzle_id, "container_searched"), false))


static func mark_container_searched(puzzle_id: String) -> bool:
    if puzzle_id.strip_edges().is_empty() or is_container_searched(puzzle_id):
        return false
    GameState.set_flag(_key(puzzle_id, "container_searched"))
    return true


static func reset_puzzle(puzzle_id: String) -> void:
    if puzzle_id.strip_edges().is_empty():
        return
    var prefix := _key(puzzle_id, "")
    for raw_key: Variant in GameState.flags.keys():
        if str(raw_key).begins_with(prefix):
            GameState.flags.erase(raw_key)


static func _set_or_erase(flag: String, value: bool) -> void:
    if value:
        GameState.set_flag(flag)
    else:
        GameState.flags.erase(flag)


static func _key(puzzle_id: String, state_name: String) -> String:
    return PREFIX + puzzle_id + ":" + state_name
