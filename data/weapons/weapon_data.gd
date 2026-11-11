class_name WeaponData
extends Resource
## Datos de un arma de fuego. Cambiar el balance = editar el .tres, no el código.

@export var display_name: String = "Pistola"
## Ítem de munición que usa (se descuenta de la mochila al recargar).
@export var ammo_item: ItemData
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

@export_group("Daño a distancia")
## Desde esta distancia el daño baja hasta min_damage en max_range (0 = no baja).
@export var falloff_start: float = 0.0
@export var min_damage: int = 1
## Balas por toque de DISPARAR (ráfaga del fusil).
@export var burst: int = 1

@export_group("Explosivo")
## Radio de la explosión (0 = bala normal). El daño baja hacia el borde.
@export var explosive_radius: float = 0.0
## Velocidad del proyectil (granada o cohete) en m/s.
@export var projectile_speed: float = 22.0

@export_group("Presentación")
## Escena propia en la mano (la pistola). Si no hay, se usa held_weapon.tscn con held_model.
@export var held_scene: PackedScene
@export var held_model: PackedScene
## Boca del cañón respecto de la empuñadura.
@export var muzzle_offset: Vector3 = Vector3(0, 0.05, 0.4)
@export var flash_scale: float = 1.0
## Sonido del disparo (ver systems/sfx.gd).
@export var sound: String = "shot"


## Daño de un impacto a cierta distancia.
func damage_at(distance: float) -> int:
    if falloff_start <= 0.0 or distance <= falloff_start or max_range <= falloff_start:
        return damage
    var t := clampf((distance - falloff_start) / (max_range - falloff_start), 0.0, 1.0)
    return maxi(roundi(lerpf(damage, min_damage, t)), min_damage)
