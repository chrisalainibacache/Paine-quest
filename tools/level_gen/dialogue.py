import sys, os; sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
from tscn import *
s = Scene()
box_style = s.subres("StyleBoxFlat", {"bg_color": col((0.02, 0.02, 0.03, 0.9)), "border_width_left": "2", "border_width_top": "2",
    "border_width_right": "2", "border_width_bottom": "2", "border_color": col((0.55, 0.5, 0.42, 0.9)),
    "corner_radius_top_left": "4", "corner_radius_top_right": "4", "corner_radius_bottom_right": "4", "corner_radius_bottom_left": "4"})
paper_style = s.subres("StyleBoxFlat", {"bg_color": col((0.82, 0.78, 0.66)), "border_width_left": "3", "border_width_top": "3",
    "border_width_right": "3", "border_width_bottom": "3", "border_color": col((0.35, 0.3, 0.22)),
    "shadow_color": col((0, 0, 0, 0.6)), "shadow_size": "12"})
s.node("Dialogue", "CanvasLayer", script=s.res("res://ui/dialogue/dialogue.gd", "Script"), layer="30")
# Bloquea los toques a la interfaz de abajo (p. ej. el botón de la nota en la mochila)
# mientras hay un mensaje o una nota abierta.
s.node("Blocker", "Control", ".", anchors_preset="15", anchor_right="1.0", anchor_bottom="1.0", grow_horizontal="2", grow_vertical="2")
s.node("Box", "Panel", ".", anchors_preset="12", anchor_top="1.0", anchor_right="1.0", anchor_bottom="1.0",
       offset_left="110.0", offset_top="-210.0", offset_right="-110.0", offset_bottom="-28.0", grow_horizontal="2", grow_vertical="0",
       mouse_filter="2", theme_override_styles_panel=box_style)
s.node("Margin", "MarginContainer", "Box", anchors_preset="15", anchor_right="1.0", anchor_bottom="1.0", grow_horizontal="2", grow_vertical="2",
       mouse_filter="2", theme_override_constants_margin_left="28", theme_override_constants_margin_top="20",
       theme_override_constants_margin_right="28", theme_override_constants_margin_bottom="20")
s.node("Text", "Label", "Box/Margin", autowrap_mode="3", text='"..."', theme_override_font_sizes_font_size="28",
       theme_override_colors_font_color=col((0.92, 0.9, 0.84)))
s.node("Next", "Label", "Box", anchors_preset="3", anchor_left="1.0", anchor_top="1.0", anchor_right="1.0", anchor_bottom="1.0",
       offset_left="-50.0", offset_top="-40.0", offset_right="-18.0", offset_bottom="-8.0", text='"▼"',
       theme_override_font_sizes_font_size="22", theme_override_colors_font_color=col((0.85, 0.7, 0.45)))
# Nombre de quien habla (por ahora solo Leo), sobre el borde del cuadro.
s.node("Speaker", "Label", "Box", offset_left="24.0", offset_top="-40.0", offset_right="300.0", offset_bottom="-4.0",
       text='"LEO"', visible="false", theme_override_font_sizes_font_size="24",
       theme_override_colors_font_color=col((0.62, 0.9, 0.45)), theme_override_colors_font_shadow_color=col((0, 0, 0, 1)),
       theme_override_constants_shadow_offset_x="2", theme_override_constants_shadow_offset_y="2")
s.node("Choices", "VBoxContainer", ".", anchors_preset="3", anchor_left="1.0", anchor_top="1.0", anchor_right="1.0", anchor_bottom="1.0",
       offset_left="-400.0", offset_top="-400.0", offset_right="-130.0", offset_bottom="-225.0", grow_horizontal="0", grow_vertical="0",
       alignment="2", theme_override_constants_separation="12")
s.node("Reader", "Control", ".", anchors_preset="15", anchor_right="1.0", anchor_bottom="1.0", grow_horizontal="2", grow_vertical="2", mouse_filter="2")
s.node("Shade", "ColorRect", "Reader", anchors_preset="15", anchor_right="1.0", anchor_bottom="1.0", grow_horizontal="2", grow_vertical="2",
       mouse_filter="2", color=col((0, 0, 0, 0.72)))
s.node("Paper", "Panel", "Reader", anchors_preset="8", anchor_left="0.5", anchor_top="0.5", anchor_right="0.5", anchor_bottom="0.5",
       offset_left="-400.0", offset_top="-310.0", offset_right="400.0", offset_bottom="310.0", grow_horizontal="2", grow_vertical="2",
       mouse_filter="2", theme_override_styles_panel=paper_style)
ink = col((0.16, 0.13, 0.1))
s.node("Title", "Label", "Reader/Paper", offset_left="44.0", offset_top="30.0", offset_right="756.0", offset_bottom="76.0",
       text='"Título"', theme_override_font_sizes_font_size="32", theme_override_colors_font_color=ink)
s.node("Rule", "ColorRect", "Reader/Paper", offset_left="44.0", offset_top="82.0", offset_right="756.0", offset_bottom="84.0",
       mouse_filter="2", color=col((0.35, 0.3, 0.22, 0.6)))
s.node("Body", "Label", "Reader/Paper", offset_left="44.0", offset_top="120.0", offset_right="756.0", offset_bottom="510.0",
       autowrap_mode="3", text='"..."', theme_override_font_sizes_font_size="25", theme_override_colors_font_color=ink)
s.node("Page", "Label", "Reader/Paper", offset_left="560.0", offset_top="88.0", offset_right="756.0", offset_bottom="112.0",
       horizontal_alignment="2", text='"1 / 2"', theme_override_font_sizes_font_size="20", theme_override_colors_font_color=col((0.35, 0.3, 0.22)))
# Botones grandes para el dedo; en la última página se oculta SIGUIENTE.
for name, text, left in [("Previous", "ANTERIOR", 44), ("Close", "CERRAR", 298), ("Next", "SIGUIENTE", 552)]:
    s.node(name, "Button", "Reader/Paper", offset_left="%d.0" % left, offset_top="554.0", offset_right="%d.0" % (left + 204), offset_bottom="604.0",
           text='"%s"' % text, theme_override_font_sizes_font_size="20")
s.node("Hint", "Label", "Reader/Paper", offset_left="44.0", offset_top="520.0", offset_right="756.0", offset_bottom="544.0",
       horizontal_alignment="1", text='"Puedes volver a leerla desde NOTAS"', theme_override_font_sizes_font_size="16",
       theme_override_colors_font_color=col((0.35, 0.3, 0.22)))
s.save(REPO + "/ui/dialogue/dialogue.tscn")
print("dialogue ok")
