#!/usr/bin/env python3
"""Escribe ui/theme/paine_theme.tres con las texturas de assets/ui/kit (ver build_ui_kit.py): botones y paneles de metal oscuro con
borde de bronce, casillas hundidas y la tipografía Josefin Sans del título. Uso: python3 tools/ui/build_theme.py"""
import os
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
K = "res://assets/ui/kit/%s.png"
tex = ["panel", "button_normal", "button_hover", "button_pressed", "button_disabled", "slot", "slot_selected", "header", "slider_grabber", "slider_grabber_hi"]
lines = ['[gd_resource type="Theme" format=3]', ""]
ids = {}
for i, t in enumerate(tex, 1):
    ids[t] = "t%d" % i
    lines.append('[ext_resource type="Texture2D" path="%s" id="%s"]' % (K % t, ids[t]))
lines.append('[ext_resource type="FontFile" path="res://assets/fonts/JosefinSans.ttf" id="font_base"]')
lines.append("")
lines += ['[sub_resource type="FontVariation" id="FontVariation_ui"]', 'base_font = ExtResource("font_base")',
          'variation_opentype = { 2003265652: 560.0 }', ""]


def box(name, texture, margin, content=(16, 10)):
    lines.extend(['[sub_resource type="StyleBoxTexture" id="%s"]' % name, 'texture = ExtResource("%s")' % ids[texture],
        "texture_margin_left = %d.0" % margin, "texture_margin_top = %d.0" % margin, "texture_margin_right = %d.0" % margin, "texture_margin_bottom = %d.0" % margin,
        "content_margin_left = %d.0" % content[0], "content_margin_top = %d.0" % content[1], "content_margin_right = %d.0" % content[0], "content_margin_bottom = %d.0" % content[1], ""])


box("Box_button_normal", "button_normal", 14)
box("Box_button_hover", "button_hover", 14)
box("Box_button_pressed", "button_pressed", 14)
box("Box_button_disabled", "button_disabled", 14)
box("Box_panel", "panel", 18, (14, 12))
box("Box_slot", "slot", 12, (4, 4))
box("Box_slot_selected", "slot_selected", 12, (4, 4))
lines.extend(['[sub_resource type="StyleBoxFlat" id="Box_focus"]', "bg_color = Color(0, 0, 0, 0)", "border_width_left = 2", "border_width_top = 2",
              "border_width_right = 2", "border_width_bottom = 2", "border_color = Color(0.88, 0.72, 0.45, 0.55)", ""])
lines.extend(['[sub_resource type="StyleBoxEmpty" id="Box_empty"]', ""])
lines.extend(['[sub_resource type="StyleBoxFlat" id="Box_groove"]', "bg_color = Color(0.03, 0.03, 0.03, 1)", "border_width_left = 1", "border_width_top = 1", "border_width_right = 1",
              "border_width_bottom = 1", "border_color = Color(0.4, 0.33, 0.22, 1)", "content_margin_top = 5.0", "content_margin_bottom = 5.0", ""])
lines.extend(['[sub_resource type="StyleBoxFlat" id="Box_fill"]', "bg_color = Color(0.55, 0.42, 0.22, 1)", "border_width_left = 1", "border_width_top = 1", "border_width_right = 1",
              "border_width_bottom = 1", "border_color = Color(0.2, 0.15, 0.08, 1)", "content_margin_top = 5.0", "content_margin_bottom = 5.0", ""])
lines.append("[resource]")
lines.append('default_font = SubResource("FontVariation_ui")')
lines.append("default_font_size = 24")
for state, box_id in (("normal", "button_normal"), ("hover", "button_hover"), ("pressed", "button_pressed"), ("disabled", "button_disabled"),
                      ("hover_pressed", "button_pressed")):
    lines.append('Button/styles/%s = SubResource("Box_%s")' % (state, box_id))
lines.append('Button/styles/focus = SubResource("Box_focus")')
lines += ["Button/colors/font_color = Color(0.9, 0.87, 0.8, 1)", "Button/colors/font_hover_color = Color(1, 0.95, 0.85, 1)",
          "Button/colors/font_pressed_color = Color(1, 0.88, 0.6, 1)", "Button/colors/font_hover_pressed_color = Color(1, 0.88, 0.6, 1)",
          "Button/colors/font_disabled_color = Color(0.45, 0.43, 0.4, 1)", "Label/colors/font_color = Color(0.9, 0.87, 0.8, 1)"]
lines.append('Panel/styles/panel = SubResource("Box_panel")')
lines.append('PanelContainer/styles/panel = SubResource("Box_panel")')
lines.append('HSlider/styles/slider = SubResource("Box_groove")')
lines.append('HSlider/styles/grabber_area = SubResource("Box_fill")')
lines.append('HSlider/styles/grabber_area_highlight = SubResource("Box_fill")')
lines.append('HSlider/icons/grabber = ExtResource("%s")' % ids["slider_grabber"])
lines.append('HSlider/icons/grabber_highlight = ExtResource("%s")' % ids["slider_grabber_hi"])
lines.append('HSlider/icons/grabber_disabled = ExtResource("%s")' % ids["slider_grabber"])
# Variante «Slot» para las casillas de la mochila.
lines.append('Slot/base_type = &"Button"')
for state, box_id in (("normal", "slot"), ("hover", "slot"), ("pressed", "slot_selected"), ("hover_pressed", "slot_selected"), ("disabled", "slot")):
    lines.append('Slot/styles/%s = SubResource("Box_%s")' % (state, box_id))
lines.append('Slot/styles/focus = SubResource("Box_empty")')
open(os.path.join(REPO, "ui", "theme", "paine_theme.tres"), "w").write("\n".join(lines) + "\n")
print("tema escrito")
