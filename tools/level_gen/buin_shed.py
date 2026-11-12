import sys, math, os; sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
from buin_common import *
# Galpón de la viña (sala segura): barricas, la oficina donde se encerró Rosa
# y la radio de los militares. La radio cierra el capítulo 3.
k = Kit("Shed", "Galpón de la viña")
k.env((0.03, 0.03, 0.03), (0.5, 0.45, 0.4), 0.85, (0.08, 0.07, 0.06), 0.035)
X0, X1, Z0, Z1, H = -5.0, 5.0, -4.0, 4.0, 4.8
k.shell(X0, X1, Z0, Z1, H, floor="planks", wall="barrel_wood", ceiling="planks")
k.door_frame("ToVineyard", X0, 0.0, "z", width=1.8, wall_side=1, panel="planks")
# Oficina de Rosa (rincón noreste): tabique con puerta.
k.block("OfficeWall", "Office", (2.8, H / 2, -1.6), (4.4, H, 0.2), "plaster_wall")
k.block("OfficeWallE", "Office", (0.6, H / 2, -2.8), (0.2, H, 2.4), "plaster_wall")
k.block("OfficeDoor", "Office", (2.6, 1.05, -1.48), (0.95, 2.1, 0.05), "planks", solid=False)
k.label("OfficeSign", "Office", (2.6, 2.4, -1.47), "OFICINA", 26, (0.2, 0.17, 0.12))
k.mesh("DoorGap", "Office", (0.9, 0.03, 0.02), k.emissive((1.0, 0.85, 0.55), 1.4), (2.6, 0.02, -1.46))
for i in range(4):
    for j in range(2):
        k.prop("Barrel%d_%d" % (i, j), "Props", "wine_barrel", (-3.2 + i * 1.15, j * 0.88, 3.1), rot=(0, math.pi / 2, 0))
for i in range(3):
    k.prop("BarrelW%d" % i, "Props", "wine_barrel", (-4.3, 0, -3.2 + i * 1.1))
k.prop("Desk", "Props", "typewriter_desk", (3.9, 0, 0.6), rot=(0, -math.pi / 2, 0))
k.block("RadioTable", "Props", (0.6, 0.38, 0.3), (1.2, 0.76, 0.7), "wood")
k.prop("Radio", "Props", "field_radio", (0.6, 0.76, 0.3))
k.light("Lamp", "Lights", (0.0, H - 0.5, 0.5), (1.0, 0.82, 0.6), 1.1, 7.5)
k.mesh("Bulb", "Lights", (0.12, 0.16, 0.12), k.emissive((1.0, 0.85, 0.6), 1.2), (0.0, H - 0.2, 0.5))
k.decal("Wine", "oil_stain", (-1.8, 0.012, 1.8), 1.8, "up")
k.decal("Hand", "blood_handprint", (2.0, 1.2, -1.48), 0.38, "+z", rot=0.3)
k.decal("Drops", "blood_footprints", (1.8, 0.012, -0.8), (1.6, 0.8), "up", rot=1.3)
# Interactuables.
k.door("ToVineyard", (-4.6, 0, 0.0), B % "vineyard", "from_shed", prompt="SALIR", reach=1.3)
k.interact("Typewriter", "typewriter", (3.55, 0.8, 0.6), reach="1.4")
k.interact("RosaDoor", "voice_door", (2.6, 0, -1.0), reach="1.3", sets_flag='"talked:rosa"',
    lines="PackedStringArray(%s)" % ", ".join('"%s"' % l for l in [
        "La puerta de la oficina tiene llave. Adentro alguien respira.",
        "Rosa: ¿Quién está ahí? ...No abras. Por favor, no abras.",
        "Rosa: Soy Rosa, de la boletería de Paine. Me mordieron en el puente, anoche. Ya tengo el frío del que hablaba don Héctor.",
        "Rosa: Escúchame bien, niña. Al hombre de la mano vendada yo le vendí el boleto del 6:30.",
        "Rosa: Llevaba una credencial colgando: «Centro de Investigación Sanitaria — Nos». Venía de ahí.",
        "Rosa: Y la radio de los militares... no para de sonar. Es una mujer. Pregunta por una tal Constanza.",
        "Leo: Cony... ella ya no va a abrir. Déjala descansar. La radio está en la mesa."]),
    repeat_lines="PackedStringArray(%s)" % ", ".join('"%s"' % l for l in [
        "Rosa: Ándate, niña. Llévate al gato. Y escucha esa radio."]))
k.interact("Radio", "chapter_exit", (0.6, 0, 0.9), reach="1.3", chapter="3", accept_text='"ESCUCHAR"',
    question='"Una radio militar encendida. Entre la estática se oye una voz de mujer.\\n¿Escuchar?"',
    before_lines="PackedStringArray(%s)" % ", ".join('"%s"' % l for l in [
        "Javiera: ...Constanza... Cony, si me escuchas... soy yo, la Javi.",
        "Javiera: No vayas a Alameda. Allá ya no queda nadie.",
        "Javiera: Me trajeron a la Maestranza de San Bernardo a atender a los enfermos. Llegan en tren, de noche, amarrados.",
        "Javiera: Hay un vagón al fondo que nadie abre. Los militares dicen que es del Centro de Nos...",
        "Javiera: Ven por la vía. Te espero en la entrada de...",
        "La señal se corta.",
        "Leo: San Bernardo. Yo sé el camino, Cony. Vamos."]))
k.pickup("Shells", (-3.0, 0.0, 1.8), "ammo_shells", 6, rot=(0, 0.8, 0))
k.pickup("Sushi", (3.7, 0.77, 1.0), "sushi", rot=(0, 0.3, 0))
k.camera("West", (-2.5, 1.5, 0.0), (5.0, 3.0, 8.0), (2.4, 3.8, 3.4), (-2.6, 0.4, -0.8), fov=64)
k.camera("East", (2.5, 1.5, 0.0), (5.0, 3.0, 8.0), (-1.8, 3.8, 3.4), (2.6, 0.4, -0.8), fov=64)
k.spawn("from_vineyard", (-4.1, 0.05, 0.0), (1, 0))
k.leo_hint("LeoRosa", (2.6, 0, -0.5), ["Leo: Ahí adentro está Rosa. Huele a ella... y a frío.", "Leo: Háblale, Cony. Pero no abras esa puerta."], hide_if="talked:rosa")
k.leo_hint("LeoRadio", (0.6, 0, 1.2), ["Leo: La radio. Alguien te está llamando, Cony."], show_if="talked:rosa")
k.save(REPO + "/levels/buin/shed.tscn")
print("shed ok")
