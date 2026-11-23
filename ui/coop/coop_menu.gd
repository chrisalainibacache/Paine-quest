extends Control
## Menú de conexión LAN y prueba de latencia entre dos teléfonos.

const TITLE_SCENE: String = "res://ui/title/title_screen.tscn"
const SESSION_SCRIPT: Script = preload("res://systems/net/net_session.gd")
const DISCOVERY_SCRIPT: Script = preload("res://systems/net/lan_discovery.gd")
const GAME_PORT: int = 7777
const DISCOVERY_PORT: int = 7778

@onready var status_label: Label = $Panel/Layout/Status
@onready var games_list: OptionButton = $Panel/Layout/Games
@onready var address_input: LineEdit = $Panel/Layout/ManualRow/Address
@onready var test_panel: VBoxContainer = $Panel/Layout/TestPanel
@onready var players_label: Label = $Panel/Layout/TestPanel/Players
@onready var ping_label: Label = $Panel/Layout/TestPanel/Ping

var _session: Node
var _discovery: Node
var _in_test: bool = false
var _ping_elapsed: float = 0.0
var _ping_nonce: int = 0
var _ping_started_msec: int = 0


func _ready() -> void:
    _session = SESSION_SCRIPT.new()
    _session.name = "NetSession"
    add_child(_session)
    _discovery = DISCOVERY_SCRIPT.new()
    _discovery.name = "LanDiscovery"
    add_child(_discovery)
    _session.connect("connected", _on_connected)
    _session.connect("connection_failed", _on_connection_failed)
    _session.connect("peer_left", _on_peer_left)
    _session.connect("message_received", _on_message_received)
    _discovery.connect("games_changed", _refresh_games)
    $Panel/Layout/Actions/HostButton.pressed.connect(_create_game)
    $Panel/Layout/Actions/JoinButton.pressed.connect(_join_selected)
    $Panel/Layout/ManualRow/ManualJoin.pressed.connect(_join_manual)
    $Panel/Layout/Actions/BackButton.pressed.connect(_back_to_title)
    $Panel/Layout/TestPanel/SignalButton.pressed.connect(_send_signal)
    $Panel/Layout/TestPanel/DisconnectButton.pressed.connect(_back_to_title)
    test_panel.visible = false
    var listen_error: int = int(_discovery.call("start_listening", DISCOVERY_PORT))
    if listen_error != OK:
        status_label.text = "Descubrimiento no disponible. Puedes unirte por IP."


func _process(delta: float) -> void:
    if not _in_test:
        return
    _ping_elapsed += delta
    if _ping_elapsed >= 1.0:
        _ping_elapsed = 0.0
        _ping_nonce = Time.get_ticks_msec()
        _ping_started_msec = _ping_nonce
        var fields: Dictionary = {"nonce": _ping_nonce, "sent_msec": _ping_started_msec}
        _session.call("send_message", "ping", fields)


func _create_game() -> void:
    var host_error: int = int(_session.call("host", GAME_PORT))
    if host_error != OK:
        status_label.text = "No se pudo crear la partida (código %d)." % host_error
        return
    var discovery_error: int = int(_discovery.call("start_host", "Paine", "Anfitrión",
        GAME_PORT, DISCOVERY_PORT))
    var local_ip: String = _local_ipv4()
    status_label.text = "Esperando a Ignacia… tu IP: %s" % local_ip
    if discovery_error != OK:
        status_label.text += "\nEl anuncio automático no está disponible; comparte tu IP."
    $Panel/Layout/Actions/HostButton.disabled = true
    $Panel/Layout/Actions/JoinButton.disabled = true


func _join_selected() -> void:
    var games: Array = _discovery.get("games")
    var index: int = games_list.selected
    if index < 0 or index >= games.size():
        status_label.text = "No hay una partida seleccionada."
        return
    var game: Dictionary = games[index]
    _join_address(String(game.get("ip", "")))


func _join_manual() -> void:
    _join_address(address_input.text.strip_edges())


func _join_address(address: String) -> void:
    if not NetMessages.is_valid_ipv4(address) or address.contains(":"):
        status_label.text = "Escribe una dirección IPv4 válida."
        return
    var join_error: int = int(_session.call("join", address, GAME_PORT))
    if join_error != OK:
        status_label.text = "No se pudo iniciar la conexión (código %d)." % join_error
        return
    status_label.text = "Conectando con %s…" % address
    $Panel/Layout/Actions/HostButton.disabled = true
    $Panel/Layout/Actions/JoinButton.disabled = true


func _on_connected() -> void:
    _in_test = true
    _ping_elapsed = 1.0
    _discovery.call("stop")
    $Panel/Layout/Actions/HostButton.disabled = true
    $Panel/Layout/Actions/JoinButton.disabled = true
    $Panel/Layout/ManualRow/ManualJoin.disabled = true
    $Panel/Layout/Games.disabled = true
    test_panel.visible = true
    var host: bool = get_tree().get_multiplayer().is_server()
    players_label.text = "Tú: Isabella  ·  Invitada: Ignacia" if host else "Tú: Ignacia  ·  Anfitrión: Isabella"
    status_label.text = "Prueba de conexión activa."


func _on_connection_failed() -> void:
    _in_test = false
    status_label.text = "No se pudo conectar o se perdió la conexión."
    _restore_controls()


func _on_peer_left(_peer_id: int) -> void:
    _in_test = false
    status_label.text = "La otra persona se desconectó."
    test_panel.visible = false
    _restore_controls()


func _on_message_received(_peer_id: int, message: Dictionary) -> void:
    var kind: String = String(message.get("kind", ""))
    var fields: Dictionary = message.get("fields", {})
    if kind == "ping":
        _session.call("send_message", "pong", fields)
    elif kind == "pong" and int(fields.get("nonce", -1)) == _ping_nonce:
        var elapsed: int = Time.get_ticks_msec() - _ping_started_msec
        ping_label.text = "PING: %d ms" % elapsed
    elif kind == "signal":
        Sfx.play("pickup", null, -2.0)
        status_label.text = "¡Ignacia te envió una señal!" if get_tree().get_multiplayer().is_server() else "¡Isabella te envió una señal!"


func _send_signal() -> void:
    var fields: Dictionary = {"event_id": Time.get_ticks_msec(), "tone_id": "signal"}
    var result: int = int(_session.call("send_message", "signal", fields))
    status_label.text = "Señal enviada." if result == OK else "No se pudo enviar la señal."


func _refresh_games() -> void:
    games_list.clear()
    var games: Array = _discovery.get("games")
    for game: Dictionary in games:
        var label: String = "%s — %s (%s)" % [
            game.get("game_name", "Paine"),
            game.get("host_name", "Anfitrión"),
            game.get("ip", ""),
        ]
        games_list.add_item(label)


func _local_ipv4() -> String:
    for address: String in IP.get_local_addresses():
        if address.contains(":") or address.begins_with("127.") or address.begins_with("169.254."):
            continue
        if NetMessages.is_valid_ipv4(address):
            return address
    return "IP no disponible"


func _restore_controls() -> void:
    $Panel/Layout/Actions/HostButton.disabled = false
    $Panel/Layout/Actions/JoinButton.disabled = false
    $Panel/Layout/ManualRow/ManualJoin.disabled = false
    $Panel/Layout/Games.disabled = false


func _back_to_title() -> void:
    if _session != null:
        _session.call("close")
    if _discovery != null:
        _discovery.call("stop")
    get_tree().change_scene_to_file(TITLE_SCENE)


func _exit_tree() -> void:
    if _session != null:
        _session.call("close")
    if _discovery != null:
        _discovery.call("stop")
