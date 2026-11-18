extends SceneTree
## Mapa de arriba de una sala en texto: "." caminable, "#" sólido (alto), "o" objeto bajo, " " vacío.
## Sirve para colocar detalle fuera del camino. Uso: godot --headless -s res://tools/room_map.gd -- sala
const Check := preload("res://tools/camera_check.gd")
const DIRS := ["res://levels/station/", "res://levels/tracks/", "res://levels/buin/"]


func _init() -> void:
    _run.call_deferred()


func _run() -> void:
    for room_name in OS.get_cmdline_user_args():
        var path := ""
        for dir in DIRS:
            if ResourceLoader.exists(dir + room_name + ".tscn"):
                path = dir + room_name + ".tscn"
        var room := (load(path) as PackedScene).instantiate() as Room
        root.add_child(room)
        for i in 4:
            await physics_frame
        var space := room.get_world_3d().direct_space_state
        var walk := {}
        for p: Vector3 in Check.walkable_points(space, Check.SEARCH_BOUNDS, 0.5):
            walk[Vector2i(roundi(p.x * 2.0), roundi(p.z * 2.0))] = true
        var min_x := 999
        var max_x := -999
        var min_z := 999
        var max_z := -999
        var rows := {}
        for gz in range(-15, 16):
            var line := ""
            for gx in range(-25, 26):
                var from := Vector3(gx * 0.5, 6.0, gz * 0.5)
                var q := PhysicsRayQueryParameters3D.create(from, from + Vector3.DOWN * 9.0)
                q.collision_mask = 1 | 16
                var hit := space.intersect_ray(q)
                var ch := " "
                if walk.has(Vector2i(gx, gz)):
                    ch = "."
                elif not hit.is_empty():
                    ch = "#" if hit.position.y > 0.9 else ("o" if hit.position.y > 0.15 else " ")
                line += ch
            rows[gz] = line
        print("=== ", room_name, " (columna 0 = x -12.5; cada carácter 0.5 m; fila 0 = z -7.5)")
        print("    x: -12.5 .... 0 .... +12.5")
        for gz in range(-15, 16):
            if rows[gz].strip_edges() != "":
                print("%5.1f %s" % [gz * 0.5, rows[gz]])
        room.queue_free()
        await physics_frame
    quit()
