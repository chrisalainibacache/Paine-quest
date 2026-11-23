# P10-b — Capítulo 1: Estación de Paine

**Estado:** diseño piloto; no implementado. Reaprovecha las seis salas actuales y propone cuatro nuevas. Este documento es una propuesta para Claude: no crear ni modificar escenas aquí. Fuente narrativa: docs/GUION.md §§2–4 y docs/GDD.md; las horas y hechos existentes se conservan.

## 1. Resumen de la zona

Viernes, 23:40. Isabella llega a la estación de Paine buscando el tren de evacuación que nunca llegará. Recorre una estación pequeña, parcialmente a oscuras, y descubre que el personal intentó refugiarse y cerrar los accesos. El objetivo es reunir información y abrir el portón del andén sur para bajar a la vía hacia el norte, sin convertir la estación en un pasillo lineal.

La zona tiene diez salas compactas, dos rutas de avance y dos atajos de regreso. El misterio del tren y del asiento 15 permanece abierto; no se explica el origen de la infección.

## 2. Grafo de salas

### Salas (10)

Dimensiones interiores aproximadas, no límites definitivos de geometría. Las formas en L/U generan esquinas de cámara y evitan salas-caja.

| ID | Nombre visible | Tamaño / forma | Función y conexiones | Enemigos |
| --- | --- | --- | --- | --- |
| anden_norte | ANDÉN NORTE | 8 × 8 m, L poco profunda | Inicio; nota arrugada, cajones, acceso a sala de espera y pasillo de servicio; portón sur visible desde el inicio. | Dos infectados comunes aparecen al volver con la pistola, como en el guion actual. |
| sala_espera | SALA DE ESPERA | 8 × 7 m, L | Máquina de escribir, aviso y reloj detenido a las 7:12; conecta andén, boletería y baños. | Un común dormido junto a las máquinas. |
| boleteria | BOLETERÍA | 7 × 8 m, U | Sala segura; escritorio, libro, pistola y caja fuerte; conecta sala de espera, oficina y cabina. | Ninguno. |
| oficina_jefe | OFICINA DEL JEFE | 7 × 7 m, L | **Nueva.** Archivo, mapa de la estación, diagrama de señalización y un fusible de repuesto. Conecta boletería, cabina y sala de máquinas. | Ninguno. |
| banos | BAÑOS | 6 × 6 m, dos cubículos en recodo | **Nueva.** Fuente del primer fusible; espejo roto y cisterna registrable. Conecta sala de espera y pasillo. | Ninguno; tensión ambiental por goteo y oscuridad. |
| pasillo_servicio | PASILLO DE SERVICIO | 9 × 6 m, L | Casilleros, cadáver real y falso cadáver; conecta andén norte, baños, bodega y sala de máquinas. Aquí se esconde la llave del portón. | Un común que finge estar muerto. |
| bodega | BODEGA | 8 × 8 m, L | Don Héctor, diario del jefe y llave de acceso al andén sur; conecta pasillo y andén sur. | Don Héctor, único pesado de la zona. |
| anden_sur | ANDÉN SUR | 10 × 8 m, L con túnel | Objetivo de salida; carro de equipaje, reja de vía y túnel rojo. Conecta bodega, sala de máquinas y cabina; el acceso desde andén norte es un atajo que se abre desde este lado. | Un común opcional, condicionado a que el jugador haga ruido. |
| sala_maquinas | SALA DE MÁQUINAS | 8 × 7 m, pasillo en U | **Nueva.** Tablero de energía para habilitar una ruta alternativa y una compuerta de servicio. Conecta oficina, pasillo y andén sur. | Ninguno. |
| cabina_senales | CABINA DE SEÑALES | 7 × 6 m, L estrecha | **Nueva.** Palancas del desvío, esquema de señales y salida al andén sur. Conecta boletería, oficina y andén sur. | Ninguno. |

### Mapa ASCII

