# Generadores de escenas

Las salas y algunas escenas de UI se escriben con estos scripts de Python (más
legibles y repetibles que editar `.tscn` a mano). Cada script sobrescribe su `.tscn`.

```
python3 tools/level_gen/waiting_room.py      # una sala
for f in platform waiting_room ticket_office service_corridor storeroom south_platform; do
  python3 tools/level_gen/$f.py; done        # todas las salas
```

- `puzzle_lab.py`: genera `levels/test/puzzle_lab.tscn`, una sala segura de puzzles fuera del recorrido; está incluida en `regenerar_todo.sh` y en `tests/levels_test.gd`.
- `tscn.py`: escritor mínimo de `.tscn` (format=3).
- `roomkit.py`: kit para salas (`Kit`: muros, puertas, ítems, notas, infectados, cámaras,
  apariciones, calcomanías con `decal`). Las salas nuevas deben usarlo.
- `platform.py` y `waiting_room.py` son anteriores al kit (usan `tscn.py` directo).
- Después de regenerar: correr `tests/levels_test.gd` (puertas, apariciones, cámaras sin
  huecos, capítulo completable) y revisar con `tools/capture_rooms.gd`.


## Sala segura de puzzles P12

La sala no forma parte de ningún capítulo. Se puede abrir con el lanzador de prueba
(sin escribir ni modificar el guardado habitual):

```bash
godot --path . --script res://tests/puzzle_lab_runner.gd
```

El lanzador inicia una partida temporal en memoria y carga la sala. Para regenerarla:

```bash
python3 tools/level_gen/puzzle_lab.py
```
