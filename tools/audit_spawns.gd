extends SceneTree
## Auditoría de llegadas: para cada punto de aparición (spawn) mira hacia ATRÁS de donde mira Isabella.
## Si hay un muro a menos de 1,6 m y ninguna puerta cerca, parece que «viene de atravesar una pared».
## Uso: godot --headless --path . -s res://tools/audit_spawns.gd
const DIRS := ["res://levels/station/", "res://levels/tracks/", "res://levels/buin/"]
const MAX_WALL := 1.6
const DOOR_NEAR := 2.4


func _init() -> void:
    _run.call_deferred()


func _run() -> void:
    var bad := 0
    for dir in DIRS:
        for file in DirAccess.get_files_at(dir):
            if not file.ends_with(".tscn"):
                continue
            var room := (load(dir + file) as PackedScene).instantiate() as Room
            root.add_child(room)
            for i in 4:
                await physics_frame
            var space := room.get_world_3d().direct_space_state
            var spawns := room.get_node_or_null("Spawns")
            if spawns == null:
                room.free()
                continue
            for spawn: Node3D in spawns.get_children():
                var facing := -spawn.global_transform.basis.z
                facing.y = 0.0
                var back := -facing.normalized()
                var from := spawn.global_position + Vector3.UP * 0.9
                var q := PhysicsRayQueryParameters3D.create(from, from + back * 6.0)
                q.collision_mask = 1
                var hit := space.intersect_ray(q)
                var dist := 99.0 if hit.is_empty() else from.distance_to(hit.position)
                if dist > MAX_WALL:
                    continue
                var door_near := false
                for node in room.find_children("*", "Door", true, false):
                    if (node as Node3D).global_position.distance_to(spawn.global_position) < DOOR_NEAR:
                        door_near = true
                var frame_near := false
                for n in room.get_children():
                    pass
                # ¿hay un marco de puerta (nodo con «Door»/«Frame» en el nombre) cerca?
                for n in room.find_children("*Frame*", "", true, false) + room.find_children("*Service*", "", true, false) + room.find_children("*Portal*", "", true, false):
                    if n is Node3D and (n as Node3D).global_position.distance_to(spawn.global_position) < DOOR_NEAR + 1.0:
                        frame_near = true
                if not frame_near:
                    bad += 1
                    print("  ✗ %s / %s: muro a %.1f m detrás, sin marco de puerta cerca" % [file.get_basename(), spawn.name, dist])
            room.free()
            await physics_frame
    print("\nRESUMEN: llegadas sin puerta visible = %d" % bad)
    quit()
