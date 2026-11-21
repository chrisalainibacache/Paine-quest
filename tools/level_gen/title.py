import sys, os; sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
from tscn import *
s = Scene()
s.node("TitleScreen", "Control", script=s.res("res://ui/title/title_screen.gd", "Script"), anchors_preset="15", anchor_right="1.0",
       anchor_bottom="1.0", grow_horizontal="2", grow_vertical="2")
# Fondo: bosque de pinos de noche con la vía perdiéndose entre la niebla (tools/prerender/render_title.gd).
s.node("Background", "TextureRect", ".", anchors_preset="15", anchor_right="1.0", anchor_bottom="1.0", grow_horizontal="2", grow_vertical="2",
       texture=s.res("res://assets/ui/title_forest.jpg", "Texture2D"), expand_mode="1", stretch_mode="6", mouse_filter="2")
s.node("Shade", "ColorRect", ".", anchors_preset="15", anchor_right="1.0", anchor_bottom="1.0", grow_horizontal="2", grow_vertical="2",
       color=col((0.0, 0.0, 0.0, 0.18)), mouse_filter="2")
s.node("Title", "Label", ".", anchors_preset="0", anchor_left="0.0", anchor_right="0.0", grow_horizontal="1",
       offset_left="70.0", offset_top="110.0", offset_right="800.0", offset_bottom="250.0", horizontal_alignment="0",
       text='"P A I N E"', theme_override_font_sizes_font_size="110", theme_override_colors_font_color=col((0.62, 0.08, 0.06)),
       theme_override_colors_font_shadow_color=col((0, 0, 0, 1)), theme_override_constants_shadow_offset_x="4", theme_override_constants_shadow_offset_y="4")
s.node("Subtitle", "Label", ".", anchors_preset="0", anchor_left="0.0", anchor_right="0.0", grow_horizontal="1",
       offset_left="74.0", offset_top="252.0", offset_right="800.0", offset_bottom="290.0", horizontal_alignment="0",
       text='"La estación  ·  Las vías  ·  Buin"', theme_override_font_sizes_font_size="28", theme_override_colors_font_color=col((0.6, 0.57, 0.5)))
s.node("Menu", "VBoxContainer", ".", anchors_preset="0", anchor_left="0.0", anchor_right="0.0", grow_horizontal="1",
       offset_left="70.0", offset_top="320.0", offset_right="430.0", offset_bottom="646.0", theme_override_constants_separation="14")
for name, text in [("NewGame", "NUEVA PARTIDA"), ("Continue", "CONTINUAR")]:
    s.node(name, "Button", "Menu", custom_minimum_size="Vector2(0, 68)", text='"%s"' % text, theme_override_font_sizes_font_size="30",
           focus_mode="0")
s.node("Graphics", "Button", "Menu", custom_minimum_size="Vector2(0, 68)", text='"GRÁFICOS: RETRO"', theme_override_font_sizes_font_size="26",
       script=s.res("res://ui/graphics_toggle.gd", "Script"))
s.node("Brightness", "Button", "Menu", custom_minimum_size="Vector2(0, 68)", text='"BRILLO 3/5"', theme_override_font_sizes_font_size="26",
       script=s.res("res://ui/brightness_toggle.gd", "Script"))
s.node("OptionsButton", "Button", ".", anchors_preset="0", anchor_left="0.0", anchor_top="0.0", anchor_right="0.0", anchor_bottom="0.0",
       grow_horizontal="0", grow_vertical="0", offset_left="20.0", offset_top="20.0", offset_right="240.0", offset_bottom="76.0",
       custom_minimum_size="Vector2(220, 56)", text='"OPCIONES"', theme_override_font_sizes_font_size="24", focus_mode="0")
s.node("CreditsButton", "Button", ".", anchors_preset="1", anchor_left="1.0", anchor_top="0.0", anchor_right="1.0", anchor_bottom="0.0",
       grow_horizontal="0", grow_vertical="0", offset_left="-240.0", offset_top="20.0", offset_right="-20.0", offset_bottom="76.0",
       custom_minimum_size="Vector2(220, 56)", text='"CRÉDITOS"', theme_override_font_sizes_font_size="24", focus_mode="0")
s.node("Credits", "Label", ".", anchors_preset="3", anchor_left="1.0", anchor_top="1.0", anchor_right="1.0", anchor_bottom="1.0",
       grow_horizontal="0", grow_vertical="0", offset_left="-520.0", offset_top="-50.0", offset_right="-24.0", offset_bottom="-16.0",
       horizontal_alignment="2", text='"Isabella y Leo · Paine, Chile"', theme_override_font_sizes_font_size="18",
       theme_override_colors_font_color=col((0.4, 0.38, 0.34)))
# Créditos que piden las licencias (CC-BY): ver CREDITS.md.
s.node("Attribution", "Label", ".", anchors_preset="2", anchor_top="1.0", anchor_bottom="1.0", grow_vertical="0",
       offset_left="24.0", offset_top="-50.0", offset_right="500.0", offset_bottom="-16.0",
       text='"Modelos: Pixelhouse (CC-BY 3.0), Rikindle3D, Quaternius · Texturas: ambientCG"',
       theme_override_font_sizes_font_size="15", theme_override_colors_font_color=col((0.33, 0.31, 0.28)))
s.node("Filter", None, ".", instance=s.res("res://ui/ps1_filter.tscn", "PackedScene"))
s.node("OptionsMenu", None, ".", instance=s.res("res://ui/options/options_menu.tscn", "PackedScene"))
s.save(REPO + "/ui/title/title_screen.tscn")
print("title ok")
