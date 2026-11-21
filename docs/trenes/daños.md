# P5-d — Catálogo de daños realistas de descarrilamiento

**Uso:** variantes visuales para los trenes de Paine Quest. El daño se distribuye por pieza para construir versiones intactas, dañadas y siniestradas sin duplicar toda la geometría.

## 1. Principios de lectura
- El daño debe comunicar arrastre longitudinal, golpe contra tope/estructura, vuelco lateral y posible incendio posterior.
- Desde cámaras fijas, priorizar 3–5 daños grandes y reconocibles por vehículo.
- Diferenciar metal doblado (pliegues), metal arrancado (hueco y pestañas), vidrio roto (marco vacío), hollín (mancha amplia) y polvo/barro (parte baja).
- Mantener el pasillo de Isabella despejado y la silueta del tren legible.
- No usar humo/fuego como sustituto de daño geométrico.

## 2. Coche de pasajeros

| Pieza | Daño | Lectura | Implementación económica |
|---|---|---|---|
| Testero | Frente comprimido, panel hundido, esquina plegada | Pliegue tipo acordeón; topes desalineados | 2–3 paneles doblados y testero alternativo |
| Laterales | Tajo longitudinal, abolladuras, costillas deformadas | Surco oscuro y nervios torcidos | 2–4 paneles alternativos inclinados |
| Techo | Rasgadura, borde levantado, sección aplastada | Hueco visible desde cámara alta | Panel ausente + lámina doblada + interior oscuro |
| Ventanas | Cristal ausente, grietas, marco deformado | Huecos negros alternados | Material roto o paneles faltantes; pocos fragmentos grandes |
| Puertas | Arrancada, atascada o torcida | Acceso irregular al interior | Hoja como pieza separada en suelo o girada |
| Escalones/barandas | Peldaño aplastado, baranda doblada | Acceso deformado | Tubos/cajas finas rotados, sin colisión |
| Bogies | Girado, desplazado o separado | Ruedas fuera de eje | Subescena independiente con transform fijo |
| Ruedas/ejes | Eje fuera de guía, rueda inclinada | Contacto irregular con riel | Eje separado; no simular física continua |
| Bajo bastidor | Depósito abollado, tubería rota, cilindro colgando | Bajos asimétricos | Cajas/tubos simples |
| Topes/enganche | Tope torcido, enganche estirado/desprendido | Extremos desalineados | Nodos independientes rotados |
| Interior | Aislación colgante, panel abierto | Interior oscuro expuesto | 2–3 tiras de malla fina |

## 3. Locomotora diésel

| Pieza | Daño | Lectura | Implementación |
|---|---|---|---|
| Capó | Chapa hundida, rejilla arrancada, tapa levantada | Motor expuesto en un costado | Rejilla separada, panel desplazado y hueco oscuro |
| Cabina | Parabrisas roto, marco doblado, techo hundido | Zona de conducción dañada | Cristal ausente/opaco y techo alternativo |
| Testero | Placa comprimida, faros rotos, quitapiedras doblado | Golpe frontal asimétrico | Paneles inclinados y faro apagado |
| Pasarela | Baranda torcida, piso levantado | Circulación interrumpida | Tramos separados; MultiMesh solo para intactos |
| Bogies | Desalineado o parcialmente desprendido | Ejes oblicuos respecto del bastidor | Subescena con transform fijo |
| Ruedas | Rueda fuera del riel o conjunto inclinado | Contacto irregular | Rotación/desplazamiento estáticos |
| Tanque | Abollado, tapa abierta, mancha | Suciedad bajo bastidor | Malla simple y mancha; sin fuga interactiva |
| Radiadores | Rejilla hundida, ventilador deformado | Capó irregular | Cambiar rejilla y retirar una pala visible |
| Escape | Tubo doblado, hollín | Mancha negra en techo | Cilindro alternativo inclinado |
| Topes/enganche | Desparejos, enganche arrastrado | Extremo torcido | Nodos independientes |
| Faro/cableado | Lente roto, soporte colgante | Punto de luz apagado | Material sin emisión y soporte separado |

