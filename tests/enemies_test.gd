extends "res://tests/test_case.gd"
## Prueba (headless) de los infectados: brazos al frente al caminar en todos los modelos y
## modos gráficos, y objetos arrojadizos (botella, ladrillo): daño, munición y efectos.
## Uso: godot --headless --path . -s res://tests/enemies_test.gd

const TYPES := ["infected", "infected_pale", "infected_worker", "infected_burnt", "infected_heavy", "infected_fast", "infected_soldier"]


var stage: Node3D


func _run() -> void:
    GameState.new_game()
    stage = Node3D.new()
    root.add_child(stage)
    var previous := GraphicsSettings.is_modern()
    for modern in [true, false]:
        GraphicsSettings.set_modern(modern)
        for type_name: String in TYPES:
            await _arms_forward(type_name, modern)
    GraphicsSettings.set_modern(previous)
    await _throwing("infected_pale", "bottle", 6)
    await _throwing("infected_worker", "brick", 10)
    await _skull_boss()
    await _boss_encounter()
    _finish()


func _spawn(type_name: String) -> Infected:
    var infected := (load("res://actors/enemies/infected.tscn") as PackedScene).instantiate() as Infected
    infected.data = load("res://data/enemies/%s.tres" % type_name)
    stage.add_child(infected)
    return infected


## Al caminar, el brazo y el antebrazo apuntan hacia delante (+Z del modelo), no hacia atrás.
func _arms_forward(type_name: String, modern: bool) -> void:
    var infected := _spawn(type_name)
    infected.set_physics_process(false)
    infected.model.rotation.y = 0.0
    infected._play("Zombie_Walk_Fwd", 0.0)
    var label := "%s (%s)" % [type_name, "moderno" if modern else "retro"]
    var skeleton := infected._find_model_skeleton(infected.model)
    var worst := 1.0
    for t in [0.0, 0.3, 0.6, 0.9, 1.2]:
        infected._anim.seek(t, true)
        skeleton.force_update_all_bone_transforms()
        for side in ["Left", "Right"]:
            var upper := skeleton.find_bone(side + "UpperArm")
            var lower := skeleton.find_bone(side + "LowerArm")
            var hand := skeleton.find_bone(side + "Hand")
            var basis := infected.model.global_transform.basis * skeleton.transform.basis
            var arm: Vector3 = basis * (skeleton.get_bone_global_pose(lower).origin - skeleton.get_bone_global_pose(upper).origin).normalized()
            var forearm: Vector3 = basis * (skeleton.get_bone_global_pose(hand).origin - skeleton.get_bone_global_pose(lower).origin).normalized()
            worst = minf(worst, minf(arm.z, forearm.z))
    _check(worst > 0.2, "%s: los brazos van al frente al caminar (peor z = %.2f)" % [label, worst])
    infected.queue_free()
    await _frames(1)


## El infectado lanza su objeto: el daño llega a Isabella una sola vez, gasta munición y suena.
func _throwing(type_name: String, kind: String, damage: int) -> void:
    var player := (load("res://actors/player/player.tscn") as PackedScene).instantiate() as Player
    stage.add_child(player)
    player.global_position = Vector3(0, 0.05, -2.5)
    var ground := StaticBody3D.new()
    ground.collision_layer = 1
    var shape := CollisionShape3D.new()
    var box := BoxShape3D.new()
    box.size = Vector3(30, 1, 30)
    shape.shape = box
    shape.position = Vector3(0, -0.5, 0)
    ground.add_child(shape)
    stage.add_child(ground)
    var infected := _spawn(type_name)
    infected.global_position = Vector3(0, 0.05, 2.5)
    infected.model.rotation.y = PI
    await _frames(2)
    _check(infected._thrower != null and infected._thrower.ammo > 0, "%s: trae un objeto para lanzar" % type_name)
    var ammo_before: int = infected._thrower.ammo
    var health_before := player.health
    var sound: String = "glass_break" if kind == "bottle" else "brick_thud"
    Sfx.reset_play_counts()
    infected._thrower._cooldown = 0.0
    for i in 90:
        await _frames(3)
        if player.health < health_before:
            break
    _check(player.health == health_before - damage, "%s: el %s le hace %d de daño a Isabella (vida %d)" % [type_name, kind, damage, player.health])
    _check(infected._thrower.ammo == ammo_before - 1, "%s: lanzar gasta munición" % type_name)
    _check(Sfx.play_count(sound) >= 1 and Sfx.play_count("thrown_hit") >= 1, "%s: suena el impacto (%s)" % [type_name, sound])
    # Sin visión/distancia correcta no lanza: de cerca ataca en vez de lanzar.
    _check(not infected._thrower.wants_throw(1.0), "%s: de cerca no lanza" % type_name)
    infected.queue_free()
    player.queue_free()
    ground.queue_free()
    await _frames(2)


