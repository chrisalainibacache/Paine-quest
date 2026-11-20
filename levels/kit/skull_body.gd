extends RefCounted
## Cuerpo de Skull armado con piezas simples (≈2,6 m): encorvado, brazos hasta el suelo con garras,
## cráneo grande y púas en la espalda. Para la sombra de la cinemática (SHADOWS_ONLY) y los avistamientos.
## Uso: var skull: Node3D = preload("res://levels/kit/skull_body.gd").build()
static func _mat(c: Color, rough := 1.0) -> StandardMaterial3D:
    var m := StandardMaterial3D.new(); m.albedo_color = c; m.roughness = rough; return m

static func _part(parent: Node3D, mesh: Mesh, pos: Vector3, rot_deg: Vector3, mat: Material) -> MeshInstance3D:
    var mi := MeshInstance3D.new(); mi.mesh = mesh; mi.position = pos; mi.rotation_degrees = rot_deg
    mi.material_override = mat; parent.add_child(mi); return mi

static func _capsule(r: float, h: float) -> CapsuleMesh:
    var c := CapsuleMesh.new(); c.radius = r; c.height = h; c.radial_segments = 8; c.rings = 4; return c

static func _cone(r: float, h: float) -> CylinderMesh:
    var c := CylinderMesh.new(); c.top_radius = 0.0; c.bottom_radius = r; c.height = h; c.radial_segments = 6; return c

static func build() -> Node3D:
    var root := Node3D.new(); root.name = "Skull"
    var skin := _mat(Color(0.16, 0.15, 0.14))
    var bone := _mat(Color(0.78, 0.74, 0.64))
    var dark := _mat(Color(0.02, 0.02, 0.02))
    # Piernas
    for s in [-1.0, 1.0]:
        _part(root, _capsule(0.11, 1.35), Vector3(0.2 * s, 0.66, 0.05), Vector3(-6, 0, 0), skin)
    # Torso encorvado y pecho ancho
    _part(root, _capsule(0.27, 1.45), Vector3(0.0, 1.78, 0.22), Vector3(34, 0, 0), skin)
    # Costillas (barras de hueso al frente)
    for i in 4:
        var r := _part(root, _capsule(0.03, 0.62), Vector3(0.0, 1.62 + i * 0.13, 0.5 - i * 0.03), Vector3(0, 0, 90), bone)
    # Hombros y brazos larguísimos hasta bajo las rodillas
    for s in [-1.0, 1.0]:
        _part(root, _capsule(0.1, 0.62), Vector3(0.36 * s, 2.12, 0.36), Vector3(0, 0, 90 + 12 * s), skin)
        _part(root, _capsule(0.065, 2.35), Vector3(0.56 * s, 1.15, 0.5), Vector3(-6, 0, 4 * s), skin)
        # Garras
        for k in 3:
            _part(root, _cone(0.025, 0.7), Vector3((0.58 + (k - 1) * 0.06) * s, 0.0, 0.6), Vector3(172, 0, 8 * (k - 1)), bone)
    # Cabeza: cráneo grande, mandíbula, cuencas
    var sk := SphereMesh.new(); sk.radius = 0.2; sk.height = 0.78; sk.radial_segments = 10; sk.rings = 6
    _part(root, sk, Vector3(0.0, 2.5, 0.78), Vector3(40, 0, 0), bone)
    var jaw := BoxMesh.new(); jaw.size = Vector3(0.26, 0.2, 0.3)
    _part(root, jaw, Vector3(0.0, 2.2, 0.98), Vector3(40, 0, 0), bone)
    var eye := SphereMesh.new(); eye.radius = 0.075; eye.height = 0.15
    for s in [-1.0, 1.0]:
        _part(root, eye, Vector3(0.085 * s, 2.52, 1.0), Vector3.ZERO, dark)
    var nose := _cone(0.035, 0.1)
    _part(root, nose, Vector3(0.0, 2.4, 1.07), Vector3(-80, 0, 0), dark)
    # Púas en la espalda
    for i in 5:
        _part(root, _cone(0.05, 0.55), Vector3(0.0, 2.35 - i * 0.3, -0.18 - i * 0.05), Vector3(-110 + i * 4, 0, 0), bone)
    return root
