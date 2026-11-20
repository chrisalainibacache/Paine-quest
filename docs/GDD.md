# Paine — Documento de diseño (GDD)

> Documento vivo. Cada decisión de diseño importante se anota aquí antes de programarla.

## 1. Concepto

**Paine** es un survival horror en 3D con **cámaras fijas por sala** (2.5D al estilo
*Resident Evil 3* de PlayStation 1), para **Android en horizontal**.

**Isabella** y su gatita **Leo** despiertan en Paine (Chile) después de que *algo pasó*:
la gente se convirtió en infectados. Intentan salir siguiendo la línea del tren hacia
Santiago.

### Pilares
1. **Espacios cortos y cerrados.** Nada de mundo abierto: salas pequeñas con muros,
   rejas, vagones o escombros que las cierran. El escenario guía al jugador.
2. **Cámara cercana y cinematográfica.** Cada sala tiene 1–3 cámaras fijas que encuadran
   a Isabella de cerca; la cámara cambia (corte seco) al cruzar zonas invisibles.
3. **Tensión con recursos escasos.** Poca munición, curación limitada, guardado manual
   en máquinas de escribir.
4. **Look PS1, no "Roblox".** Texturas sucias de baja resolución, niebla, luz cálida de
   sodio, filtro de pantalla con tramado. Nada de colores planos ni bloques lisos.
5. **Rendimiento primero.** 60 fps estables en el teléfono. Una sala cargada a la vez.

## 2. Historia (capítulos 1 y 2)

> **Nombres (decisión de Chris, noviembre):** la protagonista se llama **Isabella** (antes
> "Cony") y su hermana **Paz** (antes "Javiera"). Los archivos internos conservan `cony`
> (`cony.glb`, `cony_animations.res`); en todo texto del juego y de los documentos se usa
> Isabella y Paz.

**Por qué viaja Isabella:** su hermana **Paz** vive en Santiago. A las 22:10 le escribe:
«Dicen en la tele que esta noche pasa un tren de evacuación por Paine. Súbete con Leo.
Te espero en Alameda.» El juego empieza con esa intro (se muestra una vez, al llegar).

### Línea de tiempo (viernes) — las notas deben respetarla
| Hora | Qué pasó | Dónde se cuenta |
| --- | --- | --- |
| 6:30 | Sale el tren D-16008 Paine–Alameda (212 pasajeros). Sube un hombre con la mano vendada (asiento 15, coche 3). | Boleto con un mensaje |
| 6:41–6:48 | Mordidas en el coche 3. El conductor lo cierra. El maquinista **Jorge Muñoz** mete el tren al desvío a propósito, antes de Linderos, para que no llegue a Santiago. | Planilla del conductor, Nota del maquinista |
| 7:05 | Llaman de Buin: el tren nunca pasó. | Libro de la boletería |
| 7:12 | Pasajeros mordidos vuelven caminando por la vía. Uno muerde a otro en el andén; el guardia **don Héctor** dispara (el reloj de la sala de espera queda con un balazo, parado a las 7:12). | Libro de la boletería, reloj |
| 7:20–7:40 | Héctor, herido, se encierra en la bodega y se convierte. **Rosa** (boletería) deja su pistola y balas en el escritorio. | Libro de la boletería |
| 7:50 | Un pasajero escribe la nota del andén. | Nota arrugada |
| 13:00 | El jefe de estación **Raúl** cierra el portón sur; la llave queda en la bodega con Héctor. | Diario del jefe de estación |
| Tarde | Aviso oficial: «un tren de evacuación pasará esta noche». | Aviso de la estación |
| 23:00 | Rosa escribe abajo: el tren no vendrá, cerraron la línea en Buin. | Aviso (2ª página) |
| 23:40 | **Llega Isabella** con Leo. Capítulo 1. | Intro del andén norte |
| Medianoche → amanecer | Capítulo 2 por la vía hasta la casa de cambios. Final: caminan a Santiago, Paz las espera. | Intro de la vía norte, finales |

Geografía (Línea Sur, de sur a norte): Hospital – **Paine** – Linderos – Buin – … – Alameda.
Santiago queda al **norte**; todo el viaje es hacia el norte por la vía.

### Capítulo 1 — La estación
Isabella llega con Leo a la estación de trenes de Paine buscando un tren a Santiago.
La estación está vacía y algo anda mal. Recorre el andén, la sala de espera y la
boletería; encuentra la pistola, notas de lo que pasó y la llave del portón que da a
las vías. Cierra el capítulo saliendo a la vía.

