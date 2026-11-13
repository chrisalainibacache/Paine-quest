extends SceneTree
## Planificador de cámaras fijas: para cada sala parte el piso en zonas (1 a 9) y
## busca la mejor cámara de cada una (posición, altura, FOV) para que Cony se vea
## entera, de buen tamaño y sin que nada sólido la tape en cualquier punto.
## Guarda el resultado en tools/level_gen/cameras.json; los generadores (tscn.py)
## lo aplican solos al regenerar cada sala.
## Uso: godot --headless --path . -s res://tools/plan_cameras.gd -- sala [sala ...]

const Check := preload("res://tools/camera_check.gd")
const DIRS := ["res://levels/station/", "res://levels/tracks/", "res://levels/buin/"]
const OUT := "res://tools/level_gen/cameras.json"
const STEP := 0.25
## Cantidad de zonas (en X, en Z) que se prueba, de menos a más cámaras.
const LAYOUTS := [[1, 1], [2, 1], [1, 2], [3, 1], [2, 2], [4, 1], [3, 2], [4, 2], [5, 2], [3, 3], [4, 3], [5, 3], [6, 2], [6, 3]]
const HEIGHTS := [1.8, 2.1, 2.4, 2.8, 3.2, 3.7, 4.3, 4.9, 5.6, 6.4]
const FOVS := [56.0, 62.0, 68.0]
## Las zonas se solapan un poco para que el corte de cámara no parpadee en el borde.
const OVERLAP := 0.5
## Margen de las zonas del borde: cubre hasta el último paso de Cony junto al muro.
const EDGE := 1.0
## Se acepta la primera distribución con la peor zona ≥ 96 % y media ≥ 98 %.
const TARGET_WORST := 0.96
const TARGET_MEAN := 0.98
const MAX_SAMPLES := 260
const CELL := 1.0
## Alcance de las cámaras (el mismo que escribe camera_plan.py).
const FAR := 60.0


func _init() -> void:
    _run.call_deferred()


func _run() -> void:
    var plans := {}
    if FileAccess.file_exists(OUT):
        plans = JSON.parse_string(FileAccess.get_file_as_string(OUT))
    for room_name in OS.get_cmdline_user_args():
        var path := ""
        for dir in DIRS:
            if ResourceLoader.exists(dir + room_name + ".tscn"):
                path = dir + room_name + ".tscn"
        if path == "":
            print("no existe la sala ", room_name)
            continue
        var plan: Array = await _plan_room(path)
        plans[room_name] = plan
        var file := FileAccess.open(OUT, FileAccess.WRITE)
        file.store_string(JSON.stringify(plans, "  "))
        file.close()
    quit()


func _plan_room(path: String) -> Array:
    var room := (load(path) as PackedScene).instantiate() as Room
    root.add_child(room)
    for i in 4:
        await physics_frame
    Check.prepare_visual_blockers(room)
    for i in 2:
        await physics_frame
    var space := room.get_world_3d().direct_space_state
    _spawns = Check.spawn_positions(room)
    var points: Array = Check.reachable(Check.walkable_points(space, Check.SEARCH_BOUNDS, STEP), Check.spawn_positions(room), STEP)
    var area := _points_rect(points)
    var best_plan: Array = []
    var best_score := -1.0
    var started := Time.get_ticks_msec()
    for layout: Array in LAYOUTS:
        var plan := _plan_layout(space, points, area, layout[0], layout[1])
        var worst := 1.0
        var total := 0.0
        for z: Dictionary in plan:
            worst = minf(worst, z["coverage"])
            total += z["coverage"] * z["points"]
        var all_points := 0
        for z: Dictionary in plan:
            all_points += z["points"]
        var mean := total / maxf(all_points, 1)
        # Menos cámaras es mejor si cubren casi igual de bien (cada corte distrae).
        var score := mean - 0.02 * plan.size() + 0.03 * worst
        print("  %s  %dx%d: %d cámaras, peor zona %.1f%%, media %.1f%%" % [path.get_file().get_basename(), layout[0], layout[1], plan.size(), worst * 100.0, mean * 100.0])
        if score > best_score:
            best_score = score
            best_plan = plan
        if worst >= TARGET_WORST and mean >= TARGET_MEAN:
            best_plan = plan
            break
    print("%s: %d cámaras (%.0f s)" % [path.get_file().get_basename(), best_plan.size(), (Time.get_ticks_msec() - started) / 1000.0])
    room.free()
    await physics_frame
    return best_plan


