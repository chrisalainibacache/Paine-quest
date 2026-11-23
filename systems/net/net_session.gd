extends Node
## Transporte ENet básico para una sesión local de dos teléfonos.

signal peer_joined(peer_id: int)
signal peer_left(peer_id: int)
signal connection_failed
signal connected
signal message_received(peer_id: int, message: Dictionary)

const DEFAULT_PORT: int = 7777
const MAX_CLIENTS: int = 1

var _peer: ENetMultiplayerPeer
var _is_host: bool = false
var _remote_peer_id: int = 0


func _ready() -> void:
    var api: MultiplayerAPI = get_tree().get_multiplayer()
    api.peer_connected.connect(_on_peer_connected)
    api.peer_disconnected.connect(_on_peer_disconnected)
    api.connected_to_server.connect(_on_connected_to_server)
    api.connection_failed.connect(_on_connection_failed)
    api.server_disconnected.connect(_on_server_disconnected)


func host(port: int = DEFAULT_PORT) -> Error:
    if port < 1 or port > 65535:
        return ERR_INVALID_PARAMETER
    close()
    var server: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
    var result: Error = server.create_server(port, MAX_CLIENTS)
    if result != OK:
        return result
    _peer = server
    _is_host = true
    get_tree().get_multiplayer().multiplayer_peer = _peer
    return OK


func join(ip: String, port: int = DEFAULT_PORT) -> Error:
    if not NetMessages.is_valid_ipv4(ip) or port < 1 or port > 65535:
        return ERR_INVALID_PARAMETER
    close()
    var client: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
    var result: Error = client.create_client(ip, port)
    if result != OK:
        return result
    _peer = client
    _is_host = false
    get_tree().get_multiplayer().multiplayer_peer = _peer
    return OK


func close() -> void:
    if _peer != null:
        _peer.close()
    _peer = null
    _is_host = false
    _remote_peer_id = 0
    get_tree().get_multiplayer().multiplayer_peer = OfflineMultiplayerPeer.new()


func send_message(kind: String, fields: Dictionary) -> Error:
    if _peer == null or _peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
        return ERR_UNAVAILABLE
    var encoded: Dictionary = NetMessages.encode(kind, fields)
    if not bool(encoded.get("ok", false)):
        return ERR_INVALID_DATA
    var message: Dictionary = encoded.get("message", {})
    if _is_host:
        if _remote_peer_id <= 0:
            return ERR_UNAVAILABLE
        rpc_id(_remote_peer_id, "_receive_reliable", message)
    else:
        rpc_id(1, "_receive_reliable", message)
    return OK


@rpc("any_peer", "call_remote", "reliable")
func _receive_reliable(raw: Dictionary) -> void:
    var sender: int = get_tree().get_multiplayer().get_remote_sender_id()
    if sender <= 0:
        return
    if _is_host and sender != _remote_peer_id:
        return
    if not _is_host and sender != 1:
        return
    var decoded: Dictionary = NetMessages.decode(raw)
    if not bool(decoded.get("ok", false)):
        return
    message_received.emit(sender, decoded)


func _on_peer_connected(peer_id: int) -> void:
    if not _is_host:
        return
    if _remote_peer_id != 0 and _remote_peer_id != peer_id:
        if _peer != null:
            _peer.disconnect_peer(peer_id)
        return
    _remote_peer_id = peer_id
    peer_joined.emit(peer_id)
    connected.emit()


func _on_peer_disconnected(peer_id: int) -> void:
    if peer_id == _remote_peer_id:
        _remote_peer_id = 0
    peer_left.emit(peer_id)


func _on_connected_to_server() -> void:
    connected.emit()


func _on_connection_failed() -> void:
    connection_failed.emit()
    close()


func _on_server_disconnected() -> void:
    connection_failed.emit()
    close()
