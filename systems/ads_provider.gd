class_name AdProvider
extends RefCounted
## Contrato común para proveedores de anuncios con recompensa.

func is_ready() -> bool:
    return false


func show(_placement: StringName, on_done: Callable) -> void:
    if on_done.is_valid():
        on_done.call(false)
