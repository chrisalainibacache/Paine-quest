# P5-c — Especificación dimensional para trenes de Paine Quest

**Estado:** plan B de modelado procedural. Medidas propuestas para un tren ficticio inspirado en coches metálicos chilenos y locomotoras diésel-eléctricas. No es un plano de fabricación ni una réplica certificada de un modelo EFE.

## 1. Dimensiones de referencia

El generador actual (tools/level_gen/train_props.py) crea un coche de 14 × 2,9 m y una locomotora de 12 × 3,0 m. Esa longitud corta contribuye al aspecto de cajas.

Propuesta:
- **Coche de pasajeros:** 24,0 m sobre topes × 2,98 m ancho × 4,22 m alto sobre riel.
- **Locomotora diésel-eléctrica:** 17,4 m sobre topes × 3,0 m ancho × 4,3 m alto.
- **Vagón cerrado de carga:** 14–16,5 m × 3,1–3,3 m × 3,8–4,2 m.

Los 17,4 m se basan como proporción en la longitud publicada de 17,37 m para la familia EMD GT22CU; no significa que el tren ficticio sea ese modelo. Los 24 m del coche se aproximan a la ficha del coche Grab3D, no a una ficha técnica oficial EFE.

**Trocha:** conservar la separación real de los rieles que ya usa el proyecto. Medir centros de rieles y altura antes de importar; no cambiar la vía para acomodar un modelo externo. Los modelos descargados pueden venir en trocha estándar y necesitar ajuste de bogies.

Ejes del esquema: X = largo, Y = altura desde cabeza de riel, Z = ancho. Origen en centro del vehículo; nivel de riel = Y 0.

## 2. Coche de pasajeros metálico — 24 m

| Pieza | Cantidad | Medida (m) | Posición / notas |
|---|---:|---|---|
| Bastidor principal | 1 | 22,8 × 0,35 × 2,45 | Centro X 0; Y 1,05; vigas longitudinales y travesaños |
| Caja inferior | 1 | 23,2 × 1,25 × 2,98 | Y 1,75; paneles y zócalo reforzado |
| Banda de ventanas | 1 | 23,2 × 0,95 × 2,98 | Y 2,85; franja crema/aluminio envejecido |
| Franja superior | 1 | 23,2 × 0,65 × 2,98 | Y 3,65 |
| Techo curvo | 1 | 23 × 0,35 × 2,75 | Punto alto Y 4,22; sección curva de 5–7 segmentos |
| Bogies | 2 | 2,8 × 1,05 × 2,45 | Centros X ±8,0; pivote Y 0,95 |
| Ejes/ruedas | 4 ejes | rueda Ø 0,86; ancho 0,13 | Dos ejes por bogie |
| Ventanas laterales | 18 | 1,25 × 0,72 | 9 por lado; marco 0,06 |
| Puertas laterales | 4 | 0,85 × 1,95 | Dos por costado, cerca de extremos |
| Escalones | 8 | 0,85 × 0,28 × 0,08 | Dos niveles por puerta |
| Vestíbulo/fuelle | 2 | 1,1 × 2,1 × 0,18 | En ambos extremos |
| Topes | 4 | plato Ø 0,28 × 0,12 | Dos por extremo; centro Y 1,05 |
| Enganches | 2 | 0,65 × 0,22 × 0,25 | Bajo centro del testero |
| Equipos bajos | 4–6 | cajas de 0,8–1,6 | Baterías, depósitos, cilindros de freno y tuberías |
| Respiraderos | 4–6 | Ø 0,25–0,45 × 0,16 | Techo |

### Para que no parezca una caja
- No superponer tres prismas lisos. Usar panel lateral continuo con biseles en esquinas y techo redondeado.
- Banda de ventanas continua; vidrio oscuro retranqueado y marcos finos.
- Puertas al ras de la chapa con marco, bisagras, manilla, pasamanos y escalones.
- Techo con canaletas, respiraderos y tapas grandes legibles.
- Bajos con depósitos, cilindros de freno y tuberías agrupadas.
- Bogies independientes con bastidor, ejes, ruedas, cajas de grasa, resortes y frenos simplificados.

## 3. Locomotora diésel-eléctrica — 17,4 m

Concepto: capó largo y cabina desplazada hacia un extremo. Si se elige referencia Co'Co', usar dos bogies de tres ejes; confirmar familia y trocha antes de cerrar el diseño.