### Capítulo 2 — Las vías
Siguiendo las vías encuentran **el tren de las 6:30 ya destruido** (descarrilado y volcado;
no se ve el choque, se encuentra así). No sirve para viajar: hay que seguir a pie,
atravesando el convoy, un paso bajo nivel en apagón y una casa de cambios. El maquinista
frenó el tren contra el desvío para que los infectados no llegaran a la ciudad. Termina
con Isabella y Leo caminando por la vía hacia el norte al amanecer; **el capítulo 2 no es el final**: sigue con Buin
(capítulo 3), La Maestranza (4) y Santiago (5).

### Leo: guía y la última aventura (decisión de Chris)
Leo es la gata de Isabella. **Este juego es su última aventura**: todo lo que hace Leo se
escribe con ese cariño.
- **Guía:** si Isabella se queda quieta ~5 s, Leo camina hasta la pista activa de la sala
  (`levels/kit/leo_hint.gd`, grupo `leo_hints`), se sienta mirándola y maúlla. Al acercarse
  Isabella, Leo le explica qué hacer (una vez por pista). Si Leo tiene algo nuevo que decir,
  el botón ACCIÓN muestra **LEO**.
- **Habla:** sus líneas empiezan con `Leo: ` y salen en verde con su nombre. Habla bajito,
  tierna y segura: conoce el camino, huele el peligro y ve en la oscuridad.
- **Avisa:** bufa a los infectados cercanos, aunque se hagan los muertos.
- **Pistas sembradas (no decirlas en voz alta):** nadie ataca a Leo; Leo nunca se cansa;
  sus ojos brillan en la oscuridad; dice "siempre te he llevado yo".

### Cinemática de apertura (decisión de Chris, noviembre) — guion
Se muestra **una sola vez**, al empezar una **partida nueva** (nunca al continuar), antes de las líneas de
introducción del andén. **~7,5 s de video HD** (prerenderizado, sin personajes) + **~3 s de título** en el motor.
Se renderiza con `tools/prerender/render_cinematic.gd` (la misma técnica de los fondos del capítulo 1).
Tono: la estación de Paine de noche, vacía, **algo anda mal**; Leo e Isabella todavía no aparecen.
1. **0–2,5 s** — cámara baja junto a la vía, saliendo del túnel oeste; el andén vacío, el letrero PAINE,
   niebla; la luz de sodio **titila**. Viento lejano y zumbido eléctrico.
2. **2,5–5,5 s** — la cámara avanza despacio entre los pilares, ganando altura; los pilares pasan como cortinas.
   Cada caída de luz va con un chasquido eléctrico.
3. **5,5–7,5 s** — se detiene frente a la puerta de la sala de espera (la única ventana encendida). Fundido
   a negro con el viento que baja.
4. **Título (3 s, en el motor):** «PAINE» y debajo «Viernes · 23:40». Después, las líneas de intro de Isabella.
Reglas: saltable con un toque (tras 1 s); sin diálogo; el video vive en `assets/video/intro.ogv` (Theora + Vorbis).
La **cinemática de Skull** (puerta que estalla, capítulo 2) es otra pieza y sigue su propio ticket (T9).

### Kiara y Nala (las perras de Chris)
Aparecen en el capítulo 3 (potrero) y salvan a Isabella y Leo de una horda. Luego siguen
rescatando gente: pueden volver a aparecer más adelante (por ejemplo, en el capítulo 4 o
en el epílogo). Modelos: `actors/dogs/` (Quaternius CC0, pintadas por vértice).

### Skull, la Criatura (decisión de Chris, noviembre)
**Se llama Skull** (nombre de código y de diseño; en el juego nadie lo dice hasta que Chris lo decida). Una amenaza que **busca a Isabella** a lo largo del juego y que **nunca se ve**
(al menos hasta el encuentro). Es un recurso tipo «perseguidor»: lo que no se ve da más miedo.
- **No tiene relación con el pasajero del asiento 15 ni con el vagón del Centro de Nos** (ese misterio
  sigue su propio camino hacia el capítulo 5). Es una amenaza aparte.
- **Cinemática de entrada (capítulo 2):** al empezar el capítulo se muestra **una sola vez** una escena
  corta: en un lugar desconocido, que no volveremos a ver, la criatura **rompe una puerta**. Solo vemos
  la puerta, el polvo, la luz que titila y una **sombra enorme**. Va **en vivo** dentro del motor (no
  prerenderizada: ChatGPT no puede renderizar y no queremos inflar el APK). Ver ticket T9.
- **Ecos:** durante los capítulos 2 y 3 hay señales sueltas (un golpe lejano, Leo erizándose sin razón,
  un rugido apagado). Usan los sonidos reservados `creature_*` de `docs/AUDIO_PLAN.md`.
