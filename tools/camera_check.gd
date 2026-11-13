extends RefCounted
## Medición compartida por tools/audit_cameras.gd y tools/plan_cameras.gd:
## ¿se ve bien a Cony parada en un punto del piso desde una cámara?

## Pantalla más angosta que soportamos (16:9). Con keep_height, las más anchas ven más.
const ASPECT := 16.0 / 9.0
## Zona segura (coordenadas de pantalla -1..1): Cony entera dentro de este rectángulo.
const SAFE_X := 0.88
const SAFE_Y_TOP := 0.86
const SAFE_Y_BOTTOM := -0.80
## Altura mínima de Cony en pantalla (fracción del alto) para no "perderla".
const MIN_HEIGHT := 0.15
## Capa de colisión temporal para los adornos "no sólidos" (vigas, rieles, techos
## de madera...): no bloquean a Cony pero sí tapan la vista. Solo la usan los rayos
## de cámara de estas herramientas.
const VISUAL_LAYER := 16
const SIGHT_MASK := 1 | VISUAL_LAYER
## Un rayo que choca a menos de esto del lente cuenta como "pegado a la cámara".
const NEAR_DISTANCE := 1.8
## Máximo de rayos (de 144) pegados al lente: más que eso, algo tapa media pantalla.
const MAX_NEAR_RAYS := 16


## Límites en los que se busca piso (ninguna sala los pasa). La cuadrícula va
## anclada a múltiplos de `step`: planificador y auditoría miden los mismos puntos.
const SEARCH_BOUNDS := AABB(Vector3(-12.5, 0.0, -7.5), Vector3(25.0, 3.0, 15.0))


## Puntos del piso donde cabe Cony dentro de `bounds` (piso plano cerca de y=0, sin chocar).
static func walkable_points(space: PhysicsDirectSpaceState3D, bounds: AABB, step: float) -> Array:
    var capsule := CapsuleShape3D.new()
    capsule.radius = 0.28
    capsule.height = 1.5
    var points: Array = []
    var x := ceilf(bounds.position.x / step) * step
    while x <= bounds.end.x:
        var z := ceilf(bounds.position.z / step) * step
        while z <= bounds.end.z:
            # El rayo baja desde 1.9 m: por debajo de cualquier cielo de sala.
            var from := Vector3(x, 1.9, z)
            var q := PhysicsRayQueryParameters3D.create(from, from + Vector3.DOWN * 4.0)
            q.collision_mask = 1
            var hit := space.intersect_ray(q)
            if not hit.is_empty() and hit.normal.y > 0.9 and hit.position.y > -0.15 and hit.position.y < 0.3:
                var ground: Vector3 = hit.position
                var s := PhysicsShapeQueryParameters3D.new()
                s.shape = capsule
                s.transform = Transform3D(Basis.IDENTITY, ground + Vector3.UP * 0.9)
                s.collision_mask = 1
                if space.intersect_shape(s, 1).is_empty():
                    points.append(ground)
            z += step
        x += step
    return points


## Solo la parte geométrica (sin rayos): "" si entra en cuadro y se ve de buen tamaño.
static func frame_problem(cam_xf: Transform3D, fov: float, ground: Vector3) -> String:
    var to_local := cam_xf.affine_inverse()
    var t := tan(deg_to_rad(fov) * 0.5)
    var feet := to_local * (ground + Vector3.UP * 0.05)
    var chest := to_local * (ground + Vector3.UP * 1.0)
    var head := to_local * (ground + Vector3.UP * 1.65)
    for v: Vector3 in [feet, chest, head]:
        if v.z > -0.15:
            return "FUERA"
        var nx := v.x / (-v.z * t * ASPECT)
        var ny := v.y / (-v.z * t)
        if absf(nx) > SAFE_X or ny > SAFE_Y_TOP or ny < SAFE_Y_BOTTOM:
            return "FUERA"
    var height := (head.y / (-head.z * t) - feet.y / (-feet.z * t)) * 0.5
    if height < MIN_HEIGHT:
        return "CHICA"
    return ""


## ¿Algo sólido tapa el pecho y la cabeza de Cony vistos desde la cámara?
static func occluded(space: PhysicsDirectSpaceState3D, cam_pos: Vector3, ground: Vector3) -> bool:
    var blocked := 0
    for offset in [1.0, 1.55]:
        var target: Vector3 = ground + Vector3.UP * offset
        var q := PhysicsRayQueryParameters3D.create(cam_pos, target)
        q.collision_mask = SIGHT_MASK
        var hit := space.intersect_ray(q)
        if not hit.is_empty() and cam_pos.distance_to(hit.position) < cam_pos.distance_to(target) - 0.3:
            blocked += 1
    return blocked >= 2


