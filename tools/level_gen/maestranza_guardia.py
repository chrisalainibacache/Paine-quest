import sys, os
HERE = os.path.dirname(os.path.abspath(__file__))
if HERE not in sys.path: sys.path.insert(0, HERE)
from maestranza_common import *

k = create_room("MaestranzaGuardia", "Puesto de guardia", "office")
connect_room(k, "maestranza_acceso", "maestranza_enfermeria", "ENFERMERÍA")
k.prop("Desk", "Props", "typewriter_desk", (-2.5, 0.0, -1.8), rot=(0.0, 0.2, 0.0))
k.prop("Radio", "Props", "field_radio", (-2.5, 0.8, -1.8))
k.prop("Bench", "Props", "bench", (3.5, 0.0, 2.6), rot=(0.0, 3.14, 0.0))
k.block("MapBoard", "Details", (4.7, 1.8, -4.78), (3.0, 1.8, 0.12), "wood", solid=False)
k.label("MapTitle", "Details", (4.7, 2.2, -4.68), "CONTROL DE SECTOR", 22, (0.9, 0.82, 0.66))
k.note("SurveillanceReport", (-2.1, 0.9, -1.7), "maestranza_surveillance_report", paper_scale=0.72)
k.pickup("SmallKey", (1.0, 0.82, 2.2), "engineer_key")
# Rifle de precisión guardado sobre el banco de guardia.
k.pickup("GuardSniperRifle", (3.5, 0.72, 2.6), "sniper_rifle", rot=(0, 0.5, 0), sets_flag="found:sniper_rifle")
k.pickup("ShotgunAmmo", (3.2, 0.0, -2.8), "ammo_shells", 4)
k.examine("RadioMessage", (-2.5, 0.0, -1.1), [
    "La radio escupe estática. Una voz de mujer pregunta por sobrevivientes del sector.",
    "Paz: ¿Hay sobrevivientes en el sector? Si pueden responder, indiquen cuántos son y dónde están."
])
k.leo_hint("LeoKey", (0.7, 0.0, 2.0), [
    "Leo: Hay una llave pequeña bajo la mesa. La necesitamos para los casilleros.",
    "Leo: Acércate al escritorio y recoge la llave pequeña que quedó debajo."
])
save_room(k, "maestranza_guardia")
print("maestranza_guardia: generador listo")
