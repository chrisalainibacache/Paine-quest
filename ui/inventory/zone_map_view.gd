class_name ZoneMapView
extends Control
## Dibuja el grafo de una zona y colorea cada sala según el progreso guardado.

const CELL_SIZE := Vector2(146, 88)
const CELL_GAP := Vector2(34, 28)
const PADDING := Vector2(18, 18)

var _zone: ZoneMapData


func render(zone: ZoneMapData) -> void:
    _zone = zone
    for child: Node in get_children():
        child.queue_free()
    if _zone == null or not _zone.is_valid():
        custom_minimum_size = Vector2.ZERO
        queue_redraw()
        return

    var columns: int = maxi(_zone.grid_size.x, 1)
    var rows: int = maxi(_zone.grid_size.y, 1)
    custom_minimum_size = Vector2(
        PADDING.x * 2.0 + columns * CELL_SIZE.x + (columns - 1) * CELL_GAP.x,
        PADDING.y * 2.0 + rows * CELL_SIZE.y + (rows - 1) * CELL_GAP.y
    )
    size = custom_minimum_size

    for room_data: Dictionary in _zone.rooms:
        var room_id := String(room_data.get("id", ""))
        var grid: Vector2i = room_data.get("grid_position", Vector2i.ZERO)
        var state := _zone.room_state(room_id)
        var locked := _zone.has_locked_door(room_id)
        var button := Button.new()
        button.position = PADDING + Vector2(grid.x * (CELL_SIZE.x + CELL_GAP.x),
                grid.y * (CELL_SIZE.y + CELL_GAP.y))
        button.custom_minimum_size = CELL_SIZE
        button.size = CELL_SIZE
        button.text = String(room_data.get("name", room_id))
        if locked:
            button.text += "\n🔑"
        button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        button.add_theme_font_size_override("font_size", 20)
        button.add_theme_color_override("font_color", Color(0.92, 0.87, 0.77))
        button.mouse_filter = Control.MOUSE_FILTER_IGNORE
        button.focus_mode = Control.FOCUS_NONE
        var style := StyleBoxFlat.new()
        style.bg_color = _state_color(state)
        style.set_border_width_all(3)
        style.border_color = Color(0.78, 0.28, 0.2) if locked else Color(0.47, 0.42, 0.34)
        style.set_corner_radius_all(6)
        style.content_margin_left = 8
        style.content_margin_right = 8
        style.content_margin_top = 6
        style.content_margin_bottom = 6
        button.add_theme_stylebox_override("normal", style)
        button.add_theme_stylebox_override("hover", style)
        button.add_theme_stylebox_override("pressed", style)
        button.add_theme_stylebox_override("disabled", style)
        add_child(button)
    queue_redraw()


func _draw() -> void:
    if _zone == null:
        return
    for room_data: Dictionary in _zone.rooms:
        var room_id := String(room_data.get("id", ""))
        var from_grid: Vector2i = room_data.get("grid_position", Vector2i.ZERO)
        for target_id: String in room_data.get("connections", PackedStringArray()):
            if target_id <= room_id:
                continue
            var target_data := _zone.room_for(target_id)
            if target_data.is_empty():
                continue
            var to_grid: Vector2i = target_data.get("grid_position", Vector2i.ZERO)
            draw_line(_cell_center(from_grid), _cell_center(to_grid),
                    Color(0.58, 0.49, 0.35, 0.9), 5.0, true)


func _cell_center(grid: Vector2i) -> Vector2:
    return PADDING + Vector2(grid.x * (CELL_SIZE.x + CELL_GAP.x) + CELL_SIZE.x * 0.5,
            grid.y * (CELL_SIZE.y + CELL_GAP.y) + CELL_SIZE.y * 0.5)


func _state_color(state: ZoneMapData.RoomState) -> Color:
    match state:
        ZoneMapData.RoomState.NOT_VISITED:
            return Color(0.13, 0.14, 0.15, 0.98)
        ZoneMapData.RoomState.PENDING:
            return Color(0.43, 0.28, 0.13, 0.98)
        _:
            return Color(0.19, 0.3, 0.25, 0.98)
