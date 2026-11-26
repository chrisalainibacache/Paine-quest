extends Node3D
## Encuentro con un jefe: cuando Isabella entra en el radio, aparece el jefe en el punto `spawn_position`, se
## muestra su barra de vida (sin nombre: nadie dice «Skull») y, al caer, se anota la bandera y se avisa a la sala.
## Uso en una sala: nodo con este script + `boss_data` (EnemyData) + `trigger_radius`; `done_flag` evita repetirlo.

signal defeated

const INFECTED := preload("res://actors/enemies/infected.tscn")

@export var boss_data: EnemyData
@export var spawn_position := Vector3(8.0, 0.05, 0.0)
## Distancia a Isabella (en el piso) a la que se dispara el encuentro.
@export var trigger_radius := 9.0
@export var done_flag := "boss:skull:dead"

var boss: Infected
var _bar: ProgressBar
var _layer: CanvasLayer
var _started := false


func _ready() -> void:
    if GameState.has_flag(done_flag):
        set_physics_process(false)


func _physics_process(_delta: float) -> void:
    if _started:
        _update_bar()
        return
    var player := get_tree().get_first_node_in_group("player") as Node3D
    if player == null:
        return
    var flat := player.global_position - global_position
    flat.y = 0.0
    if flat.length() <= trigger_radius:
        start()


## Hace aparecer al jefe y la barra (también se puede llamar a mano desde una escena guionada).
func start() -> void:
    if _started or boss_data == null:
        return
    _started = true
    boss = INFECTED.instantiate() as Infected
    boss.data = boss_data
    get_parent().add_child(boss)
    boss.global_position = global_position + spawn_position
    boss.model.rotation.y = PI
    boss.died.connect(_on_died)
    _build_bar()
    Sfx.play("creature_roar_far", boss.global_position + Vector3.UP * 2.0, 6.0, 0.0)


func _build_bar() -> void:
    _layer = CanvasLayer.new()
    _layer.layer = 20
    add_child(_layer)
    _bar = ProgressBar.new()
    _bar.show_percentage = false
    _bar.max_value = float(boss_data.health)
    _bar.value = float(boss_data.health)
    _bar.anchor_left = 0.25
    _bar.anchor_right = 0.75
    _bar.anchor_top = 0.0
    _bar.offset_top = 56.0
    _bar.offset_bottom = 72.0
    _bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
    var fill := StyleBoxFlat.new()
    fill.bg_color = Color(0.62, 0.08, 0.06)
    var back := StyleBoxFlat.new()
    back.bg_color = Color(0.05, 0.04, 0.04, 0.8)
    back.border_color = Color(0.55, 0.45, 0.25)
    back.set_border_width_all(2)
    _bar.add_theme_stylebox_override("fill", fill)
    _bar.add_theme_stylebox_override("background", back)
    _layer.add_child(_bar)


func _update_bar() -> void:
    if _bar != null and is_instance_valid(boss):
        _bar.value = float(maxi(boss.health, 0))


func _on_died(_infected: Infected) -> void:
    GameState.set_flag(done_flag)
    if _layer != null:
        _layer.queue_free()
    defeated.emit()
