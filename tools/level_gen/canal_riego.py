import sys, math, os; sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
from buin_common import *
import detail
import vertical
# Canal de riego (cap. 3, ala C): pasillo largo y angosto junto al canal; pasarela de mantenimiento a 2,3 m.
# Dos palancas (compuerta, desagüe) vacían el canal y abren la caseta de bombas.
k = Kit("IrrigationCanal", "Canal de riego", ambience="day_fields")
k.env((0.12, 0.13, 0.14), (0.55, 0.57, 0.6), 0.95, (0.3, 0.32, 0.35), 0.02)
H = 4.6
k.shell(-10.0, 10.0, -2.25, 2.25, H, floor="concrete_floor", wall="old_bricks_wall", ceiling="concrete_wall", wainscot="rust")
k.door_frame("ToField", -10.0, 0.0, "z", width=1.4, wall_side=1, panel="metal")
k.door_frame("ToPump", 10.0, 0.0, "z", width=1.4, wall_side=-1, panel="metal")
k.door_frame("ToWalkwayFrame", 7.5, -2.25, "x", width=1.1, wall_side=1, panel="metal", group="Interactables", base_y=2.3)
k.door("ToField", (-9.6, 0, 0.0), B % "field", "from_canal", prompt="VOLVER", reach=1.3, marker="POTRERO")
k.door("ToPump", (9.6, 0, 0.0), B % "caseta_bomba", "from_canal", prompt="ENTRAR", reach=1.3, marker="CASETA DE BOMBAS", requires_flag=True,
       lock_id="buin_canal", locked_text="El agua del canal tapa la entrada a la caseta. Hay que vaciarlo primero.")
# Desde la pasarela de la viña se baja a esta plataforma; desde aquí no se abre al inicio.
k.door("ToWalkway", (7.5, 2.3, -1.85), B % "pasarela_vina", "from_canal", prompt="SUBIR", reach=1.3,
       lock_id="buin_shortcut_walkway_canal", one_way=True, one_way_origin=False, metal_door=True)
k.spawn("from_field", (-9.0, 0.05, 0.0), (1, 0))
k.spawn("from_pump", (9.0, 0.05, 0.0), (-1, 0))
k.spawn("from_walkway", (7.5, 2.35, -1.45), (0, 1))
# Canal: agua oscura (decorativa) a lo largo del lado sur, con marca de nivel en el muro.
k.block("Water", "Details", (0.0, 0.03, 1.55), (19.0, 0.05, 1.3), "river", solid=False)
k.block("CurbS", "Props", (0.0, 0.18, 0.85), (19.0, 0.36, 0.2), "concrete_wall")
k.label("WaterMark", "Details", (2.5, 0.95, 2.2), "NIVEL MÁX.", 20, (0.85, 0.82, 0.7), rot=(0, math.pi, 0))
# Pasarela de mantenimiento (2,3 m) sobre el lado norte, con escalera desde el oeste.
vertical.balcony(k, "Catwalk", 2.0, 9.7, -2.2, -0.9, y=2.3, rail_sides="S", columns=True)
vertical.stairs(k, "CatwalkStairs", -2.0, -1.55, "+x", width=1.1, rise=2.3)
# Palancas de la compuerta y el desagüe (orden: compuerta, luego desagüe) y el diagrama.
k.lever_sequence("CanalSequence", (-4.5, 0, -1.7), "buin_canal_levers", reach=1.6)
k.lever("GateLever", (-5.6, 0, -1.7), "buin_canal_levers", "compuerta", unlock_id="buin_canal", reach=1.2)
k.lever("DrainLever", (-3.4, 0, -1.7), "buin_canal_levers", "desague", unlock_id="buin_canal", reach=1.2)
k.note("IrrigationPlan", (-7.0, 0.95, -2.1), "buin_irrigation_plan", paper_scale=0.7, reach=1.4)
k.examine("Grate", (6.5, 0, 0.0), ["La rejilla del canal está sumergida. Con el nivel bajo se vería la entrada a la caseta.",
                                    "Una marca de agua en el muro muestra hasta dónde sube cuando la compuerta está cerrada."], reach=1.4)
k.infected("Drifter", (4.0, 0.05, 0.3), yaw=2.0, state="lying", kind="infected_pale")
k.pickup("CanalAmmo", (-8.2, 0.0, 1.5), "ammo_9mm", 12, rot=(0, 0.4, 0))
k.camera("West", (-5.0, 2.3, 0.0), (10.0, 4.6, 4.3), (-0.5, 4.2, 1.9), (-6.0, 0.4, -0.6), fov=62)
k.camera("East", (5.0, 2.3, 0.0), (10.0, 4.6, 4.3), (0.5, 4.2, 1.9), (6.0, 0.8, -0.4), fov=62)
k.leo_hint("LeoCanal", (-6.0, 0, 0.6), [
    "Leo: El agua baja por aquí... y huele a metal mojado.",
    "Leo: El nivel del canal debe bajar antes de abrir la caseta.",
    "Leo: Acciona la compuerta y luego el desagüe; después sigue hasta la caseta de bombas."])
detail.dress(k, -9.7, 9.7, -1.95, 1.95, H, theme="storage", seed=701, extra=18, avoid_rects=[(1.8, 9.8, -2.3, -0.8)], avoid=[(-9.0, 0.0, 1.2), (9.0, 0.0, 1.2), (7.5, -1.45, 1.2)])
k.save(REPO + "/levels/buin/canal_riego.tscn")
print("canal_riego ok")
