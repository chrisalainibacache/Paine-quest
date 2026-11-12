# Paine — Documento de diseño (GDD)

> Documento vivo. Cada decisión de diseño importante se anota aquí antes de programarla.

## 1. Concepto

**Paine** es un survival horror en 3D con **cámaras fijas por sala** (2.5D al estilo
*Resident Evil 3* de PlayStation 1), para **Android en horizontal**.

**Cony** y su gatita **Leo** despiertan en Paine (Chile) después de que *algo pasó*:
la gente se convirtió en infectados. Intentan salir siguiendo la línea del tren hacia
Santiago.

### Pilares
1. **Espacios cortos y cerrados.** Nada de mundo abierto: salas pequeñas con muros,
   rejas, vagones o escombros que las cierran. El escenario guía al jugador.
2. **Cámara cercana y cinematográfica.** Cada sala tiene 1–3 cámaras fijas que encuadran
   a Cony de cerca; la cámara cambia (corte seco) al cruzar zonas invisibles.
3. **Tensión con recursos escasos.** Poca munición, curación limitada, guardado manual
   en máquinas de escribir.
4. **Look PS1, no "Roblox".** Texturas sucias de baja resolución, niebla, luz cálida de
   sodio, filtro de pantalla con tramado. Nada de colores planos ni bloques lisos.
5. **Rendimiento primero.** 60 fps estables en el teléfono. Una sala cargada a la vez.

## 2. Historia (capítulos 1 y 2)

**Por qué viaja Cony:** su hermana **Javiera** vive en Santiago. A las 22:10 le escribe:
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
| 23:40 | **Llega Cony** con Leo. Capítulo 1. | Intro del andén norte |
| Medianoche → amanecer | Capítulo 2 por la vía hasta la casa de cambios. Final: caminan a Santiago, Javiera las espera. | Intro de la vía norte, finales |

Geografía (Línea Sur, de sur a norte): Hospital – **Paine** – Linderos – Buin – … – Alameda.
Santiago queda al **norte**; todo el viaje es hacia el norte por la vía.

### Capítulo 1 — La estación
Cony llega con Leo a la estación de trenes de Paine buscando un tren a Santiago.
La estación está vacía y algo anda mal. Recorre el andén, la sala de espera y la
boletería; encuentra la pistola, notas de lo que pasó y la llave del portón que da a
las vías. Cierra el capítulo saliendo a la vía.

### Capítulo 2 — Las vías
Siguiendo las vías encuentran **el tren de las 6:30 ya destruido** (descarrilado y volcado;
no se ve el choque, se encuentra así). No sirve para viajar: hay que seguir a pie,
atravesando el convoy, un paso bajo nivel en apagón y una casa de cambios. El maquinista
frenó el tren contra el desvío para que los infectados no llegaran a la ciudad. Termina
con Cony y Leo caminando por la vía hacia Santiago al amanecer: **fin del juego**.

### Leo: guía y la última aventura (decisión de Chris)
Leo es la gata de Cony. **Este juego es su última aventura**: todo lo que hace Leo se
escribe con ese cariño.
- **Guía:** si Cony se queda quieta ~5 s, Leo camina hasta la pista activa de la sala
  (`levels/kit/leo_hint.gd`, grupo `leo_hints`), se sienta mirándola y maúlla. Al acercarse
  Cony, Leo le explica qué hacer (una vez por pista). Si Leo tiene algo nuevo que decir,
  el botón ACCIÓN muestra **LEO**.
- **Habla:** sus líneas empiezan con `Leo: ` y salen en verde con su nombre. Habla bajito,
  tierna y segura: conoce el camino, huele el peligro y ve en la oscuridad.
- **Avisa:** bufa a los infectados cercanos, aunque se hagan los muertos.
- **Pistas sembradas (no decirlas en voz alta):** nadie ataca a Leo; Leo nunca se cansa;
  sus ojos brillan en la oscuridad; dice "siempre te he llevado yo".

### Capítulos siguientes (dirección aprobada)
- **Capítulo 3 — Buin (hecho, ver sección 8):** puente del Maipo, control militar abandonado,
  estación de Buin, bodega agrícola, galpón de la viña. Rosa aparece viva (diálogos). Se
  descubre que el "tren de evacuación" era para llevarse a los mordidos a cuarentena.
  Enemigo nuevo: soldado infectado con casco y chaleco. Final: por una radio militar se
  escucha a Javiera ("no vengas a Alameda, ven a…") y se corta.
- **Capítulo 4 — La Maestranza (San Bernardo):** el lugar de cuarentena del tren sanitario;
  Javiera trabaja ahí. El vagón que nadie abre (del Centro de Nos).
- **Capítulo 5 — Santiago / el Centro de Nos:** se cierra el misterio del pasajero del
  asiento 15. Cony y Javiera juntas.
- **Epílogo — La despedida de Leo** (aprobada por Chris).
- **Despedida de Leo (aprobada por Chris):** al amanecer, ya a salvo, Leo
  camina unos pasos hacia la luz por la vía, se da vuelta, maúlla una última vez y se va.
  Cony entiende. Texto final y dedicatoria: "Para Leo".

