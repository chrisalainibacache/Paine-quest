import sys, os
HERE = os.path.dirname(os.path.abspath(__file__))
if HERE not in sys.path: sys.path.insert(0, HERE)
from maestranza_common import *

k = create_room("MaestranzaPasilloCuarentena", "Pasillo de cuarentena", "underpass")
connect_room(k, "maestranza_vestuario", "maestranza_puesto_sanitario", "PUESTO SANITARIO")
k.block("YellowRoute", "Details", (0.0, 0.015, 0.0), (1.0, 0.03, 8.5), "safety_yellow", solid=False)
k.block("QuarantineFenceA", "Props", (2.8, 0.65, -1.5), (0.12, 1.3, 6.8), "metal")
k.block("QuarantineFenceB", "Props", (5.8, 0.65, -1.5), (0.12, 1.3, 6.8), "metal")
k.label("QuarantineSign", "Details", (4.3, 2.8, -4.7), "CUARENTENA — ACCESO RESTRINGIDO", 18, (0.94, 0.78, 0.46))
k.note("ClosureOrder", (-3.8, 0.9, -2.8), "maestranza_closure_order", paper_scale=0.72)
k.door("SealedNosWagon", (4.3, 0.0, -3.8), "", "", prompt="NO ABRIR",
       locked_text="El precinto del Centro de Nos está intacto. La orden prohíbe abrir este vagón.",
       reach=1.5, metal_door=True)
k.examine("Seal", (4.3, 0.0, -2.7), [
    "El precinto lleva el número de serie intacto.",
    "No hay golpes recientes ni daños en el sello. Nadie ha autorizado una inspección."
])
k.infected("QuarantinePatient", (-2.5, 0.05, 2.1), yaw=0.8, state="lying", kind="infected_worker")
k.leo_hint("LeoSeal", (1.0, 0.0, -2.0), [
    "Leo: Ese vagón tiene el sello intacto. Paz dijo que nadie lo abriera.",
    "Leo: La franja amarilla llega hasta la puerta del puesto sanitario.",
    "Leo: No toques el precinto; sigue la franja amarilla hasta la puerta de servicio."
])
save_room(k, "maestranza_pasillo_cuarentena")
print("maestranza_pasillo_cuarentena: generador listo")
