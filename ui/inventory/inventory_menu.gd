extends CanvasLayer
## Mochila (pausa el juego): 8 casillas con los ítems en 3D, estado de Isabella,
## arma equipada, usar/equipar/examinar y la lista de NOTAS leídas.

const ITEM_VIEW := preload("res://ui/inventory/item_view.gd")
const SLOT_SIZE := Vector2(98, 98)
const OPTIONS_SCENE := preload("res://ui/options/options_menu.tscn")

@onready var root: Control = $Root
@onready var grid: GridContainer = $Root/Grid
@onready var notes_list: GridContainer = $Root/Notes/List
@onready var notes_panel: Control = $Root/Notes
@onready var keys_panel: Control = $Root/Keys
@onready var keys_list: VBoxContainer = $Root/Keys/List
@onready var move_button: Button = $Root/Info/Buttons/Move
@onready var item_name: Label = $Root/Info/Name
@onready var item_text: Label = $Root/Info/Description
@onready var use_button: Button = $Root/Info/Buttons/Use
@onready var examine_button: Button = $Root/Info/Buttons/Examine
@onready var discard_button: Button = $Root/Info/Buttons/Discard
@onready var ecg: Control = $Root/Status/Ecg
@onready var condition_label: Label = $Root/Status/Condition
@onready var weapon_label: Label = $Root/Status/Weapon
@onready var examine: Control = $Root/Examine
@onready var examine_view: SubViewportContainer = $Root/Examine/View
@onready var examine_name: Label = $Root/Examine/Name
@onready var examine_text: Label = $Root/Examine/Description
@onready var reward_ammo_button: Button = $Root/Info/RewardButtons/RewardAmmo
@onready var reward_heal_button: Button = $Root/Info/RewardButtons/RewardHeal

var player: Player
var selected := -1
var _slots: Array[Button] = []
var _views: Array = []
var _counts: Array[Label] = []
var _paused_before := false
## Cuadro en que se abrió: el mismo toque de MOCHILA no debe cerrarla al tiro.
var _opened_frame := -1
var options_menu: OptionsMenu
var _discard_dialog: ConfirmationDialog
var _discard_options: OptionButton
var _discard_amounts: Array[int] = []
var _chest_open: bool = false
var _chest_mode: bool = false
var _choose_discard_mode: bool = false
var _pending_pickup: Pickup


func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    add_to_group("inventory_menu")
    visible = false
    _chest_open = false
    _chest_mode = false
    $Root/Header/NotesTab.disabled = false
    $Root/Header/KeysTab.disabled = false
    _choose_discard_mode = false
    _pending_pickup = null
    examine.visible = false
    for i in 24:
        _build_slot(i)
    $Root/Header/Close.pressed.connect(close)
    options_menu = OPTIONS_SCENE.instantiate() as OptionsMenu
    add_child(options_menu)
    $Root/Header/Options.pressed.connect(options_menu.open)
    $Root/Header/ItemsTab.pressed.connect(_show_tab.bind(false))
    $Root/Header/NotesTab.pressed.connect(_show_tab.bind(true))
    $Root/Header/KeysTab.pressed.connect(_show_keys)
    $Root/Header/ChestTab.pressed.connect(_show_chest)
    $Root/Examine/Close.pressed.connect(func() -> void: examine.visible = false)
    use_button.pressed.connect(_use_selected)
    examine_button.pressed.connect(_examine_selected)
    discard_button.pressed.connect(_discard_selected)
    move_button.pressed.connect(_move_selected)
    _build_discard_dialog()
    reward_ammo_button.pressed.connect(_offer_ammo_reward)
    reward_heal_button.pressed.connect(_offer_healing_reward)
    GameState.inventory.changed.connect(_refresh)
    GameState.chest.changed.connect(_refresh)


func is_open() -> bool:
    return visible


