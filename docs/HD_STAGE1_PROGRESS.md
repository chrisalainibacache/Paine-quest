# HD Stage 1 — prototype de shader

## Estado
- Rama experimental: `feature/hd-remaster-stage1-textures`.
- La versión estable y sus materiales originales no se modifican.
- El shader base `ps1_surface.gdshader` permanece intacto.
- Se añade `ps1_surface_hd_pilot.gdshader` como variante aislada.

## Qué prueba
- Conserva el muestreo triplanar, el color, la variación macro y la suciedad del shader original.
- Añade un canal de normal map triplanar en espacio mundo para evitar depender de UV tangentes de cada pieza.
- La intensidad `normal_strength` parte en 0.0: no cambia el aspecto hasta asignar un mapa y habilitarlo expresamente.
- Mantiene `ROUGHNESS = 1.0` y el render simple compatible con Compatibility.

## Limitaciones y puerta de validación
- El shader por sí solo no mejora una textura fuente pobre; el mapa de normales debe aportar relieve real y no ruido.
- Las normales candidatas siguen siendo diagnósticas. No se asignan a materiales de producción.
- Antes de integrar: compilar en Godot 4.7.2, probar orientación en superficies X/Y/Z y caras invertidas, revisar costuras y evaluar en Android con iluminación real.
- Si aparecen costuras, relieve invertido o un aspecto plástico, se descarta o corrige el piloto. No se reemplaza el shader original.
