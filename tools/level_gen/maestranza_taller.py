import sys, os
HERE = os.path.dirname(os.path.abspath(__file__))
if HERE not in sys.path: sys.path.insert(0, HERE)
from maestranza_common import *

k = create_room("MaestranzaTaller", "Taller de mantenimiento", "office")
connect_room(k, "maestranza_enfermeria", "maestranza_vestuario", "VESTUARIO")
k.prop("ToolBench", "Props", "typewriter_desk", (-3.8, 0.0, -2.2), rot=(0.0, 0.4, 0.0))
k.prop("Radio", "Props", "field_radio", (-3.8, 0.8, -2.2))
k.block("BluePanel", "Props", (3.8, 1.7, -3.6), (1.8, 2.6, 0.22), "iron_green")
k.label("PanelLabel", "Details", (3.8, 2.3, -3.45), "TABLERO ELÉCTRICO", 20, (0.92, 0.82, 0.54))
for i in range(3):
    k.block("Cable%d" % i, "Details", (2.1 + i * 0.75, 2.6 - i * 0.35, -3.42), (0.07, 0.07, 0.08), "safety_yellow", solid=False)
k.note("MaintenanceReport", (-3.4, 0.9, -2.0), "maestranza_maintenance_report", paper_scale=0.7)
k.examine("PowerPanel", (3.0, 0.0, -3.0), [
    "El cable amarillo termina en el tablero azul.",
    "La palanca principal está abajo. El circuito del pasillo depende de este panel."
])
k.pickup("RifleAmmo", (1.2, 0.0, 2.8), "ammo_rifle", 10)
# Lanzagranadas almacenado en la mesa de mantenimiento.
k.pickup("WorkshopGrenadeLauncher", (-3.0, 0.82, -2.2), "grenade_launcher", rot=(0, 0.4, 0), sets_flag="found:grenade_launcher")
k.pickup("Grenades", (5.4, 0.0, 2.8), "ammo_grenades", 1)
k.infected("Mechanic", (-0.8, 0.05, 1.0), yaw=1.5, kind="infected_worker")
k.leo_hint("LeoPanel", (2.7, 0.0, -2.5), [
    "Leo: El cable amarillo llega al tablero azul. La palanca está abajo.",
    "Leo: La luz del pasillo depende de ese circuito.",
    "Leo: Acércate al tablero azul y baja la palanca para restablecer la energía."
])
save_room(k, "maestranza_taller")
print("maestranza_taller: generador listo")
