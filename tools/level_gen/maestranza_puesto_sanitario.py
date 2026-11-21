import sys, os
HERE = os.path.dirname(os.path.abspath(__file__))
if HERE not in sys.path: sys.path.insert(0, HERE)
from maestranza_common import *

k = create_room("MaestranzaPuestoSanitario", "Puesto sanitario", "military")
k.door("ToQuarantine", (-7.8, 0.0, 0.0), PREV % "maestranza_pasillo_cuarentena", "from_next",
       prompt="VOLVER", reach=1.4, metal_door=True)
k.door_frame("ArrivalFrame", X0, 0.0, "z", width=1.6, wall_side=1, panel="metal")
k.prop("MedicalDesk", "Props", "typewriter_desk", (-3.2, 0.0, -2.0), rot=(0.0, 0.2, 0.0))
k.prop("Radio", "Props", "field_radio", (-3.2, 0.8, -2.0))
k.block("Bed", "Props", (2.8, 0.42, 1.2), (2.6, 0.84, 1.1), "metal")
k.block("Mattress", "Props", (2.8, 0.92, 1.2), (2.3, 0.16, 0.9), "canvas", solid=False)
k.label("SafeSign", "Details", (0.0, 3.0, -4.82), "PUESTO SANITARIO", 28, (0.76, 0.9, 0.82))
k.note("RadioTranscript", (-3.0, 0.9, -1.8), "maestranza_radio_transcript", paper_scale=0.72)
k.examine("PazMeeting", (0.0, 0.0, 1.0), [
    "Paz: Te escuché por la radio. Pensé que no ibas a llegar.",
    "Paz: ¿Viste a otros sobrevivientes en el camino?",
    "Paz: Tengo una credencial de acceso al Centro de Nos. No sé qué vamos a encontrar, pero es la única ruta que sigue abierta. Vamos juntas."
])
k.pickup("MedicalSupplies", (2.8, 1.0, 1.2), "handroll")
k.camera("West", (-4.0, 1.5, 0.0), (8.0, 3.0, 10.0), (-1.0, 4.8, 7.0), (-4.0, 0.5, 0.0), fov=62)
k.camera("East", (4.0, 1.5, 0.0), (8.0, 3.0, 10.0), (1.0, 4.8, -7.0), (4.0, 0.5, 0.0), fov=62)
k.spawn("from_previous", (-6.45, 0.05, 0.0), (1, 0))
k.interact("ContinueToNos", "chapter_exit", (0.0, 0.0, 3.7), chapter="4",
    question='"¿Seguirás con Paz hacia el Centro de Nos? No podrás volver a La Maestranza."',
    accept_text='"CONTINUAR"',
    before_lines='PackedStringArray("Paz: Vamos juntas, Isabella. La credencial debería abrir el acceso exterior.", "Leo: Ya están juntas. Cuando estés lista, sigue con Paz hacia el norte.")')
k.leo_hint("LeoPaz", (0.0, 0.0, 2.5), [
    "Leo: Paz está aquí. Deja que cierre la puerta y descansa un momento.",
    "Leo: La radio dejó un registro de su turno. Léelo antes de irte.",
    "Leo: Habla con Paz y acepta continuar cuando estés lista."
])
save_room(k, "maestranza_puesto_sanitario")
print("maestranza_puesto_sanitario: generador listo")