| Pieza | Cantidad | Medida (m) | Notas |
|---|---:|---|---|
| Bastidor | 1 | 16,2 × 0,55 × 2,5 | Y 1,0 |
| Bogies | 2 | 3,4 × 1,15 × 2,5 | Centros X ±5,9 |
| Capó largo | 1 | 9,4 × 2,3 × 2,55 | Y 2,35; ocupa aprox. 60 % del largo |
| Cabina | 1 | 3,0 × 2,7 × 2,95 | Hacia un extremo; Y 2,65 |
| Techo de cabina | 1 | 3,2 × 0,18 × 3,0 | Y 4,1; leve alero |
| Rejillas/radiadores | 4–8 | 0,7–1,4 × 0,8 | Laterales del capó |
| Ventiladores | 2–3 | Ø 0,65 × 0,18 | Sobre capó |
| Escape | 1–2 | Ø 0,25 × 0,65 | Sobre capó |
| Pasarelas | 2 | 8,0 × 0,12 × 0,48 | Y 1,55 |
| Barandas | 2 conjuntos | altura 0,85 | Postes cada 0,8–1 m |
| Escalones | 4 | 0,55 × 0,25 × 0,12 | Acceso a cabina/pasarela |
| Tanque combustible | 1 | 3,0 × 0,75 × 1,0 | Entre bogies |
| Faros | 2–3 | Ø 0,22–0,30 | Material emisivo |
| Topes | 4 | Ø 0,30 × 0,12 | Dos por extremo |
| Enganches | 2 | 0,7 × 0,25 × 0,3 | Centrados |
| Quitapiedras | 1–2 | 1,0 × 0,55 × 2,3 | Bajo testero, inclinado |
| Equipos bajos | 4–8 | cajas/cilindros | Baterías, compresor, depósitos y tuberías |

La locomotora debe mostrar capó con rejillas de distintos tamaños, tapas de servicio, cabina con ventanas amplias, bogies visibles y tanque bajo bastidor. Faros con material emisivo, no luces dinámicas múltiples. Librea y numeración ficticias; no copiar marcas oficiales.

## 4. Vagón cerrado de carga — 14–16,5 m

| Pieza | Cantidad | Medida (m) | Notas |
|---|---:|---|---|
| Bastidor | 1 | 13,2 × 0,35 × 2,4 | Travesaños |
| Caja | 1 | 13,5 × 2,8 × 3,1 | Laterales acanalados |
| Techo | 1 | 13,4 × 0,18 × 2,8 | Plano o levemente curvo |
| Puertas correderas | 2 | 3,0 × 2,3 | Una por lado |
| Bogies | 2 | 2,6 × 1,0 × 2,35 | Dos ejes por bogie |
| Escaleras | 4 | 0,45 × 1,8 | En esquinas |
| Pasarela superior | 1 | 8,0 × 0,08 × 0,35 | Madera/metal envejecido |
| Topes y enganches | 2 juegos | como coche | Altura común |

## 5. Reglas para el generador y Android
- Mantener la fuente Python tools/level_gen/train_props.py y regenerar las escenas; no editar .tscn manualmente.
- Objetivo máximo **25.000 triángulos por vehículo**. Usar LOD1 o simplificar en Blender.
- Materiales compartidos: acero pintado, aluminio envejecido, vidrio oscuro, caucho, óxido y hollín.
- Texturas objetivo: 512 px carrocería, 256 px bogies/ruedas y 128 px piezas pequeñas; para look PS1 pueden bastar 128–256 px.
- Combinar piezas repetidas en MultiMesh; tornillos y barandas pequeñas no deben multiplicar draw calls.
- Colisiones: una caja principal y colisiones adicionales solo donde el jugador camina/interactúa.
- Pivote al centro del vehículo, Y en nivel de riel; ruedas exactamente sobre los rieles actuales.
- Crear variantes dañadas con piezas alternativas/desprendibles; no duplicar el vehículo completo en la sala.
- Claude valida encuadres, pasillos transitables, cámaras y APK. No modificar cámaras en este paquete.

## 6. Referencias fotográficas (solo para mirar)
1. [Coche metálico Linke Hofmann I-203, Tren del Recuerdo, Santiago — Wikimedia Commons](https://commons.wikimedia.org/wiki/File:Tren_del_Recuerdo,_en_la_Estaci%C3%B3n_Central_de_Santiago_de_Chile,_con_coches_de_viajeros_fabricados_en_el_a%C3%B1o_1923.jpg): proporción, puertas de extremo, techo y ventanas.
2. [Passenger stock of Chile — Wikimedia Commons](https://commons.wikimedia.org/wiki/Category:Passenger_stock_of_Chile): coches EFE, coches salón y detalles.
3. [Museo Ferroviario de Santiago — Wikimedia Commons](https://commons.wikimedia.org/wiki/Category:Museo_Ferroviario_de_Santiago): coche salón EFE, ventanas, bajos y escalones.
4. [Locomotora EMD GT22CU — Wikimedia Commons](https://commons.wikimedia.org/wiki/File:Locomotora_Ferrosur_Roca_EMD_GT22CU.jpg): locomotora diésel de capó largo. Foto CC BY-SA 4.0, enlazada solo como referencia visual.
5. [EMD GT22CU locomotives — Wikimedia Commons](https://commons.wikimedia.org/wiki/Category:EMD_GT22CU_locomotives): vistas laterales y tres cuartos.

## 7. Pendientes antes de construir
- [ ] Medir trocha y altura de riel actuales.
- [ ] Elegir referencia de locomotora y confirmar configuración B-B o Co'Co'.
- [ ] Confirmar coche histórico Linke Hofmann/Cravens o coche regional más moderno.
- [ ] Descargar y revisar GLB: escala, triángulos, materiales y licencia.
- [ ] Claude planifica cámaras y prueba exportación tras la integración.

**Nota:** medidas orientativas para videojuego; no usar para ingeniería, operación ferroviaria ni fabricación física.
