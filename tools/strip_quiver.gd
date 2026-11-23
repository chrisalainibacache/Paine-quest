extends SceneTree
## Quita el carcaj, las flechas y la correa de Isabella (el modelo Mixamo «Erika Archer»): están dentro de la malla de la ropa como
## piezas de geometría sueltas, así que se detectan por componentes conectados y se borran las que cumplen:
##   · carcaj y flechas: pieza entera detrás de la espalda (z máx < BACK_Z) y por encima de MIN_Y;
##   · correa del carcaj: pieza mediana que cruza el torso de adelante hacia atrás (rango z grande, y del pecho).
## Lee el GLB tal cual y lo reescribe. Uso: godot --headless --path . -s res://tools/strip_quiver.gd -- <origen.glb> <destino.glb> [min_y]

const BACK_Z := -0.05
var min_y := 1.1


func _find(p: Array, x: int) -> int:
    while p[x] != x:
        p[x] = p[p[x]]
        x = p[x]
    return x


func _init() -> void:
    var args := OS.get_cmdline_user_args()
    if args.size() > 2:
        min_y = float(args[2])
    var doc := GLTFDocument.new()
    var state := GLTFState.new()
    var src := ProjectSettings.globalize_path(args[0]) if args[0].begins_with("res://") else args[0]
    if doc.append_from_file(src, state) != OK:
        push_error("no se pudo leer " + src)
        quit(1)
        return
    var root := doc.generate_scene(state)
    var removed_total := 0
    for mi: MeshInstance3D in root.find_children("*", "MeshInstance3D", true, false):
        var arrays := mi.mesh.surface_get_arrays(0)
        var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
        var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
        # Componentes conectados (vértices soldados por posición).
        var weld := {}
        var parent: Array = []
        var vid := PackedInt32Array()
        vid.resize(verts.size())
        for i in verts.size():
            var key := Vector3i((verts[i] * 2000.0).round())
            if not weld.has(key):
                weld[key] = parent.size()
                parent.append(parent.size())
            vid[i] = weld[key]
        for t in range(0, indices.size(), 3):
            var a := _find(parent, vid[indices[t]])
            parent[_find(parent, vid[indices[t + 1]])] = a
            parent[_find(parent, vid[indices[t + 2]])] = a
        var boxes := {}
        for t in range(0, indices.size(), 3):
            var r := _find(parent, vid[indices[t]])
            var c := (verts[indices[t]] + verts[indices[t + 1]] + verts[indices[t + 2]]) / 3.0
            if not boxes.has(r):
                boxes[r] = {"n": 0, "min": c, "max": c}
            var b: Dictionary = boxes[r]
            b["n"] += 1
            b["min"] = Vector3(minf(b["min"].x, c.x), minf(b["min"].y, c.y), minf(b["min"].z, c.z))
            b["max"] = Vector3(maxf(b["max"].x, c.x), maxf(b["max"].y, c.y), maxf(b["max"].z, c.z))
        var drop := {}
        for r in boxes:
            if _is_quiver(boxes[r]):
                drop[r] = true
        var kept := PackedInt32Array()
        var removed := 0
        for t in range(0, indices.size(), 3):
            if drop.has(_find(parent, vid[indices[t]])):
                removed += 1
            else:
                kept.append_array([indices[t], indices[t + 1], indices[t + 2]])
        if removed == 0:
            continue
        arrays[Mesh.ARRAY_INDEX] = kept
        var mesh := ArrayMesh.new()
        mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
        mesh.surface_set_material(0, mi.mesh.surface_get_material(0))
        mi.mesh = mesh
        removed_total += removed
        print(mi.name, ": ", removed, " triángulos quitados (", drop.size(), " piezas) de ", indices.size() / 3)
    var out := ProjectSettings.globalize_path(args[1]) if args[1].begins_with("res://") else args[1]
    var export_state := GLTFState.new()
    doc.append_from_scene(root, export_state)
    var err := doc.write_to_filesystem(export_state, out)
    print("total quitado: ", removed_total, " -> ", out, " (", error_string(err), ")")
    quit(0 if err == OK else 1)


func _is_quiver(b: Dictionary) -> bool:
    var lo: Vector3 = b["min"]
    var hi: Vector3 = b["max"]
    if hi.z < BACK_Z and lo.y > min_y:
        return true                                           # carcaj y flechas, detrás de la espalda
    var strap: bool = b["n"] > 120 and b["n"] < 320 and lo.y > 1.15 and hi.y < 1.56 and hi.z - lo.z > 0.3 and hi.x - lo.x < 0.34
    return strap                                              # correa que cruza el torso
