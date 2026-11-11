# Herramienta de conversión (se usó una vez; queda como registro).
# Proyecto temporal con InfectedCityMan.fbx y sus PNG (Male City Zombie, OpenGameArt, CC0):
#   godot --headless -s convert_infected_city.gd -- <salida.glb>
# Después: python3 tools/tint_infected_city.py sobre las texturas extraídas.
extends SceneTree
## Convierte InfectedCityMan.fbx (24k triángulos, texturas 2K) en un GLB liviano
## para el teléfono: menos triángulos (LOD), texturas 1024/512, huesos con
## nombres Mixamo (mixamorig_*) para el bone map del proyecto.
const TARGET_TRIS := [1600, 4200, 900]

func tex(path: String, size: int) -> ImageTexture:
    var img := Image.load_from_file(path)
    img.resize(size, size, Image.INTERPOLATE_LANCZOS)
    img.generate_mipmaps()
    return ImageTexture.create_from_image(img)

func _init() -> void:
    var root: Node = (load("res://InfectedCityMan.fbx") as PackedScene).instantiate()
    for ap in root.find_children("*", "AnimationPlayer", true, false):
        ap.get_parent().remove_child(ap)
        ap.free()
    var sk := root.find_children("*", "Skeleton3D", true, false)[0] as Skeleton3D
    # Fuera la cámara del FBX y los nodos de hueso duplicados (BoneAttachment).
    for n in root.find_children("*", "", true, false):
        if is_instance_valid(n) and (n is Camera3D or n is BoneAttachment3D):
            n.get_parent().remove_child(n)
            n.free()
    for i in sk.get_bone_count():
        sk.set_bone_name(i, sk.get_bone_name(i).replace("CityDeadOutfit_", "mixamorig_"))
    var m := root.find_children("*", "MeshInstance3D", true, false)[0] as MeshInstance3D
    # La piel une por nombre: también se renombran sus huesos.
    if m.skin:
        m.skin = m.skin.duplicate()
        for b in m.skin.get_bind_count():
            m.skin.set_bind_name(b, String(m.skin.get_bind_name(b)).replace("CityDeadOutfit_", "mixamorig_"))
    var src := m.mesh as ArrayMesh
    var im := ImporterMesh.new()
    for i in src.get_surface_count():
        im.add_surface(Mesh.PRIMITIVE_TRIANGLES, src.surface_get_arrays(i), [], {}, null, "", src.surface_get_format(i) & Mesh.ARRAY_FLAG_USE_8_BONE_WEIGHTS)
    im.generate_lods(25.0, 60.0, [])
    var out := ArrayMesh.new()
    var outfit := StandardMaterial3D.new()
    outfit.resource_name = "Outfit"
    outfit.albedo_texture = tex("InfectedCityMan_City_Man_Infected_Outfit1_BaseColor.png", 1024)
    outfit.normal_enabled = true
    outfit.normal_texture = tex("InfectedCityMan_City_Man_Infected_Outfit1_Normal.png", 512)
    outfit.roughness_texture = tex("InfectedCityMan_City_Man_Infected_Outfit1_OcclusionRoughnessMetallic.png", 256)
    outfit.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_GREEN
    var body := StandardMaterial3D.new()
    body.resource_name = "Body"
    body.albedo_texture = tex("InfectedCityMan_City_Infected_Man_Body1_BaseColor.png", 1024)
    body.normal_enabled = true
    body.normal_texture = tex("InfectedCityMan_City_Infected_Man_Body1_Normal.png", 512)
    body.roughness_texture = tex("InfectedCityMan_City_Infected_Man_Body1_OcclusionRoughnessMetallic.png", 256)
    body.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_GREEN
    var mats := [outfit, body, body]
    var total := 0
    for i in im.get_surface_count():
        var arrays := im.get_surface_arrays(i)
        var best: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
        for l in im.get_surface_lod_count(i):
            var idx := im.get_surface_lod_indices(i, l)
            if abs(idx.size() / 3 - TARGET_TRIS[i]) < abs(best.size() / 3 - TARGET_TRIS[i]):
                best = idx
        arrays[Mesh.ARRAY_INDEX] = best
        total += best.size() / 3
        print("superficie ", i, ": ", best.size() / 3, " tris (lods ", im.get_surface_lod_count(i), ")")
        out.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays, [], {}, im.get_surface_format(i) & Mesh.ARRAY_FLAG_USE_8_BONE_WEIGHTS)
        out.surface_set_material(i, mats[i])
    print("total ", total)
    m.mesh = out
    for s in m.get_surface_override_material_count():
        m.set_surface_override_material(s, null)
    var doc := GLTFDocument.new()
    var state := GLTFState.new()
    print("append ", doc.append_from_scene(root, state))
    print("write ", doc.write_to_filesystem(state, OS.get_cmdline_user_args()[0]))
    quit()
