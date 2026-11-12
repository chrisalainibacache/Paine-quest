import sys, os; sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
from tscn import *
s = Scene()
s.node("TitleScreen", "Control", script=s.res("res://ui/title/title_screen.gd", "Script"), anchors_preset="15", anchor_right="1.0",
       anchor_bottom="1.0", grow_horizontal="2", grow_vertical="2")
s.node("Background", "ColorRect", ".", anchors_preset="15", anchor_right="1.0", anchor_bottom="1.0", grow_horizontal="2", grow_vertical="2",
       color=col((0.02, 0.018, 0.02)))
s.node("Title", "Label", ".", anchors_preset="5", anchor_left="0.5", anchor_right="0.5", grow_horizontal="2",
       offset_left="-500.0", offset_top="120.0", offset_right="500.0", offset_bottom="260.0", horizontal_alignment="1",
       text='"P A I N E"', theme_override_font_sizes_font_size="110", theme_override_colors_font_color=col((0.62, 0.08, 0.06)),
       theme_override_colors_font_shadow_color=col((0, 0, 0, 1)), theme_override_constants_shadow_offset_x="4", theme_override_constants_shadow_offset_y="4")
s.node("Subtitle", "Label", ".", anchors_preset="5", anchor_left="0.5", anchor_right="0.5", grow_horizontal="2",
       offset_left="-500.0", offset_top="262.0", offset_right="500.0", offset_bottom="300.0", horizontal_alignment="1",
       text='"Capítulo 1 · La estación   ·   Capítulo 2 · Las vías"', theme_override_font_sizes_font_size="28", theme_override_colors_font_color=col((0.6, 0.57, 0.5)))
s.node("Menu", "VBoxContainer", ".", anchors_preset="5", anchor_left="0.5", anchor_right="0.5", grow_horizontal="2",
       offset_left="-180.0", offset_top="340.0", offset_right="180.0", offset_bottom="660.0", theme_override_constants_separation="14")
for name, text in [("NewGame", "NUEVA PARTIDA"), ("Continue", "CONTINUAR")]:
    s.node(name, "Button", "Menu", custom_minimum_size="Vector2(0, 68)", text='"%s"' % text, theme_override_font_sizes_font_size="30",
           focus_mode="0")
s.node("Graphics", "Button", "Menu", custom_minimum_size="Vector2(0, 68)", text='"GRÁFICOS: RETRO"', theme_override_font_sizes_font_size="26",
       script=s.res("res://ui/graphics_toggle.gd", "Script"))
s.node("Brightness", "Button", "Menu", custom_minimum_size="Vector2(0, 68)", text='"BRILLO 3/5"', theme_override_font_sizes_font_size="26",
       script=s.res("res://ui/brightness_toggle.gd", "Script"))
s.node("Credits", "Label", ".", anchors_preset="3", anchor_left="1.0", anchor_top="1.0", anchor_right="1.0", anchor_bottom="1.0",
       grow_horizontal="0", grow_vertical="0", offset_left="-520.0", offset_top="-50.0", offset_right="-24.0", offset_bottom="-16.0",
       horizontal_alignment="2", text='"Cony y Leo · Paine, Chile"', theme_override_font_sizes_font_size="18",
       theme_override_colors_font_color=col((0.4, 0.38, 0.34)))
# Créditos que piden las licencias (CC-BY): ver CREDITS.md.
s.node("Attribution", "Label", ".", anchors_preset="2", anchor_top="1.0", anchor_bottom="1.0", grow_vertical="0",
       offset_left="24.0", offset_top="-50.0", offset_right="760.0", offset_bottom="-16.0",
       text='"Modelos: Pixelhouse (CC-BY 3.0), Rikindle3D, Quaternius · Texturas: ambientCG"',
       theme_override_font_sizes_font_size="15", theme_override_colors_font_color=col((0.33, 0.31, 0.28)))
s.node("Filter", None, ".", instance=s.res("res://ui/ps1_filter.tscn", "PackedScene"))
s.save(REPO + "/ui/title/title_screen.tscn")
print("title ok")
