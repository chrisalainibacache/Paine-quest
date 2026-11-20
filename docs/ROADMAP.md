# Hoja de ruta

Estado del proyecto y próximos hitos. Las tareas se entregan en partes pequeñas; cada cambio de
código termina con «Pruebas en PR» verde. Chris prueba el APK en su teléfono Android.

## Estado general

- **Capítulos completos:** 1 (Estación de Paine), 2 (vías y tren destruido) y 3 (Buin).
- **Pendientes de diseño:** capítulo 4, La Maestranza; capítulo 5, Santiago / Centro de Nos;
  epílogo «Para Leo».
- **Próximos trabajos técnicos:** audio real (T7 y T8), cinemática en vivo de Skull (T9) y
  pruebas de orientación de puertas (T6).
- **Protagonistas:** Isabella y su hermana Paz. Los nombres internos antiguos, como `cony`
  en recursos de personaje, se conservan por compatibilidad; en textos visibles se usan
  Isabella y Paz.

## Hito 0 — Cimientos

- [x] Documentos de diseño, arquitectura y arte.
- [x] Estructura de carpetas y proyecto Godot.
- [x] Compilación automática del APK en GitHub.
- [x] Pruebas automáticas headless y workflow de validación de PR.

## Hito 1 — Sala de prueba

- [x] Kit modular de muros, pisos y techos.
- [x] Andén norte con cámaras fijas.
- [x] Movimiento de Isabella con stick y animaciones.
- [x] Leo acompaña a Isabella.
- [x] Filtro visual Retro, niebla e iluminación base.

## Hito 2 — Combate base

- [x] Apuntar, disparar, autoapuntado, munición y recarga.
- [x] Infectados con estados, ataques, daño y muerte.
- [x] Salud de Isabella, estados Bien / Precaución / Peligro y pantalla de muerte.
- [x] Efectos de impacto, sangre y vibración.
- [x] Movimiento de trote.

## Hito 3 — Sistemas de juego

- [x] Acción contextual: recoger, leer, abrir, usar y examinar.
- [x] Puertas, cambios de sala, fundidos y puntos de aparición.
- [x] Inventario, objetos consumibles y lector de documentos.
- [x] Máquina de escribir, guardado, carga y memoria del estado de las salas.
- [x] Diálogos y pistas de Leo; Leo detecta también a los infectados que fingen estar muertos.
- [x] Pantallas de título, fin de capítulo y continuación.

## Hito 4 — Capítulo 1: Estación de Paine (completo)

Seis salas: andén norte, sala de espera, boletería, pasillo de servicio, bodega y andén sur.

- [x] Isabella comienza sin arma; encuentra la pistola y munición en la boletería.
- [x] Llave de la bodega para abrir el portón del andén sur.
- [x] Infectados con aparición condicionada por el progreso, cadáveres y luces que parpadean.
- [x] El túnel del andén sur permite bajar a la vía y cerrar el capítulo.

## Arsenal y remaster de la estación

- [x] Siete armas disponibles y mochila ampliada a 16 espacios.
- [x] Escopeta, fusil, rifle, lanzagranadas y bazuca, además de la pistola.
- [x] Remaster de arquitectura y texturas de la estación.
- [x] Filtro Retro ajustado a 480 líneas.

## Hito 5 — Capítulo 2: Vías y tren destruido (completo)

Seis salas: vía norte, tren descarrilado, interior del vagón, costado del convoy,
paso bajo nivel y casa de cambios.

- [x] Tren de las 6:30 destruido y atravesado en la vía; se cruza a pie.
- [x] Llave del maquinista para abrir la reja del paso bajo nivel.
- [x] Infectado rápido y linterna para el tramo en apagón.
- [x] Punto de control y cierre del capítulo.

## Hito 6 — Capítulo 3: Buin (completo)

Siete salas, en la mañana del sábado: puente del Maipo, control militar, estación de Buin,
bodega agrícola, potrero, viña Santa Rosa y galpón.

- [x] El puente conduce al control militar abandonado.
- [x] Soldados infectados con casco y chaleco; la orden del día revela que el tren sanitario
  trasladaba personas mordidas a cuarentena.
- [x] La estación conserva la lista de pasajeros del tren sanitario.
- [x] La bodega agrícola está a oscuras; Isabella usa la linterna para encontrar en el tractor
  la llave del galpón y leer la carta de Ana.
- [x] En el potrero ocurre el rescate de Isabella y Leo por **Kiara y Nala**. Kiara es una
  akita naranja, grande; Nala es una bull terrier gris atigrada con café, más pequeña.
  La escena guionada se activa una sola vez por partida.