func open(new_player: Player) -> void:
    if visible:
        return
    player = new_player
    _chest_open = false
    _chest_mode = false
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
    if visible and (options_menu == null or not options_menu.visible) and not Dialogue.is_open() \
            and Engine.get_process_frames() != _opened_frame and Input.is_action_just_pressed(&"inventory"):
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
    var inventory: Inventory = _active_inventory()
    for i in _slots.size():
        _slots[i].visible = i < inventory.capacity
        if i >= inventory.capacity:
            continue
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
    if keys_panel.visible:
        _fill_keys()
    _refresh_status()
    _refresh_reward_offers()


func _refresh_info() -> void:
    var inventory: Inventory = _active_inventory()
    var item: ItemData = inventory.get_item(selected) if selected >= 0 and selected < inventory.capacity else null
    use_button.visible = item != null and not _chest_mode
    examine_button.visible = item != null
    discard_button.visible = item != null and not _chest_mode
    discard_button.text = "DESCARTAR Y RECOGER" if _choose_discard_mode else "DESCARTAR"
    discard_button.disabled = item == null or _discard_block_reason(item) != ""
    move_button.visible = _chest_open and item != null
    move_button.text = "RETIRAR" if _chest_mode else "GUARDAR"
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


func _refresh_reward_offers() -> void:
    reward_ammo_button.visible = false
    reward_heal_button.visible = false
    if player == null or not visible or notes_panel.visible or _chest_open:
        return
    if not Ads.available():
        return

    var equipped := GameState.equipped
    var weapon := equipped.weapon if equipped != null else null
    if weapon != null and weapon.ammo_item != null:
        var reserve := player.combat.reserve
        var low_reserve := reserve == 0 or float(reserve) < float(weapon.clip_size) * 0.25
        var ammo_reward := Ads.config.ammo_reward_for(weapon.ammo_item)
        reward_ammo_button.visible = low_reserve and ammo_reward > 0 \
                and GameState.inventory.space_for(weapon.ammo_item) > 0

    var healing_item := Ads.config.get_healing_item()
    reward_heal_button.visible = player.get_condition() == "Peligro" \
            and not _has_healing_item() and healing_item != null \
            and GameState.inventory.space_for(healing_item) > 0


func _has_healing_item() -> bool:
    for index in Inventory.SIZE:
        var item := GameState.inventory.get_item(index)
        if item != null and item.kind == ItemData.Kind.HEALING:
            return true
    return false


func _offer_ammo_reward() -> void:
    if player == null or not reward_ammo_button.visible:
        return
    Ads.show_rewarded(&"inventory_ammo", func(rewarded: bool) -> void:
        if not rewarded:
            _refresh_reward_offers()
            return
        var equipped := GameState.equipped
        var weapon := equipped.weapon if equipped != null else null
        if weapon == null or weapon.ammo_item == null:
            return
        var amount := mini(Ads.config.ammo_reward_for(weapon.ammo_item),
                GameState.inventory.space_for(weapon.ammo_item))
        if amount > 0:
            GameState.inventory.add(weapon.ammo_item, amount)
            Sfx.play("pickup", null, -6.0)
        _refresh()
    )


func _offer_healing_reward() -> void:
    if player == null or not reward_heal_button.visible:
        return
    Ads.show_rewarded(&"inventory_healing", func(rewarded: bool) -> void:
        if not rewarded:
            _refresh_reward_offers()
            return
        var healing_item := Ads.config.get_healing_item()
        if healing_item != null and GameState.inventory.space_for(healing_item) > 0:
            GameState.inventory.add(healing_item, 1)
            Sfx.play("heal", null, -6.0)
        _refresh()
    )


func _use_selected() -> void:
    if _chest_mode:
        return
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
            Sfx.play("heal", null, -6.0)
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
    var item: ItemData = _active_inventory().get_item(selected)
    if item == null:
        return
    examine_view.set_item(item)
    examine_name.text = item.display_name
    examine_text.text = item.description
    examine.visible = true
    Sfx.play("menu", null, -8.0)


