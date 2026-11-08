# Paine — Documento de diseño (GDD)

> Documento vivo. Cada decisión de diseño importante se anota aquí antes de programarla.

## 1. Concepto

**Paine** es un survival horror en 3D con **cámaras fijas por sala** (2.5D al estilo
*Resident Evil 2/3* de PlayStation 1), para **Android en horizontal**.

Cony y su gato Leo viajan por Paine (Chile) después de un brote. Siguen las vías hacia
Santiago: estación de trenes → accidente del tren → fábrica → mina.

### Pilares
1. **Espacios cortos y cerrados.** Nada de mundo abierto: salas pequeñas unidas por
   puertas, pasillos y callejones. El escenario guía al jugador.
2. **Cámara cercana y cinematográfica.** Cada sala tiene 1–3 cámaras fijas que encuadran
   a Cony de cerca; la cámara cambia al cruzar zonas invisibles.
3. **Tensión con recursos escasos.** Poca munición, curación limitada, guardado manual
   en máquinas de escribir.
4. **Rendimiento primero.** 60 fps estables en el teléfono del jugador. Cada sala se
   carga por separado; lo que no se ve no existe.

## 2. Cámara (decisión clave)

- Cada sala (`Room`) es una escena propia con sus `CameraZone` (Area3D + Camera3D).
- Al entrar Cony en una `CameraZone`, esa cámara pasa a ser la actual (corte seco,
  como en RE).
- Opcional por zona: cámara que **sigue** a Cony solo en un riel (pasillos largos).
- La cámara nunca la controla el jugador.
- FOV 50–60, a 3–6 m de Cony: se ve el personaje de cerca.

## 3. Controles (táctil)

- Stick virtual izquierdo: mover. Movimiento **relativo a la cámara** que estaba activa
  al empezar a empujar el stick (evita cambios bruscos de dirección al cortar cámara).
- Botones derechos: **Atacar/Disparar**, **Apuntar** (mantener), **Correr**, **Acción**
  (examinar, abrir, recoger).
- Botón **Mochila** arriba a la derecha.
- Sin salto: el juego no tiene plataformas.

## 4. Mecánicas

| Mecánica | Descripción |
| --- | --- |
| Movimiento | Caminar / correr. Sin salto. |
| Combate cuerpo a cuerpo | Cuchillo/espada, combo corto de 2–3 golpes. |
| Armas a distancia | Pistola, escopeta, ballesta. Auto-apuntado al infectado más cercano en el cono de visión. |
| Salud | Estados RE: Bien / Precaución / Peligro. Se cura con comida (sushi, handroll). |
| Inventario | Casillas limitadas (8 al inicio, ampliable). |
| Guardado | Máquinas de escribir (manual) + punto de control al cambiar de zona. |
| Documentos | Notas legibles que cuentan la historia. |
| Leo (gato) | Sigue a Cony, maúlla/bufa cuando hay infectados cerca. No combate. |
| Puertas | Transición con animación/fundido corto entre salas (oculta la carga). |
| Llaves | Ítems clave que abren puertas concretas. |

## 5. Enemigos

| Enemigo | Comportamiento |
| --- | --- |
| Infectado | Lento, agarra y muerde. Puede hacerse el muerto y levantarse. |
| Infectado grande (jefe cap. 1) | Lento, mucha vida, golpe fuerte. Bloquea el montacargas. |

## 6. Capítulo 1 — estructura de salas

Cada zona = 3–6 salas cortas. Primer objetivo: **la estación** (rebanada vertical).

### Zona 1: Estación de Paine
1. Andén (inicio, Leo, primera nota).
2. Sala de espera (máquina de escribir, primer infectado).
3. Boletería (llave del portón).
4. Callejón lateral (salida hacia la vía).

### Zona 2: Accidente del tren
1. Vía con el convoy volcado (cinemática de entrada).
2. Interior de un vagón (ítems, infectado escondido).
3. Patio del desvío (escopeta junto a la camioneta).

### Zona 3: Fábrica
1. Portón principal (bloqueado).
2. Patio de carga (ballesta, caseta del guardia con llave).
3. Sala de máquinas (máquina de escribir).

### Zona 4: Mina
1. Acceso minero.
2. Túnel con rieles (apagón y emboscada).
3. Sala de acopio.
4. Montacargas (jefe) → fin del capítulo 1.

## 7. Estilo visual

- Look PS1: texturas de baja resolución con filtro *nearest*, filtro de pantalla con
  color de 15 bits y tramado, niebla densa, iluminación de sodio cálida.
- Modelos low-poly (Quaternius, packs PSX).
- Interfaz sobria estilo RE (fuente serif/mono, paneles oscuros).

## 8. Técnico

- **Motor:** Godot 4.7.2 (renderer *Compatibility*, Android).
- **Resolución interna:** 3D renderizado a baja resolución y escalado (look PS1 + rendimiento).
- **Presupuesto por sala:** ≤ 30k triángulos visibles, ≤ 4 luces dinámicas, sombras
  solo de la luz principal o ninguna.
- Ver `docs/ARCHITECTURE.md` para la organización del código.

## 9. Fuera de alcance (por ahora)

- Multijugador, mundo abierto, salto/plataformas, crafting.
