import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from tscn import *

# La geometría se construye en vivo por el script; Python genera la escena raíz.
s = Scene()
s.node("CreatureDoor", "Node3D", script=s.res("res://levels/kit/cinematic.gd", "Script"), groups=["cinematics"])
s.save(os.path.join(os.path.dirname(os.path.abspath(__file__)), "../../levels/cinematics/creature_door.tscn"))
print("creature door ok")
