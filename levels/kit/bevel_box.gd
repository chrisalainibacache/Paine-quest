@tool
extends RefCounted
## Caja con las aristas biseladas y la luz suavizada (modo Moderno). Una arista de
## 90° perfecta no atrapa la luz y se ve "tosca"; con un bisel de unos centímetros
## recibe un brillo fino y el objeto parece de verdad. Las mallas se reutilizan por
## tamaño. La colisión sigue siendo la caja (no cambia nada para las cámaras).

## Bisel máximo en metros y fracción de la dimensión más chica.
const MAX_RADIUS := 0.035
const MIN_DIMENSION := 0.06
const FRACTION := 0.2

static var _cache := {}


## Malla biselada de ese tamaño (o una caja normal si es demasiado delgada).
static func build(size: Vector3) -> Mesh:
    var smallest := minf(size.x, minf(size.y, size.z))
    if smallest < MIN_DIMENSION:
        var plain := BoxMesh.new()
        plain.size = size
        return plain
    var radius := minf(MAX_RADIUS, smallest * FRACTION)
    var key := "%d_%d_%d_%d" % [roundi(size.x * 1000.0), roundi(size.y * 1000.0), roundi(size.z * 1000.0), roundi(radius * 1000.0)]
    if _cache.has(key):
        return _cache[key]
    var mesh := _make(size * 0.5, radius)
    _cache[key] = mesh
    return mesh


static func _make(half: Vector3, r: float) -> ArrayMesh:
    var inner := half - Vector3(r, r, r)
    var vertices := PackedVector3Array()
    var normals := PackedVector3Array()
    var uvs := PackedVector2Array()
    var indices := PackedInt32Array()
    var axes := [Vector3.RIGHT, Vector3.UP, Vector3.BACK]
    # Caras principales: 6 rectángulos achicados por el bisel.
    for axis in 3:
        var u: int = (axis + 1) % 3
        var v: int = (axis + 2) % 3
        for sign in [-1.0, 1.0]:
            var n: Vector3 = axes[axis] * sign
            var corners: Array = []
            for su in [-1.0, 1.0]:
                for sv in [-1.0, 1.0]:
                    var p: Vector3 = n * half[axis] + axes[u] * (su * inner[u]) + axes[v] * (sv * inner[v])
                    corners.append(p)
            _quad(vertices, normals, uvs, indices, [corners[0], corners[1], corners[3], corners[2]], [n, n, n, n])
    # Franjas de las 12 aristas: la normal pasa de una cara a la otra (se ve redondeado).
    for c in 3:
        var a: int = (c + 1) % 3
        var b: int = (c + 2) % 3
        for sa in [-1.0, 1.0]:
            for sb in [-1.0, 1.0]:
                var na: Vector3 = axes[a] * sa
                var nb: Vector3 = axes[b] * sb
                var p1: Vector3 = na * half[a] + axes[b] * (sb * inner[b])
                var p2: Vector3 = nb * half[b] + axes[a] * (sa * inner[a])
                var along: Vector3 = axes[c] * inner[c]
                _quad(vertices, normals, uvs, indices, [p1 - along, p1 + along, p2 + along, p2 - along], [na, na, nb, nb])
    # Esquinas: un triángulo con las tres normales.
    for sx in [-1.0, 1.0]:
        for sy in [-1.0, 1.0]:
            for sz in [-1.0, 1.0]:
                var px := Vector3(sx * half.x, sy * inner.y, sz * inner.z)
                var py := Vector3(sx * inner.x, sy * half.y, sz * inner.z)
                var pz := Vector3(sx * inner.x, sy * inner.y, sz * half.z)
                _quad(vertices, normals, uvs, indices, [px, py, pz, pz], [Vector3(sx, 0, 0), Vector3(0, sy, 0), Vector3(0, 0, sz), Vector3(0, 0, sz)], true)
    var arrays := []
    arrays.resize(Mesh.ARRAY_MAX)
    arrays[Mesh.ARRAY_VERTEX] = vertices
    arrays[Mesh.ARRAY_NORMAL] = normals
    arrays[Mesh.ARRAY_TEX_UV] = uvs
    arrays[Mesh.ARRAY_INDEX] = indices
    var mesh := ArrayMesh.new()
    mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
    return mesh


## Agrega un cuadrilátero (o un triángulo si `triangle`) orientado hacia afuera
## (Godot usa el sentido horario como cara frontal).
static func _quad(vertices: PackedVector3Array, normals: PackedVector3Array, uvs: PackedVector2Array, indices: PackedInt32Array,
        points: Array, point_normals: Array, triangle := false) -> void:
    var base := vertices.size()
    var count := 3 if triangle else 4
    for i in count:
        vertices.append(points[i])
        normals.append((point_normals[i] as Vector3).normalized())
        uvs.append(Vector2.ZERO)
    var outward := Vector3.ZERO
    for i in count:
        outward += point_normals[i]
    var facing: Vector3 = (points[1] - points[0]).cross(points[2] - points[0])
    var flip := facing.dot(outward) > 0.0
    var order: Array = [0, 1, 2] if not triangle else [0, 1, 2]
    if flip:
        order = [0, 2, 1]
    for i in order:
        indices.append(base + i)
    if not triangle:
        var second: Array = [0, 2, 3] if not flip else [0, 3, 2]
        for i in second:
            indices.append(base + i)