- [x] La llave del tractor abre el galpón de la viña.
- [x] En el galpón, Rosa habla desde la oficina cerrada y la radio transmite el mensaje de Paz:
  está en La Maestranza, San Bernardo. Fin del capítulo.

## Hito 7 — Orientación, cámaras y presentación visual (implementado)

### Cámaras fijas

- [x] Planificador de cámaras: `tools/plan_cameras.gd`.
- [x] Planificación guardada en `tools/level_gen/cameras.json`: 73 zonas de cámara distribuidas
  en 19 salas.
- [x] Los generadores aplican los datos de cámara al crear las escenas.
- [x] Auditoría global: `tools/audit_cameras.gd`, incluida en «Pruebas en PR».
- [ ] Si se modifica geometría, props grandes o cámaras, volver a planificar, regenerar,
  auditar y avisar si se necesitan nuevos fondos prerenderizados.

### Túneles

- [x] Portales ferroviarios con arco y túneles transitables generados por
  `tools/level_gen/tunnels.py`.
- [x] Variantes de portal oscuro y con resplandor rojo.
- [x] Paso bajo nivel del capítulo 2 con apagón y linterna.

### Modo gráfico

- [x] **Moderno es el modo predeterminado** en una instalación nueva.
- [x] El jugador puede alternar entre Moderno y Retro; la preferencia queda guardada.
- [x] Moderno aplica materiales de mayor detalle, suavizado, sombras limitadas y fondos
  prerenderizados cuando existen.
- [x] Retro conserva el aspecto PS1 y el filtro de pantalla.
- [x] Los fondos prerenderizados están preparados para el capítulo 1; capítulos 2 y 3 usan
  geometría renderizada en vivo.

### Señalización y orientación

- [x] Las puertas de avance muestran una flecha amarilla y el nombre del destino.
- [x] Si la puerta de avance está bloqueada, el marcador indica «CON LLAVE».
- [x] Las puertas de retorno con el texto «VOLVER» no muestran flecha.
- [x] Los destinos se resuelven mediante `Door.LABELS` o el texto explícito de la puerta.
- [x] Al entrar a una sala, aparece temporalmente el nombre del lugar en la parte superior
  central de la pantalla.

### Diagnóstico en el teléfono

- [x] Botón **DIAG** en la mochila.
- [x] La pantalla DIAG muestra información del dispositivo, últimos eventos y errores
  registrados; sirve para que Chris comparta una captura cuando algo no responde.

## Hito 8 — Audio real (pendiente)

- [ ] **T7 — Parte 1:** cargador de SFX OGG con selección aleatoria de variantes y respaldo
  sintetizado cuando no exista el archivo; buses Master, Sfx, Music, Ambience y Ui;
  director de audio para ambientes, música, tensión e interacción con diálogos.
- [ ] **T8 — Parte 2:** propiedad `ambience` en cada sala y asignación de ambiente a todos los
  generadores según `docs/AUDIO_PLAN.md`.
- [ ] Los archivos OGG los incorpora Claude por tandas; no se deben inventar ni subir audios
  desde este trabajo.
- [ ] Validar que el juego siga funcionando sin ningún OGG y que el APK no supere el
  presupuesto de audio establecido.

## Hito 9 — Cinemática de Skull (pendiente)

- [ ] **T9:** cinemática en vivo de unos 10 segundos al inicio del capítulo 2, una sola vez
  por partida y saltable con un toque.
- [ ] Skull nunca se muestra: solo puerta metálica, impactos, polvo, luz, sombra y sonido.
- [ ] Escena generada con Python y reproducida por el sistema de cinemáticas; no prerenderizar.
- [ ] Claude revisa la puesta en escena con capturas.

## Hito 10 — Capítulos siguientes (diseño pendiente)

- [ ] **Capítulo 4 — La Maestranza (San Bernardo):** 6–8 salas pequeñas y cerradas. Paz trabaja
  allí; el encuentro con Skull se diseña como persecución o jefe del capítulo. El vagón del
  Centro de Nos permanece cerrado.
- [ ] **Capítulo 5 — Santiago / Centro de Nos:** Isabella y Paz juntas; se resuelve el misterio
  del pasajero del asiento 15.
- [ ] **Epílogo — «Para Leo»:** despedida aprobada por Chris, al amanecer y ya a salvo.

## Próximos tickets

Orden de trabajo acordado: **T5 → T7 → T8 → T9 → T6 → T1 → T2 → T3**.
T5 actualiza esta hoja de ruta; después se implementan audio y cinemática, se refuerzan las
pruebas de puertas y se continúa con el diseño de los capítulos siguientes.

La implementación del capítulo 4 (tarea D) sigue **bloqueada** hasta que Claude escriba
literalmente `APROBADO D` en `docs/CHATGPT_LOG.md`.