## 4. Vagón de carga

| Pieza | Daño | Lectura | Implementación |
|---|---|---|---|
| Caja | Costado abombado, panel hundido, esquina abierta | Planos deformados | 3–5 paneles alternativos y abertura |
| Puerta corredera | Fuera de guía, torcida o caída | Hueco de carga irregular | Hoja separada y apoyada junto al vagón |
| Techo | Panel levantado o hundido | Borde quebrado | Panel alternativo y hueco interior |
| Escaleras | Peldaños doblados/faltantes | Acceso incompleto | Quitar o rotar peldaños |
| Pasarela | Tramo desprendido | Línea superior interrumpida | 1–2 segmentos sueltos |
| Bogies/ejes | Bogie desplazado, ejes fuera de vía | Apoyo desigual | Subescena independiente |
| Topes/enganche | Tope aplastado, enganche roto | Separación entre vagones | Ocultar pieza y añadir variante doblada |

## 5. Niveles de daño

### Nivel 1 — Golpe y arrastre
- Dos ventanas rotas.
- Un panel lateral hundido.
- Pintura raspada y polvo en zócalo.
- Un tope ligeramente torcido.
- Ambos bogies todavía bajo el bastidor.

### Nivel 2 — Descarrilamiento
- Vagón ladeado entre 8° y 18°.
- Un bogie desplazado o girado.
- Tres a cinco ventanas rotas.
- Puerta de extremo deformada.
- Tajo lateral y sección de techo abierta.
- Enganche estirado o separado.

### Nivel 3 — Vuelco y destrucción severa
- Caja inclinada entre 25° y 70° o apoyada sobre un costado.
- Bogie fuera del bastidor; ruedas y eje visibles junto a la vía.
- Testero comprimido y techo rasgado.
- Varias ventanas ausentes.
- Chapa levantada, hollín y marcas de calor localizadas.
- Puerta arrancada y piezas de pasarela en el suelo.

### Nivel 4 — Incendio posterior
- Aplicar solo si lo requiere la historia.
- Hollín alrededor de rejillas, techo y ventanas rotas.
- Pintura oscurecida y cristales ennegrecidos.
- Humo/llamas muy limitados, con partículas CPU.
- Una luz cálida como máximo o material emisivo; no sumar luces dinámicas.
- Mantener visibles los daños estructurales previos.

## 6. Composición del tren descarrilado del capítulo 2

El GDD establece que el tren D-16008 está destruido y volcado en el ramal. Propuesta:
1. Coche principal con Nivel 3, ladeado y un extremo aplastado.
2. Un bogie completo suelto a un costado, ruedas visibles fuera de la vía.
3. Puerta desprendida junto al hueco, sin flotar.
4. Segundo coche con Nivel 2, inclinado en sentido contrario o trabado con el primero.
5. Locomotora fuera del encuadre principal o con daños frontales y un bogie desalineado.
6. Balasto desplazado, traviesas rotas, cables/tuberías sueltas y hollín; conservar libre el camino jugable.

La composición debe sugerir que el convoy golpeó el cambio de vía/tope y salió de la vía, no que está estacionado con cajas torcidas.

## 7. Reglas de implementación móvil
- Una escena intacta y una siniestrada por vehículo; compartir mallas y materiales.
- Piezas desprendibles como nodos estáticos precolocados, no RigidBody con simulación permanente.
- Máximo 3–5 piezas sueltas grandes visibles por sala.
- Partículas CPU solo en secuencias puntuales; apagarlas al terminar.
- No usar Decal en Compatibility; usar mallas planas o materiales de suciedad.
- Reutilizar materiales/atlas y evitar material único por fragmento.
- Respetar ART_PIPELINE: ~30k triángulos visibles y ≤4 luces por sala.
- Claude revisa cámaras cuando se integren modelos.
