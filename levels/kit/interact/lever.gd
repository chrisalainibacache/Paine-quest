class_name Lever
extends Interactable
## Palanca que informa su identificador a una secuencia compartida.

@export var puzzle: PuzzleData
@export var lever_id: String = ""
@export var unlock_id: String = ""
@export var required_flag: String = ""

func _init() -> void:
    prompt = "ACCIONAR"
    reach = 1.3


func can_interact() -> bool:
    return puzzle != null and puzzle.is_valid() and not LeverSequence.is_solved(puzzle) \
            and (required_flag.is_empty() or GameState.has_flag(required_flag))


func interact(_player: Player) -> void:
    if puzzle == null or not puzzle.is_valid() or lever_id.is_empty():
        await Dialogue.say(["La palanca está suelta."])
        return
    var result: int = LeverSequence.register_lever(puzzle, lever_id, unlock_id)
    match result:
        LeverSequence.Result.RESULT_PROGRESS:
            Sfx.play("menu", global_position, -7.0)
            await Dialogue.say(["La palanca encajó."])
        LeverSequence.Result.RESULT_SOLVED:
            Sfx.play("unlock", global_position, -4.0)
            await Dialogue.say(["Las palancas quedaron en el orden correcto. El mecanismo se abrió."])
        _:
            Sfx.play("locked", global_position, -4.0)
            await Dialogue.say(["Ese no era el orden. El mecanismo volvió a su posición inicial."])
