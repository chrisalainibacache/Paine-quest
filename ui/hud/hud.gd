extends CanvasLayer
## Interfaz en pantalla: controles táctiles, munición, estado de Isabella,
## destello rojo al recibir daño y pantalla de muerte.
## ACCIÓN aparece en el lugar de DISPARAR cuando Isabella tiene algo a mano.

signal inventory_requested
signal retry_requested
signal rewarded_continue_requested

const CONDITION_COLORS := {
    "Bien": Color(0.45, 0.85, 0.45),
    "Precaución": Color(0.95, 0.75, 0.25),
    "Peligro": Color(0.95, 0.25, 0.2),
}

@onready var fire_button: Control = $FireButton
@onready var action_button: Control = $ActionButton
@onready var aim_button: Control = $AimButton
@onready var ammo_label: Label = $AmmoLabel
@onready var condition_label: Label = $ConditionLabel
@onready var damage_flash: ColorRect = $DamageFlash
@onready var death_screen: Control = $DeathScreen
@onready var reward_continue_button: Button = $DeathScreen/RewardContinue

var player: Player
var _objective_label: Label
var _objective_timer := 0.0
var _reward_continue_used := false


func _ready() -> void:
    add_to_group("hud")
    fire_button.visible = false
    action_button.visible = false
    damage_flash.color.a = 0.0
    death_screen.visible = false
    $DeathScreen/Retry.pressed.connect(func() -> void: retry_requested.emit())
    reward_continue_button.visible = false
    reward_continue_button.pressed.connect(_offer_rewarded_continue)


func bind(new_player: Player) -> void:
    player = new_player
    player.health_changed.connect(_on_health_changed)
    player.damaged.connect(_on_damaged)
    player.died.connect(_on_died)
    player.combat.ammo_changed.connect(_on_ammo_changed)
    player.combat.aiming_changed.connect(_on_aiming_changed)
    player.interaction.focus_changed.connect(_on_focus_changed)
    action_button.tapped.connect(player.interaction.queue_use)
    player.interaction.used.connect(_on_used)
    player.interaction.finished.connect(_on_used_finished)
    _on_health_changed(player.health, Player.MAX_HEALTH)
    _on_ammo_changed(player.combat.clip, player.combat.reserve)


func _process(delta: float) -> void:
    _objective_timer -= delta
    if _objective_timer <= 0.0:
        _objective_timer = 1.0
        _update_objective()
    if player and player.is_alive() and not player.controls_locked and Input.is_action_just_pressed(&"inventory"):
        inventory_requested.emit()


## Cartel con el nombre del lugar: entra, se queda un rato y se apaga.
func show_place(place: String) -> void:
    var label := get_node_or_null("PlaceBanner") as Label
    if label == null:
        label = Label.new()
        label.name = "PlaceBanner"
        label.set_anchors_preset(Control.PRESET_TOP_WIDE)
        label.offset_top = 16.0
        label.offset_bottom = 60.0
        label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        label.mouse_filter = Control.MOUSE_FILTER_IGNORE
        label.add_theme_font_size_override("font_size", 26)
        label.add_theme_color_override("font_color", Color(0.93, 0.88, 0.75))
        label.add_theme_color_override("font_outline_color", Color(0.03, 0.03, 0.03))
        label.add_theme_constant_override("outline_size", 8)
        add_child(label)
    label.text = place.to_upper()
    label.modulate.a = 0.0
    var tween := create_tween()
    tween.tween_property(label, "modulate:a", 1.0, 0.5)
    tween.tween_interval(2.4)
    tween.tween_property(label, "modulate:a", 0.0, 0.9)


## Aviso chico y discreto del último uso (sirve para ver si un toque llegó).
func _on_used(target: Interactable) -> void:
    var label := get_node_or_null("UseNotice") as Label
    if label == null:
        label = Label.new()
        label.name = "UseNotice"
        label.position = Vector2(24.0, 668.0)
        label.add_theme_font_size_override("font_size", 15)
        label.modulate = Color(0.75, 0.75, 0.7, 0.55)
        add_child(label)
    label.text = "%s · %s" % [target.prompt, target.name]
    label.visible = true
    get_tree().create_timer(3.0, true, false, true).timeout.connect(func() -> void:
        if is_instance_valid(label):
            label.visible = false)


func _on_used_finished(target: Interactable, seconds: float) -> void:
    var label := get_node_or_null("UseNotice") as Label
    if label:
        label.text = "%s · %s · %.1f s" % [target.prompt, target.name, seconds]
        label.visible = true


func _on_aiming_changed(aiming: bool) -> void:
    fire_button.visible = aiming
    if aiming:
        action_button.visible = false


func _on_focus_changed(target: Interactable) -> void:
    action_button.visible = target != null and not player.combat.aiming
    if target:
        action_button.label = target.prompt
        action_button.queue_redraw()


func _on_ammo_changed(clip: int, reserve: int) -> void:
    ammo_label.visible = player.combat.has_weapon()
    aim_button.visible = player.combat.has_weapon()
    ammo_label.text = "%d  /  %d" % [clip, reserve]
    ammo_label.modulate = Color(1, 0.4, 0.35) if clip == 0 else Color.WHITE


func _on_health_changed(_health: int, _max_health: int) -> void:
    var condition := player.get_condition()
    condition_label.text = condition.to_upper()
    condition_label.add_theme_color_override("font_color", CONDITION_COLORS[condition])


func _on_damaged(_amount: int) -> void:
    damage_flash.color.a = 0.45
    create_tween().tween_property(damage_flash, "color:a", 0.0, 0.5)


func _on_died() -> void:
    await get_tree().create_timer(1.8).timeout
    death_screen.visible = true
    reward_continue_button.visible = not _reward_continue_used and Ads.available()
    reward_continue_button.disabled = false
    death_screen.modulate.a = 0.0
    create_tween().tween_property(death_screen, "modulate:a", 1.0, 0.8)


func _offer_rewarded_continue() -> void:
    if _reward_continue_used or not reward_continue_button.visible:
        return
    reward_continue_button.disabled = true
    Ads.show_rewarded(&"death_continue", func(rewarded: bool) -> void:
        if rewarded:
            _reward_continue_used = true
            reward_continue_button.visible = false
            rewarded_continue_requested.emit()
            return
        reward_continue_button.disabled = false
        reward_continue_button.visible = Ads.available()
    )


## Línea de objetivo: lo último que Leo diría en la pista activa de la sala.
func _update_objective() -> void:
    if _objective_label == null:
        _objective_label = Label.new()
        _objective_label.name = "Objective"
        _objective_label.position = Vector2(28.0, 60.0)
        _objective_label.add_theme_font_size_override("font_size", 15)
        _objective_label.modulate = Color(0.95, 0.9, 0.7, 0.75)
        add_child(_objective_label)
    var text := ""
    for hint: Node in get_tree().get_nodes_in_group("leo_hints"):
        if hint.has_method("is_active") and hint.is_active() and not hint.lines.is_empty():
            text = hint.lines[hint.lines.size() - 1].trim_prefix("Leo: ")
            break
    _objective_label.text = "» " + text if text != "" else ""