var _spawns: Array = []


func _plan_layout(space: PhysicsDirectSpaceState3D, points: Array, area: Rect2, nx: int, nz: int) -> Array:
    var plan: Array = []
    var index := 1
    for iz in nz:
        for ix in nx:
            var cell := Rect2(area.position + Vector2(area.size.x * ix / nx, area.size.y * iz / nz), Vector2(area.size.x / nx, area.size.y / nz))
            var extended := cell.grow_individual(OVERLAP if ix > 0 else EDGE, OVERLAP if iz > 0 else EDGE, OVERLAP if ix < nx - 1 else EDGE, OVERLAP if iz < nz - 1 else EDGE)
            var inside: Array = []
            for p: Vector3 in points:
                # Borde incluido (igual que la zona real: Area3D y la auditoría).
                if p.x >= extended.position.x - 0.01 and p.x <= extended.end.x + 0.01 \
                        and p.z >= extended.position.y - 0.01 and p.z <= extended.end.y + 0.01:
                    inside.append(p)
            if inside.size() < 3:
                continue
            # Los puntos de aparición (donde llega Cony al cambiar de sala) cuentan ×8.
            var weighted: Array = inside.duplicate()
            for s: Vector3 in _spawns:
                if s.x >= extended.position.x and s.x <= extended.end.x and s.z >= extended.position.y and s.z <= extended.end.y:
                    for k in 8:
                        weighted.append(s)
            var best := _best_camera(space, weighted, area)
            # La búsqueda usa una muestra; el resultado se mide con todos los puntos.
            var pos := Vector3(best["cam_pos"][0], best["cam_pos"][1], best["cam_pos"][2])
            var tgt := Vector3(best["target"][0], best["target"][1], best["target"][2])
            var xf := Transform3D(Basis.looking_at(tgt - pos, Vector3.UP), pos)
            var good := 0
            for p: Vector3 in inside:
                if Check.problem(space, xf, best["fov"], p) == "":
                    good += 1
            best["coverage"] = float(good) / inside.size()
            best["name"] = "Cam%d" % index
            best["zone_center"] = [extended.get_center().x, 1.5, extended.get_center().y]
            best["zone_size"] = [extended.size.x, 3.0, extended.size.y]
            best["points"] = inside.size()
            plan.append(best)
            index += 1
    return plan


