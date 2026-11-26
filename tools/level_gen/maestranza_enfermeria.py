import sys, os
HERE = os.path.dirname(os.path.abspath(__file__))
if HERE not in sys.path: sys.path.insert(0, HERE)
from maestranza_common import *

k = create_room("MaestranzaEnfermeria", "Enfermería", "service_corridor", theme="infirmary", size=(14.0, 9.0), height=4.2)
connect_room(k, "maestranza_guardia", "maestranza_taller", "TALLER")
for i, x in enumerate((-4.0, 4.0)):
    k.block("Bed%d" % i, "Props", (x, 0.25, -1.8), (2.5, 0.5, 1.0), "metal")
    k.block("Mattress%d" % i, "Props", (x, 0.58, -1.8), (2.2, 0.16, 0.9), "canvas", solid=False)
    k.block("Curtain%d" % i, "Props", (x + 1.2, 1.4, -1.8), (0.06, 1.2, 1.8), "canvas", solid=False)
k.block("MedicineCabinet", "Props", (-5.7, 1.1, 3.2), (1.4, 2.2, 0.7), "metal")
k.label("ClinicSign", "Details", (0.0, 3.0, -4.82), "ENFERMERÍA", 28, (0.82, 0.88, 0.86))
k.note("NursingLog", (-5.2, 1.0, 3.0), "maestranza_nursing_log", paper_scale=0.68)
k.block("Nightstand", "Props", (0.0, 0.4, -1.2), (0.6, 0.8, 0.5), "metal")
k.note("PatientStatement", (0.0, 0.85, -1.2), "maestranza_patient_statement", paper_scale=0.68)
k.pickup("MedicalFood", (-5.0, 0.0, 2.2), "sushi")
k.infected("Patient", (3.5, 0.05, 1.5), yaw=-1.1, state="lying", kind="infected_pale")
k.leo_hint("LeoClinic", (1.0, 0.0, 2.2), [
    "Leo: La cortina del fondo se mueve. No te acerques de frente.",
    "Leo: Hay algo junto a las camillas y el armario está abierto.",
    "Leo: Rodea las camillas, revisa el armario bajo y recoge lo que quede dentro."
])
save_room(k, "maestranza_enfermeria")
print("maestranza_enfermeria: generador listo")
