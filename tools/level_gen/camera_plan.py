# Aplica el plan de cámaras (cameras.json, lo calcula tools/plan_cameras.gd) a una
# sala: reemplaza las cámaras y zonas que puso el generador por las planificadas.
# Se llama solo desde Scene.save(): no hay que tocar cada generador.
import json
import math
import os

PLAN = os.path.join(os.path.dirname(os.path.abspath(__file__)), "cameras.json")


def _plan_for(path):
    if not os.path.exists(PLAN):
        return None
    with open(PLAN) as f:
        data = json.load(f)
    plan = data.get(os.path.splitext(os.path.basename(path))[0])
    return plan or None


def apply(scene, path):
    from tscn import v3, look_rotation, fmt
    plan = _plan_for(path)
    if not plan:
        return
    # 1. Fuera las cámaras viejas (nodos hijos de "Cameras") y sus formas de zona.
    kept = []
    removed_text = ""
    for header, props in scene.nodes:
        if 'parent="Cameras' in header:
            removed_text += header + str(props)
            continue
        kept.append((header, props))
    scene.nodes = kept
    still_used = "".join(h + str(p) for h, p in scene.nodes) + "".join(str(p) for _, _, p in scene.sub)
    scene.sub = [(t, rid, p) for (t, rid, p) in scene.sub
                 if not (t == "BoxShape3D" and ('"%s"' % rid) in removed_text and ('"%s"' % rid) not in still_used)]
    if not any(h.startswith('[node name="Cameras"') for h, _ in scene.nodes):
        scene.node("Cameras", "Node3D", ".")
    # 2. Las planificadas.
    script = scene.res("res://levels/kit/camera_zone.gd", "Script")
    for cam in plan:
        c, size = cam["zone_center"], cam["zone_size"]
        scene.node(cam["name"], "Area3D", "Cameras", position=v3(c), script=script)
        scene.node("Zone", "CollisionShape3D", "Cameras/" + cam["name"], shape=scene.subres("BoxShape3D", {"size": v3(size)}))
        pos, target = cam["cam_pos"], cam["target"]
        rel = tuple(pos[i] - c[i] for i in range(3))
        scene.node("Camera", "Camera3D", "Cameras/" + cam["name"], position=v3(rel), rotation=v3(look_rotation(pos, target)),
                   fov=fmt(float(cam["fov"])), near="0.1", far="60.0")
