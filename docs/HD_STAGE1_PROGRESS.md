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

## Auditoría de candidatos
- Se generan ampliaciones 2x y mapas de altura/normales en `artifacts/hd_stage1/`; los archivos fuente no se sobrescriben.
- La ampliación 2x y el microdetalle procedural son experimentos de comparación. No equivalen a reconstrucción artística HD y no están aprobados para envío. La reconstrucción real debe conservar la silueta de las piedras, las juntas, manchas y grietas fuente; no se debe fabricar detalle con ruido genérico.
- Existe una evaluación paralela en `feature/remaster-hd-textures-pilot` que recomienda no enviar ampliaciones automáticas como remaster final. La dirección de producción deberá ser reconstrucción artística a 512x512, usando los originales como referencia estricta.
- Se corrigió el nombre del mapa normal del muro de piedra en el render comparativo: el generador produce `old_bricks_normal_512.png` y ahora el renderizador consume exactamente ese archivo.
- La inspección visual de los PNG fuente confirmó que `bricks_old.png` representa mampostería de piedra irregular, no ladrillo convencional. La dirección artística quedó corregida para preservar las piedras y sus juntas originales.
- Los comparativos rotulan `ORIGINAL` y `CANDIDATO 2X`, e identifican la mampostería correctamente para evitar confusiones durante la revisión.
- El comparativo de normales ahora usa pares A/B por material: el mismo albedo e iluminación con `normal_strength=0.0` frente a `0.55`. Esto permite aislar el efecto del mapa diagnóstico sin confundirlo con cambios de textura o luz.
- El workflow comprueba que ambas imágenes comparativas tengan dimensiones mínimas y contenido no plano, además de verificar que los tres PNG fuente sigan intactos en el checkout.
- Los mapas de normales actuales se derivan de la luminancia del albedo y son solo diagnósticos: el color no equivale a altura física. No se consideran mapas de relieve artísticos ni se habilitan en producción.
- El workflow valida ahora la existencia y dimensiones 512x512 de los seis mapas de altura/normales antes de renderizar.

## Puertas de validación pendientes
- Ejecutar y revisar el workflow de GitHub Actions; el cambio de código por sí solo no acredita que haya pasado. El push de esta rama solicita la ejecución automática, pero el resultado debe consultarse antes de darlo por aprobado.
- Compilar y ejecutar con Godot 4.7.2.
- El validador configura una caja rotada con escala no uniforme y seis planos orientados hacia +X, -X, +Y, -Y, +Z y -Z. Esto amplía la cobertura de configuración, pero no sustituye la inspección del render ni confirma por sí solo que las normales se vean correctas.
- Revisar visualmente orientación en superficies X/Y/Z y caras invertidas; detectar costuras, relieve invertido y apariencia plástica. La nueva escena de validación configura seis planos orientados y el render A/B permite comparar el efecto de las normales, pero ambos siguen pendientes de ejecución.
- Comparar albedo y normales bajo iluminación controlada, y después evaluar en Android con iluminación real.
- Revisar visualmente los artefactos antes de aceptar cualquier textura.
- Si aparecen costuras, relieve invertido o aspecto plástico, corregir o descartar el piloto. No reemplazar el shader original.

## Decisión de integración
- Ninguna textura candidata se integra todavía en los assets del juego.
- No se cambia geometría, cámara, proporciones de personajes, paleta artística ni interfaz móvil.
- La aprobación visual humana y la prueba Android son obligatorias antes de promover cualquier recurso.
