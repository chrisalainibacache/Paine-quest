extends CanvasLayer
## Mochila (pausa el juego): 8 casillas con los ítems en 3D, estado de Cony,
## arma equipada, usar/equipar/examinar y la lista de NOTAS leídas.

const ITEM_VIEW := preload("res://ui/inventory/item_view.gd")
const SLOT_SIZE := Vector2(98, 98)

@onready var root: Control = $Root
@onready var grid: GridContainer = $Root/Grid
@onready var notes_list: VBoxContainer = $Root/Notes/List
@onready var notes_panel: Control = $Root/Notes
@onready var item_name: Label = $Root/Info/Name
@onready var item_text: Label = $Root/Info/Description
@onready var use_button: Button = $Root/Info/Buttons/Use
@onready var examine_button: Button = $Root/Info/Buttons/Examine
@onready var ecg: Control = $Root/Status/Ecg
@onready var condition_label: Label = $Root/Status/Condition
@onready var weapon_label: Label = $Root/Status/Weapon
@onready var examine: Control = $Root/Examine
@onready var examine_view: SubViewportContainer = $Root/Examine/View
@onready var examine_name: Label = $Root/Examine/Name
@onready var examine_text: Label = $Root/Examine/Description

var player: Player
var selected := -1
var _slots: Array[Button] = []
var _views: Array = []
var _counts: Array[Label] = []
var _paused_before := false
## Cuadro en que se abrió: el mismo toque de MOCHILA no debe cerrarla al tiro.
var _opened_frame := -1


func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    visible = false
    examine.visible = false
    for i in Inventory.SIZE:
        _build_slot(i)
    $Root/Header/Close.pressed.connect(close)
    $Root/Header/ItemsTab.pressed.connect(_show_tab.bind(false))
    $Root/Header/NotesTab.pressed.connect(_show_tab.bind(true))
    $Root/Examine/Close.pressed.connect(func() -> void: examine.visible = false)
    use_button.pressed.connect(_use_selected)
    examine_button.pressed.connect(_examine_selected)
    GameState.inventory.changed.connect(_refresh)


func is_open() -> bool:
    return visible


func open(new_player: Player) -> void:
    if visible:
        return
    player = new_player
    _paused_before = get_tree().paused
    get_tree().paused = true
    visible = true
    _opened_frame = Engine.get_process_frames()
    examine.visible = false
    _show_tab(false)
    if selected < 0 or GameState.inventory.get_item(selected) == null:
        selected = _first_filled()
    _refresh()
    Sfx.play("menu", null, -6.0)


func close() -> void:
    if not visible:
        return
    visible = false
    examine.visible = false
    get_tree().paused = _paused_before
    Sfx.play("menu", null, -8.0)


func _process(_delta: float) -> void:
    if visible and not Dialogue.is_open() and Engine.get_process_frames() != _opened_frame \
            and Input.is_action_just_pressed(&"inventory"):
        close()


## Elige una casilla (también lo usan las pruebas).
func select(index: int) -> void:
    selected = index
    Sfx.play("menu", null, -10.0)
    _refresh()


func _build_slot(index: int) -> void:
    var slot := Button.new()
    slot.custom_minimum_size = SLOT_SIZE
    slot.toggle_mode = true
    slot.focus_mode = Control.FOCUS_NONE
    slot.pressed.connect(select.bind(index))
    grid.add_child(slot)
    var view := ITEM_VIEW.new() as SubViewportContainer
    view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    view.offset_left = 8
    view.offset_top = 8
    view.offset_right = -8
    view.offset_bottom = -8
    view.spin_speed = 0.0
    slot.add_child(view)
    var count := Label.new()
    count.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
    count.offset_left = -70
    count.offset_top = -34
    count.offset_right = -8
    count.offset_bottom = -4
    count.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    count.add_theme_font_size_override("font_size", 22)
    count.add_theme_color_override("font_outline_color", Color.BLACK)
    count.add_theme_constant_override("outline_size", 6)
    slot.add_child(count)
    _slots.append(slot)
    _views.append(view)
    _counts.append(count)


