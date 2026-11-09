class_name Interactable
extends Node3D
## Algo con lo que Cony puede interactuar con el botón ACCIÓN (examinar, leer,
## recoger, abrir, guardar). El nodo se ubica donde está el objeto: Cony lo
## "ve" cuando está a menos de `reach` metros y más o menos de frente.

## Texto del botón ACCIÓN cuando este objeto está a mano.
@export var prompt: String = "EXAMINAR"
@export var reach: float = 1.3
## Algunos objetos pequeños (documentos) se detectan por proximidad sin exigir orientación.
@export var requires_facing: bool = true


func _ready() -> void:
    add_to_group("interactables")


func can_interact() -> bool:
    return true


## Se sobrescribe en cada tipo. Puede esperar (await) diálogos o cambios de sala.
func interact(_player: Player) -> void:
    pass
