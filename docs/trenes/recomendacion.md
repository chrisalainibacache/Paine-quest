# P5-b — Recomendación de modelos para Paine Quest

**Criterios:** silueta ferroviaria reconocible, licencia comercial clara, importación a Godot 4 y límite de ~25.000 triángulos por vehículo para Android.

## Ranking

### 1. Locomotora diésel — tevy, LOD1
- Ficha: https://tevy.dev/models/diesel-locomotive
- Licencia: CC0 1.0.
- Polígonos: 61.808 en LOD0; **21.272 en LOD1**; 4.682 en LOD2.
- Dimensiones: 19,9 × 3,38 × 4,66 m.
- Motivo: capó largo, cabina, pasarelas, rejillas, dos bogies de tres ejes y piezas móviles separadas. Es más cercana a una locomotora diésel industrial que los modelos de tranvía/juguete.
- Adaptación: usar LOD1, texturas 1K o 512 px, librea ficticia envejecida y numeración inventada. Revisar largo y trocha antes de colocar.
- Límite: no es réplica documentada de una EMD GT22CU ni de una locomotora EFE concreta.

### 2. Coche de pasajeros — Grab3D, variante Light
- Ficha: https://grab3d.com/models/vehicles/passenger-car/
- Licencia: CC0 1.0.
- Polígonos: 27.308; **14.920 en Light**.
- Dimensiones: 24 × 2,98 × 4,22 m.
- Motivo: coche largo, nueve ventanas por lado, puertas de extremo, escalones, fuelles, bogies y topes. Es la base más completa para reemplazar el coche actual de 14 m de train_props.py.
- Adaptación: descargar Light; cambiar azul/crema por pintura ferroviaria chilena envejecida, oscurecer vidrios, ensuciar zócalos/bajos y añadir daños puntuales.
- Límite: estilizado, no un coche EFE histórico exacto.

### 3. Vagón cerrado de carga — tevy, LOD1
- Ficha: https://tevy.dev/models/covered-freight-wagon
- Licencia: CC0 1.0.
- Polígonos: 42.980 en LOD0; **14.032 en LOD1**; 2.434 en LOD2.
- Dimensiones: 16,5 × 3,31 × 4,18 m.
- Motivo: bogies, ejes y puertas correderas separados, óxido, suciedad y polvo de frenos. Sirve para el convoy industrial y el tren destruido.
- Adaptación: LOD1, texturas 1K, variar óxido/hollín, torcer o desprender puertas y conservar bogies/ejes como piezas independientes.

## Alternativa de menor riesgo
[Boxcar de Grab3D](https://grab3d.com/models/vehicles/boxcar/): 20.690 triángulos (10.345 Light), 14 m de largo, chapa acanalada, puerta corredera, escalas, pasarela, bogies y enganches. Es la alternativa de carga más liviana y detallada.

## Comparación con el generador actual
En tools/level_gen/train_props.py:
- Coche: 14 m de largo y 2,9 m de ancho, cuerpo por bloques y ventanas planas.
- Locomotora: 12 m de largo y 3 m de ancho, capó y cabina hechos con cajas.

El coche de 24 m y una locomotora de ~17–20 m cambiarán la escala de las escenas. No escalar assets a ojo: ajustar pivote, altura de riel, separación de bogies, topes y espacio jugable.

## Licencias y créditos
- **CC0 1.0:** no exige atribución. Mantener autor, URL, fecha de descarga y licencia original en el registro de activos.
- **CC BY 4.0:** exige atribución, enlace a licencia e indicar modificaciones.
- **CC BY-SA 4.0:** añade compartir adaptaciones bajo licencia igual o compatible.
- Los tres primeros del ranking son CC0. No incorporar créditos a CREDITS.md hasta que se confirme qué modelos se descargan e integran.

Créditos opcionales recomendados:
- «Locomotora diésel — tevy (CC0 1.0), modelo LOD1 adaptado».
- «Coche de pasajeros — Grab3D / Cozy Trains & Railway Kit (CC0 1.0), variante Light adaptada».
- «Vagón cerrado — tevy (CC0 1.0), modelo LOD1 adaptado».

## Tratamiento visual para el juego
Paine usa cámaras fijas, materiales sucios, texturas 128–256 px y un presupuesto aproximado de 30k triángulos visibles por sala (docs/ART_PIPELINE.md). Para que los modelos no parezcan plásticos:
1. Reducir texturas a 512/256 px si la cámara no resuelve más; filtro nearest.
2. Paleta de acero pintado, aluminio envejecido, vidrio oscuro, caucho, óxido y hollín.
3. Bajar brillo especular; añadir suciedad en zócalos y bajos.
4. Conservar silueta y detalles grandes: ventanas, puertas, rejillas, bogies, ruedas, escalones y topes.
5. Usar materiales emisivos en faros; no añadir muchas luces dinámicas.
6. Crear variantes dañadas a partir de la misma malla, evitando duplicar el tren completo.
7. LOD1 en primer plano y LOD2 en distancia.

## Recomendación final
Probar primero **coche Grab3D Light + locomotora tevy LOD1**. Añadir vagón tevy LOD1 como tercera pieza. Boxcar Grab3D queda como reemplazo si el vagón tevy no importa bien o no encaja visualmente.

Flujo acordado: Chris descarga 2–3 GLB desde el teléfono y los sube a Drive; Claude revisa importación, pivotes, materiales, cámaras y APK. No modificar train_props.py hasta inspeccionar los archivos en el proyecto.