- **Encuentro:** **sí habrá**. Propuesta: en el **capítulo 4 (La Maestranza)**, como persecución o
  jefe final del capítulo. Lo diseña el ticket T1 (el «enemigo o jefe nuevo» del capítulo 4 es ella).

### Regla del mundo: los gatos son inmunes (decisión de Chris, noviembre)
**Los gatos son inmunes a los infectados:** no se contagian y los infectados no los atacan (tampoco Skull). Por eso nadie ataca a Leo y puede
caminar entre ellos. **No se explica por qué** (queda como misterio para la parte 2, junto al origen de la infección). Se puede sembrar en
notas y diálogos sin explicarlo (p. ej. alguien que vio un gato durmiendo junto a un infectado). Leo no lo dice en voz alta.

### Skull: cómo se ve (diseño, noviembre)
ChatGPT **no puede dibujar a Skull** (sus normas de contenido lo rechazan), así que **no se le piden imágenes**. El aspecto lo define Claude
y se arma con piezas simples en el motor (`levels/kit/skull_body.gd`; capturas en `docs/arte/`). Rasgos: **~2,6 m**, encorvado, **brazos
larguísimos que llegan al suelo y terminan en garras**, **cráneo grande y alargado** que cuelga hacia adelante (cuencas negras, sin ojos),
**púas de hueso en la espalda**, torso flaco con costillas a la vista. **Solo se ve de silueta/sombra y en destellos**; el cuerpo completo
solo en el encuentro del capítulo 4. Estado: prototipo (v0) de forma; el modelo final con textura se afina cuando se acerque el capítulo 4.

### APROBADO por Chris: Rosa se transforma en Skull en la batalla final
Idea de Chris (aprobada): **Rosa es, en realidad, Skull**, y se la ve transformarse en la **batalla final**. Para que encaje **sin tocar la línea de tiempo**
(el maquinista vio a un «sujeto grande» el viernes por la mañana, el ejército lo reportó «al sur del puente» el viernes a las 21:00, y Rosa
estaba en Paine a las 23:00 y dice que la mordieron «en el puente, anoche»), la lectura aprobada es:
- **Hay un Skull original** (el de las notas, el que rompe la puerta en la cinemática). Es el **jefe del capítulo 4**.
- **Rosa fue mordida por él en el puente.** Por eso es «un infectado distinto» (lo que sospecha Leo): su infección es la de Skull y avanza más lento.
- **Rosa lo sabe a medias** («Ándate, niña. Llévate al gato»): intenta avisar y proteger.
- **Rosa los sigue** (su puerta aparece rota más adelante: eco para el capítulo 4 o 5) y en la **batalla final se completa la transformación**:
  Rosa-Skull es el **jefe final**. Es el golpe emocional: la mujer que dejó la pistola en la boletería para Isabella.
- Sigue abierto para la parte 2 por qué Skull busca a Isabella y por qué los gatos son inmunes.
**Aplicado:** Rosa dice que «algo enorme» la agarró en el puente y la dejó «guardada»; avisa («antes de que yo cambie de idea»).
**Por hacer (P3, ChatGPT):** eco en el capítulo 4 o 5 (la puerta del galpón de Buin aparece arrancada **desde dentro**; un parte, una radio o un
soldado lo cuenta), pistas de Rosa en notas, y el **jefe final del capítulo 5: Rosa-Skull**, con la transformación a la vista del jugador.
**Reglas:** (1) **no se dice** que Rosa y Skull son lo mismo hasta la transformación; solo se siembran indicios; (2) el **Skull original**
(jefe del capítulo 4) **muere** en el capítulo 4; (3) Leo sospecha, nunca lo explica; (4) emoción: Isabella no quiere dispararle, y Rosa, por
momentos, todavía es Rosa (frases suyas dentro de la pelea).

### Rosa convertida: referencia visual (imagen de Chris, `docs/arte/rosa_convertida_ref.jpg`)
Chris trajo una imagen de referencia de **Rosa en plena transformación**. Rasgos a respetar: **sigue siendo reconociblemente una mujer** (cara y pelo
de Rosa, ojos rojos brillantes, gesto de dolor y furia), **púas y raíces de hueso/carne que le brotan de hombros, brazos y torso**, el **pecho abierto
con un resplandor rojo** (punto débil para la pelea), **manos con garras largas**, ropa rota (la chaqueta verde oliva de arriba), en un pasillo oscuro con filamentos.
**Cómo se conecta con Skull:** la imagen es la **fase intermedia**; la pelea final avanza hacia el cuerpo de Skull (más alto, encorvado, brazos al suelo,
cráneo pelado, púas en la espalda: `levels/kit/skull_body.gd`). Fases sugeridas: **1)** Rosa a medio transformar (como la imagen), **2)** brota el cuerpo de
Skull y la cara se descarna, **3)** Skull completo con el resplandor del pecho como punto débil.
**Uso:** es **solo referencia** para modelar/pintar en el motor (nada de la imagen se publica en el juego tal cual).

