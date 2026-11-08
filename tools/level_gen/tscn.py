# Pequeño escritor de .tscn (Godot 4, format=3) para armar escenas legibles.
import math

def v3(v): return "Vector3(%s, %s, %s)" % tuple(fmt(x) for x in v)
def fmt(x):
    if isinstance(x, float):
        s = ("%.4f" % x).rstrip("0").rstrip(".")
        return s if s not in ("-0", "") else "0"
    return str(x)
def col(c): return "Color(%s, %s, %s, %s)" % tuple(fmt(float(x)) for x in (list(c) + [1.0])[:4])

class Scene:
    def __init__(self):
        self.ext = []      # (type, path, id)
        self.sub = []      # (type, id, props)
        self.nodes = []    # (header, props)
        self._extmap = {}
    def res(self, path, typ):
        if path not in self._extmap:
            rid = "%d_%s" % (len(self.ext) + 1, path.split("/")[-1].split(".")[0][:12])
            self.ext.append((typ, path, rid)); self._extmap[path] = rid
        return 'ExtResource("%s")' % self._extmap[path]
    def subres(self, typ, props):
        rid = "%s_%d" % (typ, len(self.sub) + 1)
        self.sub.append((typ, rid, props))
        return 'SubResource("%s")' % rid
    def node(self, name, typ=None, parent=None, instance=None, groups=None, **props):
        h = '[node name="%s"' % name
        if typ: h += ' type="%s"' % typ
        if parent is not None: h += ' parent="%s"' % parent
        if instance: h += ' instance=%s' % instance
        if groups: h += ' groups=[%s]' % ", ".join('"%s"' % g for g in groups)
        h += "]"
        self.nodes.append((h, props))
    def save(self, path):
        out = ["[gd_scene format=3]", ""]
        for typ, p, rid in self.ext:
            out.append('[ext_resource type="%s" path="%s" id="%s"]' % (typ, p, rid))
        if self.ext: out.append("")
        for typ, rid, props in self.sub:
            out.append('[sub_resource type="%s" id="%s"]' % (typ, rid))
            out += ["%s = %s" % kv for kv in props.items()]
            out.append("")
        import re
        fix = lambda k: re.sub(r"^theme_override_(font_sizes|colors|constants|styles|fonts)_", r"theme_override_\1/", k)
        for h, props in self.nodes:
            out.append(h)
            out += ["%s = %s" % (fix(k), v) for k, v in props.items()]
            out.append("")
        open(path, "w").write("\n".join(out))

def look_rotation(pos, target):
    dx, dy, dz = (target[i] - pos[i] for i in range(3))
    yaw = math.atan2(-dx, -dz)
    pitch = math.atan2(dy, math.hypot(dx, dz))
    return (pitch, yaw, 0.0)
