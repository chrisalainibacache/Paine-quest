import sys, os; sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
from tscn import *
s = Scene()
s.node("ChapterEnd", "Control", script=s.res("res://ui/chapter_end/chapter_end.gd", "Script"), anchors_preset="15", anchor_right="1.0",
       anchor_bottom="1.0", grow_horizontal="2", grow_vertical="2")
s.node("Background", "ColorRect", ".", anchors_preset="15", anchor_right="1.0", anchor_bottom="1.0", grow_horizontal="2", grow_vertical="2",
       color=col((0.0, 0.0, 0.0)))
def centered(name, top, bottom, text, size, color, wrap=False):
    extra = {"autowrap_mode": "3"} if wrap else {}
    s.node(name, "Label", ".", anchors_preset="5", anchor_left="0.5", anchor_right="0.5", grow_horizontal="2",
           offset_left="-520.0", offset_top=fmt(float(top)), offset_right="520.0", offset_bottom=fmt(float(bottom)), horizontal_alignment="1",
           text='"%s"' % text, theme_override_font_sizes_font_size=str(size), theme_override_colors_font_color=col(color), **extra)
centered("Title", 110, 190, "FIN DEL CAPÍTULO 1", 64, (0.62, 0.08, 0.06))
centered("Subtitle", 195, 235, "La estación", 30, (0.6, 0.57, 0.5))
centered("Story", 270, 420, "Cony y Leo bajan a la vía y siguen hacia el norte, hacia el resplandor rojo.\\nDetrás queda la estación de Paine, en silencio.", 26, (0.85, 0.82, 0.75), True)
centered("Summary", 440, 480, "", 22, (0.6, 0.57, 0.5))
centered("Next", 500, 540, "Continuará en el Capítulo 2: Las vías", 24, (0.85, 0.72, 0.5))
s.node("Back", "Button", ".", anchors_preset="7", anchor_left="0.5", anchor_top="1.0", anchor_right="0.5", anchor_bottom="1.0",
       grow_horizontal="2", grow_vertical="0", offset_left="-190.0", offset_top="-130.0", offset_right="190.0", offset_bottom="-56.0",
       text='"VOLVER AL TÍTULO"', theme_override_font_sizes_font_size="28", focus_mode="0")
s.save(REPO + "/ui/chapter_end/chapter_end.tscn")
print("chapter end ok")
