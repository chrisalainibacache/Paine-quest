import sys, math, os; sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
from buin_common import *
import detail
import vertical
# Galpón de la viña (sala segura): barricas, la oficina donde se encerró Rosa
# y la radio de los militares. La radio cierra el capítulo 3.
k = Kit("Shed", "Galpón de la viña", ambience="barn")
k.env((0.03, 0.03, 0.03), (0.5, 0.45, 0.4), 0.85, (0.08, 0.07, 0.06), 0.035)
X0, X1, Z0, Z1, H = -5.0, 5.0, -4.0, 4.0, 4.8
k.shell(X0, X1, Z0, Z1, H, floor="planks", wall="barrel_wood", ceiling="planks")
k.door_frame("ToVineyard", X0, 0.0, "z", width=1.8, wall_side=1, panel="planks")
k.door_frame("ToPatioFrame", -1.5, Z0, "x", width=1.1, wall_side=1, panel="metal")
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
# Rifle de cacería sobre el escritorio de la bodega.
k.pickup("HuntingMauser", (3.9, 0.82, 0.6), "mauser", rot=(0, 0.4, 0), sets_flag="found:mauser")
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
# Atajo B: el pestillo se levanta desde el patio de cosecha; desde el galpón la puerta está trancada por fuera.
k.door("door_shed_patio", (-1.5, 0, -3.6), B % "patio_cosecha", "from_shed", prompt="ABRIR", reach=1.3,
       lock_id="buin_shortcut_patio_shed", one_way=True, one_way_origin=False, metal_door=True)
k.spawn("from_patio", (-1.5, 0.05, -3.0), (0, 1))
# Altillo de almacenamiento (2,2 m) al suroeste, con escalera desde el este.
vertical.balcony(k, "Attic", -4.9, -3.4, 1.2, 3.9, y=2.2, rail_sides="NE", gap=("E", 1.2, 2.4))
vertical.stairs(k, "AtticStairs", 0.2, 1.8, "-x", width=1.1, rise=2.2)
# Zócalo de la batería de la radio (la batería se recupera en la caseta de bombas).
k.interact("RadioSocket", "fuse_box", (1.3, 0, 0.9), puzzle=k._puzzle_resource("buin_radio_socket"), unlock_id='"buin_radio_power"', prompt='"INSTALAR BATERÍA"',
           missing_text='"La tapa de la radio tiene dos contactos vacíos y una etiqueta: 12 V. Falta la batería."',
           solved_text='"La batería encaja. El indicador de la radio se enciende, verde y estable."', reach="1.3")
k.storage_chest("StorageChest", (-2.5, 0.45, -2.5))
k.interact("RosaDoor", "voice_door", (2.6, 0, -1.0), reach="1.3", sets_flag='"talked:rosa"',
    lines="PackedStringArray(%s)" % ", ".join('"%s"' % l for l in [
        "La puerta de la oficina tiene llave. Adentro alguien respira.",
        "Rosa: ¿Quién está ahí? ...No abras. Por favor, no abras.",
        "Rosa: Soy Rosa, de la boletería de Paine. Me mordieron en el puente, anoche. Ya tengo el frío del que hablaba don Héctor.",
        "Rosa: Algo enorme me agarró en el puente. No me terminó de matar... me miró, y se fue. Como si me hubiera dejado guardada.",
        "Rosa: Escúchame bien, niña. Al hombre de la mano vendada yo le vendí el boleto del 6:30.",
        "Rosa: Llevaba una credencial colgando: «Centro de Investigación Sanitaria — Nos». Venía de ahí.",
        "Rosa: Y la radio de los militares... no para de sonar. Es una mujer. Pregunta si hay sobrevivientes.",
        "Algo no cuadra. Rosa estaba en Paine a las once de la noche. ¿Cómo cruzó sola hasta aquí, con ellos por todos lados?",
        "Leo: Isabella... no le creas. Ese olor no es de persona, y tampoco es de los otros. Es distinto. Ella no es como los demás.",
        "Leo: No abras esa puerta. La radio está en la mesa."]),
    repeat_lines="PackedStringArray(%s)" % ", ".join('"%s"' % l for l in [
        "Rosa: Ándate, niña. Llévate al gato. Y escucha esa radio... antes de que yo cambie de idea."]))
k.interact("Radio", "chapter_exit", (0.6, 0, 0.9), reach="1.3", chapter="3", accept_text='"ESCUCHAR"',
    required_flags='PackedStringArray("talked:rosa", "unlocked:buin_control_clear", "unlocked:buin_radio_power")',
    blocked_text='"La radio solo suelta estática. Algo le falta: energía, el paso del control y escuchar antes a quien está en la oficina."',
    question='"Una radio militar encendida. Entre la estática se oye una voz de mujer.\\n¿Escuchar?"',
    before_lines="PackedStringArray(%s)" % ", ".join('"%s"' % l for l in [
        "Paz: ...¿Hay sobrevivientes? Si alguien me escucha... Isabella, si me escuchas... soy yo, Paz.",
        "Paz: No vayas a Alameda. Allá ya no queda nadie.",
        "Paz: Me trajeron a la Maestranza de San Bernardo a atender a los enfermos. Llegan en tren, de noche, amarrados.",
        "Paz: Hay un vagón al fondo que nadie abre. Los militares dicen que es del Centro de Nos...",
        "Paz: Ven por la vía. Te espero en la entrada de...",
        "La señal se corta.",
        "Leo: San Bernardo. Yo sé el camino, Isabella. Vamos."]))
k.pickup("Shells", (-4.2, 2.2, 2.6), "ammo_shells", 6, rot=(0, 0.8, 0))
k.pickup("Sushi", (3.7, 0.77, 1.0), "sushi", rot=(0, 0.3, 0))
k.camera("West", (-2.5, 2.1, 0.0), (5.0, 4.2, 8.0), (2.4, 3.8, 3.4), (-2.6, 0.4, -0.8), fov=64)
k.camera("East", (2.5, 1.5, 0.0), (5.0, 3.0, 8.0), (-1.8, 3.8, 3.4), (2.6, 0.4, -0.8), fov=64)
k.spawn("from_vineyard", (-4.1, 0.05, 0.0), (1, 0))
k.leo_hint("LeoRosa", (2.6, 0, -0.5), ["Leo: Ahí adentro está Rosa. Huele a ella... y a algo más que no me gusta.", "Leo: Háblale, Isabella, pero con cuidado. Y no abras esa puerta.", "Leo: Interactúa con la puerta para hablar con Rosa, pero no la abras."], hide_if="talked:rosa")
k.leo_hint("LeoRadio", (0.6, 0, 1.2), ["Leo: La radio. Alguien te está llamando, Isabella.", "Leo: Acércate a la radio y escucha el mensaje de Paz antes de salir."], show_if="talked:rosa")
detail.dress(k, -4.7, 4.7, -3.7, 3.7, H, theme="storage", seed=713, extra=8, avoid_rects=[(0.4, 5.1, -4.1, -0.8), (-5.0, -3.3, 1.1, 4.0), (-3.4, 0.4, 1.2, 2.4)])
k.save(REPO + "/levels/buin/shed.tscn")
print("shed ok")
