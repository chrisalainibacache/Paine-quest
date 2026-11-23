class_name LeverSequence
extends Interactable
## Control y lógica de una secuencia de palancas. Cada Lever envía su ID;
## el orden se compara con PuzzleData.sequence y el avance queda guardado.

enum Result { WRONG, RESULT_PROGRESS, RESULT_SOLVED }

@export var puzzle: PuzzleData

func _init() -> void:
    prompt = "REVISAR MECANISMO"
    reach = 1.4


func can_interact() -> bool:
    return puzzle != null and puzzle.is_valid()


func interact(_player: Player) -> void:
    if puzzle == null or not puzzle.is_valid():
        await Dialogue.say(["El mecanismo no responde."])
        return
    if is_solved(puzzle):
        await Dialogue.say(["El mecanismo ya está abierto."])
        return
    var progress := PuzzleState.get_lever_sequence_progress(puzzle.id)
    await Dialogue.say(["El orden de las palancas está incompleto (%d de %d)." % [progress, puzzle.sequence.size()]])


static func is_solved(definition: PuzzleData) -> bool:
    return definition != null and GameState.has_flag("puzzle:" + definition.id + ":lever_solved")


static func register_lever(definition: PuzzleData, lever_id: String, unlock_id: String = "") -> int:
    if definition == null or not definition.is_valid() or definition.puzzle_type != PuzzleData.PuzzleType.LEVER_SEQUENCE:
        return Result.WRONG
    if is_solved(definition):
        return Result.RESULT_SOLVED

    var progress := PuzzleState.get_lever_sequence_progress(definition.id)
    if progress < 0 or progress >= definition.sequence.size():
        progress = 0
    if definition.sequence[progress] != lever_id:
        PuzzleState.set_lever_sequence_progress(definition.id, 0)
        return Result.WRONG

    progress += 1
    PuzzleState.set_lever_sequence_progress(definition.id, progress)
    if progress < definition.sequence.size():
        return Result.RESULT_PROGRESS

    GameState.set_flag("puzzle:" + definition.id + ":lever_solved")
    if not unlock_id.is_empty():
        GameState.set_flag("unlocked:" + unlock_id)
    return Result.RESULT_SOLVED