**Rosa sin convertirse** (`docs/arte/rosa_humana_ref.jpg`): mujer de unos **55–60 años**, pelo canoso recogido, rostro cansado y sereno, mirada firme.
Viste una **chaqueta verde oliva tipo militar** con manchas de sangre y **pantalón cargo**. Esa ropa es la que luego se rompe en la transformación.
Detalle de historia: la chaqueta apunta a que **se la dieron o la tomó en el control militar de Buin** (o venía con los soldados); no se explica.
Por eso Isabella le dice y Rosa le dice «niña»: es una mujer mayor, maternal. **Dato de cámara/pelea:** el contraste entre las dos imágenes
(la mujer tranquila y la criatura) es la herramienta emocional del capítulo 5.

### «La señora»: escalera de pistas hacia Rosa (decisión de Chris, noviembre)
En la parte avanzada del juego (**capítulos 4 y 5**), distintos personajes y notas van hablando de **«una señora»** terrorífica **sin saber que es Rosa**.
Es lo que hace que el jugador sospeche, y la **escalera** va de lo vago a lo específico. Nadie dice «Skull» ni «Rosa» hasta el último peldaño.
Quién habla: sobrevivientes y personal de La Maestranza, notas de turno, la radio y **Paz** (que nunca la vio). Tono: miedo contenido, cotidiano.

| Peldaño | Dónde | Qué se dice (borrador; ChatGPT lo escribe) | Qué debe sentir el jugador |
| --- | --- | --- | --- |
| 1 | Inicio del cap. 4, un paciente o soldado | «Por las vías de noche anda una señora. No corre. Camina. Y los infectados le abren paso.» | Curiosidad: ¿quién?, ¿por qué no la atacan? |
| 2 | Nota de turno de enfermería | «Anoche una señora se quedó parada frente a la reja, sin pestañear, tarareando. Los perros no ladraron; se echaron al suelo.» | Algo anda mal con ella |
| 3 | Un sobreviviente (diálogo) | «Era mayor, con el pelo canoso recogido. Tenía una chaqueta verde. Sonreía… y a mí me dio más miedo que el grande.» | Recuerda a Rosa; Isabella lo nota |
| 4 | Cap. 4, tras la muerte del Skull original (radio, nota o sobreviviente) | «Cuando cayó el grande, alguien aplaudió despacito en el pasillo. Una señora. Pregunta por la niña del gato.» | **Terror:** viene por ellas, y Leo se eriza |
| 5 | Paz (cara a cara o radio) | «Un paciente jura que ella lo visitó dormido. Dice que te mira con la cara de alguien que quisiste. Isabella… ¿quién es esa señora?» | Isabella calla y piensa en la puerta del galpón |
| 6 | Cap. 5, justo antes del jefe final | Una grabación o nota firmada: «…sujeto con vínculo directo, Rosa C., boletería de Paine. La infección no avanzó: **esperó**.» | **Confirmación:** la señora es Rosa |

**Decisión de Claude (Chris delegó): el peldaño 4 es una ESCENA EN VIVO** (el 5 queda como diálogo con Paz). Escena «el aplauso» (una sola vez, bandera
`scene:applause`, saltable con un toque, mismo patrón que `levels/kit/rescue_scene.gd`): tras morir el Skull original, la sala queda en silencio y la luz
parpadea. Se oye **un aplauso lento** que viene del pasillo. Leo se eriza y se pega a Isabella. En el **fondo del pasillo** hay un destello: una **silueta de
mujer** de pie (nunca se ve la cara). Por el **altavoz de La Maestranza** (voz tenue, tarareando) sale: «¿Dónde está la niña del gato?». La silueta desaparece
y se corta la luz. Isabella: «Esa voz...» · Leo: «Isabella... no te quedes. Vámonos.» **No se dice el nombre.** Sonidos nuevos (Claude los genera):
`applause_slow_1` y `hum_far_1`; el resto reutiliza `Sfx`.