```text
                         ┌────────────────────┐
                         │ OFICINA DEL JEFE D │
                         └──────┬───────┬─────┘
                                │       │
┌──────────────┐   ┌────────────┴─┐  ┌──┴────────────┐
│ BAÑOS E      ├───┤ SALA ESPERA B├──┤ BOLETERÍA C   │
└──────┬───────┘   └──────┬───────┘  └──┬─────────┬──┘
       │                  │             │         │
┌──────┴────────┐   ┌─────┴───────┐  ┌──┴─────────┴───┐
│ PASILLO F     ├───┤ ANDÉN NORTE A│  │ CABINA SEÑALES J│
└───┬────────┬──┘   └──────┬──────┘  └──────┬─────────┘
    │        │             ╳                │
┌───┴────┐ ┌─┴──────────┐  ╳        ┌───────┴────────┐
│BODEGA G├─┤ MÁQUINAS I ├───────────┤ ANDÉN SUR H    │──→ VÍA
└────────┘ └────────────┘           └────────────────┘
```

El diagrama representa conexiones, no escala. La puerta A↔H está cerrada desde A y se abre desde H como atajo; no es la salida final a la vía. La salida de zona está en H y requiere la llave oculta del pasillo F.

### Conexiones y estado inicial

| Puerta ID | De → a | Estado inicial | Qué la abre / observación |
| --- | --- | --- | --- |
| door_anden_espera | A ↔ B | Abierta | Paso público principal. |
| door_anden_pasillo | A ↔ F | Abierta | Puerta de servicio lateral. |
| door_anden_sur_shortcut | A → H | Cerrada desde A; abre desde H | Atajo unidireccional PZ-21; no bloquea la ruta principal. |
| door_espera_boleteria | B ↔ C | Abierta | Puerta de boletería. |
| door_espera_banos | B ↔ E | Abierta | Pasillo corto a baños. |
| door_banos_pasillo | E ↔ F | Abierta | Segunda conexión a servicios. |
| door_pasillo_bodega | F ↔ G | Cerrada con pestillo simple | Se abre desde cualquiera de los lados tras retirar una barra caída; no consume llave. |
| door_bodega_sur | G ↔ H | Cerrada con candado | gate_key escondida en un casillero de F; ID de cerradura estable. |
| door_boleteria_oficina | C ↔ D | Abierta | Puerta interior de jefatura. |
| door_boleteria_cabina | C ↔ J | Cerrada con llave de servicio | La llave está en el archivador de D; no es la llave de salida. |
| door_oficina_cabina | D ↔ J | Abierta | Ruta alternativa al panel de señales. |
| door_oficina_maquinas | D ↔ I | Abierta | Corredor técnico. |
| door_pasillo_maquinas | F ↔ I | Cerrada por falta de energía | El tablero de I libera el pestillo eléctrico desde dentro (atajo PZ-21). |
| door_maquinas_sur | I ↔ H | Abierta | Ruta de servicio al andén sur. |
| door_cabina_sur | J ↔ H | Cerrada por falta de energía | Requiere restaurar energía en I; ruta alternativa al andén sur. |
| door_exit_track | H → vía | Cerrada con candado | gate_key del casillero de F; al abrirla se cierra el capítulo. |

**Bucles y rutas demostrables**
- Bucle público: A → B → C → D → I → F → A.
- Bucle de servicios: A → F → G → H → I → F → A.
- Bucle de señales: B → C → D → J → H → I → D → C → B.
- Ruta 1 al objetivo H: A → F → G → H. La llave de salida se encuentra en F antes de llegar a G/H.
- Ruta 2 al objetivo H: A → B → C → D → I → H, o A → B → C → D → J → H. La segunda variante requiere los dos fusibles en I.
- Atajo 1: H abre desde dentro la puerta A→H, permitiendo volver al andén norte.
- Atajo 2: I libera desde dentro la compuerta eléctrica I→F, creando un retorno rápido.
- No hay cadena imposible: el casillero con la llave se alcanza desde A por A→F o A→B→E→F; la llave no está detrás del portón que abre.

## 3. Objetos y llaves

