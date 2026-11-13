class_name PlayerInteraction
extends Node
## Busca el objeto interactuable más a mano (cerca y frente a Cony) y lo usa
## cuando se presiona ACCIÓN. El HUD muestra el botón con el texto del objeto.

signal focus_changed(target: Interactable)

## Ángulo máximo (a cada lado) para considerar que Cony mira el objeto.
const FACING_ANGLE := deg_to_rad(80.0)
## Más cerca que esto, cuenta aunque Cony no lo esté mirando.
const CLOSE_DISTANCE := 0.45

## Si un toque en ACCIÓN llega cuando no hay objeto a mano (o entre dos revisiones),
## se recuerda este tiempo (s) para no perderlo.
const TAP_MEMORY := 0.35
## Una acción que no abre nada ni cambia de sala en este tiempo se da por trabada.
const STUCK_AFTER := 2.5

signal used(target: Interactable)
signal finished(target: Interactable, seconds: float)

var focus: Interactable
var busy := false
var _queued_until := 0.0
var _busy_since := 0.0

@onready var player: Player = get_parent()


func _physics_process(_delta: float) -> void:
    var available := player.is_alive() and not busy and not player.controls_locked \
        and not SceneLoader.is_busy() and not player.combat.aiming and not player.is_hurt()
    _set_focus(_find_focus() if available else null)
    _recover_if_stuck()
    var tapped := Input.is_action_just_pressed(&"interact") or Time.get_ticks_msec() / 1000.0 < _queued_until
    if focus and tapped:
        _queued_until = 0.0
        use(focus)


## El botón ACCIÓN avisa directo (no depende de revisar la acción a tiempo).
func queue_use() -> void:
    _queued_until = Time.get_ticks_msec() / 1000.0 + TAP_MEMORY


## Si una acción quedó trabada (un error dentro de un diálogo, p. ej.), devuelve el
## control a Cony en vez de dejarla bloqueada para siempre.
func _recover_if_stuck() -> void:
    if not busy:
        return
    if Dialogue.is_open() or SceneLoader.is_busy():
        _busy_since = Time.get_ticks_msec() / 1000.0
        return
    if Time.get_ticks_msec() / 1000.0 - _busy_since > STUCK_AFTER:
        push_warning("PlayerInteraction: acción trabada, se libera a Cony.")
        busy = false
        player.controls_locked = false


## Usa un objeto (también lo llaman las pruebas).
func use(target: Interactable) -> void:
    busy = true
    _busy_since = Time.get_ticks_msec() / 1000.0
    used.emit(target)
    player.controls_locked = true
    _set_focus(null)
    player.face_direction(target.global_position - player.global_position, 1.0)
    var started := Time.get_ticks_msec()
    await target.interact(player)
    finished.emit(target, (Time.get_ticks_msec() - started) / 1000.0)
    # Si la acción cambió de sala, el SceneLoader devuelve los controles al terminar.
    if not SceneLoader.is_busy():
        player.controls_locked = false
    busy = false


func _find_focus() -> Interactable:
    var best: Interactable = null
    var best_score := INF
    var forward := player.get_forward()
    for node in get_tree().get_nodes_in_group("interactables"):
        var target := node as Interactable
        if target == null or not target.is_inside_tree() or not target.can_interact():
            continue
        var to_target := target.global_position - player.global_position
        to_target.y = 0.0
        var distance := to_target.length()
        if distance > target.reach:
            continue
        var angle := 0.0 if distance < CLOSE_DISTANCE else forward.angle_to(to_target)
        if angle > FACING_ANGLE:
            continue
        var score := distance + angle * 0.6 + target.focus_penalty
        if score < best_score:
            best_score = score
            best = target
    return best


func _set_focus(target: Interactable) -> void:
    if target == focus:
        return
    focus = target
    focus_changed.emit(focus)