func _show_tab(notes: bool) -> void:
    _chest_mode = false
    if selected >= GameState.inventory.capacity:
        selected = _first_filled()
    grid.visible = not notes
    $Root/Info.visible = not notes
    notes_panel.visible = notes
    keys_panel.visible = false
    $Root/Header/KeysTab.button_pressed = false
    $Root/Header/ChestTab.button_pressed = false
    $Root/Header/ItemsTab.button_pressed = not notes
    $Root/Header/NotesTab.button_pressed = notes
    move_button.visible = _chest_open and not notes
    move_button.text = "GUARDAR"
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
    # Las más nuevas primero: es lo último que encontró y lo que quiere releer.
    var paths: Array[String] = GameState.documents.duplicate()
    paths.reverse()
    for path in paths:
        var document := load(path) as DocumentData
        if document == null or document.pages.is_empty():
            push_warning("No se pudo cargar la nota guardada: %s" % path)
            continue
        var button := Button.new()
        button.text = document.title
        button.alignment = HORIZONTAL_ALIGNMENT_LEFT
        button.clip_text = true
        button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        button.custom_minimum_size = Vector2(0, 64)
        button.add_theme_font_size_override("font_size", 24)
        button.pressed.connect(_open_document.bind(document))
        notes_list.add_child(button)


func _open_document(document: DocumentData) -> void:
    Dialogue.read(document)


func _first_filled() -> int:
    var inventory: Inventory = _active_inventory()
    for i in inventory.capacity:
        if inventory.get_item(i) != null:
            return i
    return -1



func _show_keys() -> void:
    if _chest_open:
        return
    _chest_mode = false
    move_button.visible = false
    grid.visible = false
    $Root/Info.visible = false
    notes_panel.visible = false
    keys_panel.visible = true
    $Root/Header/ItemsTab.button_pressed = false
    $Root/Header/NotesTab.button_pressed = false
    $Root/Header/KeysTab.button_pressed = true
    _fill_keys()


func _fill_keys() -> void:
    for child: Node in keys_list.get_children():
        child.queue_free()
    var inventory: Inventory = GameState.inventory
    if inventory.key_items.is_empty():
        var empty: Label = Label.new()
        empty.text = "Todavía no has encontrado llaves."
        empty.add_theme_font_size_override("font_size", 26)
        keys_list.add_child(empty)
        return
    for index in inventory.key_items.size():
        var item: ItemData = inventory.key_item_at(index)
        if item == null:
            continue
        var row: Label = Label.new()
        row.text = "%s   ×%d\n%s" % [item.display_name, inventory.key_count_at(index), item.description]
        row.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        row.custom_minimum_size = Vector2(0, 76)
        row.add_theme_font_size_override("font_size", 22)
        keys_list.add_child(row)



func _build_discard_dialog() -> void:
    _discard_dialog = ConfirmationDialog.new()
    _discard_dialog.title = "DESCARTAR OBJETO"
    _discard_dialog.dialog_text = "¿Qué dejo?"
    _discard_options = OptionButton.new()
    _discard_options.name = "Amount"
    _discard_options.custom_minimum_size = Vector2(280, 54)
    _discard_options.add_theme_font_size_override("font_size", 24)
    _discard_dialog.add_child(_discard_options)
    add_child(_discard_dialog)
    _discard_dialog.confirmed.connect(_confirm_discard)


func _discard_block_reason(item: ItemData) -> String:
    if item.kind == ItemData.Kind.KEY:
        return "Las llaves no se pueden descartar."
    if item.kind == ItemData.Kind.WEAPON and item == GameState.equipped \
            and GameState.inventory.count_of(item) <= 1:
        return "Primero debo equipar otra arma."
    return ""