| ID / objeto | Ubicación y obtención | Uso / desbloqueo |
| --- | --- | --- |
| pistol | Escritorio del guardia en C; registrable, no en el piso. | Arma de la historia; se obtiene antes de los dos infectados que llegan al volver a A. |
| ammo_9mm | Cajón del escritorio en C y caja cerrada de G. | Munición limitada. |
| gate_key | Dentro del casillero 04 de F; se registra tras descubrir chapa raspada y etiqueta «04». | Abre lock_south_exit en H. |
| office_key | Bolsillo del abrigo colgado dentro de un armario de D. | Abre archivador y acceso C↔J. |
| fuse_station_a | Dentro de la cisterna de E; cerrar el agua y abrir tapa. | Primer espacio del tablero I. |
| fuse_station_b | Cajón inferior del escritorio de D, tras abrirlo con office_key. | Segundo espacio del tablero I. |
| map_paine_station | Plano plegado en archivador de D. | Activa el mapa completo; sin él solo aparecen salas visitadas. |
| signal_key | Caja de herramientas de D/J, tras resolver palancas o caja fuerte. | Abre C↔J; D↔J sigue abierta como alternativa. |
| first_aid | Botiquín de pared en E, detrás de la puerta del cubículo. | Una cura opcional. |
| document_clock_log | Libro de boletería en C; texto canónico existente. | Segunda pista del código 0712. |

Los objetos críticos nunca aparecen como sprites sueltos en el piso. Los pickups se colocan sobre escritorio, dentro de cajón/casillero o junto a un cuerpo con contexto. Cada nodo registrable usa un ID estable y bandera de una sola recogida.

## 4. Puzzles de la zona

Hay 7 puzzles principales de 6 tipos distintos. La ruta de servicios permite avanzar sin resolverlos todos. La salida requiere gate_key.

### PZ-01 — Caja fuerte 0712 (código deducido)
- **Sala:** C, boletería. **Tipo:** código de cuatro dígitos.
- **Pasos:** inspeccionar la caja («No tengo idea de la combinación»); descubrir la hora del reloj en B; revisar el libro en C; introducir 0712.
- **Pista 1:** reloj de pared de B: «Se detuvo a las 7:12. Tiene un agujero de bala en el vidrio».
- **Pista 2:** libro de boletería en C, entrada de las 7:12 describe los disparos de don Héctor.
- **Solución exacta:** 0712.
- **Recompensa:** munición 9 mm y copia del esquema de señales; la llave de salida no está dentro de la caja.
- **Fallo:** clic grave y «No es esa hora»; sin daño ni bloqueo por intentos.
- **Cooperativo:** Isabella lee el reloj; Ignacia encuentra la entrada del libro y dicta el código.

### PZ-02 — Fusibles de la estación (energía)
- **Sala:** I. **Tipo:** fusibles/energía.
- **Pasos:** conseguir fuse_station_a en E y fuse_station_b en D; leer amperaje; instalar cada fusible; bajar interruptor principal.
- **Pista 1:** placa del tablero: «Circuito de señales: 2 × 10 A. No puentear».
- **Pista 2:** hoja de inventario en D: «Se retiró un fusible del baño para revisar humedad; el repuesto quedó en el cajón inferior».
- **Solución exacta:** instalar ambos fusibles de 10 A y activar el interruptor.
- **Recompensa:** energía en J, abre la ruta J↔H y pestillo I↔F.
- **Fallo:** fusible incorrecto no entra; «No corresponde a este tablero». No consume el objeto.
- **Cooperativo:** una jugadora sostiene la tapa mientras la otra instala; también se resuelve en solitario.

### PZ-03 — Llave oculta en casillero 04
- **Sala:** F. **Tipo:** llave oculta/registrar.
- **Pasos:** observar casilleros; comparar etiquetas; localizar pintura fresca y chapa raspada; registrar el casillero 04.
- **Pista 1:** nota del personal en E: «El casillero cuatro no cierra. Dejé la llave donde no se vea desde el pasillo».
- **Pista 2:** casillero 04 de F tiene pintura azul fresca y marca semicircular junto al pestillo.
- **Solución exacta:** registrar el casillero 04; llave en el bolsillo interior de una chaqueta.
- **Recompensa:** gate_key, abre lock_south_exit en H.
- **Fallo:** otros casilleros solo muestran ropa húmeda; no consume objeto.
- **Cooperativo:** Ignacia mantiene la linterna frontal sobre etiquetas; Isabella registra. No requiere dos jugadoras.

