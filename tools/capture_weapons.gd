extends SceneTree
## Captura a Cony apuntando y disparando con cada arma (revisión de arte).
## Uso: xvfb-run godot --path . --rendering-driver opengl3 -s res://tools/capture_weapons.gd -- <carpeta>

const WEAPONS := ["pistol", "mauser", "shotgun", "assault_rifle", "sniper_rifle", "grenade_launcher", "bazooka"]


func _init() -> void:
    _run.call_deferred()


func _run() -> void:
    var out: String = OS.get_cmdline_user_args()[0]
    DirAccess.make_dir_recursive_absolute(out)
    SaveSystem.save_path = "user://captura_armas.json"
    GameState.new_game()
    GameState.set_flag("found:pistol")
    change_scene_to_file("res://main.tscn")
    await create_timer(1.3).timeout
    var main := current_scene
    var player: Player = main.player
    for enemy in main.room.get_tree().get_nodes_in_group("enemies"):
        enemy.queue_free()
    # Mochila con todo el arsenal.
    main.get_node("InventoryMenu").open(player)
    await create_timer(0.6).timeout
    root.get_viewport().get_texture().get_image().save_png(out + "/00_mochila.png")
    main.get_node("InventoryMenu").close()
    var close := Camera3D.new()
    main.add_child(close)
    close.fov = 50.0
    for i in WEAPONS.size():
        GameState.equip(load("res://data/items/%s.tres" % WEAPONS[i]))
        player.combat.sync_from_state()
        player.global_position = Vector3(-1.0, 0.05, 3.0)
        player.model.rotation.y = PI / 2.0
        var infected: Infected = (load("res://actors/enemies/infected.tscn") as PackedScene).instantiate()
        main.room.add_child(infected)
        infected.global_position = Vector3(3.5, 0.05, 3.0)
        infected.set_physics_process(false)
        await create_timer(0.3).timeout
        Input.action_press(&"aim")
        await create_timer(0.7).timeout
        close.global_position = player.global_position + Vector3(0.6, 1.55, 2.3)
        close.look_at(player.global_position + Vector3(0.7, 1.25, 0.0))
        close.make_current()
        root.get_viewport().get_texture().get_image().save_png(out + "/%d_%s_apunta.png" % [i + 1, WEAPONS[i]])
        Input.action_press(&"fire")
        await process_frame
        await process_frame
        Input.action_release(&"fire")
        var wait := 0.04 if player.combat.weapon.explosive_radius <= 0.0 else 0.4
        await create_timer(wait).timeout
        root.get_viewport().get_texture().get_image().save_png(out + "/%d_%s_dispara.png" % [i + 1, WEAPONS[i]])
        Input.action_release(&"aim")
        main.room.pick_camera_for(player)
        await create_timer(0.8).timeout
        if is_instance_valid(infected):
            infected.queue_free()
        await create_timer(0.3).timeout
    quit()
