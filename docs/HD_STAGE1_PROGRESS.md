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
- La ampliación 2x y el microdetalle procedural son experimentos de comparación. No equivalen a reconstrucción artística HD y no están aprobados para envío.
- Existe una evaluación paralela en `feature/remaster-hd-textures-pilot` que recomienda no enviar ampliaciones automáticas como remaster final. La dirección de producción deberá ser reconstrucción artística a 512x512, usando los originales como referencia estricta.
- Se corrigió el nombre del mapa normal de ladrillos en el render comparativo: el generador produce `old_bricks_normal_512.png` y ahora el renderizador consume exactamente ese archivo.
- El workflow valida ahora la existencia y dimensiones 512x512 de los seis mapas de altura/normales antes de renderizar.

## Puertas de validación pendientes
- Ejecutar y revisar el workflow de GitHub Actions; el cambio de código por sí solo no acredita que haya pasado.
- Compilar y ejecutar con Godot 4.7.2.
- Probar orientación en superficies X/Y/Z y caras invertidas; revisar costuras, relieve invertido y apariencia plástica.
- Comparar albedo y normales bajo iluminación controlada, y después evaluar en Android con iluminación real.
- Revisar visualmente los artefactos antes de aceptar cualquier textura.
- Si aparecen costuras, relieve invertido o aspecto plástico, corregir o descartar el piloto. No reemplazar el shader original.

## Decisión de integración
- Ninguna textura candidata se integra todavía en los assets del juego.
- No se cambia geometría, cámara, proporciones de personajes, paleta artística ni interfaz móvil.
- La aprobación visual humana y la prueba Android son obligatorias antes de promover cualquier recurso.
