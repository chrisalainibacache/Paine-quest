extends Node
## Escena de juego: crea a Cony y a Leo, conecta la interfaz y entra a la sala
## que indique GameState (la inicial, o la de la partida cargada).
## El cambio de sala lo hace el nodo SceneLoader.

const PLAYER_SCENE := preload("res://actors/player/player.tscn")
const LEO_SCENE := preload("res://actors/companion/leo.tscn")

@onready var loader: SceneLoader = $SceneLoader

var player: Player
var leo: Node3D
var room: Room:
    get:
        return loader.room


func _ready() -> void:
    if not GameState.started:
        GameState.new_game()

    player = PLAYER_SCENE.instantiate() as Player
    $World.add_child(player)
    player.health = GameState.health

    leo = LEO_SCENE.instantiate()
    $World.add_child(leo)
    leo.target = player

    $HUD.bind(player)
    $HUD.inventory_requested.connect(func() -> void: $InventoryMenu.open(player))
    $HUD.retry_requested.connect(retry)
    loader.setup($World, player, leo, $Fade/Black)
    await loader.enter_first_room()


func _process(delta: float) -> void:
    if not get_tree().paused:
        GameState.play_time += delta


## Tras morir: vuelve a la última máquina de escribir (o empieza de nuevo).
func retry() -> void:
    if not SaveSystem.load_game():
        GameState.new_game()
    get_tree().paused = false
    get_tree().reload_current_scene()
