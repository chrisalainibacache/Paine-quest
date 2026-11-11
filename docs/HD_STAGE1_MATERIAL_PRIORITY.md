# HD Stage 1 — prioridad de materiales del escenario real

## Evidencia revisada
La escena `levels/station/platform.tscn` y los recursos `levels/kit/materials/*.tres` se inspeccionaron en la rama experimental. El artefacto de GitHub Actions del 11-11-2026 contiene capturas reales de las cámaras Oeste y Este, además de las comparaciones aisladas de textura y normales.

## Orden recomendado para el andén de Paine

1. **Pavimento del andén — `paving.png` / `paving_floor.tres`.** Es el suelo dominante en ambos encuadres y no estaba incluido en el primer lote HD. Prioridad máxima: preservar tamaño, forma y distribución de adoquines/juntas; no sustituir por concreto.
2. **Mampostería antigua — `bricks_old.png` / `old_bricks_wall.tres`.** Visible en el muro de contención. La textura es piedra irregular, no ladrillo regular. Preservar siluetas y juntas.
3. **Revoque — `plaster.png` / `plaster_wall.tres`.** Visible en la fachada cálida. Mejorar grano y desgaste con moderación, manteniendo la paleta.
4. **Baldosas — `tiles.png` / `tiles_wall.tres`.** Franja inferior de la fachada, visible en primer plano.
5. **Madera y metal — `wood.png`, `planks.png`, `metal.png`, `rust.png`.** Bancas, postes, marcos y elementos ferroviarios; requieren lectura de material sin brillos plásticos.
6. **Grava y seguridad — `gravel.png` y el material `safety_yellow.tres`.** Importantes para la vía y borde de seguridad; conservar contraste funcional.

## Qué cubría el piloto anterior
- `concrete.png`: sí se usa en materiales del kit, pero no es el material del suelo principal del andén.
- `bricks_old.png`: sí se usa en el muro de contención.
- `asphalt_cracked.png`: se usa en `asphalt.tres`, pero no aparece como material dominante en el andén principal capturado.
- Por tanto, el piloto anterior no cubría el material de mayor superficie visual: `paving.png`.

## Decisión técnica
- Ampliar la auditoría automatizada a las 14 texturas del directorio de entorno.
- No generar candidatos 2x indiscriminadamente ni cambiar los recursos de producción.
- El siguiente lote artístico debe comenzar por `paving.png`, `bricks_old.png` y `plaster.png`, usando las capturas Oeste/Este como referencia de escala y luz.
- Crear comparaciones A/B dentro de la escena real antes de aceptar cualquier textura. Los cubos aislados sirven para diagnóstico técnico, no para aprobar el resultado en el juego.

## Criterios que no cambian
Geometría, encuadres, arquitectura reconocible de la estación, paleta, proporciones y UI permanecen intactos. Toda sustitución debe ser reversible y pasar Godot 4.7.2, Compatibility renderer y prueba Android.