## 3. Cámara

- Cada sala (`Room`) es una escena propia con sus `CameraZone` (Area3D + Camera3D).
- Al entrar Cony en una `CameraZone`, esa cámara pasa a ser la actual (corte seco).
- Opcional por zona: cámara que **sigue** a Cony solo sobre un riel (pasillos largos).
- La cámara nunca la controla el jugador. FOV 50–60, a 3–6 m de Cony.

## 4. Controles (táctil)

- **Stick virtual flotante** (mitad izquierda de la pantalla): mover. Empujar poco =
  caminar, empujar a fondo = trotar. Dirección relativa a la cámara activa al empezar
  a empujar (evita giros bruscos en el corte de cámara).
- **APUNTAR** (mantener, pulgar izquierdo, sobre el stick): Cony se planta y apunta
  sola al infectado más cercano.
- **DISPARAR** (pulgar derecho, botón pequeño abajo a la derecha): aparece mientras apunta.
- **ACCIÓN** (mismo lugar que DISPARAR, cuando no apunta): aparece solo si hay algo a
  mano y dice qué hace: RECOGER, LEER, ABRIR, USAR, EXAMINAR.
- **MOCHILA**: arriba a la derecha. Pausa el juego.
- Sin salto, sin cuerpo a cuerpo.

## 5. Armas (solo armas de fuego)

Decisión: **nada de cuerpo a cuerpo ni barra de cambio rápido**. Como en RE: el arma se
elige desde la mochila (EQUIPAR); cada arma guarda las balas de su cargador.
**Cony empieza con todo el arsenal en la mochila** (pedido de Chris). Modelos de dos
packs: *Heavy Weapons Pack* (Mauser, lanzagranadas, bazuca) y Quaternius CC0
(escopeta, fusil, rifle). El cuchillo del pack no se usa.

| Arma | Munición | Cargador | Rol |
| --- | --- | --- | --- |
| Pistola 9 mm | Balas 9 mm | 10 | Arma base: 7 tiros por infectado común, 11 el pesado. |
| Mauser C96 | Balas 9 mm | 10 | Más lenta, pega el doble. |
| Escopeta | Cartuchos | 6 | 5 de daño de cerca, cae a 1 a 9 m; siempre hace tambalear. |
| Fusil de asalto | Balas de fusil | 30 | Ráfaga de 3 por toque. |
| Rifle de francotirador | Balas de fusil | 5 | 7 de daño, alcance 28 m, recarga lenta. |
| Lanzagranadas | Granadas 40 mm | 6 | Explota al impactar (radio 2,6 m). Cerca, daña a Cony. |
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
| Leo | Gatita gris con pecho y patas blancas y ojos verdes que brillan en la oscuridad. Guía a Cony (ver sección 2). Sigue a Cony y entra con ella a cada sala. Bufa y mira a cualquier infectado vivo a menos de 5,5 m, aunque se esté haciendo el muerto (es la pista para el jugador). No pelea, no muere. |
| Puertas | Fundido corto entre salas (oculta la carga). Las que piden llave quedan abiertas para siempre al usarla. |
| Memoria de las salas | Lo recogido no vuelve a aparecer y los infectados muertos siguen en el suelo al volver. |

## 7. Enemigos y daño

| Enemigo | Comportamiento |
| --- | --- |
| Infectado | Camina lento hacia Cony, la agarra y muerde. Algunos están en el suelo haciéndose los muertos. |
| Infectado rápido (cap. 2) | Corre a ráfagas cortas. |

**Respuesta al daño (lo que se ve y se siente):**
- Impacto: salpicadura de sangre oscura (partículas pequeñas), el infectado se
  tambalea hacia atrás, sonido seco.
- Muerte: cae de rodillas y al suelo; queda una mancha en el piso.
- Cony herida: pantalla con borde rojo breve, vibración del teléfono, cojea en Peligro.

## 8. Estructura de salas

Regla: **cada sala cabe en 1–3 cámaras** y está cerrada por todos lados.

### Capítulo 1 — Estación de Paine (Hito 4: completo)
Cony empieza **sin arma**. Recorrido:

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
| 5 | Paso bajo nivel (`underpass`) | **Apagón**: Cony usa la linterna. Dos infectados rápidos. |
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
| 5 | Viña Santa Rosa (`vineyard`) | Hileras de parras; el galpón se abre con la llave. |
| 6 | Galpón (`shed`) | Sala segura. **Rosa**, mordida, habla a través de la puerta (credencial del Centro de Nos). La **radio**: Javiera está en la Maestranza de San Bernardo → fin del capítulo. |

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

## 10. Técnico

- **Motor:** Godot 4.7.2 (renderer *Compatibility*, Android).
- **Presupuesto por sala:** ≤ 30k triángulos visibles, ≤ 4 luces dinámicas.
- Ver `docs/ARCHITECTURE.md` para la organización del código.

## 11. Fuera de alcance (por ahora)

- Cuerpo a cuerpo, cambio rápido de armas, salto, mundo abierto, multijugador.
- Cinemática del choque del tren (el tren ya está destruido cuando llegan).
