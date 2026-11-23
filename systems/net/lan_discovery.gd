extends Node
## Descubrimiento de anfitriones en la red local mediante broadcast UDP.

signal games_changed

const DEFAULT_DISCOVERY_PORT: int = 7778
const DEFAULT_GAME_PORT: int = 7777
const ANNOUNCE_INTERVAL: float = 1.0
const GAME_TIMEOUT: float = 4.0

var games: Array[Dictionary] = []
var _listener: PacketPeerUDP
var _sender: PacketPeerUDP
var _hosting: bool = false
var _discovery_port: int = DEFAULT_DISCOVERY_PORT
var _game_port: int = DEFAULT_GAME_PORT
var _game_name: String = "Paine"
var _host_name: String = "Anfitrión"
var _announce_elapsed: float = 0.0
var _game_seen_at: Dictionary = {}


func start_listening(discovery_port: int = DEFAULT_DISCOVERY_PORT) -> Error:
    if discovery_port < 1 or discovery_port > 65535:
        return ERR_INVALID_PARAMETER
    stop()
    var listener: PacketPeerUDP = PacketPeerUDP.new()
    var result: Error = listener.bind(discovery_port, "*")
    if result != OK:
        return result
    _listener = listener
    _discovery_port = discovery_port
    return OK


func start_host(game_name: String, host_name: String, game_port: int = DEFAULT_GAME_PORT,
        discovery_port: int = DEFAULT_DISCOVERY_PORT) -> Error:
    if game_port < 1 or game_port > 65535 or discovery_port < 1 or discovery_port > 65535:
        return ERR_INVALID_PARAMETER
    var result: Error = start_listening(discovery_port)
    if result != OK:
        return result
    _sender = PacketPeerUDP.new()
    _sender.set_broadcast_enabled(true)
    _game_name = game_name.strip_edges() if not game_name.strip_edges().is_empty() else "Paine"
    _host_name = host_name.strip_edges() if not host_name.strip_edges().is_empty() else "Anfitrión"
    _game_port = game_port
    _hosting = true
    _announce_elapsed = ANNOUNCE_INTERVAL
    _broadcast()
    return OK


func stop() -> void:
    _hosting = false
    if _listener != null:
        _listener.close()
    if _sender != null:
        _sender.close()
    _listener = null
    _sender = null
    games.clear()
    _game_seen_at.clear()
    games_changed.emit()


func _process(delta: float) -> void:
    if _hosting:
        _announce_elapsed += delta
        if _announce_elapsed >= ANNOUNCE_INTERVAL:
            _announce_elapsed = 0.0
            _broadcast()
    _poll_packets()
    _remove_expired_games()


func _broadcast() -> void:
    if _sender == null:
        return
    var announcement: Dictionary = {
        "protocol_version": NetMessages.PROTOCOL_VERSION,
        "kind": "paine_host",
        "game_name": _game_name,
        "host_name": _host_name,
        "port": _game_port,
    }
    if _sender.set_dest_address("255.255.255.255", _discovery_port) != OK:
        return
    _sender.put_packet(JSON.stringify(announcement).to_utf8_buffer())


func _poll_packets() -> void:
    if _listener == null:
        return
    while _listener.get_available_packet_count() > 0:
        var packet: PackedByteArray = _listener.get_packet()
        if packet.size() > 2048:
            continue
        var raw: Variant = JSON.parse_string(packet.get_string_from_utf8())
        if not raw is Dictionary:
            continue
        var announcement: Dictionary = raw
        if int(announcement.get("protocol_version", -1)) != NetMessages.PROTOCOL_VERSION:
            continue
        if announcement.get("kind", "") != "paine_host":
            continue
        var port: Variant = announcement.get("port", null)
        var game_name: Variant = announcement.get("game_name", null)
        var host_name: Variant = announcement.get("host_name", null)
        if not port is int or int(port) < 1 or int(port) > 65535:
            continue
        if not game_name is String or not host_name is String:
            continue
        var address: String = _listener.get_packet_ip()
        if not NetMessages.is_valid_ipv4(address) or address.contains(":"):
            continue
        var game: Dictionary = {
            "ip": address,
            "port": int(port),
            "game_name": String(game_name),
            "host_name": String(host_name),
        }
        var key: String = "%s:%d" % [address, int(port)]
        _game_seen_at[key] = Time.get_ticks_msec()
        var found: bool = false
        for index in games.size():
            if "%s:%d" % [games[index].get("ip", ""), int(games[index].get("port", 0))] == key:
                games[index] = game
                found = true
                break
        if not found:
            games.append(game)
        games_changed.emit()


func _remove_expired_games() -> void:
    var now: int = Time.get_ticks_msec()
    var changed: bool = false
    for index in range(games.size() - 1, -1, -1):
        var key: String = "%s:%d" % [games[index].get("ip", ""), int(games[index].get("port", 0))]
        var seen: int = int(_game_seen_at.get(key, 0))
        if now - seen > int(GAME_TIMEOUT * 1000.0):
            games.remove_at(index)
            _game_seen_at.erase(key)
            changed = true
    if changed:
        games_changed.emit()
