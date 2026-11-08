# Herramienta de conversión de assets (se usó una vez; se guarda como registro).
# Se ejecuta en un proyecto temporal junto al archivo original, por ejemplo:
#   godot --headless -s convert_character.gd -- <origen> <destino>
# Los originales (FBX de 20 MB, texturas de 2048 px) no se suben al repositorio.
extends SceneTree
# Convierte cony.fbx (2048 px, 20 MB) en cony.glb con texturas PS1 pequeñas.
func shrink(tex: Texture2D, size: int) -> ImageTexture:
    var img := tex.get_image()
    if img.is_compressed():
        img.decompress()
    img.resize(size, size, Image.INTERPOLATE_LANCZOS)
    return ImageTexture.create_from_image(img)

func _init():
    var root: Node = (load("res://cony.fbx") as PackedScene).instantiate()
    for ap in root.find_children("*", "AnimationPlayer", true, false):
        ap.get_parent().remove_child(ap)
        ap.free()
    for m: MeshInstance3D in root.find_children("*", "MeshInstance3D", true, false):
        for s in m.mesh.get_surface_count():
            var src := m.get_active_material(s) as BaseMaterial3D
            var mat := StandardMaterial3D.new()
            mat.resource_name = src.resource_name if src else m.name
            if src and src.albedo_texture:
                var big := "Body" in m.name or "Eyelashes" in m.name
                mat.albedo_texture = shrink(src.albedo_texture, 512 if big else 256)
                mat.albedo_color = src.albedo_color
                mat.transparency = src.transparency
            mat.roughness = 1.0
            mat.metallic_specular = 0.2
            m.mesh.surface_set_material(s, mat)
            m.set_surface_override_material(s, null)
    var doc := GLTFDocument.new()
    var state := GLTFState.new()
    var err := doc.append_from_scene(root, state)
    print("append ", err)
    err = doc.write_to_filesystem(state, "res://out_cony.glb")
    print("write ", err)
    quit()
