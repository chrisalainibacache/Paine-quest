# Remaster de la estación — decisiones (contradicciones resueltas)

La imagen de referencia ("Remaster HD Etapa 1") es una foto generada por IA: de día,
con otra arquitectura y luz solar real. El brief que la acompañaba pedía a la vez "no
rediseñar la estación, no cambiar geometría ni iluminación". Esas dos cosas se
contradicen; esto es lo que se decidió y por qué.

| Tema | Contradicción | Decisión |
| --- | --- | --- |
| Día vs. noche | La imagen es de día; el juego es terror nocturno. | Se mantiene **la noche, la niebla y la luz de sodio** (identidad del juego). |
| Geometría | El brief la prohíbe; lo que da riqueza a la imagen es justamente geometría. | Se permite **geometría de detalle** si la planta no cambia: colisiones, cámaras y puntos de aparición iguales (lo verifica `tests/levels_test.gd`). |
| Qué se toma de la imagen | — | Columnas de fierro con capitel y ménsulas, alero de tablas con vigas, zócalo y pilastras rojas, ventanas y puerta en arco, reloj, afiche turístico de Paine con la cordillera, maceteros, faroles de pared, bancas de fierro y madera. |
| Texturas HD | Reescalar las de 256 px no agrega detalle (lo comprobó la rama de ChatGPT). | **Hecho:** las 14 texturas se rehicieron a 512 px **desde los mismos originales de ambientCG (CC0)** que usó la versión de 256 (`tools/remaster_textures.gd`, mismo tratamiento PS1). Respaldo de las de 256 px en `assets/environment/textures_ps1_256/`. |
| Resolución de pantalla | El filtro PS1 bajaba la imagen a 300 líneas: el detalle nuevo se perdía. | El filtro pasa a **480 líneas** (`shaders/ps1_screen.gdshader`): en un teléfono de 1080 px quedan píxeles de 2x2 en vez de 3x3; se mantienen el tramado y el color de 15 bits. Es el cambio que más se nota. |
| Fotorrealismo | Imposible a 60 fps en Android con el renderer Compatibility. | Estilo PS1 con más detalle; nada de reflejos ni materiales fotográficos. |
| Dificultad | Un cambio posterior bajó a 5 balazos; Chris pidió 7. | **7 balazos** el infectado común (11 el pesado). Manda lo que pidió Chris. |
| Armas | El GDD decía "la pistola se encuentra en la boletería" y "solo armas de fuego". | Chris pidió **todas las armas en la mochila al inicio**: la boletería ahora tiene la munición del guardia. Se mantiene "solo armas de fuego": el cuchillo del pack no se usa. |

Revisión visual: `tools/capture_rooms.gd` (cada cámara de cada sala) y
`tools/capture_weapons.gd` (cada arma).
