# Paine — dirección artística de texturas HD

## Objetivo visual
Subir definición material sin cambiar la identidad survival horror de Paine. Las texturas nuevas deben parecer una versión mejor resuelta de los recursos existentes, no un cambio de dirección artística ni un acabado PBR brillante.

## Reglas comunes
- Mantener geometría, escala aparente, cámara, composición, paleta y contraste de la escena.
- Usar los PNG originales como referencia visual obligatoria y como rollback.
- Trabajar a 512x512 cuando el recurso fuente sea 256x256, pero no confundir resolución mayor con detalle real.
- No inventar grietas, juntas, manchas grandes, ladrillos ni patrones que no estén en la referencia.
- El detalle nuevo debe ser de escala fina, material-específico y de baja amplitud.
- La textura debe conservar un rango tonal compatible con la escena nocturna; evitar blancos quemados y negros empastados.
- Revisar el recurso a escala de juego y a tamaño 1:1. Una textura que solo se ve bien ampliada no queda aprobada.
- Comprobar repetición en mosaico. Si el original no es tileable, no esconder la costura con un filtro: documentar si el recurso se usa como decal, atlas o proyección triplanar.

## Fichas por material

### Concreto
- Preservar manchas, variación de tono y desgaste existentes.
- Añadir microgranulado mineral fino y discreto.
- Evitar ruido uniforme tipo televisión y relieves redondeados/plásticos.
- No inventar fisuras profundas.

### Muro de piedra antiguo (`bricks_old.png`)
- Corrección de clasificación visual: el recurso muestra mampostería de piedras irregulares, no ladrillos convencionales.
- Preservar siluetas, tamaño, orientación y distribución de cada piedra, además del trazado y ancho de las juntas.
- Añadir únicamente microdetalle mineral y erosión discreta dentro de las piedras, respetando sus tonos ocres y grises existentes.
- No regularizar las piezas, convertirlas en bloques uniformes, desplazar juntas ni aumentar artificialmente el contraste del mortero.
- Revisar especialmente la continuidad de juntas entre bordes y que el relieve no deforme la lectura de la mampostería.

### Asfalto agrietado
- Mantener exactamente los recorridos y bifurcaciones de las grietas.
- Añadir grano de árido fino y desgaste sutil fuera de las grietas.
- No convertir grietas finas en surcos anchos ni añadir grietas nuevas.
- Evitar brillo húmedo salvo que la escena lo requiera expresamente.

### Adoquines (siguiente lote)
- Mantener cantidad, forma, separación y orientación de las piezas.
- Añadir variación fina de piedra y desgaste en cantos, sin alterar la silueta.
- Evitar relieve exagerado que cambie la lectura del suelo desde la cámara actual.

### Madera y metal (lote posterior)
- Madera: conservar dirección de veta y desgaste existente.
- Metal: conservar pintura, oxidación y bordes; controlar reflejos para mantener acabado mate.

## Criterios de aceptación
Una textura solo pasa a integración cuando:
1. La comparación lado a lado no altera el diseño macro ni la paleta.
2. Los detalles nuevos son visibles a escala de juego, pero no dominan la escena.
3. La repetición no muestra costuras en las superficies donde se usa tileado.
4. No aparecen halos, ruido, bandas ni artefactos de reescalado.
5. Se revisa en Godot 4.7.2 con el renderer Compatibility y luego en un Android real.
6. Existe rollback inmediato al PNG original.

## Estado
Documento de dirección artística. No significa que las texturas estén reconstruidas o aprobadas.