### PZ-04 — Secuencia de palancas del desvío
- **Sala:** J. **Tipo:** palancas/secuencia.
- **Pasos:** inspeccionar panel; encontrar diagrama en D o copia de la caja fuerte; alinear tres palancas y confirmar.
- **Pista 1:** diagrama de D: «Primero vía libre, luego desvío, al final bloqueo».
- **Pista 2:** placa del panel J tiene pictogramas de señal, aguja y candado, en ese orden.
- **Solución exacta:** posiciones 2 → 1 → 3 (libre, desvío, bloqueo), según numeración grabada.
- **Recompensa:** abre armario de herramientas y entrega signal_key.
- **Fallo:** luces vuelven a rojo; palancas se restablecen sin penalización.
- **Cooperativo:** una jugadora lee el diagrama y otra acciona; se resuelve en solitario.

### PZ-05 — Válvula de cisterna
- **Sala:** E. **Tipo:** ambiental/flujo.
- **Pasos:** cerrar llave de paso, esperar que baje el nivel, girar tapa de inspección y registrar interior.
- **Pista 1:** inscripción en cañería: «CERRAR ANTES DE ABRIR».
- **Pista 2:** nota del auxiliar: «La tapa no se puede sacar mientras corre el agua».
- **Solución exacta:** válvula cerrada antes de girar tapa.
- **Recompensa:** fuse_station_a.
- **Fallo:** con agua corriendo, la tapa vibra y no abre; no se pierde salud ni objeto.
- **Cooperativo:** una jugadora cierra la válvula y otra registra la cisterna.

### PZ-06 — Pestillo del atajo del andén
- **Sala:** H. **Tipo:** puerta de un solo lado.
- **Pasos:** llegar a H desde G o I; reconocer pestillo del portón que da a A; retirar barra interior.
- **Pista 1:** desde A se ve placa «APERTURA INTERIOR».
- **Pista 2:** desde H, la barra está a mano y tiene marcas de uso en el lado interior.
- **Solución exacta:** accionar la barra desde H; atajo queda abierto.
- **Recompensa:** retorno rápido H→A y bucle completo.
- **Fallo:** intentar abrir desde A muestra «Se traba desde este lado».
- **Cooperativo:** Ignacia puede mantener libre el paso; no es requisito.

### PZ-07 — Máquina de bebidas y ruido
- **Sala:** B. **Tipo:** ambiental/sonido y sigilo.
- **Pasos:** escuchar patrón del motor; cortar energía en interruptor lateral; esperar a que el infectado dormido deje de reaccionar; pasar por el lado contrario.
- **Pista 1:** zumbido irregular de la máquina, que se detiene al accionar interruptor.
- **Pista 2:** aviso: «No golpear el compresor. El ruido se oye hasta el andén».
- **Solución exacta:** apagar la máquina antes de cruzar detrás del infectado.
- **Recompensa:** acceso silencioso al aviso y al reloj; conserva munición.
- **Fallo:** si se golpea la máquina, el infectado despierta y persigue; no hay muerte inevitable.
- **Cooperativo:** una jugadora apaga mientras la otra cruza; en individual se puede apagar y esperar.

## 5. Pistas de Leo por puzzle

N1 ocurre al acercarse y mirar/maullar; N2 tras inactividad aproximada; N3 aparece únicamente si se pulsa AYUDA.

| Puzzle | N1 (sin palabras) | N2 (≤ 12 palabras) | N3 (solo AYUDA) |
| --- | --- | --- | --- |
| PZ-01 Caja fuerte | Mira al reloj de B y luego al libro de C. | «La hora quedó escrita dos veces.» | «Usa 0712: el reloj se detuvo a esa hora.» |
| PZ-02 Fusibles | Olfatea las dos ranuras vacías del tablero I. | «Falta energía en dos lugares.» | «Busca un fusible en baños y otro en la oficina.» |
| PZ-03 Casillero | Se sienta frente al casillero con pintura fresca. | «No todos los casilleros están igual.» | «Registra el casillero 04; la llave está en la chaqueta.» |
| PZ-04 Palancas | Mira el diagrama y después las palancas. | «El orden está dibujado en otra sala.» | «Libre, desvío, bloqueo: posiciones 2, 1 y 3.» |
| PZ-05 Cisterna | Toca con la pata la válvula de paso. | «Primero hay que dejar de escuchar el agua.» | «Cierra la llave de paso antes de abrir la tapa.» |
| PZ-06 Atajo | Mira el pestillo desde el lado de H. | «Esa puerta se abre desde aquí.» | «Levanta la barra interior para abrir el atajo a A.» |
| PZ-07 Máquina | Se queda quieta cuando el compresor zumba. | «Ese ruido despierta al que duerme.» | «Apaga el interruptor lateral antes de cruzar.» |