func _best_camera(space: PhysicsDirectSpaceState3D, points: Array, area: Rect2) -> Dictionary:
    var samples: Array = points
    if points.size() > MAX_SAMPLES:
        samples = []
        var stride := float(points.size()) / MAX_SAMPLES
        for i in MAX_SAMPLES:
            samples.append(points[int(i * stride)])
    var rect := _points_rect(points)
    var center := rect.get_center()
    var target := Vector3(center.x, 0.6, center.y)
    var region := area.grow(1.2)
    var sphere := SphereShape3D.new()
    sphere.radius = 0.35
    var best := {"cam_pos": [0, 3, 0], "target": [target.x, target.y, target.z], "fov": 62.0, "coverage": -1.0}
    var candidates: Array = []
    var x := region.position.x
    while x <= region.end.x:
        var z := region.position.y
        while z <= region.end.y:
            var flat := Vector2(x, z).distance_to(center)
            if flat >= 2.2 and flat <= 16.0:
                for h: float in HEIGHTS:
                    var pos := Vector3(x, h, z)
                    var pitch := rad_to_deg(atan2(h - 0.6, flat))
                    if pitch < 8.0 or pitch > 52.0:
                        continue
                    if not _free_space(space, pos, sphere):
                        continue
                    var xf := Transform3D(Basis.looking_at(target - pos, Vector3.UP), pos)
                    for fov: float in FOVS:
                        var ok: Array = []
                        for p: Vector3 in samples:
                            if Check.frame_problem(xf, fov, p) == "":
                                ok.append(p)
                        var frame_cov := float(ok.size()) / samples.size()
                        if frame_cov < 0.9 or frame_cov < best["coverage"] - 0.03:
                            continue
                        var good := 0
                        for p: Vector3 in ok:
                            if not Check.occluded(space, pos, p):
                                good += 1
                        var coverage := float(good) / samples.size()
                        # Prefiere ángulos de cine: picado de ~30°, FOV normal, cerca de un muro (no en
                        # medio de la sala) y ni muy lejos de Cony.
                        var edge := minf(minf(x - area.position.x, area.end.x - x), minf(z - area.position.y, area.end.y - z))
                        var score := coverage - 0.012 * absf(pitch - 30.0) / 15.0 - 0.01 * maxf(pitch - 45.0, 0.0) / 15.0 - 0.01 * (fov - 56.0) / 12.0 \
                            - 0.01 * clampf(flat - 8.0, 0.0, 8.0) / 8.0 - 0.012 * clampf(edge, 0.0, 3.5) / 3.5
                        if coverage >= 0.8:
                            candidates.append([score, pos, fov, coverage])
            z += CELL
        x += CELL
    # La mejor que además no ve el vacío (ningún rayo sin choque al borde de la sala).
    candidates.sort_custom(func(a: Array, b: Array) -> bool: return a[0] > b[0])
    for i in mini(candidates.size(), 250):
        var c: Array = candidates[i]
        var xf := Transform3D(Basis.looking_at(target - c[1], Vector3.UP), c[1])
        if Check.void_rays(space, xf, c[2], FAR) == 0 and Check.near_rays(space, xf, c[2]) <= Check.MAX_NEAR_RAYS:
            var pos: Vector3 = c[1]
            return {"cam_pos": [pos.x, pos.y, pos.z], "target": [target.x, target.y, target.z], "fov": c[2], "coverage": c[3]}
    # Ninguna cumple todo: la menos mala sin vacío, y si no, la mejor a secas.
    for relaxed in [1, 2]:
        for i in mini(candidates.size(), 400):
            var c: Array = candidates[i]
            var xf := Transform3D(Basis.looking_at(target - c[1], Vector3.UP), c[1])
            if relaxed == 2 or Check.void_rays(space, xf, c[2], FAR) == 0:
                var pos: Vector3 = c[1]
                return {"cam_pos": [pos.x, pos.y, pos.z], "target": [target.x, target.y, target.z], "fov": c[2], "coverage": c[3]}
    return best


## ¿La cámara cabe en ese lugar (no dentro de un muro ni pegada al cielo)?
func _free_space(space: PhysicsDirectSpaceState3D, pos: Vector3, sphere: SphereShape3D) -> bool:
    var s := PhysicsShapeQueryParameters3D.new()
    s.shape = sphere
    s.transform = Transform3D(Basis.IDENTITY, pos)
    s.collision_mask = Check.SIGHT_MASK
    if not space.intersect_shape(s, 1).is_empty():
        return false
    var up := PhysicsRayQueryParameters3D.create(pos, pos + Vector3.UP * 0.3)
    up.collision_mask = Check.SIGHT_MASK
    return space.intersect_ray(up).is_empty()


func _points_rect(points: Array) -> Rect2:
    var rect := Rect2(Vector2(points[0].x, points[0].z), Vector2.ZERO)
    for p: Vector3 in points:
        rect = rect.expand(Vector2(p.x, p.z))
    return rect


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
