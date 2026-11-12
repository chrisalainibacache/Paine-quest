extends Node3D
## Escena guionada del potrero (capítulo 3): al llegar Cony al centro aparecen
## demasiados infectados, el arma se traba, Leo se pone delante... y llegan
## Kiara y Nala a salvarlas. Cony les da las gracias y les pide que sigan
## sacando gente; ladran y se van. Ocurre una sola vez.

const INFECTED := preload("res://actors/enemies/infected.tscn")
const KIARA := preload("res://actors/dogs/kiara.tscn")
const NALA := preload("res://actors/dogs/nala.tscn")
const KINDS := ["infected", "infected_worker", "infected_pale", "infected_soldier", "infected_burnt", "infected"]

## Distancia al centro que dispara la escena.
@export var trigger_radius: float = 2.6
@export var horde_count: int = 13
## Radio desde donde salen los infectados y radio donde se detienen.
@export var spawn_radius: float = 8.5
@export var stop_radius: float = 2.6
## Por dónde llegan y por dónde se van las perras (relativo a este nodo).
@export var dogs_from: Vector3 = Vector3(9.0, 0, -4.0)
@export var dogs_exit: Vector3 = Vector3(-9.5, 0, 5.0)
@export var flag: String = "rescue:kiara_nala"

@onready var camera: Camera3D = $Camera

var _running := false


func _physics_process(_delta: float) -> void:
    if _running or GameState.has_flag(flag) or Dialogue.is_open() or SceneLoader.is_busy():
        return
    var player := get_tree().get_first_node_in_group("player") as Player
    if player == null or not player.is_alive():
        return
    var to := player.global_position - global_position
    to.y = 0.0
    if to.length() <= trigger_radius:
        _run(player)


func _run(player: Player) -> void:
    _running = true
    GameState.set_flag(flag)
    var leo := get_tree().get_first_node_in_group("leo") as Node3D
    player.controls_locked = true
    player.velocity = Vector3.ZERO
    if leo:
        leo.set_physics_process(false)
    camera.make_current()
    var center := player.global_position

    # 1. Aparecen demasiados.
    var horde: Array[Node3D] = []
    var walks: Array[Tween] = []
    for i in horde_count:
        # En abanico frente a la cámara (hacia -Z), para que se vean todos.
        var angle := PI + lerpf(-2.0, 2.0, float(i) / maxf(horde_count - 1, 1)) + randf_range(-0.1, 0.1)
        var dir := Vector3(sin(angle), 0, cos(angle))
        var zombie := INFECTED.instantiate()
        zombie.data = load("res://data/enemies/%s.tres" % KINDS[i % KINDS.size()])
        zombie.name = "Horde%d" % i
        get_parent().add_child(zombie)
        zombie.global_position = center + dir * (spawn_radius + randf_range(0.0, 2.0))
        zombie.set_physics_process(false)
        zombie.model.rotation.y = atan2(-dir.x, -dir.z)
        zombie._play("Zombie_Walk_Fwd", 0.2, 0.9)
        var walk := create_tween()
        walk.tween_property(zombie, "global_position", center + dir * (stop_radius + randf_range(0.0, 1.2)), randf_range(5.0, 7.0))
        walks.append(walk)
        horde.append(zombie)
    GraphicsSettings.apply(get_parent())
    Sfx.play("groan", center + Vector3(3, 1.5, 0), 0.0)
    await _wait(1.2)
    Sfx.play("groan", center + Vector3(-3, 1.5, 2), -2.0)
    await Dialogue.say(["Son muchos...", "No. Son demasiados."])

    # 2. El arma se traba.
    var nearest := horde[0]
    player.face_direction(nearest.global_position - player.global_position, 1.0)
    player.play_action("Pistol_Aim_Neutral", 30.0)
    await _wait(0.8)
    Sfx.play("click", player.global_position, 0.0)
    await _wait(0.45)
    Sfx.play("click", player.global_position, 0.0)
    await Dialogue.say(["*clic* ... *clic*", "¡Se trabó! ¡La pistola se trabó!"])

    # 3. Leo se pone delante.
    if leo:
        var front := center + (nearest.global_position - center).normalized() * 0.9
        front.y = leo.global_position.y
        var step := create_tween()
        step.tween_property(leo, "global_position", front, 0.35)
        leo.model.rotation.y = atan2(nearest.global_position.x - front.x, nearest.global_position.z - front.z)
        leo._play("Idle", 2.6)
        Sfx.play("hiss", front + Vector3.UP * 0.3, 0.0)
    await _wait(0.5)
    await Dialogue.say(["Leo: Tranquila, Cony. Yo te protejo."])

    # 4. Llegan Kiara y Nala.
    var kiara := KIARA.instantiate()
    var nala := NALA.instantiate()
    get_parent().add_child(kiara)
    get_parent().add_child(nala)
    kiara.global_position = global_position + dogs_from
    nala.global_position = global_position + dogs_from + Vector3(1.2, 0, 1.0)
    GraphicsSettings.apply(kiara)
    GraphicsSettings.apply(nala)
    kiara.bark()
    await _wait(0.25)
    nala.bark()
    for walk in walks:
        walk.kill()
    # Cada una derriba a la mitad de la horda (al mismo tiempo).
    var half := horde.size() / 2
    _hunt(kiara, horde.slice(0, half))
    await _hunt(nala, horde.slice(half))
    await _wait(0.6)

    # 5. Gracias, y a seguir sacando gente.
    var spot_k := center + Vector3(1.4, 0, 0.9)
    var spot_n := center + Vector3(-1.2, 0, 1.2)
    kiara.run_to(spot_k)
    await nala.run_to(spot_n)
    kiara.face(center)
    nala.face(center)
    player.play_action("Idle", 0.1)
    await _wait(0.4)
    await Dialogue.say([
        "¿Kiara? ¿Nala?",
        "Kiara: ¡Guau!",
        "Gracias, chicas. Nos salvaron.",
        "Hay mucha gente sola por aquí. Sigan sacándola, por favor. Ustedes pueden.",
        "Nala: ¡Guau, guau!",
        "Leo: Son valientes, Cony. Ellas saben lo que hacen.",
        "Golpeo la pistola contra la mano. Se destrabó."])
    kiara.bark()
    nala.bark()
    kiara.run_to(global_position + dogs_exit)
    await nala.run_to(global_position + dogs_exit + Vector3(0.8, 0, -0.6))
    kiara.queue_free()
    nala.queue_free()

    # 6. Vuelve el control.
    player.controls_locked = false
    if leo:
        leo.set_physics_process(true)
    var room := owner as Room
    if room:
        room.pick_camera_for(player)
    _running = false


func _hunt(dog: Node3D, targets: Array) -> void:
    for enemy in targets:
        await dog.attack(enemy)


func _wait(seconds: float) -> void:
    await get_tree().create_timer(seconds, false).timeout