## 6. Mapa de zona

- **Objeto:** map_paine_station, plano plegado en el archivador de la oficina D.
- **Obtención:** abrir el cajón del archivador con office_key; el plano está dentro de una carpeta, no a la vista.
- **Cobertura:** mapa completo de las diez salas.
- **Sin mapa:** solo se dibujan las salas visitadas y las puertas ya cruzadas.
- **Estados:** sin visitar (gris oscuro), visitada (gris claro), con objeto/puzzle pendiente (dorado), puerta cerrada con llave (icono de llave). Derivar de visited:<room>, pickups y banderas; no duplicar el grafo en el guardado.
- **Pista 1:** plano de evacuación en B menciona «archivo de jefatura».
- **Pista 2:** etiqueta del archivador en D dice «Planos de estación».

## 7. Enemigos y recursos por sala

### Enemigos

| Sala | Tipo / cantidad | Comportamiento |
| --- | --- | --- |
| A | 2 comunes | Se activan al volver con la pistola; entran desde la vía. |
| B | 1 común | Dormido junto a máquina de bebidas; puede evitarse con PZ-07. |
| F | 1 común | Se hace el muerto; Leo bufa, como en el juego actual. |
| G | 1 pesado: don Héctor | Encerrado; único pesado de la zona. |
| H | 1 común opcional | Se activa por ruido; puede evitarse al abrir salida de servicio. |

**Balance máximo:** un pesado (don Héctor) y cero rápidos; no exceder el límite de dos rápidos por capítulo.

### Recursos (cantidades propuestas; ajustar en playtest)

| Sala | Recurso | Cantidad / ubicación |
| --- | --- | --- |
| A | Munición 9 mm | 5 balas en caja de herramientas junto a cajones. |
| B | Cura | 1 cura pequeña en botiquín de pared con tapa. |
| C | Pistola | 1 en escritorio del guardia, como establece el guion. |
| C | Munición 9 mm | 10 balas en cajón del escritorio. |
| D | Munición 9 mm | 5 balas en caja de archivo, tras registrar. |
| E | Fusible / cura | 1 fusible en cisterna; la cura de E es la única cura garantizada. |
| F | Llave de salida | gate_key en casillero 04; no se entrega como pickup visible. |
| G | Munición 9 mm | 5 balas en caja junto al diario, protegida por el pesado. |
| H | Munición 9 mm | Ninguna garantizada. |
| I/J | Fusibles / herramientas | Dos fusibles para ruta eléctrica; sin armas adicionales. |

**Discrepancia de economía a resolver:** el criterio general de P10 pide que un jugador cuidadoso llegue al final con aproximadamente 5 balas y 1 cura; P11-e pide que llegue al final del capítulo 1 con ~25 balas de 9 mm. Las cantidades propuestas suman 25 balas de reserva, además del cargador, por lo que no cumplen el objetivo de 5 balas restantes si el jugador recoge todo y evita disparar. Dejo la decisión en «Preguntas»: Claude/Chris deben definir si P11-e sustituye el objetivo general de P10 o si las 5 balas se refieren al saldo tras un consumo de combate previsto.

## 8. Notas y documentos nuevos (texto exacto)

Cada documento tiene menos de 120 palabras y complementa el canon.

### Nota 1 — «Registro del reloj» (B, junto al reloj)
«Viernes, 7:12. El reloj se quedó detenido después de los disparos del andén. No lo arreglen todavía: necesito que alguien revise el mecanismo cuando vuelva la luz. — Mantenimiento»

Pista: confirma 0712; no añade un hecho distinto al libro de boletería.

### Nota 2 — «Inventario de fusibles» (D, dentro del archivador)
«Tablero de señales: dos fusibles de 10 A. Uno se retiró para revisar la humedad de los baños. El repuesto quedó guardado en el cajón inferior de esta oficina. No instalar piezas de otro amperaje. — Mantenimiento»

