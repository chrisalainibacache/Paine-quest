# Herramienta de conversión de assets (se usó una vez; se guarda como registro).
# Se ejecuta en un proyecto temporal junto a cat_quaternius.glb.
extends SceneTree
# Gato Quaternius (CC0) -> Leo: pelaje gris, nombres de animación cortos.
func _init():
    var n: Node = (load("res://cat_quaternius.glb") as PackedScene).instantiate()
    var ap: AnimationPlayer = n.find_children("*", "AnimationPlayer", true, false)[0]
    var lib := ap.get_animation_library(&"")
    for a in lib.get_animation_list():
        var short := String(a).get_slice("|", String(a).get_slice_count("|") - 1)
        lib.rename_animation(a, short)
    print(ap.get_animation_list())
    for m: MeshInstance3D in n.find_children("*", "MeshInstance3D", true, false):
        var mat := m.get_active_material(0) as StandardMaterial3D
        var img := mat.albedo_texture.get_image()
        if img.is_compressed(): img.decompress()
        img.convert(Image.FORMAT_RGBA8)
        for y in img.get_height():
            for x in img.get_width():
                var c := img.get_pixel(x, y)
                var l := c.get_luminance()
                var g := Color(l, l, l * 1.04, c.a) * 0.9
                img.set_pixel(x, y, c.lerp(g, 0.88))
        var new_mat := StandardMaterial3D.new()
        new_mat.albedo_texture = ImageTexture.create_from_image(img)
        new_mat.roughness = 1.0
        m.mesh.surface_set_material(0, new_mat)
        m.set_surface_override_material(0, null)
    var doc := GLTFDocument.new()
    var state := GLTFState.new()
    print("append ", doc.append_from_scene(n, state))
    print("write ", doc.write_to_filesystem(state, "res://out_leo.glb"))
    quit()