## Skull (jefe del capítulo 4): más alto que un humano, embiste, y si choca con una pared queda aturdido (doble daño).
func _skull_boss() -> void:
    GraphicsSettings.set_modern(true)
    var ground := StaticBody3D.new()
    ground.collision_layer = 1
    var shape := CollisionShape3D.new()
    var box := BoxShape3D.new()
    box.size = Vector3(40, 1, 40)
    shape.shape = box
    shape.position = Vector3(0, -0.5, 0)
    ground.add_child(shape)
    stage.add_child(ground)
    var wall := StaticBody3D.new()
    wall.collision_layer = 1
    var wall_shape := CollisionShape3D.new()
    var wall_box := BoxShape3D.new()
    wall_box.size = Vector3(10, 4, 1)
    wall_shape.shape = wall_box
    wall.add_child(wall_shape)
    wall.position = Vector3(0, 2, 6)
    stage.add_child(wall)
    var skull := _spawn("skull")
    skull.global_position = Vector3(0, 0.05, 0)
    skull.model.rotation.y = 0.0
    await _frames(3)
    _check(skull.health == 120 and skull._charger != null, "Skull: jefe con 120 de vida y embestida")
    var top := 0.0
    for mesh_instance: MeshInstance3D in skull.model.find_children("*", "MeshInstance3D", true, false):
        top = maxf(top, (mesh_instance.global_transform * mesh_instance.get_aabb()).end.y)
    _check(top > 2.1, "Skull: mide más de 2,1 m (%.2f)" % top)
    # Embiste contra la pared (sin Isabella en medio): queda aturdido.
    skull.target = null
    skull._charger.direction = Vector3.BACK
    skull._enter(Infected.State.CHARGE)
    skull._charger.direction = Vector3.BACK
    for i in 200:
        await _frames(2)
        if skull.state == Infected.State.STAGGER:
            break
    _check(skull.state == Infected.State.STAGGER and skull._stun_extra > 0.0, "Skull: al chocar con la pared queda aturdido")
    var before := skull.health
    skull.take_hit(1, Vector3(0, 1, -3), Vector3(0, 1.5, 0), 0.0)
    _check(before - skull.health == 2, "Skull: aturdido recibe doble daño (%d)" % (before - skull.health))
    skull.queue_free()
    wall.queue_free()
    ground.queue_free()
    await _frames(2)


## Arena del jefe: al acercarse Isabella aparece Skull con su barra; al caer se anota la bandera.
func _boss_encounter() -> void:
    GameState.new_game()
    var room := (load("res://levels/test/skull_arena.tscn") as PackedScene).instantiate()
    stage.add_child(room)
    var player := (load("res://actors/player/player.tscn") as PackedScene).instantiate() as Player
    room.add_child(player)
    player.global_position = Vector3(-9.0, 0.05, 0.0)
    await _frames(10)
    var encounter := room.get_node("BossEncounter")
    _check(encounter.boss == null, "arena: el jefe no aparece con Isabella lejos")
    player.global_position = Vector3(0.0, 0.05, 0.0)
    for i in 30:
        await _frames(2)
        if encounter.boss != null:
            break
    _check(encounter.boss != null and encounter._bar != null, "arena: al acercarse aparece el jefe con su barra de vida")
    if encounter.boss != null:
        encounter.boss.take_hit(9999, Vector3.ZERO, Vector3(8, 1.5, 0), 0.0)
        await _frames(4)
        _check(GameState.has_flag("boss:skull:dead"), "arena: al caer el jefe se anota la bandera")
    GameState.flags.erase("boss:skull:dead")
    room.queue_free()
    await _frames(2)
