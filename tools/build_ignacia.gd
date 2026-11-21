extends SceneTree
## Construye a Ignacia (jugadora 2) a partir de la base humana CC0 «Universal Base Characters» de Quaternius
## (esqueleto Unreal/UAL de 65 huesos, mismas animaciones que el resto del juego) y la guarda como GLB.
##   1) Cuerpo con «complexión robusta» (inflado por zonas, siguiendo las normales).
##   2) Ropa generada sobre el cuerpo: polerón rojo burdeo, buzo gris y zapatillas blancas (mallas con los mismos huesos y pesos).
##   3) Pelo largo teñido de burdeo, cejas oscuras, mochila de paramédico (cuerpo rígido en la espalda).
## Las fuentes (no van al repositorio) están en render_src/ignacia_src/. Se usa una vez; se guarda como registro.
## Uso: godot --headless --path . -s res://tools/build_ignacia.gd

const SRC := "res://render_src/ignacia_src/"
const OUT := "res://assets/characters/ignacia/ignacia.glb"
const SKIN_TEX := "T_Superhero_Female_Light_BaseColor.png"

const SHIRT_BONES := ["spine_01", "spine_02", "spine_03", "clavicle_l", "clavicle_r", "upperarm_l", "upperarm_r", "lowerarm_l", "lowerarm_r"]
const PANTS_BONES := ["pelvis", "thigh_l", "thigh_r", "calf_l", "calf_r"]
const SHOE_BONES := ["foot_l", "foot_r", "ball_l", "ball_r"]
## Cuánto se «infla» cada zona (metros, a lo largo de la normal) para dar complexión robusta.
## Cuánto se «infla» (o adelgaza, si es negativo) cada zona, en metros a lo largo de la normal. Ajusta la complexión.
## v2 (Chris: «hazla flaca»): delgada, algo más fina que la base.
const INFLATE := {"spine_01": -0.02, "spine_02": -0.025, "spine_03": -0.025, "pelvis": -0.018, "thigh_l": -0.022, "thigh_r": -0.022,
    "calf_l": -0.012, "calf_r": -0.012, "upperarm_l": -0.012, "upperarm_r": -0.012, "lowerarm_l": -0.006, "lowerarm_r": -0.006,
    "clavicle_l": 0.0, "clavicle_r": 0.0, "neck_01": 0.0, "Head": 0.0}
const COLOR_SHIRT := Color(0.46, 0.09, 0.15)
const COLOR_PANTS := Color(0.42, 0.44, 0.47)
const COLOR_SHOES := Color(0.86, 0.86, 0.84)
const COLOR_HAIR := Color(0.5, 0.1, 0.14)
const COLOR_BAG := Color(0.17, 0.29, 0.22)

var _skel: Skeleton3D
var _skin: Skin


