class_name EnemyData
extends Resource
## Datos de un tipo de infectado.

@export var display_name: String = "Infectado"
@export var health: int = 5
@export var walk_speed: float = 0.75
@export var turn_speed: float = 3.0
## Distancia a la que nota a Cony (si la ve).
@export var notice_range: float = 9.0
@export var attack_range: float = 1.15
@export var attack_damage: int = 20
## Segundos de espera entre ataques.
@export var attack_cooldown: float = 1.4
@export var model_scene: PackedScene
