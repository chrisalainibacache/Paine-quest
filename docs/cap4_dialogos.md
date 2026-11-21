# Capítulos 4 y 5 — diálogos y pistas de Leo/Paz

**Estado:** propuesta P3; no implementar hasta revisión de Claude y confirmación de Chris.

## Reglas de voz

- Todas las líneas de Leo comienzan exactamente con «Leo: ».
- Cada pista de Leo termina en una acción concreta: mirar, abrir, seguir, recoger, activar, rodear o detenerse.
- Leo habla con ternura, calma y seguridad. No explica por qué los infectados no atacan a los gatos y no habla del origen de la infección.
- En la escena del aplauso Leo se asusta por única vez: se eriza y se esconde detrás de Isabella.
- Paz pregunta por sobrevivientes del sector en general. No pregunta por una persona específica.
- El cargo de Paz como personal sanitario de apoyo es provisional hasta que Chris lo confirme.

## La señora — escalera completa de seis pasos

### Paso 1 — paciente, enfermería de La Maestranza

**Texto:**

> Por la vía de servicio camina una señora cuando cae la tarde.  
> No corre. Los infectados se apartan antes de que llegue a la reja.  
> Yo me quedé quieto hasta que dejó de tararear.  
> No pienso volver a pasar por ese pasillo.

**Reacción de Leo:** adelanta las orejas y luego se queda pegado al talón de Isabella. No habla.  
**Condición:** leer la declaración de la camilla 4.

### Paso 2 — nota de enfermería, puesto sanitario

**Texto:**

> En el turno anterior, una mujer se detuvo frente a la reja.  
> No parpadeó; tarareaba una melodía que no reconocí.  
> Los perros se echaron al suelo y dejaron de ladrar.  
> La gata de la sala siguió junto a la puerta.

**Reacción de Leo:** mira la reja, baja la cola y vuelve junto a Isabella.  
**Condición:** leer el registro de enfermería.

### Paso 3 — operario sobreviviente, vestuario

**Texto:**

> La vi al fondo, detrás del vidrio. Pelo gris recogido, chaqueta verde oliva.  
> No parecía perdida; miraba como si estuviera esperando a alguien.  
> Cuando el infectado salió, se apartó para dejarla pasar.  
> Yo me escondí antes de verle la cara.

**Reacción de Leo:** se coloca entre Isabella y el pasillo; después señala la salida de servicio.  
**Condición:** hablar con el operario después de despejar el vestuario. El operario no dice el nombre.

### Paso 4 — escena en vivo, pasillo de cuarentena

**Texto / líneas:**

> Voz lejana por el altavoz: «¿Dónde está la niña del gato?».  
> Isabella: «Esa voz…».  
> Leo: «Isabella… no te quedes. Vámonos.»

**Reacción de Leo:** se eriza y se esconde detrás de Isabella. Es la única vez que muestra miedo de esta forma.  
**Condición:** se activa una sola vez al salir del patio después de la muerte del Skull original. La mujer aparece únicamente como silueta; no se ve su rostro ni se dice su nombre.

### Paso 5 — Paz por radio, puesto sanitario

**Texto:**

> Un paciente me habló de una mujer que se sentó junto a su cama.  
> Dice que no parecía un infectado; hablaba como si lo conociera de antes.  
> Yo no la vi, Isabella. Solo tengo su relato.  
> Si la reconoces, no te acerques. Ven al puesto sanitario.

**Reacción de Leo:** se acerca a Isabella y le toca la mano con el hocico.  
**Condición:** recibir la transmisión de Paz después de la escena del aplauso. Paz nunca la vio.

### Paso 6 — registro de personal en audio, preaislamiento del Centro de Nos

**Texto:**

> Registro de personal: Rosa C. — Boletería de Paine.  
> Último turno confirmado: viernes, 23:00.  
> El archivo la clasifica como «sujeto con vínculo directo».  
> La infección no avanzó. Esperó.

**Reacción de Leo:** mira a Isabella y después la salida. No maúlla.  
**Condición:** escuchar el registro en el área de preaislamiento, antes del jefe final. Es la primera pista que dice Rosa por nombre; no explica el origen de la infección.

## Capítulo 4 — La Maestranza

| Sala | Quién | Línea / texto | Disparador |
|---|---|---|---|
| maestranza_acceso | Leo | Leo: El olor viene de la caseta. Rodea la barrera y entra por la puerta lateral. | Al detenerse ante la barrera. |
| maestranza_guardia | Paz, radio | Paz: ¿Hay sobrevivientes en el sector? Si pueden responder, indiquen cuántos son y dónde están. | Al encender la radio de guardia. |
| maestranza_guardia | Leo | Leo: Hay una llave bajo la mesa. Agáchate y recógela. | Al acercarse al escritorio. |
| maestranza_enfermeria | Leo | Leo: La cortina se mueve. Rodea las camillas y revisa el armario bajo. | Antes de entrar al área de curaciones. |
| maestranza_taller | Leo | Leo: El cable llega al tablero azul. Síguelo y baja la palanca. | Al encontrar el fusible. |
| maestranza_taller | Paz, radio | Paz: La luz del pasillo depende del tablero del taller. Restablece la energía y busca la puerta norte. | Después de activar la radio. |
| maestranza_vestuario | Leo | Leo: Ese casillero tiene marcas nuevas. Prueba la llave pequeña en la cerradura inferior. | Al mirar el último casillero. |
| maestranza_pasillo_cuarentena | Leo | Leo: No toques el sello del vagón. Sigue la franja amarilla hasta la puerta de servicio. | Al acercarse al vagón cerrado. |
| maestranza_pasillo_cuarentena | Paz, radio | Paz: El vagón del Centro de Nos sigue sellado. No lo abran. Necesito comprobar el número del precinto antes de autorizar cualquier movimiento. | Al encontrar el altavoz. |
| maestranza_patio_maniobras | Leo | Leo: La grúa está sobre la vía. Llega al panel y activa el freno. | Durante la fase ambiental del jefe. |
| maestranza_puesto_sanitario | Paz | Paz: Te escuché por la radio. Pensé que no ibas a llegar. ¿Viste a otros sobrevivientes en el camino? | Al reunirse con Paz. |
| maestranza_puesto_sanitario | Paz | Paz: Tengo una credencial de acceso al Centro de Nos. No sé qué vamos a encontrar, pero es la única ruta que sigue abierta. Vamos juntas. | Al cerrar el capítulo 4; [PROPUESTA]. |
| maestranza_puesto_sanitario | Leo | Leo: Paz está aquí. Deja que cierre la puerta y descansa un momento junto a la camilla. | Después de la reunión. |