func _init() -> void:
    var base := _load("Superhero_Female_FullBody.gltf")
    _skel = base.find_children("*", "Skeleton3D", true, false)[0]
    var body := _skel.find_child("Superhero_Female", true, false) as MeshInstance3D
    _skin = body.skin
    var arrays := body.mesh.surface_get_arrays(0)
    var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
    var norms: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
    var uvs: PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV]
    var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
    var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
    var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
    var per := bones.size() / verts.size()
    print("cuerpo: ", verts.size(), " vértices, ", per, " influencias, ", indices.size() / 3, " triángulos")

    # --- Inflado por zonas y clasificación de cada vértice por pesos (piel / polerón / buzo / zapatillas).
    var neck_y := _skel.get_bone_global_rest(_skel.find_bone("neck_01")).origin.y
    var hem_y := _skel.get_bone_global_rest(_skel.find_bone("pelvis")).origin.y + 0.1   # largo del polerón
    var vgroup := PackedInt32Array()
    vgroup.resize(verts.size())
    var vtorso := PackedFloat32Array()
    vtorso.resize(verts.size())
    for v in verts.size():
        var group := {"skin": 0.0, "shirt": 0.0, "pants": 0.0, "shoes": 0.0}
        var push := 0.0
        for k in per:
            var w := weights[v * per + k]
            if w <= 0.0:
                continue
            var bname := _bone_name(bones[v * per + k])
            push += w * float(INFLATE.get(bname, 0.0))
            if bname.begins_with("spine_"):
                vtorso[v] += w
            if bname in SHIRT_BONES:
                group["shirt"] += w
            elif bname in PANTS_BONES:
                group["pants"] += w
            elif bname in SHOE_BONES:
                group["shoes"] += w
            else:
                group["skin"] += w
        verts[v] += norms[v] * push
        var best := "skin"
        for key in group:
            if group[key] > group[best]:
                best = key
        vgroup[v] = ["skin", "shirt", "pants", "shoes"].find(best)
    # --- Máscara por triángulo (bits: 1 cuerpo, 2 polerón, 4 buzo, 8 zapatillas). El corte del polerón es un plano horizontal
    # (con un tramo de 5 cm donde se solapan polerón y buzo) y el cuello queda de piel.
    _tri_mask = PackedInt32Array()
    for t in range(0, indices.size(), 3):
        var counts := [0, 0, 0, 0]
        var cy := 0.0
        var cx := 0.0
        var torso := 0.0
        for k in 3:
            var vi := indices[t + k]
            counts[vgroup[vi]] += 1
            cy += verts[vi].y / 3.0
            cx += absf(verts[vi].x) / 3.0
            torso += vtorso[vi] / 3.0
        var mask := 1
        match counts.find(counts.max()):
            1:
                if torso > 0.5:
                    if cy >= hem_y and not (cy > neck_y - 0.02 and cx < 0.14):
                        mask |= 2
                    if cy < hem_y + 0.05:
                        mask |= 4
                else:
                    mask |= 2
            2:
                mask |= 4
            3:
                mask |= 8
        _tri_mask.append(mask)

    # --- Cuerpo inflado (piel) con su textura.
    var skin_mat := _mat(Color.WHITE, 0.85)
    skin_mat.albedo_texture = _shrunk(SRC + SKIN_TEX, 512)
    var parts := _node("Body", _make_mesh(verts, norms, uvs, bones, weights, indices, per, 1, 0.0), skin_mat)
    _skel.add_child(parts)
    # --- Ropa: copia de los triángulos de cada clase, un poco más afuera que el cuerpo.
    _skel.add_child(_node("Shirt", _make_mesh(verts, norms, uvs, bones, weights, indices, per, 2, 0.022), _mat(COLOR_SHIRT, 1.0)))
    _skel.add_child(_node("Pants", _make_mesh(verts, norms, uvs, bones, weights, indices, per, 4, 0.024), _mat(COLOR_PANTS, 1.0)))
    _skel.add_child(_node("Shoes", _make_mesh(verts, norms, uvs, bones, weights, indices, per, 8, 0.03), _mat(COLOR_SHOES, 0.7)))
    # --- Ojos (de la base) y pelo / cejas.
    var eyes := _skel.find_child("Eyes", true, false) as MeshInstance3D
    var old_brows := _skel.find_child("Eyebrows", true, false) as MeshInstance3D
    _skel.remove_child(old_brows)
    old_brows.free()
    _skel.remove_child(body)
    body.free()
    _skel.remove_child(eyes)
    _skel.add_child(_node("Eyes", eyes.mesh, null, true))
    eyes.free()
    for item in [["Hair_Long.gltf", "Hair_Long", COLOR_HAIR, "Hair"], ["Eyebrows_Female.gltf", "Eyebrows_Female", Color(0.2, 0.06, 0.07), "Eyebrows"]]:
        var scene := _load(item[0])
        var mi := scene.find_child(item[1], true, false) as MeshInstance3D
        var hair_skel := scene.find_children("*", "Skeleton3D", true, false)[0] as Skeleton3D
        var mesh := _remap_mesh(mi, hair_skel)
        var mat := mi.mesh.surface_get_material(0).duplicate() as StandardMaterial3D
        mat.albedo_color = item[2]
        mat.albedo_texture = _shrink_tex(mat.albedo_texture, 512)
        mat.normal_texture = null
        mat.normal_enabled = false
        mesh.surface_set_material(0, mat)
        _skel.add_child(_node(item[3], mesh, null, true))
    # --- Mochila de paramédico: cuerpo rígido pegado a la columna (peso 100 % a spine_03).
    _skel.add_child(_backpack())

    var root := Node3D.new()
    root.name = "Ignacia"
    var holder := _skel.get_parent()
    holder.remove_child(_skel)
    root.add_child(_skel)
    _own(root, root)
    var doc := GLTFDocument.new()
    var state := GLTFState.new()
    var err := doc.append_from_scene(root, state)
    print("append: ", error_string(err))
    DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT.get_base_dir()))
    err = doc.write_to_filesystem(state, OUT)
    print("escrito ", OUT, ": ", error_string(err))
    quit(0 if err == OK else 1)


func _load(file: String) -> Node:
    var doc := GLTFDocument.new()
    var state := GLTFState.new()
    var err := doc.append_from_file(ProjectSettings.globalize_path(SRC + file), state)
    if err != OK:
        push_error("no se pudo leer " + file)
        quit(1)
    return doc.generate_scene(state)


func _bone_name(bind: int) -> String:
    var n := _skin.get_bind_name(bind)
    if n == "":
        n = _skel.get_bone_name(_skin.get_bind_bone(bind))
    return n


func _mat(color: Color, rough: float) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = color
    m.roughness = rough
    m.metallic_specular = 0.2
    return m


