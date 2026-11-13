extends SceneTree
## Auditoría de cámaras: para cada punto caminable de cada sala calcula con qué
## cámaras podría verse a Cony y marca los puntos donde se "pierde":
##   TAPADA   = un muro, vagón o mueble sólido tapa su cuerpo (pecho y cabeza).
##   FUERA    = queda fuera del cuadro (o pegada al borde, bajo los botones).
##   CHICA    = se ve más chica que MIN_HEIGHT de la pantalla.
## También revisa cada punto de aparición (spawn), que es donde más se pierde.
## Uso: godot --headless --path . -s res://tools/audit_cameras.gd -- [sala ...] [--verbose]
## Sale con código 1 si hay problemas en los spawns o más de MAX_BAD_PERCENT de puntos malos.

const Check := preload("res://tools/camera_check.gd")
const STEP := 0.25
const MAX_BAD_PERCENT := 4.0
const DIRS := ["res://levels/station/", "res://levels/tracks/", "res://levels/buin/"]

var verbose := false
var total_bad_spawns := 0
var worst_percent := 0.0
var unreachable := 0
var total_bad_cameras := 0


func _init() -> void:
    _run.call_deferred()


func _run() -> void:
    var wanted: Array = []
    for arg in OS.get_cmdline_user_args():
        if arg == "--verbose":
            verbose = true
        else:
            wanted.append(arg)
    for dir in DIRS:
        for file in DirAccess.get_files_at(dir):
            if file.ends_with(".tscn") and (wanted.is_empty() or file.get_basename() in wanted):
                await _audit_room(dir + file)
    print("\nRESUMEN: spawns malos=%d, interactuables inalcanzables=%d, cámaras pegadas=%d, peor sala=%.1f%% de puntos malos" % [total_bad_spawns, unreachable, total_bad_cameras, worst_percent])
    quit(1 if total_bad_spawns > 0 or unreachable > 0 or total_bad_cameras > 0 or worst_percent > MAX_BAD_PERCENT else 0)


func _audit_room(path: String) -> void:
    var room := (load(path) as PackedScene).instantiate() as Room
    root.add_child(room)
    for i in 4:
        await physics_frame
    Check.prepare_visual_blockers(room)
    for i in 2:
        await physics_frame
    var space := room.get_world_3d().direct_space_state
    var zones: Array = room.find_children("*", "CameraZone", true, false)
    var samples: Array = Check.reachable(Check.walkable_points(space, Check.SEARCH_BOUNDS, STEP), Check.spawn_positions(room), STEP)
    var stats := {"n": 0, "tapada": 0, "fuera": 0, "chica": 0, "sin_zona": 0}
    var offenders: Array = []
    for p: Vector3 in samples:
        var candidates := _zones_at(zones, p)
        if candidates.is_empty():
            stats["sin_zona"] += 1
            continue
        stats["n"] += 1
        var worst := ""
        for zone: CameraZone in candidates:
            var why := Check.problem(space, zone.get_camera().global_transform, zone.get_camera().fov, p)
            if why != "":
                worst = "%s (%s)" % [why, zone.name]
                break
        if worst != "":
            offenders.append([p, worst])
            var key := worst.get_slice(" ", 0).to_lower()
            stats[key] = int(stats.get(key, 0)) + 1
    # Cámaras con algo pegado al lente.
    for zone: CameraZone in zones:
        var cam := zone.get_camera()
        var near := Check.near_rays(space, cam.global_transform, cam.fov)
        # Pegada de verdad = más de la mitad de la imagen (columnas cercanas son normales en cámaras fijas).
        if near > 72:
            print("   ✗ CÁMARA %s tiene algo pegado al lente (%d de 144 rayos a menos de %.1f m)" % [zone.name, near, Check.NEAR_DISTANCE])
            total_bad_cameras += 1
    var bad := offenders.size()
    var percent := 100.0 * bad / maxf(stats["n"], 1)
    worst_percent = maxf(worst_percent, percent)
    print("%-18s puntos=%4d  malos=%3d (%4.1f%%)  tapada=%d fuera=%d chica=%d  sin_zona=%d" % [
        path.get_file().get_basename(), stats["n"], bad, percent,
        stats["tapada"], stats["fuera"], stats["chica"], stats["sin_zona"]])
    if verbose or percent > MAX_BAD_PERCENT:
        for o in offenders.slice(0, 80):
            print("      %s  %s" % [_fmt(o[0]), o[1]])
    # Alcanzable: puertas, notas, ítems y demás deben poder usarse caminando.
    for node in room.find_children("*", "Interactable", true, false):
        var spot := (node as Node3D).global_position
        var near := INF
        for p: Vector3 in samples:
            near = minf(near, Vector2(p.x, p.z).distance_to(Vector2(spot.x, spot.z)))
        if near > (node as Interactable).reach * 0.95:
            unreachable += 1
            print("   ✗ NO ALCANZABLE %s %s (a %.1f m del piso caminable, alcance %.1f)" % [node.name, _fmt(spot), near, (node as Interactable).reach])
    # Puntos de aparición.
    var spawns := room.get_node_or_null("Spawns")
    if spawns:
        for spawn: Node3D in spawns.get_children():
            var p := spawn.global_position
            var zs := _zones_at(zones, p)
            if zs.is_empty():
                var nearest := room._nearest_camera_zone(p, zones)
                zs = [nearest] if nearest else []
            var problem := ""
            for zone: CameraZone in zs:
                var why := Check.problem(space, zone.get_camera().global_transform, zone.get_camera().fov, p)
                if why != "":
                    problem = "%s con la cámara %s" % [why, zone.name]
            if problem != "":
                total_bad_spawns += 1
                print("   ✗ SPAWN %s %s: %s" % [spawn.name, _fmt(p), problem])
    room.free()
    await physics_frame


func _fmt(p: Vector3) -> String:
    return "(%.1f, %.1f, %.1f)" % [p.x, p.y, p.z]


func _zone_bounds(zones: Array) -> AABB:
    var box := AABB()
    var first := true
    for zone: CameraZone in zones:
        var shape := zone.get_node("Zone") as CollisionShape3D
        var size := (shape.shape as BoxShape3D).size
        var aabb := AABB(shape.global_position - size * 0.5, size)
        box = aabb if first else box.merge(aabb)
        first = false
    return box


func _zones_at(zones: Array, p: Vector3) -> Array:
    var found: Array = []
    for zone: CameraZone in zones:
        if zone.get_camera() == null:
            continue
        var shape := zone.get_node("Zone") as CollisionShape3D
        var local := shape.global_transform.affine_inverse() * (p + Vector3.UP * 0.9)
        var half := (shape.shape as BoxShape3D).size * 0.5
        if absf(local.x) <= half.x and absf(local.y) <= half.y and absf(local.z) <= half.z:
            found.append(zone)
    return found
