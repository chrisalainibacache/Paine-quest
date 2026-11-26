import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
from roomkit import *

ROOM = "res://levels/test/puzzle_lab.tscn"
k = Kit("PuzzleLab", "Laboratorio de puzzles", ambience="storeroom")
k.env((0.035, 0.03, 0.025), (0.62, 0.57, 0.48), 0.95, (0.08, 0.07, 0.06), 0.015)
k.shell(-7.0, 7.0, -5.0, 5.0, 3.2, floor="concrete_floor", wall="plaster_wall", ceiling="concrete_wall")

# Muebles bajos: la sala es segura y mantiene las líneas de cámara despejadas.
k.block("BenchA", "Furniture", (0.0, 0.34, 0.0), (1.8, 0.68, 0.65), "wood")
k.block("BenchB", "Furniture", (3.0, 0.34, -1.0), (1.2, 0.68, 0.65), "wood")
k.block("LowCrate", "Furniture", (3.8, 0.25, 2.4), (0.7, 0.5, 0.7), "planks")
k.label("RoomTitle", "Details", (0.0, 2.55, -4.7), "SALA SEGURA · PRUEBAS P12", 24, (0.92, 0.82, 0.62))

# Cerradura numérica 0712.
k.code_lock("CodeLock", (-5.7, 0.0, -3.5), "test_code_lock", unlock_id="test_code_gate")
k.door("CodeGate", (6.2, 0.0, -3.5), ROOM, "after_code", key="gate_key",
       lock_id="test_code_gate", marker="CERRADURA DE CÓDIGO")

# Tablero de dos fusibles de 10 A.
k.fuse_box("FuseBoard", (-5.7, 0.0, 0.0), "test_fuse_box", unlock_id="test_fuse_gate")
k.pickup("FuseA", (-3.8, 0.05, 0.8), "fuse_10a")
k.pickup("FuseB", (-2.6, 0.05, 0.8), "fuse_10a")
k.door("FuseGate", (6.2, 0.0, 0.0), ROOM, "after_fuse", key="gate_key",
       lock_id="test_fuse_gate", marker="TABLERO DE FUSIBLES")

# Tres palancas en orden norte → oeste → este.
k.lever_sequence("LeverController", (0.0, 0.0, -2.6), "test_lever_sequence")
k.lever("LeverNorth", (-1.6, 0.0, -1.3), "test_lever_sequence", "north", unlock_id="test_lever_gate")
k.lever("LeverWest", (0.0, 0.0, -1.3), "test_lever_sequence", "west", unlock_id="test_lever_gate")
k.lever("LeverEast", (1.6, 0.0, -1.3), "test_lever_sequence", "east", unlock_id="test_lever_gate")
k.door("LeverGate", (6.2, 0.0, 3.5), ROOM, "after_levers", key="gate_key",
       lock_id="test_lever_gate", marker="SECUENCIA DE PALANCAS")

# Cajón registrable y dos componentes para probar COMBINAR.
k.container("SearchDrawer", (-5.7, 0.0, 3.5), "test_container", item_ids=("sushi",), counts=(1,))
k.pickup("Crank", (3.0, 0.05, 3.5), "manivela")
k.pickup("RustedAxle", (4.2, 0.05, 3.5), "eje_oxidado")

# Atajo de un solo lado: primero se abre desde el oeste; después se puede volver.
k.one_way_door("ShortcutOrigin", (-5.8, 0.0, 1.5), ROOM, "shortcut_return",
               "test_shortcut", origin=True, marker="ATAJO")
k.one_way_door("ShortcutReverse", (-5.8, 0.0, -1.5), ROOM, "shortcut_origin",
               "test_shortcut", origin=False, marker="ATAJO")

k.examine("Instructions", (0.0, 0.0, 4.35), [
    "Sala segura para probar las mecánicas P12. No hay enemigos ni forma de perder salud.",
    "Código de prueba: 0712. Recoge dos fusibles, instala ambos y prueba las tres palancas.",
    "Registra el cajón una vez y combina la manivela con el eje oxidado desde la mochila."
], reach=1.4)
k.light("CeilingLight", "Lights", (0.0, 2.85, 0.0), (1.0, 0.82, 0.62), 1.8, 9.0)
k.camera("WholeRoom", (0.0, 1.4, 0.0), (13.5, 2.8, 9.5), (0.0, 2.55, 4.4), (0.0, 0.3, -1.2), fov=70)
k.spawn("start", (2.0, 0.05, 4.0), (-1, 0))
k.spawn("after_code", (5.0, 0.05, -3.5), (-1, 0))
k.spawn("after_fuse", (5.0, 0.05, 0.0), (-1, 0))
k.spawn("after_levers", (5.0, 0.05, 3.5), (-1, 0))
k.spawn("shortcut_return", (-4.5, 0.05, -3.5), (1, 0))
k.spawn("shortcut_origin", (-4.5, 0.05, 3.5), (1, 0))

out = os.path.join(REPO, "levels", "test", "puzzle_lab.tscn")
os.makedirs(os.path.dirname(out), exist_ok=True)
k.save(out)
print("puzzle test room ok")