**Reglas:** (1) los peldaños 1 a 5 **no nombran** a Rosa; (2) **ninguno explica el origen**; (3) en cada peldaño puede haber una **reacción de Leo** (bufa,
se eriza, se esconde detrás de Isabella: es la única vez que Leo tiene miedo); (4) la señora **nunca aparece** hasta la transformación del jefe final,
salvo **un destello** (silueta al fondo de un pasillo) en el capítulo 4; (5) los infectados le abren paso y los gatos (inmunes) no huyen de ella, los perros sí.

### Rosa y Skull en las notas (decisiones de Chris, noviembre)
- **Rosa (capítulo 3):** no se explica cómo llegó de Paine a Buin. Isabella empieza a sospechar de ella y **Leo sospecha más que Isabella**:
  cree que es **un infectado distinto**. La pregunta queda abierta (puede resolverse en la parte 2).
- **La radio** no pregunta por una persona («Constanza» se eliminó): **pregunta si hay sobrevivientes**.
- **Skull en las notas:** además de las cinemáticas y los ecos, **aparece en las notas que se encuentran en el camino** (capítulos 2, 3 y los
  siguientes) como **un infectado más grande y aterrador**: más alto que un hombre (~2,3 m), cara pelada «como una calavera», resiste el fuego
  de fusil, **no corre: espera y busca**. Las notas **no lo nombran** («algo grande», «sujeto de gran tamaño»). Ya está en: nota del maquinista,
  orden del día de Buin y carta de Ana. Toda nota nueva puede mencionarlo, siempre sin verlo.

### Origen de la infección: reservado para la parte 2 (decisión de Chris, noviembre)
**Este juego no explica por qué empezó todo.** Esa respuesta es el centro de una **segunda parte**. En esta primera parte solo
se pueden sembrar preguntas (registros incompletos, rumores, cosas que nadie sabe explicar), nunca respuestas. Skull y el
pasajero del asiento 15 siguen siendo misterios abiertos para la parte 2. Todo texto nuevo (notas, diálogos de Leo y de Paz,
capítulos 4 y 5, epílogo) debe respetar esto.

### Capítulos siguientes (dirección aprobada)
- **Capítulo 3 — Buin (hecho, ver sección 8):** puente del Maipo, control militar abandonado,
  estación de Buin, bodega agrícola, galpón de la viña. Rosa aparece viva (diálogos). Se
  descubre que el "tren de evacuación" era para llevarse a los mordidos a cuarentena.
  Enemigo nuevo: soldado infectado con casco y chaleco. Final: por una radio militar se
  escucha a Paz ("no vengas a Alameda, ven a…") y se corta.
- **Capítulo 4 — La Maestranza (San Bernardo):** el lugar de cuarentena del tren sanitario;
  Paz trabaja ahí. El vagón que nadie abre (del Centro de Nos).
- **Capítulo 5 — Santiago / el Centro de Nos:** se cierra el misterio del pasajero del
  asiento 15. Isabella y Paz juntas.
- **Epílogo — La despedida de Leo** (aprobada por Chris).
- **Despedida de Leo (aprobada por Chris):** al amanecer, ya a salvo, Leo
  camina unos pasos hacia la luz por la vía, se da vuelta, maúlla una última vez y se va.
  Isabella entiende. Texto final y dedicatoria: "Para Leo".

## 3. Cámara

> **Decisión de Chris (noviembre):** las cámaras se prefieren **más desde arriba** (picado
> ~42°, hasta 62°) y deben mostrar la **puerta de avance** cuando Isabella anda cerca de ella.
> Lo hace `tools/plan_cameras.gd` (`PREFERRED_PITCH`, `DOOR_WEIGHT`). Aplicado a los capítulos
> 2 y 3. El capítulo 1 conserva sus cámaras porque tiene fondos prerenderizados: cambiarlas
> exige re-renderizar (ver `update grafica.txt`).

- Cada sala (`Room`) es una escena propia con sus `CameraZone` (Area3D + Camera3D).
- Al entrar Isabella en una `CameraZone`, esa cámara pasa a ser la actual (corte seco).
- Opcional por zona: cámara que **sigue** a Isabella solo sobre un riel (pasillos largos).
- La cámara nunca la controla el jugador. FOV 50–60, a 3–6 m de Isabella.

## 4. Controles (táctil)

- **Stick virtual flotante** (mitad izquierda de la pantalla): mover. Empujar poco =
  caminar, empujar a fondo = trotar. Dirección relativa a la cámara activa al empezar
  a empujar (evita giros bruscos en el corte de cámara).
- **APUNTAR** (mantener, pulgar izquierdo, sobre el stick): Isabella se planta y apunta
  sola al infectado más cercano.
