"""Adaptador para usar detail.dress en los generadores antiguos basados en tscn.Scene."""
from roomkit import v3, add_decal
from tscn import fmt, look_rotation, col

class SceneKitAdapter:
    """Adaptador para los generadores antiguos basados en tscn.Scene."""
    def __init__(self, scene, block_fn, prop_fn):
        self.s = scene
        self._block_fn = block_fn
        self._prop_fn = prop_fn
        self._groups = set()

    def _group(self, parent):
        if parent == "." or parent in self._groups:
            return
        self.s.node(parent, "Node3D", ".")
        self._groups.add(parent)

    def block(self, name, parent, pos, size, mat, solid=True, rot=None):
        self._group(parent)
        self._block_fn(name, parent, pos, size, mat, solid=solid, rot=rot)

    def prop(self, name, parent, scene, pos, rot=None, **extra):
        self._group(parent)
        self._prop_fn(name, parent, scene, pos, rot=rot, **extra)

    def label(self, name, parent, pos, text, size, color, rot=None):
        self._group(parent)
        props = {"position": v3(pos), "text": '"%s"' % text, "font_size": str(size),
                 "pixel_size": "0.004", "modulate": col(color), "outline_size": "0"}
        if rot:
            props["rotation"] = v3(rot)
        self.s.node(name, "Label3D", parent, **props)

    def decal(self, name, tex, pos, size, normal, rot=0.0, tint=None, opacity=1.0, wear=0.0):
        self._group("DetailDecals")
        add_decal(self.s, "DetailDecals", name, tex, pos, size, normal,
                  rot=rot, tint=tint, opacity=opacity, wear=wear)

    def light(self, name, parent, pos, color, energy, rng, flicker=False):
        self._group(parent)
        props = {"position": v3(pos), "light_color": col(color),
                 "light_energy": fmt(float(energy)), "omni_range": fmt(float(rng))}
        if flicker:
            props["script"] = self.s.res("res://levels/kit/flicker_light.gd", "Script")
        self.s.node(name, "OmniLight3D", parent, **props)

    def camera(self, name, zone_center, zone_size, cam_pos, target, fov=60.0, priority=0):
        self._group("Cameras")
        props = {"position": v3(zone_center),
                 "script": self.s.res("res://levels/kit/camera_zone.gd", "Script")}
        if priority:
            props["camera_priority"] = str(priority)
        self.s.node(name, "Area3D", "Cameras", **props)
        self.s.node("Zone", "CollisionShape3D", "Cameras/" + name,
                    shape=self.s.subres("BoxShape3D", {"size": v3(zone_size)}))
        relative = tuple(cam_pos[index] - zone_center[index] for index in range(3))
        self.s.node("Camera", "Camera3D", "Cameras/" + name, position=v3(relative),
                    rotation=v3(look_rotation(cam_pos, target)), fov=fmt(float(fov)),
                    near="0.1", far="30.0")


    def mesh(self, name, parent, size, material, pos):
        self._group(parent)
        self.s.node(name, "MeshInstance3D", parent,
                    mesh=self.s.subres("BoxMesh", {"size": v3(size)}),
                    material_override=material, position=v3(pos))