func _refresh() -> void:
    if not is_node_ready() or not visible:
        return
    var inventory := GameState.inventory
    for i in Inventory.SIZE:
        var item := inventory.get_item(i)
        if not _views[i].has_meta("item") or _views[i].get_meta("item") != item:
            _views[i].set_item(item)
            _views[i].set_meta("item", item)
        _counts[i].text = str(inventory.get_count(i)) if item and item.is_stackable() else ""
        if item == GameState.equipped and item != null:
            _counts[i].text = "E"
        _slots[i].button_pressed = i == selected
        # Solo gira el ítem elegido (los demás quedan quietos y legibles).
        _views[i].spin_speed = 0.7 if i == selected else 0.0
    _refresh_info()
    _refresh_status()


func _refresh_info() -> void:
    var item := GameState.inventory.get_item(selected) if selected >= 0 else null
    use_button.visible = item != null
    examine_button.visible = item != null
    if item == null:
        item_name.text = ""
        item_text.text = "Toca una casilla para ver el ítem."
        return
    item_name.text = item.display_name
    item_text.text = item.description
    use_button.disabled = false
    match item.kind:
        ItemData.Kind.HEALING:
            use_button.text = "COMER"
        ItemData.Kind.WEAPON:
            use_button.text = "EQUIPADA" if item == GameState.equipped else "EQUIPAR"
            use_button.disabled = item == GameState.equipped
        _:
            use_button.text = "USAR"
            use_button.disabled = true


func _refresh_status() -> void:
    if player == null:
        return
    var condition := player.get_condition()
    ecg.condition = condition
    condition_label.text = condition.to_upper()
    condition_label.add_theme_color_override("font_color", ecg.COLORS[condition])
    if GameState.equipped:
        weapon_label.text = "%s\n%d / %d" % [GameState.equipped.display_name, player.combat.clip, player.combat.reserve]
    else:
        weapon_label.text = "Sin arma"


func _use_selected() -> void:
    var item := GameState.inventory.get_item(selected)
    if item == null:
        return
    match item.kind:
        ItemData.Kind.HEALING:
            if player.health >= Player.MAX_HEALTH:
                item_text.text = "Estoy bien. Mejor lo guardo para después."
                return
            player.heal(item.heal_amount)
            GameState.inventory.remove_at(selected)
            Sfx.play("pickup", null, -6.0)
            if GameState.inventory.get_item(selected) == null:
                selected = _first_filled()
            _refresh()
            item_text.text = "Comí: %s. Me siento mejor." % item.display_name
        ItemData.Kind.WEAPON:
            GameState.equip(item)
            player.combat.sync_from_state()
            Sfx.play("reload", null, -6.0)
            _refresh()


func _examine_selected() -> void:
    var item := GameState.inventory.get_item(selected)
    if item == null:
        return
    examine_view.set_item(item)
    examine_name.text = item.display_name
    examine_text.text = item.description
    examine.visible = true
    Sfx.play("menu", null, -8.0)


func _show_tab(notes: bool) -> void:
    grid.visible = not notes
    $Root/Info.visible = not notes
    notes_panel.visible = notes
    $Root/Header/ItemsTab.button_pressed = not notes
    $Root/Header/NotesTab.button_pressed = notes
    if notes:
        _fill_notes()


func _fill_notes() -> void:
    for child in notes_list.get_children():
        child.queue_free()
    if GameState.documents.is_empty():
        var empty := Label.new()
        empty.text = "Todavía no has encontrado notas."
        empty.add_theme_font_size_override("font_size", 24)
        notes_list.add_child(empty)
        return
    for path in GameState.documents:
        var document := load(path) as DocumentData
        if document == null or document.pages.is_empty():
            push_warning("No se pudo cargar la nota guardada: %s" % path)
            continue
        var button := Button.new()
        button.text = document.title
        button.alignment = HORIZONTAL_ALIGNMENT_LEFT
        button.custom_minimum_size = Vector2(0, 64)
        button.add_theme_font_size_override("font_size", 26)
        button.pressed.connect(_open_document.bind(document))
        notes_list.add_child(button)


func _open_document(document: DocumentData) -> void:
    Dialogue.read(document)


func _first_filled() -> int:
    for i in Inventory.SIZE:
        if GameState.inventory.get_item(i) != null:
            return i
    return -1