- **DISPARAR** (pulgar derecho, botón pequeño abajo a la derecha): aparece mientras apunta.
- **ACCIÓN** (mismo lugar que DISPARAR, cuando no apunta): aparece solo si hay algo a
  mano y dice qué hace: RECOGER, LEER, ABRIR, USAR, EXAMINAR.
- **MOCHILA**: arriba a la derecha. Pausa el juego.
- Sin salto, sin cuerpo a cuerpo.

## 5. Armas (solo armas de fuego)

Decisión: **nada de cuerpo a cuerpo ni barra de cambio rápido**. Como en RE: el arma se
elige desde la mochila (EQUIPAR); cada arma guarda las balas de su cargador.
**Isabella empieza con todo el arsenal en la mochila** (pedido de Chris). Modelos de dos
packs: *Heavy Weapons Pack* (Mauser, lanzagranadas, bazuca) y Quaternius CC0
(escopeta, fusil, rifle). El cuchillo del pack no se usa.

| Arma | Munición | Cargador | Rol |
| --- | --- | --- | --- |
| Pistola 9 mm | Balas 9 mm | 10 | Arma base: 7 tiros por infectado común, 11 el pesado. |
| Mauser C96 | Balas 9 mm | 10 | Más lenta, pega el doble. |
| Escopeta | Cartuchos | 6 | 5 de daño de cerca, cae a 1 a 9 m; siempre hace tambalear. |
| Fusil de asalto | Balas de fusil | 30 | Ráfaga de 3 por toque. |
| Rifle de francotirador | Balas de fusil | 5 | 7 de daño, alcance 28 m, recarga lenta. |
| Lanzagranadas | Granadas 40 mm | 6 | Explota al impactar (radio 2,6 m). Cerca, daña a Isabella. |
| Bazuca | Cohetes | 1 | Explosión grande (radio 4 m). Último recurso. |

Mochila inicial: las 7 armas + 30 balas 9 mm, 10 cartuchos, 45 balas de fusil, 6 granadas
y 2 cohetes (12 de 16 casillas). Recarga automática al vaciar el cargador. Sin
munición: "clic".

## 6. Mecánicas

| Mecánica | Descripción |
| --- | --- |
| Salud | Bien / Precaución / Peligro (electrocardiograma en la mochila, cojea en Peligro). |
| Curación | Comida, se come desde la mochila: sushi (+30) y handroll (+70). |
| Mochila | 16 casillas. Las balas se apilan (60 por casilla); armas, comida y llaves usan una casilla cada una. La munición de reserva es la que hay en la mochila. |
| Examinar | Cualquier ítem se ve en 3D y se gira con el dedo. |
| Guardado | Máquina de escribir (una ranura, sin cintas de tinta). Al morir, REINTENTAR vuelve a la última partida guardada. |
| Documentos | Notas legibles (papel en pantalla) que cuentan qué pasó en Paine; quedan en NOTAS. |
| Leo | Gatita gris con pecho y patas blancas y ojos verdes que brillan en la oscuridad. Guía a Isabella (ver sección 2). Sigue a Isabella y entra con ella a cada sala. Bufa y mira a cualquier infectado vivo a menos de 5,5 m, aunque se esté haciendo el muerto (es la pista para el jugador). No pelea, no muere. |
| Puertas | Fundido corto entre salas (oculta la carga). Las que piden llave quedan abiertas para siempre al usarla. |
| Memoria de las salas | Lo recogido no vuelve a aparecer y los infectados muertos siguen en el suelo al volver. |

## 7. Enemigos y daño

| Enemigo | Comportamiento |
| --- | --- |
| Infectado | Camina lento hacia Isabella, la agarra y muerde. Algunos están en el suelo haciéndose los muertos. |
| Infectado rápido (cap. 2) | Corre a ráfagas cortas. |

**Respuesta al daño (lo que se ve y se siente):**
- Impacto: salpicadura de sangre oscura (partículas pequeñas), el infectado se
  tambalea hacia atrás, sonido seco.
- Muerte: cae de rodillas y al suelo; queda una mancha en el piso.
- Isabella herida: pantalla con borde rojo breve, vibración del teléfono, cojea en Peligro.

## 8. Estructura de salas

Regla: **cada sala cabe en 1–3 cámaras** y está cerrada por todos lados.

### Capítulo 1 — Estación de Paine (Hito 4: completo)
Isabella empieza **sin arma**. Recorrido:

