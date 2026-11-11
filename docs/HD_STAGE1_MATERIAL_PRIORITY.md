# HD Stage 1 — prioridad de materiales del escenario real

## Evidencia revisada
La escena `levels/station/platform.tscn` y los recursos `levels/kit/materials/*.tres` se inspeccionaron en la rama experimental. El artefacto de GitHub Actions contiene capturas reales de las cámaras Oeste y Este.

## Orden recomendado para el andén de Paine

1. **Pavimento del andén — `paving.png` / `paving_floor.tres`.** Es el suelo dominante en ambos encuadres y no estaba incluido en el primer lote HD.
2. **Mampostería antigua — `bricks_old.png` / `old_bricks_wall.tres`.** Visible en el muro de contención. Es piedra irregular, no ladrillo regular.
3. **Revoque — `plaster.png` / `plaster_wall.tres`.** Fachada cálida.
4. **Baldosas — `tiles.png` / `tiles_wall.tres`.** Franja inferior de la fachada.
5. **Madera y metal — `wood.png`, `planks.png`, `metal.png`, `rust.png`.**
6. **Grava y seguridad — `gravel.png` y `safety_yellow.tres`.**

## Hallazgo crítico: continuidad de texturas
La auditoría de las 14 texturas encontró que todas tienen 256x256. La diferencia media RGB entre bordes opuestos (0..1) es un indicador diagnóstico de continuidad, no una prueba absoluta de costura visible.

- `paving.png`: X=0.0678, Y=0.1224. Es el mayor valor observado; requiere resolver continuidad antes de crear o aprobar una versión repetible.
- `gravel.png`: X=0.0580, Y=0.0625.
- `planks.png`: X=0.0131, Y=0.0452.
- `roof_tiles.png`: X=0.0094, Y=0.0460.
- `bricks_old.png`: X=0.0389, Y=0.0384.

No se fijó un umbral automático de aprobación porque aún no está calibrado contra inspección visual en el motor. El informe ordena ahora los materiales por su mayor diferencia entre bordes para decidir dónde inspeccionar primero.

## Qué cubría el piloto anterior
- `concrete.png`: se usa en materiales del kit, pero no es el suelo principal del andén.
- `bricks_old.png`: sí se usa en el muro de contención.
- `asphalt_cracked.png`: se usa en `asphalt.tres`, pero no domina la escena principal.
- El primer piloto omitió el material de mayor superficie visual: `paving.png`.

## Decisión técnica
- No ampliar ni aplicar microdetalle a `paving.png` hasta evaluar su repetición en escena y resolver bordes sin deformar adoquines ni juntas.
- Crear primero una prueba de continuidad visual de pavimento con desplazamiento/teselado controlado y comparación dentro de la escena real.
- Después crear candidatos artísticos de `paving.png`, `bricks_old.png` y `plaster.png`.
- Comparar A/B desde cámaras Oeste/Este con la misma geometría, luz y escala.

## Criterios que no cambian
Geometría, encuadres, arquitectura reconocible, paleta, proporciones y UI permanecen intactos. Toda sustitución debe ser reversible y pasar Godot 4.7.2, Compatibility renderer y prueba Android.
