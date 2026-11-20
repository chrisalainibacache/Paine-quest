class_name AdsConfig
extends Resource
## Límites y cantidades configurables para anuncios con recompensa.

@export_range(1, 3600, 1) var cooldown_seconds: int = 300
@export_range(1, 20, 1) var max_per_chapter: int = 3
@export_range(1, 600, 1) var minimum_play_seconds: int = 60
@export var pistol_ammo_reward: int = 12
@export var shotgun_ammo_reward: int = 6
@export var rifle_ammo_reward: int = 12
