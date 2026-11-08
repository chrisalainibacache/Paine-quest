extends CanvasLayer
## Interfaz en pantalla: controles táctiles, munición, estado de Cony,
## destello rojo al recibir daño y pantalla de muerte.

const CONDITION_COLORS := {
    "Bien": Color(0.45, 0.85, 0.45),
    "Precaución": Color(0.95, 0.75, 0.25),
    "Peligro": Color(0.95, 0.25, 0.2),
}

@onready var fire_button: Control = $FireButton
@onready var ammo_label: Label = $AmmoLabel
@onready var condition_label: Label = $ConditionLabel
@onready var damage_flash: ColorRect = $DamageFlash
@onready var death_screen: Control = $DeathScreen

var player: Player


func _ready() -> void:
    fire_button.visible = false
    damage_flash.color.a = 0.0
    death_screen.visible = false
    $DeathScreen/Retry.pressed.connect(func() -> void: get_tree().reload_current_scene())


func bind(new_player: Player) -> void:
    player = new_player
    player.health_changed.connect(_on_health_changed)
    player.damaged.connect(_on_damaged)
    player.died.connect(_on_died)
    player.combat.ammo_changed.connect(_on_ammo_changed)
    player.combat.aiming_changed.connect(func(aiming: bool) -> void: fire_button.visible = aiming)
    _on_health_changed(player.health, Player.MAX_HEALTH)
    _on_ammo_changed(player.combat.clip, player.combat.reserve)


func _on_ammo_changed(clip: int, reserve: int) -> void:
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
