import sys, os; sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
from tscn import *
s = Scene()
panel = s.subres("StyleBoxFlat", {"bg_color": col((0.04, 0.045, 0.05, 0.85)), "border_width_left": "2", "border_width_top": "2",
    "border_width_right": "2", "border_width_bottom": "2", "border_color": col((0.4, 0.37, 0.3, 0.8))})
TXT = col((0.9, 0.87, 0.8)); DIM = col((0.6, 0.57, 0.5))
def rect(**kw):
    d = {}
    for k in ("left", "top", "right", "bottom"):
        if k in kw: d["offset_" + k] = fmt(float(kw[k]))
    return d
def label(name, parent, text, size, color=TXT, **kw):
    s.node(name, "Label", parent, text='"%s"' % text, theme_override_font_sizes_font_size=str(size),
           theme_override_colors_font_color=color, **kw)
def button(name, parent, text, size=24, **kw):
    s.node(name, "Button", parent, text='"%s"' % text, theme_override_font_sizes_font_size=str(size), focus_mode="0", **kw)

s.node("InventoryMenu", "CanvasLayer", script=s.res("res://ui/inventory/inventory_menu.gd", "Script"), layer="20")
s.node("Root", "Control", ".", anchors_preset="15", anchor_right="1.0", anchor_bottom="1.0", grow_horizontal="2", grow_vertical="2")
s.node("Shade", "ColorRect", "Root", anchors_preset="15", anchor_right="1.0", anchor_bottom="1.0", grow_horizontal="2", grow_vertical="2",
       color=col((0.01, 0.012, 0.016, 0.93)))
# Encabezado: título, pestañas y cerrar.
s.node("Header", "HBoxContainer", "Root", anchors_preset="10", anchor_right="1.0", grow_horizontal="2",
       theme_override_constants_separation="14", **rect(left=40, top=22, right=-40, bottom=92))
label("Title", "Root/Header", "MOCHILA", 38, col((0.85, 0.72, 0.5)), size_flags_horizontal="3", vertical_alignment="1")
button("ItemsTab", "Root/Header", "OBJETOS", 24, toggle_mode="true", custom_minimum_size="Vector2(170, 64)")
button("NotesTab", "Root/Header", "NOTAS", 24, toggle_mode="true", custom_minimum_size="Vector2(170, 64)")
button("Close", "Root/Header", "CERRAR", 24, custom_minimum_size="Vector2(170, 64)")
# Estado de Cony.
s.node("Status", "Panel", "Root", theme_override_styles_panel=panel, **rect(left=40, top=118, right=330, bottom=430))
label("Label", "Root/Status", "ESTADO", 22, DIM, **rect(left=18, top=12, right=270, bottom=42))
s.node("Ecg", "Control", "Root/Status", script=s.res("res://ui/inventory/ecg.gd", "Script"), **rect(left=18, top=48, right=272, bottom=150))
label("Condition", "Root/Status", "BIEN", 30, TXT, **rect(left=18, top=158, right=272, bottom=198))
label("WeaponTitle", "Root/Status", "ARMA", 22, DIM, **rect(left=18, top=214, right=272, bottom=242))
label("Weapon", "Root/Status", "Pistola", 22, TXT, autowrap_mode="3", **rect(left=18, top=244, right=272, bottom=306))
# Casillas.
s.node("Grid", "GridContainer", "Root", columns="8", theme_override_constants_h_separation="10",
       theme_override_constants_v_separation="10", **rect(left=360, top=118, right=1240, bottom=330))
# Información del ítem.
s.node("Info", "Panel", "Root", theme_override_styles_panel=panel, **rect(left=360, top=404, right=1240, bottom=694))
label("Name", "Root/Info", "", 30, col((0.85, 0.72, 0.5)), **rect(left=24, top=14, right=840, bottom=54))
label("Description", "Root/Info", "", 24, TXT, autowrap_mode="3", **rect(left=24, top=60, right=600, bottom=274))
s.node("Buttons", "VBoxContainer", "Root/Info", theme_override_constants_separation="14", **rect(left=640, top=60, right=856, bottom=274))
button("Use", "Root/Info/Buttons", "USAR", 26, custom_minimum_size="Vector2(0, 80)")
button("Examine", "Root/Info/Buttons", "EXAMINAR", 26, custom_minimum_size="Vector2(0, 80)")
# Notas.
s.node("Notes", "ScrollContainer", "Root", **rect(left=360, top=118, right=1240, bottom=694))
s.node("List", "VBoxContainer", "Root/Notes", size_flags_horizontal="3", theme_override_constants_separation="10")
# Examinar: el ítem en grande, se gira con el dedo.
s.node("Examine", "Control", "Root", anchors_preset="15", anchor_right="1.0", anchor_bottom="1.0", grow_horizontal="2", grow_vertical="2")
s.node("Shade", "ColorRect", "Root/Examine", anchors_preset="15", anchor_right="1.0", anchor_bottom="1.0", grow_horizontal="2", grow_vertical="2",
       color=col((0, 0, 0, 0.92)))
s.node("View", "SubViewportContainer", "Root/Examine", script=s.res("res://ui/inventory/item_view.gd", "Script"),
       anchors_preset="5", anchor_left="0.5", anchor_right="0.5", grow_horizontal="2", spin_speed="0.25", draggable="true",
       **rect(left=-330, top=30, right=330, bottom=500))
label("Name", "Root/Examine", "", 32, col((0.85, 0.72, 0.5)), anchors_preset="5", anchor_left="0.5", anchor_right="0.5",
      horizontal_alignment="1", **rect(left=-500, top=505, right=500, bottom=545))
label("Description", "Root/Examine", "", 24, TXT, anchors_preset="5", anchor_left="0.5", anchor_right="0.5",
      horizontal_alignment="1", autowrap_mode="3", **rect(left=-500, top=548, right=500, bottom=650))
label("Hint", "Root/Examine", "Arrastra para girar", 18, DIM, **rect(left=40, top=660, right=400, bottom=690))
button("Close", "Root/Examine", "VOLVER", 24, anchors_preset="1", anchor_left="1.0", anchor_right="1.0", grow_horizontal="0",
       custom_minimum_size="Vector2(170, 64)", **rect(left=-210, top=22, right=-40, bottom=86))
s.save(REPO + "/ui/inventory/inventory_menu.tscn")
print("inventory ok")
