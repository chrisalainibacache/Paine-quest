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

### Capítulo 1 — La estación
Cony llega con Leo a la estación de trenes de Paine buscando un tren a Santiago.
La estación está vacía y algo anda mal. Recorre el andén, la sala de espera y la
boletería; encuentra la pistola, notas de lo que pasó y la llave del portón que da a
las vías. Cierra el capítulo saliendo a la vía.

### Capítulo 2 — Las vías
Siguiendo las vías encuentran **el tren ya destruido** (descarrilado y volcado; no se
ve el choque, se encuentra así). No sirve para viajar: hay que seguir a pie por el
costado de las vías, atravesando el convoy, un paso bajo nivel y una casa de
cambios. Termina en un punto de corte (el camino sigue → capítulo 3 en el futuro).

## 3. Cámara

- Cada sala (`Room`) es una escena propia con sus `CameraZone` (Area3D + Camera3D).
- Al entrar Cony en una `CameraZone`, esa cámara pasa a ser la actual (corte seco).
- Opcional por zona: cámara que **sigue** a Cony solo sobre un riel (pasillos largos).
- La cámara nunca la controla el jugador. FOV 50–60, a 3–6 m de Cony.

## 4. Controles (táctil)

- **Stick virtual flotante** (mitad izquierda de la pantalla): mover. Empujar poco =
  caminar, empujar a fondo = trotar. Dirección relativa a la cámara activa al empezar
  a empujar (evita giros bruscos en el corte de cámara).
- **Apuntar** (mantener): Cony se planta y apunta al infectado más cercano.
- **Disparar**: mientras apunta.
- **Acción**: examinar, abrir puertas, recoger.
- **Mochila**: arriba a la derecha.
- Sin salto, sin cuerpo a cuerpo.

## 5. Armas (solo armas de fuego)

Decisión: **nada de espadas ni barra de cambio rápido**. Como en RE: el arma se elige
desde la mochila; recoger un arma nueva pregunta si equiparla.

| Arma | Capítulo | Munición | Rol |
| --- | --- | --- | --- |
| Pistola | 1 | Balas 9 mm | Arma base. Cargador de 10, 5 tiros por infectado común. |
| Escopeta | 2 | Cartuchos | Escasa, derriba de un tiro a corta distancia. |

Recarga automática al vaciar el cargador (animación corta). Sin munición: Cony hace
"clic" y hay que huir o buscar más.

## 6. Mecánicas

| Mecánica | Descripción |
| --- | --- |
| Salud | Bien / Precaución / Peligro (se ve en la mochila y en el andar de Cony). |
| Curación | Comida: sushi (poco) y handroll (mucho). |
| Mochila | 8 casillas. Munición e ítems clave ocupan espacio. |
| Guardado | Máquina de escribir (manual) + punto de control al empezar cada capítulo. |
| Documentos | Notas legibles que cuentan qué pasó en Paine. |
| Leo | Sigue a Cony; bufa cuando hay infectados cerca (aviso). No pelea, no muere. |
| Puertas | Fundido corto entre salas (oculta la carga). Algunas piden llave. |

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

### Capítulo 1 — Estación de Paine
1. **Andén norte** — inicio. Leo, primera nota. Vía bloqueada por rejas.
2. **Sala de espera** — máquina de escribir, primer infectado.
3. **Boletería** — pistola + munición, nota del boletero.
4. **Pasillo de servicio** — infectado haciéndose el muerto.
5. **Bodega** — llave del portón.
6. **Andén sur / portón a la vía** — sale del capítulo.

### Capítulo 2 — Las vías
1. **Vía con el tren descarrilado** — se ve el convoy volcado; el paso está cortado por los vagones.
2. **Interior del vagón** — se atraviesa por dentro (pasillo estrecho, asientos), escopeta.
3. **Costado del convoy** — infectados entre los vagones.
4. **Paso bajo nivel** — túnel corto, apagón (solo la linterna).
5. **Casa de cambios de vía** — máquina de escribir, nota del maquinista.
6. **Salida por la vía** — fin del capítulo 2.

## 9. Estilo visual

Ver `docs/ART_PIPELINE.md` (texturas, variación sin repetición visible, sin huecos negros).

## 10. Técnico

- **Motor:** Godot 4.7.2 (renderer *Compatibility*, Android).
- **Presupuesto por sala:** ≤ 30k triángulos visibles, ≤ 4 luces dinámicas.
- Ver `docs/ARCHITECTURE.md` para la organización del código.

## 11. Fuera de alcance (por ahora)

- Cuerpo a cuerpo, cambio rápido de armas, salto, mundo abierto, multijugador.
- Cinemática del choque del tren (el tren ya está destruido cuando llegan).
