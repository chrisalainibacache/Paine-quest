import sys, os
HERE = os.path.dirname(os.path.abspath(__file__))
if HERE not in sys.path: sys.path.insert(0, HERE)
from maestranza_common import *
import vertical

k = create_room("MaestranzaAcceso", "Acceso a La Maestranza", "military", theme="corridor", size=(17.0, 8.0), height=4.6)
connect_room(k, "", "maestranza_guardia", "PUESTO DE GUARDIA", first=True)
k.prop("Barrier", "Props", "barrier", (0.0, 0.0, -2.1), rot=(0.0, 0.12, 0.0))
k.prop("GuardDesk", "Props", "typewriter_desk", (-3.2, 0.0, 2.1), rot=(0.0, -0.4, 0.0))
k.prop("Radio", "Props", "field_radio", (-3.2, 0.8, 2.1))
k.prop("Crate", "Props", "crate", (4.5, 0.0, -2.8), rot=(0.0, 0.6, 0.0))
k.label("SiteSign", "Details", (0.0, 3.0, -4.82), "LA MAESTRANZA", 36, (0.86, 0.82, 0.72))
k.note("GuardPart", (-3.0, 0.85, 2.0), "maestranza_guard_part", paper_scale=0.75)
k.pickup("PistolAmmo", (4.7, 0.0, 2.8), "ammo_9mm", 20)
k.infected("Worker", (2.0, 0.05, -1.0), yaw=2.4, kind="infected_worker")
k.leo_hint("LeoAccess", (-1.0, 0.0, -1.8), [
    "Leo: El puesto está detrás de la barrera. Hay una puerta lateral.",
    "Leo: No cruces por el centro; ese infectado puede oírte.",
    "Leo: Rodea la barrera y entra por la puerta lateral hacia el puesto de guardia."
])
# Pasarela de vigilancia sobre el muro norte (2,6 m), con escalera desde el este y munición para quien suba.
vertical.balcony(k, "Walkway", -4.5, 3.4, -3.9, -2.2, y=2.6, rail_sides="SW", gap=None)
vertical.stairs(k, "WalkwayStairs", 7.6, -3.05, "-x", width=1.3, rise=2.6)
k.raw["pickup"]("WalkwayAmmo", (-3.5, 2.6, -3.2), "ammo_9mm", 10)
save_room(k, "maestranza_acceso", avoid_rects=[(-4.9, 3.8, -4.4, -1.8), (3.3, 8.2, -4.0, -2.2)])
print("maestranza_acceso: generador listo")
