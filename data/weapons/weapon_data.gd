class_name WeaponData
extends Resource
## Datos de un arma de fuego. Cambiar el balance = editar el .tres, no el código.

@export var display_name: String = "Pistola"
@export var damage: int = 1
@export var clip_size: int = 10
## Segundos mínimos entre disparos.
@export var fire_interval: float = 0.45
@export var reload_time: float = 1.6
@export var max_range: float = 14.0
## Ángulo (a cada lado) en que el auto-apuntado busca infectados.
@export_range(0.0, 90.0) var aim_cone_degrees: float = 60.0
## Probabilidad de que un tiro lo haga tambalear.
@export_range(0.0, 1.0) var stagger_chance: float = 0.35
