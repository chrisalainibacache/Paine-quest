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


static func encode(kind: String, fields: Dictionary) -> Dictionary:
    if not MESSAGE_FIELDS.has(kind):
        return _failure("Tipo de mensaje desconocido.")
    if fields == null:
        return _failure("Los campos deben ser un diccionario.")
    var allowed: Array = MESSAGE_FIELDS[kind]
    for key: Variant in fields.keys():
        if not key is String or not allowed.has(key):
            return _failure("Campo no permitido en el mensaje.")
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
    var allowed: Array = MESSAGE_FIELDS[kind]
    for key: Variant in fields.keys():
        if not key is String or not allowed.has(key):
            return _failure("Campo no permitido en el mensaje.")
    return {
        "ok": true,
        "error": "",
        "kind": String(kind),
        "fields": (fields as Dictionary).duplicate(true),
        "protocol_version": PROTOCOL_VERSION,
    }


static func _failure(reason: String) -> Dictionary:
    return {"ok": false, "error": reason}
