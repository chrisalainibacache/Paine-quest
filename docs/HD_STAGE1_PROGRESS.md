# HD Stage 1 — prototype de shader y texturas

## Estado
- Rama experimental: `feature/hd-remaster-stage1-textures`.
- La rama se mantiene aislada de `main`; no se han reemplazado texturas, escenas ni materiales de producción.
- El shader base `ps1_surface.gdshader` permanece intacto.
- `ps1_surface_hd_pilot.gdshader` es una variante de prueba, no aprobada para producción.

## Qué prueba
- Conserva el muestreo triplanar, el color, la variación macro y la suciedad del shader original.
- Añade un canal de normal map triplanar en espacio mundo.
- La intensidad `normal_strength` parte en 0.0: no cambia el aspecto hasta asignar un mapa y habilitarlo expresamente.
- Mantiene `ROUGHNESS = 1.0` y el render simple compatible con Compatibility.

## Resultados comprobados en GitHub Actions
- Las dos ejecuciones más recientes del workflow terminaron correctamente con Godot 4.7.2, importación del proyecto, validador del shader, comparativos y captura de las dos cámaras reales.
- Una ejecución anterior falló en la etapa de validación de dimensiones/preservación; las dos ejecuciones posteriores sí completaron y publicaron artefactos.
- El artefacto revisado contiene `anden_real_camara_west.png` y `anden_real_camara_east.png`, ambos de 1280x720. Son capturas base auténticas de la escena original, sin sustitución de materiales.
- La imagen `comparacion_hd.png` confirma que el reescalado 2x produce cambios muy sutiles. No es una reconstrucción artística HD ni está aprobado como mejora final.
- La imagen `comparacion_normales_luz.png` permite ver diferencias A/B, pero el encuadre de diagnóstico deja los objetos pequeños y no es suficiente para aprobar el relieve.
- `shader_orientaciones.png` se genera correctamente, pero la inspección visual muestra cobertura/encuadre insuficiente para considerar demostradas las seis orientaciones. Se debe mejorar la composición del validador.

## Auditoría y prioridad de materiales
- El primer piloto generaba candidatos para concreto, mampostería antigua y asfalto agrietado.
- La revisión de `platform.tscn` y sus materiales encontró una omisión importante: el suelo dominante del andén usa `paving.png`, no concreto. El asfalto agrietado no es dominante en la escena principal capturada.
- Se añadió `HD_STAGE1_MATERIAL_PRIORITY.md` con el orden recomendado para el andén: pavimento, mampostería antigua, revoque, baldosas, madera/metal y grava/seguridad.
- La auditoría automatizada se amplía para medir las 14 texturas de entorno sin modificarlas.

## Qué significa el piloto 2x
- La ampliación Lanczos y el microdetalle procedural son experimentos de comparación. No equivalen a reconstrucción artística HD.
- Las métricas estructurales son barreras de regresión para preservar apariencia macro, no aprobación artística.
- Los mapas de normales se derivan de luminancia del albedo; el color no equivale a altura física. Son diagnósticos y no se habilitan en producción.
- La mampostería de `bricks_old.png` es piedra irregular, no ladrillo convencional. Preservar piedras, juntas, proporciones y distribución.

## Próximas puertas de validación
1. Ejecutar la auditoría completa de las 14 texturas y priorizar por presencia real en la estación.
2. Construir comparaciones A/B usando la escena real y las cámaras Oeste/Este; mantener geometría y luz idénticas.
3. Mejorar el encuadre del validador de normales para que las seis orientaciones sean visibles y verificables.
4. Crear candidatos artísticos de `paving.png`, `bricks_old.png` y `plaster.png`; no aplicar ruido genérico ni alterar patrones reconocibles.
5. Revisar visualmente los artefactos, validar Compatibility y probar en Android antes de promover cualquier recurso.

## Decisión de integración
- Ninguna textura candidata se integra todavía en los assets del juego.
- No se cambia geometría, cámara, proporciones de personajes, paleta artística ni interfaz móvil.
- La aprobación visual humana y la prueba Android son obligatorias antes de promover cualquier recurso.