## "" si Cony se ve bien; si no, el motivo (FUERA, CHICA o TAPADA).
static func problem(space: PhysicsDirectSpaceState3D, cam_xf: Transform3D, fov: float, ground: Vector3) -> String:
    var frame := frame_problem(cam_xf, fov, ground)
    if frame != "":
        return frame
    return "TAPADA" if occluded(space, cam_xf.origin, ground) else ""


## Se queda solo con los puntos a los que Cony puede llegar caminando desde los
## puntos de aparición (la oficina cerrada de un galpón, p. ej., no cuenta).
static func reachable(points: Array, seeds: Array, step: float) -> Array:
    var grid := {}
    for p: Vector3 in points:
        grid[Vector2i(roundi(p.x / step), roundi(p.z / step))] = p
    var seen := {}
    var queue: Array[Vector2i] = []
    for seed_pos: Vector3 in seeds:
        var best := Vector2i.ZERO
        var best_d := INF
        for key: Vector2i in grid:
            var d := Vector2(key.x * step, key.y * step).distance_to(Vector2(seed_pos.x, seed_pos.z))
            if d < best_d:
                best_d = d
                best = key
        if best_d < step * 2.5 and not seen.has(best):
            seen[best] = true
            queue.append(best)
    while not queue.is_empty():
        var cur: Vector2i = queue.pop_back()
        for dx in [-1, 0, 1]:
            for dz in [-1, 0, 1]:
                var nxt := Vector2i(cur.x + dx, cur.y + dz)
                if grid.has(nxt) and not seen.has(nxt):
                    seen[nxt] = true
                    queue.append(nxt)
    var out: Array = []
    for key: Vector2i in seen:
        out.append(grid[key])
    return out


static func spawn_positions(room: Node3D) -> Array:
    var seeds: Array = []
    var spawns := room.get_node_or_null("Spawns")
    if spawns:
        for spawn: Node3D in spawns.get_children():
            seeds.append(spawn.global_position)
    return seeds


## Rayos de la pantalla que no chocan con nada (la cámara "ve el vacío"). Mismas
## reglas que tests/test_case.gd, y en 16:9 y 20:9 (los celulares son más anchos).
static func void_rays(space: PhysicsDirectSpaceState3D, cam_xf: Transform3D, fov: float, far: float) -> int:
    var tan_y := tan(deg_to_rad(fov) * 0.5)
    var misses := 0
    for aspect in [16.0 / 9.0, 20.0 / 9.0]:
        for gx in 16:
            for gy in 9:
                var ndc := Vector2((gx + 0.5) / 16.0, (gy + 0.5) / 9.0) * 2.0 - Vector2.ONE
                var local := Vector3(ndc.x * tan_y * aspect, -ndc.y * tan_y, -1.0).normalized()
                var direction := (cam_xf.basis * local).normalized()
                if direction.y > 0.15:
                    continue
                var q := PhysicsRayQueryParameters3D.create(cam_xf.origin, cam_xf.origin + direction * far)
                q.collision_mask = 1
                if space.intersect_ray(q).is_empty():
                    misses += 1
    return misses


## Activa la colisión de los adornos no sólidos en la capa VISUAL_LAYER (los de
## KitBlock con solid = false). Llamar antes de medir y esperar un cuadro de física.
static func prepare_visual_blockers(room: Node) -> void:
    for node in room.find_children("*", "KitBlock", true, false):
        var block := node as KitBlock
        if block.solid:
            continue
        block.collision_layer = VISUAL_LAYER
        block.collision_mask = 0
        for i in block.get_child_count(true):
            var child := block.get_child(i, true)
            if child is CollisionShape3D:
                (child as CollisionShape3D).disabled = false


## Cantidad de rayos de la pantalla (16:9) que chocan a menos de NEAR_DISTANCE del
## lente: una viga, un muro o un vagón pegados a la cámara que tapan media imagen.
static func near_rays(space: PhysicsDirectSpaceState3D, cam_xf: Transform3D, fov: float) -> int:
    var tan_y := tan(deg_to_rad(fov) * 0.5)
    var near := 0
    for gx in 16:
        for gy in 9:
            var ndc := Vector2((gx + 0.5) / 16.0, (gy + 0.5) / 9.0) * 2.0 - Vector2.ONE
            var local := Vector3(ndc.x * tan_y * (16.0 / 9.0), -ndc.y * tan_y, -1.0).normalized()
            var direction := (cam_xf.basis * local).normalized()
            var q := PhysicsRayQueryParameters3D.create(cam_xf.origin, cam_xf.origin + direction * NEAR_DISTANCE)
            q.collision_mask = SIGHT_MASK
            if not space.intersect_ray(q).is_empty():
                near += 1
    return near