func _discard_selected() -> void:
    if selected < 0:
        return
    var item: ItemData = GameState.inventory.get_item(selected)
    if item == null:
        return
    var reason: String = _discard_block_reason(item)
    if not reason.is_empty():
        item_text.text = reason
        return
    var count: int = GameState.inventory.get_count(selected)
    _discard_amounts.clear()
    _discard_options.clear()
    var amounts: Array[int] = [1]
    if item.is_stackable():
        amounts.append(mini(10, count))
        amounts.append(count)
    for amount: int in amounts:
        if amount <= 0 or _discard_amounts.has(amount):
            continue
        _discard_amounts.append(amount)
        _discard_options.add_item("TODO" if amount == count and count > 1 else "−%d" % amount)
    _discard_dialog.dialog_text = "¿Qué dejo de %s?" % item.display_name
    _discard_dialog.popup_centered()


func _confirm_discard() -> void:
    if selected < 0 or _discard_options.selected < 0:
        return
    var item: ItemData = GameState.inventory.get_item(selected)
    if item == null or not _discard_block_reason(item).is_empty():
        return
    var amount_index: int = _discard_options.selected
    if amount_index >= _discard_amounts.size():
        return
    var amount: int = _discard_amounts[amount_index]
    var name: String = item.display_name
    GameState.inventory.remove_at(selected, amount)
    if GameState.inventory.get_item(selected) == null:
        selected = _first_filled()
    Sfx.play("pickup", null, -6.0)
    _refresh()
    if _pending_pickup != null and is_instance_valid(_pending_pickup):
        var pickup: Pickup = _pending_pickup
        _pending_pickup = null
        _choose_discard_mode = false
        close()
        pickup.interact(player)
        return
    item_text.text = "Dejé: %s." % name



func open_chest(new_player: Player) -> void:
    if visible:
        return
    open(new_player)
    _chest_open = true
    _chest_mode = false
    _show_tab(false)
    move_button.visible = true
    move_button.text = "GUARDAR"
    $Root/Header/NotesTab.disabled = true
    $Root/Header/KeysTab.disabled = true


func _show_chest() -> void:
    if not _chest_open:
        return
    _chest_mode = true
    grid.visible = true
    $Root/Info.visible = true
    notes_panel.visible = false
    keys_panel.visible = false
    $Root/Header/ItemsTab.button_pressed = false
    $Root/Header/NotesTab.button_pressed = false
    $Root/Header/KeysTab.button_pressed = false
    $Root/Header/ChestTab.button_pressed = true
    selected = _first_filled()
    move_button.visible = true
    move_button.text = "RETIRAR"
    _refresh()


func _active_inventory() -> Inventory:
    return GameState.chest if _chest_mode else GameState.inventory


func _move_selected() -> void:
    if not _chest_open or selected < 0:
        return
    var source: Inventory = _active_inventory()
    var destination: Inventory = GameState.inventory if _chest_mode else GameState.chest
    var item: ItemData = source.get_item(selected)
    if item == null or item.kind == ItemData.Kind.KEY:
        return
    var count: int = source.get_count(selected)
    var left: int = destination.add(item, count)
    var moved: int = count - left
    if moved <= 0:
        item_text.text = "No hay espacio en el otro inventario."
        return
    source.remove_at(selected, moved)
    if source.get_item(selected) == null:
        selected = _first_filled()
    Sfx.play("pickup", null, -6.0)
    _refresh()
    item_text.text = "%s: %s (%d)." % ["Retiré" if _chest_mode else "Guardé", item.display_name, moved]



func open_for_pickup(new_player: Player, pickup: Pickup) -> void:
    if pickup == null or not is_instance_valid(pickup):
        return
    _pending_pickup = pickup
    _choose_discard_mode = true
    if not visible:
        open(new_player)
    _show_tab(false)
    item_text.text = "¿QUÉ DEJO para poder recoger: %s?" % pickup.item.display_name
    discard_button.text = "DESCARTAR Y RECOGER"
    _refresh()
