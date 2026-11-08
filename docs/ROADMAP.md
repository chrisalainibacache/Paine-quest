# Hoja de ruta

Partes chicas: cada hito termina con algo que se puede probar en el teléfono.

## Hito 0 — Cimientos
- [x] Documentos de diseño, arquitectura y arte.
- [x] Estructura de carpetas y `project.godot`.
- [x] Compilación automática del APK en GitHub (descargar e instalar en el teléfono).
- [x] Pruebas automáticas headless (`tests/smoke_test.gd`).

## Hito 1 — Sala de prueba ("caja gris" con texturas)
- [x] Kit modular de muros/pisos/techo en grilla + shader de variación.
- [x] Una sala cerrada (andén norte) con 2 cámaras fijas.
- [x] Cony camina/trota con el stick (control relativo a la cámara) con animaciones Quaternius reasignadas a su esqueleto.
- [x] Filtro PS1 + niebla + luz de sodio.
- [x] Leo (gatita gris, Quaternius CC0) sigue a Cony con animaciones de caminar/correr.
- [x] Ajustes tras la primera prueba: trote más natural y dirección inteligente en los cortes de cámara.
- **Prueba en el teléfono:** caminar por la sala, cortes de cámara, 60 fps.

## Hito 2 — Combate base
- [x] Apuntar (mantener) y disparar con la pistola, auto-apuntado, munición (10 + 20) y recarga automática.
- [x] Infectado (modelo PSX + animaciones zombi Quaternius): de pie, comiendo o haciéndose el muerto; camina, ataca, se tambalea y muere.
- [x] Sangre, mancha en el piso, sonidos sintetizados y vibración al recibir daño.
- [x] Salud de Cony (Bien / Precaución / Peligro, cojea en Peligro) y pantalla de muerte con reintentar.
- [x] Trote natural (Mixamo) en vez del "salto de zanja".

## Hito 3 — Sistemas
- [x] Botón ACCIÓN contextual (RECOGER / LEER / ABRIR / USAR / EXAMINAR) en el lugar de DISPARAR.
- [x] Puertas y cambio de sala (fundido a negro + punto de aparición). Puertas con llave.
- [x] Sala de espera (2 cámaras): ventanillas de la boletería, bancas, máquina de bebidas, reloj detenido.
- [x] Recoger ítems, mochila de 8 casillas (balas apiladas), comer para curarse, examinar en 3D.
- [x] Notas legibles (lector de papel) guardadas en NOTAS.
- [x] Máquina de escribir: guardar partida. Pantalla de título con NUEVA PARTIDA / CONTINUAR.
- [x] Lo recogido y los infectados muertos se recuerdan al volver a una sala y al cargar.
- [x] Leo bufa y mira a los infectados cercanos (también a los que se hacen los muertos).
- **Prueba en el teléfono:** recoger, leer, pasar a la sala de espera y volver, guardar, cerrar la app y CONTINUAR.

## Hito 4 — Capítulo 1 completo (estación, 6 salas)
- [x] Cony empieza sin arma; la pistola se encuentra cargada en la boletería y se equipa sola.
- [x] Salas nuevas: boletería, pasillo de servicio, bodega y andén sur (con el kit `roomkit`).
- [x] Infectados que aparecen según el progreso (`requires_flag`), cadáveres de verdad, luz que parpadea.
- [x] Portón del andén sur con la llave de la bodega; bajar a la vía cierra el capítulo.
- [x] Prueba de niveles: puertas y apariciones conectadas, sin huecos de cámara, capítulo completable.
- **Prueba en el teléfono:** jugar el capítulo 1 de principio a fin.

## Hito 5 — Capítulo 2 completo (vías y tren destruido, 6 salas)

## Hito 6 — Pulido
- Menú principal, opciones, sonido final, balance de munición, ícono y nombre de la app.
