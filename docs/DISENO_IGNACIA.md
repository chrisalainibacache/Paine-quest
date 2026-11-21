# Diseño de Ignacia (jugadora 2, solo modo cooperativo) — borrador del 2026-11-21

> Referencia: **foto que envió Chris** («Ella es Ignacia»). **La foto NO se sube al repositorio** mientras sea público (es una persona real); se queda en la conversación de Chris. Aquí solo hay su descripción.
> **Antes de publicar el juego en tienda:** confirmar con ella (y con su familia si fuera menor) que acepta que su imagen inspire un personaje. El guion dice 26 años: **Chris confirma la edad que quiere para el personaje**.

## 1. Rasgos de la referencia (para el modelo)
- **Pelo:** largo, ondulado, rojo oscuro (burdeo / caoba) con flequillo largo hacia los lados; le cae sobre los hombros y el pecho.
- **Cara:** redonda, mirada directa y tranquila, expresión seria con un punto de timidez. Cejas definidas.
- **Complexión:** **delgada** (decisión de Chris, 2026-11-21: la versión robusta le pareció demasiado; ella podría molestarse). Se cuida que el personaje sea respetuoso con su imagen.
- **Ropa de la foto:** polerón de mangas largas rojo burdeo, amplio; buzo gris; (zapatillas). Colgante fino al cuello.

## 2. Vestuario en el juego (coherente con el guion)
Ignacia salió **a toda prisa de su casa** a las 22:40 a buscar a la hermana de Paz: por eso viste **ropa de casa**, no uniforme. Se agrega lo que explica su oficio:
| Pieza | Detalle |
| --- | --- |
| Polerón rojo burdeo, mangas largas | Ya con manchas de polvo y hollín al avanzar los capítulos (versión «sucia» en capítulo 3+). |
| Buzo gris | Rodillas gastadas. |
| **Mochila de paramédico** | Verde oscuro con cruz blanca descolorida: el rasgo que la distingue de Isabella a lo lejos. |
| **Linterna frontal** | La que usa en los apagones (guion §10.5). |
| **Credencial de la clínica** colgando | Detalle para el primer plano de las cinemáticas. |
| Zapatillas blancas, sucias | — |

**Silueta y color:** Isabella es oscura y angulosa (negro, carcaj); Ignacia es **roja, redonda y cálida**. En las cámaras fijas, con el piso gris, el **burdeo** la hace identificable al instante. Paleta: burdeo `#7b1a2a`, gris `#6f7378`, verde mochila `#2f4a3a`, acento blanco cruz.

## 3. Papel jugable (PROPUESTA; decide Chris)
| Isabella | Ignacia |
| --- | --- |
| Dispara (pistola y las armas que encuentra) | **Paramédica**: cura a su compañera y a sí misma con **+50 % de eficacia** y puede **levantar a Isabella** si cae (una vez por sala). |
| Habla poco; Leo la guía | **Tiene llave inglesa** (cuerpo a cuerpo, silenciosa): empuja y remata infectados caídos. Puede usar las armas de fuego que recoja. |
| — | Su **mochila** sube de 8 a 10 espacios (guarda más curas). |
Objetivo: que no sea «Isabella con otro peinado»: dos estilos que se complementan (una cubre a distancia, la otra sostiene y cura).

## 4. Producción del modelo (a decidir)
Isabella es un modelo con rig Mixamo. Opciones para Ignacia:
1. **Mixamo + retoque (recomendada):** Chris descarga un personaje femenino de Mixamo con su cuenta; yo lo reviso, le pinto la textura (polerón burdeo, buzo gris), le pongo pelo largo burdeo y la mochila. Mismas animaciones que Isabella.
2. **Base CC0** (p. ej. de Quaternius) retocada en código: más lento de parecerse a la referencia.
3. **Pedirle a ChatGPT un concepto 2D** (tabla de personaje) a partir de esta descripción para validar el aspecto antes del 3D.
Siguiente paso que propongo: **(3) concepto 2D → aprobación de Chris → (1) modelo 3D → pruebas con el motor**.

## 5. Ficha para pasarle a ChatGPT (concepto 2D)
> Personaje de videojuego de survival horror 2.5D estilo PS1 en Chile. **Ignacia**, técnica en enfermería, mujer joven de complexión robusta, pelo largo ondulado rojo oscuro con flequillo, cara redonda, mirada tranquila y seria. Polerón rojo burdeo amplio de mangas largas, buzo gris, zapatillas blancas sucias, mochila de paramédico verde oscuro con cruz blanca, linterna frontal en la frente, credencial colgando. Aspecto de noche de apocalipsis: polvo, hollín. Hoja de personaje: vista frontal, lateral y de espaldas, y tres expresiones (serena, asustada, decidida). Sin armas de fuego; lleva una llave inglesa. Estilo realista estilizado, paleta cálida.

## 6. Estado (2026-11-21): modelo jugable v1 HECHO
- **Modelo con huesos:** `assets/characters/ignacia/ignacia.glb`, generado por `tools/build_ignacia.gd` a partir de la base CC0 de Quaternius (esqueleto de 65 huesos, humanoide de Godot). **Usa las mismas animaciones que Isabella** (caminar, trotar, apuntar, disparar, recargar, morir…) y el mismo control con joystick.
- **Cómo se ve:** pelo largo burdeo, polerón rojo burdeo, buzo gris, zapatillas blancas, mochila verde de paramédico, complexión **delgada** (v2; ajustable en `INFLATE` de `tools/build_ignacia.gd`).
- **Cómo probarla en el teléfono:** Opciones → botón **«PERSONAJE: ISABELLA»** → pasa a **IGNACIA (PRUEBA)**; se aplica al cargar la siguiente sala (o al volver a entrar a la partida). Es un interruptor temporal hasta que exista el modo cooperativo.
- **Pendiente de pulir:** cara (más parecida a la referencia), mochila con cruz blanca, textura de tela del polerón, versión «sucia» desde el capítulo 3, habilidades de paramédica (curar +50 %, llave inglesa).
- Revisión de arte: `xvfb-run godot --path . --rendering-driver opengl3 --resolution 1600x720 -s res://tools/capture_ignacia.gd -- salida.png Idle|Jog`.
- Corregido de paso un fallo previo: guardar el modo gráfico **borraba** los volúmenes guardados (ahora conserva las demás secciones del archivo de ajustes).

## 7. Vestuario v3 (2026-11-21): uniforme táctico de paramédica (pedido de Chris: «casi fuerzas especiales de la Cruz Roja»)
- Chaqueta roja de manga larga con **bandas reflectantes** blancas en los brazos; **chaleco táctico** carbón con bolsas y **parche de cruz blanca**; buzo táctico oscuro con **rodilleras** y **bolsillos de carga**; **botas y guantes negros**; **cinturón** con bolsa médica roja; **mochila roja** de primeros auxilios con cruz blanca; **linterna frontal**.
- Todo se genera en `tools/build_ignacia.gd` (ropa que sigue el cuerpo + piezas rígidas pegadas a los huesos), sin packs de terceros: no hay licencias nuevas.
- **Aviso legal antes de publicar:** la **cruz roja sobre fondo blanco es un emblema protegido** (Convenios de Ginebra y leyes nacionales, también en Chile). El juego usa una **cruz blanca sobre rojo/oscuro** (colores invertidos) y no dice «Cruz Roja»; aun así, antes de salir a la tienda conviene cambiarla por un símbolo médico propio o confirmar que no hay problema.
