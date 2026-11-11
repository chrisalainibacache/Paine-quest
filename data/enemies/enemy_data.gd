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
## Modelo detallado para el modo gráfico Moderno (vacío = usa model_scene).
@export var modern_model_scene: PackedScene
## Infectado rápido: corre a ráfagas a esta velocidad (0 = nunca corre).
@export var sprint_speed: float = 0.0
@export var sprint_time: float = 1.2
@export var rest_time: float = 1.6
## Tinte de la textura (para aclarar modelos oscuros o darles un tono).
@export var tint: Color = Color.WHITE