## Paso 4 — guion técnico de la escena del aplauso

- **Disparador:** primera salida del patio de maniobras después de que el Skull original haya muerto; ocurre en el pasillo de cuarentena, antes de llegar a Paz.
- **Duración objetivo:** 9–10 segundos. Una sola reproducción por partida, con bandera de escena scene:applause. Se puede saltar con un toque después del primer segundo, siguiendo el patrón de las cinemáticas ya existentes.
- **0–1,5 s:** silencio casi total. Plano medio de Isabella de espaldas. Dos parpadeos de luz de emergencia. El cuerpo del jefe queda fuera de cuadro.
- **1,5–3,5 s:** comienza un aplauso lento y distante (applause_slow_1). La cámara avanza despacio hacia el fondo del pasillo.
- **3,5–5 s:** durante un parpadeo aparece una silueta femenina inmóvil al final del corredor. No se ve rostro, ropa en detalle ni transformación.
- **5–6,5 s:** zumbido y tarareo por el altavoz (hum_far_1). Voz lejana: «¿Dónde está la niña del gato?».
- **6,5–8 s:** el siguiente parpadeo deja el pasillo vacío. El aplauso se corta en seco y la luz cae.
- **8–10 s:** corte a Isabella. Isabella: «Esa voz…». Leo se eriza, se esconde detrás de ella y dice: «Isabella… no te quedes. Vámonos.» La salida queda habilitada.
- **Límites:** no mostrar la cara, no pronunciar el nombre Rosa, no vincular la escena con el origen de la infección y no explicar por qué la mujer busca a la niña del gato. Los dos sonidos se crearán en una etapa posterior; este documento no añade audio ni código.

## Capítulo 5 — Santiago / Centro de Nos

| Sala | Quién | Línea / texto | Disparador |
|---|---|---|---|
| santiago_via_norte | Leo | Leo: La luz de emergencia sigue encendida. Sigue las flechas verdes hasta recepción. | Al llegar al acceso. |
| centro_nos_acceso | Paz, radio | Paz: La entrada principal está bloqueada. Busca el control junto a la garita y abre el paso desde ahí. | Al encender la radio exterior. |
| centro_nos_recepcion | Leo | Leo: El registro cayó detrás del mostrador. Rodea por la izquierda y recógelo. | Al acercarse al mostrador. |
| centro_nos_archivo | Paz | Paz: El registro del asiento quince está incompleto. Falta la hoja con el nombre y el destino. No puedo decirte quién era. | Al abrir el archivo de traslados. |
| centro_nos_archivo | Leo | Leo: El cajón inferior tiene una llave pequeña. Ábrelo y revisa la carpeta azul. | Al encontrar el llavero. |
| centro_nos_enfermeria | Leo | Leo: El monitor sigue sonando. Sigue el pitido hasta la sala de curaciones. | Al entrar a enfermería. |
| centro_nos_pasillo_transferencia | Leo | Leo: El precinto está entero. No abras el vagón; revisa el número de la placa. | Al llegar al vagón sellado. |
| centro_nos_pasillo_transferencia | Paz | Paz: Mientras el sello siga intacto, no sabemos qué hay dentro. Déjalo cerrado y sigue por el corredor de transferencia. | Al leer la orden de NO ABRIR. |
| centro_nos_preaislamiento | Leo | Leo: La grabadora está debajo del escritorio. Enciéndela y escucha el registro completo. | Antes del paso 6. |
| centro_nos_preaislamiento | Paz | Paz: La ficha de personal tiene un audio adjunto. Escúchalo completo antes de entrar al área restringida. | Al encontrar el expediente. |
| centro_nos_sala_aislamiento | Rosa, fase 1 | Rosa: No te acerques, niña. Llévate al gato. | Primera aparición de Rosa transformándose. [PROPUESTA] |
| centro_nos_sala_aislamiento | Rosa, fase 2 | Rosa: No… no quería que me vieras así. | Cuando la transformación se hace visible. [PROPUESTA] |
| centro_nos_sala_aislamiento | Rosa, fase 3 | Rosa: La pistola… la dejé para que pudieras seguir. | Durante una ventana de conciencia. [PROPUESTA] |
| centro_nos_sala_aislamiento | Leo | Leo: Cuando el pecho se ilumine, apunta ahí y retrocede hacia la puerta lateral. | Pista del punto vulnerable. |
| centro_nos_sala_aislamiento | Paz | Paz: Isabella, mírame. No estás sola. Espera a que abra el panel y cruza cuando te lo indique. | Durante la fase final. |
| epilogo_amanecer | Sin diálogo hablado de Leo | Leo camina unos pasos hacia la luz, se detiene, gira y maúlla una vez. Después se aleja. | Epílogo; no añadir una explicación verbal. |

