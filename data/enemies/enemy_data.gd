class_name EnemyData
extends Resource
## Datos de un tipo de infectado.

@export var display_name: String = "Infectado"
@export var health: int = 5
@export var walk_speed: float = 0.75
@export var turn_speed: float = 3.0
## Distancia a la que nota a Isabella (si la ve).
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
## Casco militar (soldado infectado).
@export var helmet: bool = false
## Usa pasos pesados; es una propiedad del tipo de infectado, no del nombre visible.
@export var heavy: bool = false
## Objeto que lanza ("" = ninguno): "bottle" o "brick".
@export var throw_kind: String = ""
## Cuántos objetos trae (se acaban al lanzarlos).
@export var throw_ammo: int = 0
@export var throw_damage: int = 6
## Segundos entre lanzamientos.
@export var throw_cooldown: float = 5.0
## Distancia mínima y máxima a Isabella para lanzar (de cerca prefiere atacar).
@export var throw_min_range: float = 3.0
@export var throw_max_range: float = 8.0
## Equipo especial que se arma por código sobre el modelo ("" = ninguno, "skull" = el jefe del capítulo 4).
@export var kit: String = ""
