import sys, math, os; sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
from roomkit import *
import detail
import vertical
T = "res://levels/tracks/%s.tscn"
# Sala de inspección de la locomotora volcada (cap. 2, ala A): válvulas de combustible (sello «incendio apagado»)
# y una pasarela de inspección con un compartimento de herramientas que solo se abre al cortar el combustible.
k = Kit("LocomotiveRoom", "Sala de la locomotora", ambience="fire_wreck")
k.env((0.05, 0.03, 0.025), (0.36, 0.3, 0.28), 0.65, (0.12, 0.06, 0.04), 0.03)
H = 3.4
k.shell(-4.5, 4.5, -3.5, 3.5, H, floor="concrete_floor", wall="old_bricks_wall", ceiling="concrete_wall", wainscot="rust")
k.door_frame("ToHub", -4.5, 0.0, "z", width=1.1, wall_side=1, panel="metal")
k.door("ToHub", (-4.1, 0, 0.0), T % "derailed_train", "from_locomotive", prompt="VOLVER", reach=1.3)
k.spawn("from_hub", (-3.6, 0.05, 0.0), (1, 0))
# Pasarela de inspección sobre el muro norte (2,1 m) con escalera desde el oeste.
vertical.balcony(k, "Catwalk", 0.6, 4.3, -3.4, -1.8, y=2.1, rail_sides="SE")
vertical.stairs(k, "CatwalkStairs", -3.1, -2.6, "+x", width=1.3, rise=2.1)
# Válvulas de combustible: se cierran en el orden de la placa (2 aislar, 3 cortar, 1 confirmar).
k.lever_sequence("FuelSequence", (0.0, 0, 3.0), "cap2_fire_valves", reach=1.6)
for lever_id, x in (("1", -1.6), ("2", 0.0), ("3", 1.6)):
    k.lever("Valve" + lever_id, (x, 0, 3.0), "cap2_fire_valves", lever_id, unlock_id="tracks_fire_out", reach=1.2)
k.examine("ServicePlate", (-0.8, 0, 3.0), ["Placa de servicio: CORTE DE COMBUSTIBLE.", "2 AISLAR · 3 CORTAR · 1 CONFIRMAR. Si el testigo sigue rojo, no se toque nada más."], reach=1.4)
k.examine("MaintenanceNote", (2.9, 2.1, -2.6), ["Parte del maquinista, 6:46: tras el choque, el combustible prendió la cabina.", "«Primero aislar, después cortar, al final confirmar. Que nadie abra la puerta de atrás.» — J. Muñoz"], reach=1.4)
k.container("ToolCompartment", (2.6, 2.1, -2.7), "cap2_loco_cache", item_ids=("ammo_9mm", "handroll"), counts=(10, 1),
            required_flag="unlocked:tracks_fire_out", reach=1.3)
k.infected("Stoker", (2.4, 0.05, 1.0), yaw=-2.0, kind="infected_worker")
k.camera("West", (-1.8, 1.5, 0.0), (4.6, 3.0, 6.8), (1.6, 3.0, 3.2), (-2.6, 0.5, -0.4), fov=64)
k.camera("East", (2.2, 1.5, 0.0), (4.6, 3.0, 6.8), (-1.8, 3.0, -3.0), (2.6, 0.5, 0.6), fov=64)
k.leo_hint("LeoValves", (0.0, 0, 2.5), [
    "Leo: Huele a combustible quemado. La salida está por aquí atrás.",
    "Leo: Jorge dejó un orden escrito antes de irse.",
    "Leo: Lee la placa de servicio y mueve las válvulas en el orden 2, 3 y 1."])
detail.dress(k, -4.2, 4.2, -3.2, 3.2, H, theme="workshop", seed=601, avoid_rects=[(-3.8, 4.7, -3.6, -1.6)], extra=34)
k.save(REPO + "/levels/tracks/sala_locomotora.tscn")
print("sala_locomotora ok")
