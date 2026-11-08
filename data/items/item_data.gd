class_name ItemData
extends Resource
## Un tipo de ítem de la mochila (balas, comida, llaves, armas).
## Cambiar textos o balance = editar el .tres, no el código.

enum Kind { WEAPON, AMMO, HEALING, KEY }

## Identificador estable: se usa en las partidas guardadas y en las puertas.
@export var id: String = ""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var kind: Kind = Kind.KEY
## Cuántas unidades caben en una casilla.
@export var max_stack: int = 1
## Vida que recupera (comida).
@export var heal_amount: int = 0
## Datos del arma (solo armas).
@export var weapon: WeaponData
## Modelo 3D: se usa en el suelo, en el ícono de la mochila y al examinar.
@export var model: PackedScene


func is_stackable() -> bool:
    return max_stack > 1
