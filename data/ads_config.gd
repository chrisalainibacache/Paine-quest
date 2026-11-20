class_name AdsConfig
extends Resource
## Límites y cantidades configurables para anuncios con recompensa.

@export_range(1, 3600, 1) var cooldown_seconds: int = 300
@export_range(1, 20, 1) var max_per_chapter: int = 3
@export_range(1, 600, 1) var minimum_play_seconds: int = 60
@export var pistol_ammo_reward: int = 12
@export var shotgun_ammo_reward: int = 6
@export var rifle_ammo_reward: int = 12
@export var grenade_ammo_reward: int = 2
@export var rocket_ammo_reward: int = 1
@export_file("*.tres") var healing_item_path: String = "res://data/items/sushi.tres"


func ammo_reward_for(ammo_item: ItemData) -> int:
    if ammo_item == null:
        return 0
    match ammo_item.id:
        "ammo_9mm":
            return pistol_ammo_reward
        "ammo_shells":
            return shotgun_ammo_reward
        "ammo_rifle":
            return rifle_ammo_reward
        "ammo_grenades":
            return grenade_ammo_reward
        "ammo_rockets":
            return rocket_ammo_reward
    return 0


func get_healing_item() -> ItemData:
    if not ResourceLoader.exists(healing_item_path):
        return null
    return load(healing_item_path) as ItemData