Pista: indica cantidad, amperaje y ubicación del segundo fusible.

### Nota 3 — «Aviso de casilleros» (E, detrás de la puerta)
«El casillero 04 sigue sin pestillo. La chaqueta de trabajo que dejaron ahí no es de bodega. Si aparece la llave del portón, entréguenla al jefe de estación. No la dejen sobre la mesa.»

Pista: número 04 y chaqueta; no dice directamente que la llave esté en el bolsillo.

### Nota 4 — «Instrucciones de la cisterna» (E, sobre la cañería)
«Para abrir la tapa de inspección, cierre primero la llave de paso. Si queda presión, la tapa salta y el agua moja el tablero. Avise a mantenimiento si el sello está roto.»

Pista: orden del puzzle de válvula.

### Nota 5 — «Prueba de señales» (D, pared junto al plano)
«Secuencia de comprobación: señal libre, cambio de vía, bloqueo. Confirmar cada posición antes de pasar a la siguiente. No dejar las agujas a medio recorrido.»

Pista: orden de las palancas en J.

### Nota 6 — «Parte de energía» (I, junto al tablero)
«El circuito de señales no responde. La alimentación está aislada hasta que estén instalados los dos fusibles de 10 A. No puentear contactos: el tablero debe quedar cerrado antes de activar el interruptor principal.»

Pista: regla de instalación y seguridad.

### Nota 7 — «Plano de evacuación» (B, vitrina de anuncios)
«En caso de cierre, el personal debe reunirse en el andén sur. Los planos completos de la estación están en el archivo de jefatura. Mantener despejados el pasillo de servicio y la cabina de señales.»

Pista: ubicación del mapa y relación espacial.

### Nota 8 — «Turno de limpieza» (F, pared de casilleros)
«La máquina de bebidas hace un ruido que llega hasta el andén. Si hay alguien durmiendo en la sala de espera, apagar el compresor antes de pasar. No golpear la carcasa: el ruido se transmite por el suelo.»

Pista: puzzle ambiental PZ-07.

### Continuidad
- El reloj sigue detenido a las 7:12 por el disparo de don Héctor.
- Nota arrugada, libro, aviso y diario de Raúl conservan su texto canónico; los nuevos documentos añaden instrucciones de mantenimiento.
- Rosa dejó la pistola y las balas en la boletería. No se cambia el lugar ni la hora.
- Don Héctor sigue siendo el único infectado pesado de la zona.
- Ningún texto explica la infección ni identifica al pasajero del asiento 15.

## 9. Cámaras y aspecto por sala

Cámaras provisionales para el render; Claude define encuadres finales. Cada cámara debe mostrar a Isabella completa, la puerta de llegada y el siguiente punto de interés.

| Sala | Cámaras propuestas (2–3) | Paleta | Luz (máx. 4) | Detalle memorable |
| --- | --- | --- | --- | --- |
| A Andén norte | Desde kiosco hacia banca/puerta de espera; desde pilar opuesto hacia portón sur; contraplano corto del túnel. | Azul noche, amarillo sodio, hormigón gris. | Dos lámparas de sodio y rebote tenue. | Banca húmeda con nota arrugada. |
| B Sala espera | Desde entrada hacia reloj; desde máquinas hacia máquina de escribir. | Verde apagado, crema sucia, negro azulado. | Tubo fluorescente intermitente y luz de emergencia. | Reloj parado con agujero. |
| C Boletería | Desde puerta de espera al escritorio; desde ventanilla a caja fuerte. | Madera oscura, verde botella, latón. | Lámpara de escritorio y ambiente. | Cristal rayado y caja fuerte antigua. |
| D Oficina jefe | Desde marco de puerta al escritorio; desde archivador al mapa. | Caoba, papel sepia, verde oliva. | Lámpara articulada y ventana alta. | Mapa de vías con chinches. |
| E Baños | Desde lavamanos hacia cubículos; desde puerta al tanque de cisterna. | Azulejo verde, blanco amarillento, óxido. | Tubo frío y luz cálida filtrada. | Espejo roto que duplica el marco. |
| F Pasillo | Desde A hacia casilleros; desde E en diagonal a G; desde I hacia falso cadáver. | Verde industrial, gris, rojo tenue. | Dos tubos intermitentes. | Casillero 04 con pintura fresca. |
| G Bodega | Desde entrada en diagonal a mesa/diario; desde sacos hacia don Héctor. | Marrón húmedo, verde oscuro, óxido. | Bombilla desnuda y luz de rendija. | Diario junto a la llave. |
| H Andén sur | Desde puerta G al carro; desde cabina hacia túnel; contraplano al portón A. | Rojo de túnel, azul noche, amarillo sucio. | Dos lámparas de andén y resplandor rojo indirecto. | Carro de equipaje frente al túnel. |
| I Sala máquinas | Desde puerta D al tablero; desde pasillo F al generador. | Azul petróleo, metal, naranja de testigos. | Dos pilotos y luz de techo. | Dos ranuras de fusible vacías. |
| J Cabina señales | Desde C hacia palancas; desde D hacia ventana de vías. | Verde oscuro, latón, negro. | Luz de panel y lámpara de techo. | Palancas mecánicas y señal roja por ventana. |

