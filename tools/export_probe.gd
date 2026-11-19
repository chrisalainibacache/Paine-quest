extends SceneTree
## Comprueba el PAQUETE EXPORTADO (el que corre en el teléfono): que las notas, los
## objetos examinables, las pistas de Leo y los textos de introducción lleguen con su
## texto. En el proyecto abierto desde el editor todo funciona; el export puede perder
## datos (pasó con la conversión de recursos a binario). Sale con error si falta algo.
## Uso: godot --headless --path . --export-pack Android /tmp/p.pck
##      godot --headless --main-pack /tmp/p.pck -s /ruta/a/tools/export_probe.gd
func _init() -> void:
    _run.call_deferred()


func _run() -> void:
    var problems: Array = []
    var notes := 0
    var examines := 0
    var hints := 0
    var intros := 0
    for dir in ["res://levels/station/", "res://levels/tracks/", "res://levels/buin/"]:
        for f in DirAccess.get_files_at(dir):
            if not (f.ends_with(".tscn") or f.ends_with(".tscn.remap")):
                continue
            var room := (load(dir + f.trim_suffix(".remap")) as PackedScene).instantiate()
            root.add_child(room)
            for n in room.find_children("*", "Interactable", true, false):
                var cls: String = n.get_script().resource_path.get_file()
                if cls.begins_with("note"):
                    notes += 1
                    var doc = n.get("document")
                    if doc == null or (doc.get("pages") as PackedStringArray).is_empty():
                        problems.append("nota vacía: %s/%s" % [f, n.name])
                elif cls.begins_with("examine"):
                    examines += 1
                    if (n.get("lines") as PackedStringArray).is_empty():
                        problems.append("examinar vacío: %s/%s" % [f, n.name])
            for h in room.find_children("*", "Marker3D", true, false):
                if h.get_script() != null and h.get_script().resource_path.ends_with("leo_hint.gd"):
                    hints += 1
                    if (h.get("lines") as PackedStringArray).is_empty():
                        problems.append("pista de Leo vacía: %s/%s" % [f, h.name])
            if f.begins_with("platform"):
                intros += 1
                if (room.get("intro_lines") as PackedStringArray).is_empty():
                    problems.append("introducción vacía: %s" % f)
            room.queue_free()
    print("PAQUETE: %d notas, %d objetos examinables, %d pistas de Leo, %d introducciones" % [notes, examines, hints, intros])
    for p in problems:
        print("  ✗ ", p)
    print("RESULTADO PAQUETE: ", "OK" if problems.is_empty() and notes > 0 else "FALLA (%d)" % problems.size())
    quit(0 if problems.is_empty() and notes > 0 else 1)
