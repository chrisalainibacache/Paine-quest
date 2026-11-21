import sys, os
HERE = os.path.dirname(os.path.abspath(__file__))
if HERE not in sys.path: sys.path.insert(0, HERE)
from maestranza_common import *

k = create_room("MaestranzaVestuario", "Vestuario del personal", "service_corridor")
connect_room(k, "maestranza_taller", "maestranza_pasillo_cuarentena", "PASILLO DE CUARENTENA")
for i, x in enumerate((-5.2, -2.8, -0.4, 2.0)):
    k.block("Locker%d" % i, "Props", (x, 1.15, -3.2), (1.5, 2.3, 0.8), "iron_green")
    k.block("LockerDoor%d" % i, "Details", (x, 1.15, -2.76), (1.38, 2.15, 0.05), "metal", solid=False)
    k.label("LockerNumber%d" % i, "Details", (x, 2.1, -2.7), "0%d" % (i + 1), 16, (0.9, 0.82, 0.62))
k.prop("Bench", "Props", "bench", (3.7, 0.0, 1.7), rot=(0.0, 1.57, 0.0))
k.note("UnsentLetter", (-4.9, 0.9, -2.6), "maestranza_worker_letter", paper_scale=0.72)
k.examine("WorkerTestimony", (4.8, 0.0, 1.5), [
    "Operario: La vi al fondo, detrás del vidrio. Pelo gris recogido, chaqueta verde oliva.",
    "Operario: No parecía perdida; miraba como si estuviera esperando a alguien.",
    "Operario: Cuando el infectado salió, se apartó para dejarla pasar. Yo me escondí antes de verle la cara."
])
k.pickup("Ammo", (3.8, 0.0, -0.5), "ammo_9mm", 10)
k.infected("LockerInfected", (-0.2, 0.05, 1.4), yaw=2.2, kind="infected_pale")
k.leo_hint("LeoLocker", (3.8, 0.0, 1.2), [
    "Leo: Ese operario vio a una mujer detrás del vidrio. No le vio la cara.",
    "Leo: La carta habla de una puerta arrancada desde dentro. No es el mismo informe del taller.",
    "Leo: Habla con el operario desde el lado seguro y lee la carta que quedó junto al casillero."
])
save_room(k, "maestranza_vestuario")
print("maestranza_vestuario: generador listo")