## 10. Variante cooperativa

Aplicar solo si GameState.cooperative está activo. En individual no se crea Ignacia ni se muestran estas frases.

- **Entrada:** tras las líneas de llegada y la frase final de Leo, reproducir el encuentro de Ignacia de GUION §10.3 en station/platform / coop_intro.
- **B:** al acercarse a la máquina de escribir: «¿Una máquina de escribir? Bueno… guardar es guardar».
- **C:** al recoger la pistola: «Yo con eso me disparo en un pie. La llevas tú».
- **F:** al detectar el falso cadáver, Ignacia advierte que se mueve; cuando Leo bufa, ella dice que ambas piensan igual.
- **G:** al observar a don Héctor, frase de compasión, sin explicar su destino.
- **H:** al abrir la salida: «Entonces es por la vía. Vamos».
- **PZ-02:** Ignacia puede leer la placa mientras Isabella instala fusibles; sigue siendo resoluble por una sola jugadora.
- **PZ-04:** una jugadora lee el diagrama y otra acciona; no imponer temporizador estricto.
- Las cámaras y controles se mantienen locales por teléfono; esta propuesta no implica que ENet sincronice dos avatares.

## 11. Lista de comprobación final

- [x] Diez salas: seis existentes y cuatro nuevas; todas tienen al menos dos conexiones.
- [x] Grafo con tres bucles y dos rutas hasta el andén sur.
- [x] Dos atajos que se abren desde el lado opuesto.
- [x] Llave de salida alcanzable antes de necesitarla; no hay cadena imposible.
- [x] Siete puzzles, seis tipos, dos pistas exactas por puzzle, solución, fallo y variante cooperativa.
- [x] Caja fuerte 0712 vinculada al reloj de las 7:12 y al libro.
- [x] Fusibles, panel de energía y llave oculta en casillero.
- [x] Mapa de zona con estados derivados del progreso.
- [x] Enemigos dentro de límites: un pesado y cero rápidos.
- [x] Ocho textos nuevos, cada uno menor de 120 palabras y sin contradicción de cronología.
- [x] Cámaras y aspecto propuestos para todas las salas.
- [x] Sin cruces médicas, sin nombres internos y sin revelar el origen.
- [ ] Validación de Claude: medidas, conexiones, economía y coherencia con generadores actuales.
- [ ] Decisión de Chris sobre discrepancia de munición (5 balas vs ~25 balas 9 mm al final del capítulo 1).

## 12. Preguntas y decisiones pendientes

1. **Economía de munición:** P10 pide ~5 balas al terminar la zona; P11-e pide ~25 balas de 9 mm al terminar el capítulo 1. Este diseño lista 25 balas de reserva. ¿P11-e reemplaza el objetivo de P10 o las 5 balas se refieren al saldo tras un consumo de combate previsto?
2. **Caja fuerte:** propongo que 0712 entregue munición y copia del esquema, no la llave de salida; la llave permanece escondida en casillero 04. Claude puede ajustar la recompensa sin cambiar el código.
3. **Salas nuevas:** oficina, baños, sala de máquinas y cabina de señales. Si el presupuesto no admite cuatro nuevas, se puede fusionar sala de máquinas con cabina manteniendo diez nodos mediante una sala de archivo alternativa.
