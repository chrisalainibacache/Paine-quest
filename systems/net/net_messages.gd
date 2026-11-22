class_name NetMessages
extends RefCounted
## Codec de mensajes cooperativos. No depende de nodos ni de transporte.

const PROTOCOL_VERSION: int = 1
const MAX_MESSAGE_BYTES: int = 65536
const MESSAGE_FIELDS: Dictionary = {
    "hello": ["display_name", "role"],
    "welcome": ["host_name", "guest_name", "room_id", "session_id"],
    "input": ["sequence", "move", "aim", "actions"],
    "snapshot": ["sequence", "server_tick", "players", "enemies"],
    "event": ["event_id", "kind", "payload"],
    "request": ["request_id", "kind", "payload"],
    "request_result": ["request_id", "accepted", "reason", "state_delta"],
    "ping": ["nonce", "sent_msec"],
    "pong": ["nonce", "sent_msec"],
    "signal": ["event_id", "tone_id"],
    "room_prepare": ["transition_id", "room_path", "spawn_id", "server_tick"],
    "room_commit": ["transition_id", "room_path", "spawn_id", "server_tick"],
}
const FIELD_TYPES: Dictionary = {
    "hello": {"display_name": TYPE_STRING, "role": TYPE_STRING},
    "welcome": {"host_name": TYPE_STRING, "guest_name": TYPE_STRING, "room_id": TYPE_STRING, "session_id": TYPE_STRING},
    "input": {"sequence": TYPE_INT, "move": TYPE_VECTOR2, "aim": TYPE_VECTOR3, "actions": TYPE_DICTIONARY},
    "snapshot": {"sequence": TYPE_INT, "server_tick": TYPE_INT, "players": TYPE_ARRAY, "enemies": TYPE_ARRAY},
    "event": {"event_id": TYPE_INT, "kind": TYPE_STRING, "payload": TYPE_DICTIONARY},
    "request": {"request_id": TYPE_INT, "kind": TYPE_STRING, "payload": TYPE_DICTIONARY},
    "request_result": {"request_id": TYPE_INT, "accepted": TYPE_BOOL, "reason": TYPE_STRING, "state_delta": TYPE_DICTIONARY},
    "ping": {"nonce": TYPE_INT, "sent_msec": TYPE_INT},
    "pong": {"nonce": TYPE_INT, "sent_msec": TYPE_INT},
    "signal": {"event_id": TYPE_INT, "tone_id": TYPE_STRING},
    "room_prepare": {"transition_id": TYPE_INT, "room_path": TYPE_STRING, "spawn_id": TYPE_STRING, "server_tick": TYPE_INT},
    "room_commit": {"transition_id": TYPE_INT, "room_path": TYPE_STRING, "spawn_id": TYPE_STRING, "server_tick": TYPE_INT},
}


static func encode(kind: String, fields: Dictionary) -> Dictionary:
    if not MESSAGE_FIELDS.has(kind):
        return _failure("Tipo de mensaje desconocido.")
    if not _valid_fields(kind, fields):
        return _failure("Los campos del mensaje no son válidos.")
    var message: Dictionary = {
        "protocol_version": PROTOCOL_VERSION,
        "kind": kind,
        "fields": fields.duplicate(true),
    }
    if var_to_bytes(message).size() > MAX_MESSAGE_BYTES:
        return _failure("El mensaje supera el tamaño permitido.")
    return {"ok": true, "error": "", "message": message}


static func decode(raw: Variant) -> Dictionary:
    if not raw is Dictionary:
        return _failure("El mensaje recibido no es un diccionario.")
    var message: Dictionary = raw
    if message.size() != 3:
        return _failure("La estructura del mensaje no es válida.")
    if not message.has("protocol_version") or not message.has("kind") or not message.has("fields"):
        return _failure("Faltan campos obligatorios del mensaje.")
    var version: Variant = message["protocol_version"]
    var kind: Variant = message["kind"]
    var fields: Variant = message["fields"]
    if not version is int:
        return _failure("La versión del protocolo debe ser un entero.")
    if int(version) != PROTOCOL_VERSION:
        return _failure("La versión del protocolo no es compatible.")
    if not kind is String or not MESSAGE_FIELDS.has(kind):
        return _failure("Tipo de mensaje desconocido.")
    if not fields is Dictionary:
        return _failure("Los campos del mensaje deben ser un diccionario.")
    var encoded_size: int = var_to_bytes(message).size()
    if encoded_size > MAX_MESSAGE_BYTES:
        return _failure("El mensaje supera el tamaño permitido.")
    if not _valid_fields(String(kind), fields):
        return _failure("Los campos del mensaje no son válidos.")
    return {
        "ok": true,
        "error": "",
        "kind": String(kind),
        "fields": (fields as Dictionary).duplicate(true),
        "protocol_version": PROTOCOL_VERSION,
    }


static func _valid_fields(kind: String, fields: Dictionary) -> bool:
    var allowed: Array = MESSAGE_FIELDS[kind]
    var types: Dictionary = FIELD_TYPES[kind]
    for key: Variant in fields.keys():
        if not key is String or not allowed.has(key) or not types.has(key):
            return false
        if typeof(fields[key]) != int(types[key]):
            return false
    return true


static func _failure(reason: String) -> Dictionary:
    return {"ok": false, "error": reason}
