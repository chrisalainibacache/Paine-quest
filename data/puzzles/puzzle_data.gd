class_name PuzzleData
extends Resource
## Definición reutilizable de un puzzle. El progreso de cada instancia se guarda
## por separado en PuzzleState; este recurso contiene solo sus reglas.

enum PuzzleType { CODE_LOCK, FUSE_BOX, LEVER_SEQUENCE, CONTAINER }

@export var id: String = ""
@export var puzzle_type: PuzzleType = PuzzleType.CODE_LOCK
## Código numérico esperado para una cerradura (3 a 6 dígitos).
@export var code: String = ""
## Orden de identificadores de palancas para una secuencia.
@export var sequence: PackedStringArray = []
## IDs de objetos que exige el puzzle (fusibles, piezas, etc.).
@export var required_items: PackedStringArray = []
## Cantidad mínima requerida cuando el puzzle trabaja con unidades.
@export_range(0, 32, 1) var required_count: int = 0
## Bandera de éxito del capítulo; si está vacía, el puzzle solo conserva su estado propio.
@export var success_flag: String = ""


func is_valid() -> bool:
    if id.strip_edges().is_empty():
        return false
    match puzzle_type:
        PuzzleType.CODE_LOCK:
            return code.length() >= 3 and code.length() <= 6 and code.is_valid_int()
        PuzzleType.FUSE_BOX:
            return required_count > 0 or not required_items.is_empty()
        PuzzleType.LEVER_SEQUENCE:
            return sequence.size() >= 2
        PuzzleType.CONTAINER:
            return true
    return false
