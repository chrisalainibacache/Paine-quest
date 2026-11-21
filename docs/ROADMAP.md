# Hoja de ruta

Estado del proyecto y próximos hitos. Las tareas se entregan en partes pequeñas; cada cambio de
código termina con «Pruebas en PR» verde. Chris prueba el APK en su teléfono Android.

## Estado general

- **Capítulos completos:** 1 (Estación de Paine), 2 (vías y tren destruido) y 3 (Buin).
- **Capítulo 4:** diseño aprobado (APROBADO D); implementación de La Maestranza en curso en PR #13. Las siete salas jugables se separan del patio de maniobras y la escena del aplauso, a cargo de Claude.
- **Capítulo 5 y epílogo:** diseño narrativo documentado; implementación posterior a la fusión de P6.
- **Sistemas:** P1 (créditos, opciones, sonidos y anuncios de prueba) fusionado; audio por sala y director de audio integrados. Los OGG definitivos y sus ajustes de mezcla se incorporan por Claude.
- **Trenes:** locomotora, coche de pasajeros y vagón de carga CC0 importados; Vía norte y Tren descarrilado tienen fondos prerenderizados. El campo abierto de Buin usa cerco, portones y continuidad visual exterior.
- **Protagonistas:** Isabella y su hermana Paz. Los nombres internos antiguos, como cony en recursos de personaje, se conservan por compatibilidad; en textos visibles se usan Isabella y Paz.
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

## Hito 8 — Audio real (sistema integrado; activos definitivos en incorporación)

- [x] **T7 — Parte 1:** cargador de SFX con variantes y respaldo sintetizado; buses Master, Sfx, Music, Ambience y Ui; director de audio con ambiente por sala, música por capítulo, tensión y atenuación durante diálogos.
- [x] **T8 — Parte 2:** propiedad ambience en Room y asignación de ambiente en los generadores de salas.
- [ ] Claude incorpora los OGG definitivos por tandas y revisa la mezcla; no inventar ni subir audios desde este trabajo.
- [x] El sistema conserva el respaldo sintetizado cuando no hay archivos OGG.

## Hito 9 — Cinemática de Skull (implementada; revisión visual de Claude)

- [x] **T9:** cinemática en vivo de unos 10 segundos al inicio del capítulo 2, una sola vez por partida y saltable con un toque.
- [x] Skull nunca se muestra: solo puerta metálica, impactos, polvo, luz, sombra y sonido.
- [x] Escena y geometría generadas por Python; reproducción integrada en el sistema de cinemáticas, sin prerenderizar.
- [x] PR #8 fusionado; Claude revisó la secuencia con capturas y ajustó la sombra. Los sonidos específicos de criatura siguen a cargo de Claude.

## Hito 10 — Capítulo 4: La Maestranza (aprobado; implementación en curso)

- [x] APROBADO D por Chris: Rosa muere en paz; Paz es sanitaria de apoyo; se conservan las semillas A y D.
- [x] Recorrido definido en siete salas: acceso, guardia, enfermería, taller, vestuario, pasillo de cuarentena y puesto sanitario.
- [x] Ocho documentos, diálogos y pistas de Leo definidos en docs/cap4_notas.md y docs/cap4_dialogos.md.
- [ ] P6 — implementación: generadores, recursos de documentos, conexiones, pruebas y limpieza en PR #13. Claude ejecuta los generadores y revisa cámaras/renders.
- [ ] Patio de maniobras (encuentro con Skull) y escena del aplauso: responsabilidad de Claude; fuera del alcance de P6.
- [ ] El vagón del Centro de Nos permanece sellado y sin interior visible.

## Hito 11 — Capítulo 5, epílogo y pulido

- [x] Diseño de capítulo 5 / Centro de Nos y epílogo Para Leo documentado en P3.
- [ ] Implementación de capítulo 5 y epílogo, después de fusionar P6.
- [x] Menú de opciones con controles de efectos, música y ambiente; etiquetas alineadas junto a sus deslizadores.
- [ ] Balance de munición y dificultad tras jugar los capítulos completos.
- [ ] Ícono y nombre definitivo de la app.
- [x] Josefin Sans incorporada; conservar su licencia OFL en el inventario.
- [ ] Revisar y confirmar licencias pendientes de personajes y paquetes PSX.

## Hito 12 — Monetización y publicación (en planificación)

- [x] Auditoría documental de recursos y licencias en docs/store/licencias_activos.md.
- [x] Créditos visibles en el juego y atribuciones CC BY de música y texturas.
- [ ] Resolver recursos con licencia comercial no verificada y paquetes que no permiten redistribuir archivos fuente.
- [ ] Confirmar los términos del fondo del título generado con IA antes de publicar.
- [ ] Cerrar modelo de ingresos, política de privacidad, requisitos de Google Play y reparto de tareas.

Ver docs/MONETIZACION.md para el detalle del modelo y los riesgos pendientes.

## Próximos trabajos

Orden vigente: terminar P6 (siete salas, notas, conexiones, pruebas, limpieza y documentación); Claude ejecuta los generadores y prepara cámaras/renders; tras la fusión de P6 comienza P7 (capítulo 5 y epílogo). Los OGG definitivos y las tareas visuales reservadas permanecen con Claude.