| # | Sala (`levels/station/`) | Qué pasa |
| --- | --- | --- |
| 1 | Andén norte (`platform`) | Inicio tranquilo, nota en la banca, balas junto a los cajones. El portón al andén sur tiene candado. Al volver con la pistola, llegaron 2 infectados desde la vía (uno comiendo, uno haciéndose el muerto). |
| 2 | Sala de espera (`waiting_room`) | Máquina de escribir. Un infectado come junto a la máquina de bebidas: se puede pasar por el lado este sin despertarlo. Aviso de la estación (pistola en la boletería, llave en la bodega). |
| 3 | Boletería (`ticket_office`) | Sala segura. **Pistola cargada** + 15 balas en el escritorio del guardia, libro de la boletería. |
| 4 | Pasillo de servicio (`service_corridor`) | 3 cámaras, luz que parpadea. Un cadáver de verdad (Leo no le bufa), uno haciéndose el muerto (Leo sí) y uno de espaldas. Handroll y balas. |
| 5 | Bodega (`storeroom`) | El guardia convertido (infectado pesado, 11 balazos). **Llave del portón** y diario del jefe de estación sobre la mesa. |
| 6 | Andén sur (`south_platform`) | Por el portón del andén norte. Infectados, carro de equipaje, túnel con resplandor rojo. **Bajar a la vía** cierra el capítulo (pantalla de fin). |

Munición del capítulo: 10 (cargador) + 75 en cajas. La resistencia queda en 5 disparos para infectados comunes y 7 para el pesado, dejando margen para fallar tiros.

### Capítulo 2 — Las vías (completo)
Se llega con CONTINUAR al terminar el capítulo 1 (punto de control: guarda la partida).

| # | Sala (`levels/tracks/`) | Qué pasa |
| --- | --- | --- |
| 1 | Vía norte (`track_north`) | Inicio. Vagón volcado de través y fuego al fondo. Primer **infectado rápido**. Boleto con mensaje. |
| 2 | Tren descarrilado (`derailed_train`) | Locomotora volcada y vagón fuera de la vía; el guardia pesado comiendo. Se entra al vagón. |
| 3 | Interior del vagón (`wagon_interior`) | Pasillo entre asientos, 3 cámaras. **Llave del maquinista** y planilla del conductor. |
| 4 | Costado del convoy (`convoy_side`) | Infectados entre los vagones. Reja del paso bajo nivel (se abre con la llave del maquinista). |
| 5 | Paso bajo nivel (`underpass`) | **Apagón**: Isabella usa la linterna. Dos infectados rápidos. |
| 6 | Casa de cambios (`switch_house`) | Sala segura: máquina de escribir, nota del maquinista. La salida a la vía termina el juego. |

### Capítulo 3 — Buin (completo)
Se llega con CONTINUAR al terminar el capítulo 2. Sábado en la mañana: luz de día nublado
(contraste con la noche de los capítulos 1 y 2).

| # | Sala (`levels/buin/`) | Qué pasa |
| --- | --- | --- |
| 1 | Puente del Maipo (`bridge`) | Inicio. Puente de fierro sobre el río crecido. |
| 2 | Control militar (`checkpoint`) | Carpa, camión con camillas, **soldados infectados con casco** (10 balazos). **Orden del día**: el "tren de evacuación" era para los mordidos. Máquina de escribir. |
| 3 | Estación de Buin (`station`) | Hall convertido en espera del tren sanitario. **Lista del tren** (Raúl, el capitán, un niño). |
| 4 | Bodega agrícola (`warehouse`) | Apagón (linterna). Dos infectados rápidos. **Llave del galpón** en el tractor y la **carta de Ana**. |
| 4b | Potrero (`field`) | Despejado... demasiado. **Escena de Kiara y Nala** (`levels/kit/rescue_scene.gd`): aparece una horda, a Isabella se le traba la pistola, Leo se pone delante ("Tranquila, Isabella. Yo te protejo") y llegan **Kiara** (akita naranja, enorme: parada en dos patas es más alta que Isabella) y **Nala** (bull terrier gris atigrado con café, más chica). Las salvan; Isabella les da las gracias y les pide que sigan sacando gente; ladran y se van. Una sola vez. |
| 5 | Viña Santa Rosa (`vineyard`) | Hileras de parras; el galpón se abre con la llave. |
| 6 | Galpón (`shed`) | Sala segura. **Rosa**, mordida, habla a través de la puerta (credencial del Centro de Nos). La **radio** (la voz de Paz pregunta si hay **sobrevivientes**): Paz está en la Maestranza de San Bernardo → fin del capítulo. **Rosa es sospechosa:** estaba en Paine a las 23:00 y nadie explica cómo cruzó sola hasta Buin (**sin explicación a propósito**). Isabella empieza a sospechar y **Leo, más aún**: cree que Rosa es **un infectado distinto**, no como los demás. |

