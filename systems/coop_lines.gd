class_name CoopLines
extends Resource
## Líneas adicionales de Ignacia. Se consultan por sala y disparador solo en cooperativo.

@export var entries: Array[Dictionary] = []


func lines_for(room: String, event: String) -> PackedStringArray:
    var result: PackedStringArray = []
    if not GameState.cooperative:
        return result
    for entry: Dictionary in entries:
        if String(entry.get("room", "")) == room and String(entry.get("event", "")) == event:
            result.append(String(entry.get("text", "")))
    return result
