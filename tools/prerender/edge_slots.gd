extends SceneTree
## Busca los "bordes" de cada sala (piso caminable pegado a un muro) y los guarda en
## render_src/slots/<sala>.json. room_details.py reparte ahí los objetos de detalle.
## Uso: godot --headless --path . -s res://tools/prerender/edge_slots.gd -- sala [sala...]
const Check := preload("res://tools/camera_check.gd")
const DIRS := ["res://levels/station/", "res://levels/tracks/", "res://levels/buin/"]
const STEP := 0.5


func _init() -> void:
    _run.call_deferred()


func _run() -> void:
    DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://render_src/slots"))
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
        for p: Vector3 in Check.walkable_points(space, Check.SEARCH_BOUNDS, STEP):
            walk[Vector2i(roundi(p.x / STEP), roundi(p.z / STEP))] = p.y
        # Lo que hay que dejar libre: puertas, ítems, notas, apariciones y pistas de Leo.
        var keep_out: Array = []
        for group in ["Interactables", "Spawns"]:
            var node := room.get_node_or_null(group)
            if node:
                for child in node.get_children():
                    if child is Node3D:
                        keep_out.append([child.global_position.x, child.global_position.z])
        for hint in room.find_children("*", "Marker3D", true, false):
            keep_out.append([hint.global_position.x, hint.global_position.z])
        var slots: Array = []
        var tall := {}
        for cell: Vector2i in walk:
            var y: float = walk[cell]
            for dir: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
                var neighbor: Vector2i = cell + dir
                if walk.has(neighbor):
                    continue
                # ¿Hay un muro sólido al lado? (rayo horizontal corto hacia el vecino)
                var from := Vector3(cell.x * STEP, y + 0.9, cell.y * STEP)
                var to := from + Vector3(dir.x, 0, dir.y) * (STEP + 0.1)
                var hit_query := PhysicsRayQueryParameters3D.create(from, to)
                hit_query.collision_mask = 1 | Check.VISUAL_LAYER
                if space.intersect_ray(hit_query).is_empty():
                    continue
                slots.append({"x": cell.x * STEP + dir.x * 0.2, "y": y, "z": cell.y * STEP + dir.y * 0.2,
                    "yaw": atan2(-dir.x, -dir.y)})
        var file := FileAccess.open("res://render_src/slots/%s.json" % room_name, FileAccess.WRITE)
        file.store_string(JSON.stringify({"slots": slots, "keep_out": keep_out}))
        file.close()
        print("%s: %d bordes, %d zonas libres" % [room_name, slots.size(), keep_out.size()])
        room.queue_free()
        await physics_frame
    quit()