## 9. Estilo visual

Ver `docs/ART_PIPELINE.md` (texturas, variación sin repetición visible, sin huecos negros).

**Dos modos gráficos (decisión de Chris, prototipo):** botón **GRÁFICOS: RETRO / MODERNO** en
el título y en la mochila; cambia al tiro y queda guardado. La jugabilidad es la misma.
- **Retro:** el look PS1 de siempre (texturas pixeladas, filtro de pantalla con tramado).
- **Moderno:** texturas 1K con relieve (mapa normal) y rugosidad, filtrado suave, brillos,
  sombras en tiempo real en la luz principal de cada sala, tonemap fílmico, resplandor en
  luces y MSAA 4x; sin filtro PS1. Pensado para un Redmi 13C (Mali-G52): una sola luz con
  sombra, texturas comprimidas (ETC2), normal y rugosidad con 2 muestras por píxel.
- En Moderno el infectado común y el rápido usan un modelo detallado (*Male City Zombie*,
  CC0, 7k triángulos, piel pálida y ropa oscura con sangre); el pálido y el obrero usan el
  *Zombie* de Pixelhouse (CC-BY 3.0, polera y jeans, 3,6k triángulos; crédito en el título
  y en `CREDITS.md`). El quemado y el guardia siguen con su modelo PSX. El cambio de modelo se nota al
  entrar a la siguiente sala.

**Brillo (pedido de Chris: "demasiado oscuro"):** botón **BRILLO 1/5…5/5** en el título y la
mochila (por defecto 3/5); se guarda en el teléfono. Las salas del capítulo 2 tienen más luz
base (ambiente y luna más fuertes, niebla azulada en vez de negra, linterna más ancha).
Meta: ninguna cámara con brillo medio bajo ~35/255 en el nivel 3.

**Fondos prerenderizados (decisión de Chris, opción 2):** en modo Moderno cada cámara fija
muestra una imagen renderizada con calidad de película (como RE3) y los personajes van en
3D encima. Prototipo: andén norte. Detalle técnico y pasos: `update grafica.txt`.

## 10. Técnico

- **Motor:** Godot 4.7.2 (renderer *Compatibility*, Android).
- **Presupuesto por sala:** ≤ 30k triángulos visibles, ≤ 4 luces dinámicas.
- Ver `docs/ARCHITECTURE.md` para la organización del código.
- **Cámaras planificadas:** `tools/plan_cameras.gd` reparte las cámaras fijas de cada sala
  (1 a 9) para que Isabella se vea entera y sin nada sólido delante en cualquier punto
  caminable; guarda `tools/level_gen/cameras.json`, que aplican solos los generadores.
  `tools/audit_cameras.gd` comprueba todas las salas (apariciones, alcance, cámaras
  pegadas). Si se cambia una sala: planificar, regenerar, auditar y re-renderizar fondos.
- **Túneles:** los andenes tienen túneles reales con arco (`tools/level_gen/tunnels.py`):
  oscuro al oeste/norte y con resplandor rojo al este del andén sur.
- **Gráficos:** Moderno es el modo por defecto (el botón GRÁFICOS alterna con Retro). Los
  fondos prerenderizados existen solo para el capítulo 1; los capítulos 2 y 3 se dibujan en
  vivo. Pruebas y conclusiones en `update grafica.txt` (sección 7).
- **Objetivo en pantalla:** línea bajo el estado de Isabella con lo último que Leo diría en la
  pista activa de la sala. La mochila muestra las notas en dos columnas, la más nueva primero.
- **Orientación (decisión de Chris: "no se sabe adónde ir"):** cada puerta de avance lleva una
  **▼ amarilla con el nombre del destino** flotando encima (roja con "CON LLAVE" si falta la
  llave; las puertas "VOLVER" no llevan). Se ve a través de muros y vagones. Al entrar a una sala
  aparece su **nombre arriba, al centro**. Las pistas de Leo dicen la acción concreta ("subirse al
  vagón", "la puerta de la flecha amarilla"). Toda puerta nueva necesita su nombre en `Door.LABELS`
  (la prueba de niveles lo exige).
- **Interacción táctil:** ACCIÓN guarda el toque unos instantes (no se pierde en cuadros
  lentos), prefiere notas/ítems sobre Leo y muestra un aviso gris con el último uso.

## 11. Fuera de alcance (por ahora)

- Cuerpo a cuerpo, cambio rápido de armas, salto, mundo abierto, multijugador.
- Cinemática del choque del tren (el tren ya está destruido cuando llegan).
