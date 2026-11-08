extends CanvasLayer
## Interfaz en pantalla: controles táctiles, munición, estado de Cony,
## destello rojo al recibir daño y pantalla de muerte.
## ACCIÓN aparece en el lugar de DISPARAR cuando Cony tiene algo a mano.

signal inventory_requested
signal retry_requested

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

var player: Player


func _ready() -> void:
    fire_button.visible = false
    action_button.visible = false
    damage_flash.color.a = 0.0
    death_screen.visible = false
    $DeathScreen/Retry.pressed.connect(func() -> void: retry_requested.emit())


func bind(new_player: Player) -> void:
    player = new_player
    player.health_changed.connect(_on_health_changed)
    player.damaged.connect(_on_damaged)
    player.died.connect(_on_died)
    player.combat.ammo_changed.connect(_on_ammo_changed)
    player.combat.aiming_changed.connect(_on_aiming_changed)
    player.interaction.focus_changed.connect(_on_focus_changed)
    _on_health_changed(player.health, Player.MAX_HEALTH)
    _on_ammo_changed(player.combat.clip, player.combat.reserve)


func _process(_delta: float) -> void:
    if player and player.is_alive() and not player.controls_locked and Input.is_action_just_pressed(&"inventory"):
        inventory_requested.emit()


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
    death_screen.modulate.a = 0.0
    create_tween().tween_property(death_screen, "modulate:a", 1.0, 0.8)
