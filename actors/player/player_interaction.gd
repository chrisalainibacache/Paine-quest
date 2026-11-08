class_name PlayerInteraction
extends Node
## Busca el objeto interactuable más a mano (cerca y frente a Cony) y lo usa
## cuando se presiona ACCIÓN. El HUD muestra el botón con el texto del objeto.

signal focus_changed(target: Interactable)

## Ángulo máximo (a cada lado) para considerar que Cony mira el objeto.
const FACING_ANGLE := deg_to_rad(80.0)
## Más cerca que esto, cuenta aunque Cony no lo esté mirando.
const CLOSE_DISTANCE := 0.45

var focus: Interactable
var busy := false

@onready var player: Player = get_parent()


func _physics_process(_delta: float) -> void:
    var available := player.is_alive() and not busy and not player.controls_locked \
        and not SceneLoader.is_busy() and not player.combat.aiming and not player.is_hurt()
    _set_focus(_find_focus() if available else null)
    if focus and Input.is_action_just_pressed(&"interact"):
        use(focus)


## Usa un objeto (también lo llaman las pruebas).
func use(target: Interactable) -> void:
    busy = true
    player.controls_locked = true
    _set_focus(null)
    player.face_direction(target.global_position - player.global_position, 1.0)
    await target.interact(player)
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
        var score := distance + angle * 0.6
        if score < best_score:
            best_score = score
            best = target
    return best


func _set_focus(target: Interactable) -> void:
    if target == focus:
        return
    focus = target
    focus_changed.emit(focus)