func _node(node_name: String, mesh: Mesh, mat: Material, keep_materials := false) -> MeshInstance3D:
    var mi := MeshInstance3D.new()
    mi.name = node_name
    mi.mesh = mesh
    if mat != null:
        mesh.surface_set_material(0, mat)
    mi.skin = _skin
    mi.skeleton = NodePath("..")
    return mi


## Copia los triángulos de las clases dadas (índices en 'wanted') con los mismos huesos y pesos.
func _make_mesh(verts: PackedVector3Array, norms: PackedVector3Array, uvs: PackedVector2Array, bones: PackedInt32Array,
        weights: PackedFloat32Array, indices: PackedInt32Array, per: int, bit: int, offset: float) -> ArrayMesh:
    var out_v := PackedVector3Array()
    var out_n := PackedVector3Array()
    var out_uv := PackedVector2Array()
    var out_b := PackedInt32Array()
    var out_w := PackedFloat32Array()
    var out_i := PackedInt32Array()
    var remap := {}
    for t in range(0, indices.size(), 3):
        if (_tri_mask[t / 3] & bit) == 0:
            continue
        for k in 3:
            var vi := indices[t + k]
            if not remap.has(vi):
                remap[vi] = out_v.size()
                out_v.append(verts[vi] + norms[vi] * offset)
                out_n.append(norms[vi])
                out_uv.append(uvs[vi])
                for j in per:
                    out_b.append(bones[vi * per + j])
                    out_w.append(weights[vi * per + j])
            out_i.append(remap[vi])
    var arrays := []
    arrays.resize(Mesh.ARRAY_MAX)
    arrays[Mesh.ARRAY_VERTEX] = out_v
    arrays[Mesh.ARRAY_NORMAL] = out_n
    arrays[Mesh.ARRAY_TEX_UV] = out_uv
    arrays[Mesh.ARRAY_BONES] = out_b
    arrays[Mesh.ARRAY_WEIGHTS] = out_w
    arrays[Mesh.ARRAY_INDEX] = out_i
    var mesh := ArrayMesh.new()
    mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
    return mesh


var _tri_mask := PackedInt32Array()


## Mesh de otro glTF (pelo, cejas) con los índices de hueso traducidos al esqueleto del cuerpo, por nombre.
func _remap_mesh(mi: MeshInstance3D, other_skel: Skeleton3D) -> ArrayMesh:
    var src_skin := mi.skin
    var arrays := mi.mesh.surface_get_arrays(0)
    var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
    var table := {}
    for i in src_skin.get_bind_count():
        var n := src_skin.get_bind_name(i)
        if n == "":
            n = other_skel.get_bone_name(src_skin.get_bind_bone(i))
        for j in _skin.get_bind_count():
            if _bone_name(j) == n:
                table[i] = j
    for i in bones.size():
        bones[i] = int(table.get(bones[i], 0))
    arrays[Mesh.ARRAY_BONES] = bones
    var mesh := ArrayMesh.new()
    mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
    return mesh


func _backpack() -> MeshInstance3D:
    var spine := _skel.get_bone_global_rest(_skel.find_bone("spine_03")).origin
    var st := SurfaceTool.new()
    st.begin(Mesh.PRIMITIVE_TRIANGLES)
    var box := BoxMesh.new()
    box.size = Vector3(0.30, 0.36, 0.13)
    st.append_from(box, 0, Transform3D(Basis.IDENTITY, Vector3(0.0, spine.y - 0.09, spine.z - 0.2)))
    var mesh := st.commit()
    var arrays := mesh.surface_get_arrays(0)
    var n: int = (arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array).size()
    var b := PackedInt32Array()
    var w := PackedFloat32Array()
    var bind_index := 0
    for i in _skin.get_bind_count():
        if _bone_name(i) == "spine_03":
            bind_index = i
    for i in n:
        b.append_array([bind_index, 0, 0, 0])
        w.append_array([1.0, 0.0, 0.0, 0.0])
    arrays[Mesh.ARRAY_BONES] = b
    arrays[Mesh.ARRAY_WEIGHTS] = w
    var out := ArrayMesh.new()
    out.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
    out.surface_set_material(0, _mat(COLOR_BAG, 0.9))
    return _node("Backpack", out, null, true)


func _shrunk(path: String, size: int) -> ImageTexture:
    var img := Image.load_from_file(ProjectSettings.globalize_path(path))
    img.resize(size, size, Image.INTERPOLATE_LANCZOS)
    return ImageTexture.create_from_image(img)


func _shrink_tex(tex: Texture2D, size: int) -> Texture2D:
    if tex == null:
        return null
    var img := tex.get_image()
    if img.is_compressed():
        img.decompress()
    img.resize(size, size, Image.INTERPOLATE_LANCZOS)
    return ImageTexture.create_from_image(img)


func _own(node: Node, root: Node) -> void:
    for c in node.get_children():
        c.owner = root
        _own(c, root)
