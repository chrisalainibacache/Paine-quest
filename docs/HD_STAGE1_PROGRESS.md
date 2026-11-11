# HD Stage 1 — prototype de shader y texturas

## Estado
- Rama experimental: `feature/hd-remaster-stage1-textures`.
- Aislada de `main`; no se han reemplazado texturas, escenas ni materiales de producción.
- El shader base `ps1_surface.gdshader` permanece intacto.
- `ps1_surface_hd_pilot.gdshader` es una variante de prueba, no aprobada para producción.

## Resultados comprobados
- Dos ejecuciones recientes del workflow completaron con Godot 4.7.2, importación, validador de shader, comparativos y captura de cámaras reales.
- Una ejecución anterior falló en validación de dimensiones/preservación; las dos posteriores finalizaron correctamente.
- El artefacto contiene capturas de las cámaras Oeste y Este a 1280x720.
- El candidato 2x es un cambio sutil, no una reconstrucción artística HD.
- Los mapas normales derivados de luminancia son diagnósticos, no mapas físicos ni aptos para producción.
- La imagen de orientación del shader no demuestra por sí sola las seis orientaciones; falta mejorar su composición.

## Auditoría completa de entorno
- Se revisaron las 14 texturas de `assets/environment/textures/`; todas son 256x256.
- El suelo dominante de la estación usa `paving.png`, ausente del primer piloto.
- La auditoría calcula diferencias medias RGB entre bordes opuestos y ordena los materiales por mayor diferencia. Es un indicador diagnóstico, sin umbral de aprobación calibrado.
- Hallazgo: `paving.png` presenta X=0.0678 e Y=0.1224; `gravel.png` X=0.0580 e Y=0.0625. No debemos ampliarlas ni repetirlas sin revisar continuidad visual.
- Se documentó el orden de materiales en `HD_STAGE1_MATERIAL_PRIORITY.md`.

## Próximas puertas
1. Probar visualmente la continuidad de `paving.png` en el suelo real, conservando adoquines y juntas.
2. Preparar una comparación A/B del material del pavimento desde las cámaras Oeste/Este.
3. Crear candidatos artísticos para pavimento, mampostería y revoque solo después de resolver la continuidad.
4. Mejorar el encuadre del validador de normales; no activar normales en producción.
5. Revisar visualmente, validar Compatibility y probar Android antes de promover cualquier recurso.

## Decisión de integración
- Ninguna textura candidata se integra todavía en assets del juego.
- No se cambia geometría, cámara, proporciones de personajes, paleta ni interfaz móvil.
- La aprobación visual humana y la prueba Android son obligatorias.
## Revisión visual de repetición — ejecución 80
- El workflow ejecutado en el commit `cc75dc5623cf0a30cf5c2c5715024c7bb24d9d38` terminó correctamente y el artefacto ahora incluye `environment_texture_tiling_review.png`.
- Se inspeccionó la repetición 3x3 de `paving.png`: la textura conserva los adoquines y juntas, pero la repetición del motivo se reconoce en mosaico; no se considera aprobada como mejora HD ni se corrige con un simple escalado.
- La captura real de cámara Oeste confirma que el pavimento ocupa gran parte del encuadre y que la lectura de sus juntas es importante bajo la iluminación nocturna. La captura es baseline; no contiene un material candidato.
- Decisión: mantener `paving.png` y `paving_floor.tres` intactos. Próximo paso técnico: preparar A/B en la escena real usando una variante aislada del material y comparar ambas cámaras, sin sobrescribir recursos originales.
