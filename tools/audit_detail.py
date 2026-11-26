#!/usr/bin/env python3
"""Mide el nivel de detalle de cada sala (lee los .tscn; no necesita Godot).
Referencia: el andén norte (levels/station/platform.tscn), lo primero que ve el jugador.
Uso:  python3 tools/audit_detail.py            -> tabla de todas las salas
      python3 tools/audit_detail.py --check    -> falla si una sala de tools/detail_rooms.json no llega al mínimo
Mínimos (docs/ESTANDAR_DETALLE.md): nodos >= 150, props >= 40, tipos distintos >= 14, manchas/suciedad >= 15, cámaras >= 4."""
import json
import os
import re
import sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
MINIMOS = {"nodos": 150, "props": 40, "tipos": 14, "manchas": 15, "camaras": 4}


def medir(path: str) -> dict:
    t = open(path, encoding="utf-8").read()
    inst = re.findall(r'\[node name="[^"]+" parent="[^"]*" instance=ExtResource\("([^"]+)"\)', t)
    return {"nodos": len(re.findall(r"^\[node", t, re.M)), "props": len(inst), "tipos": len(set(inst)),
            "manchas": len(re.findall(r"stain|Decal|Stain", t)), "camaras": len(re.findall(r'type="Camera3D"|CameraZone', t))}


def salas() -> list:
    out = []
    for d in ("station", "tracks", "buin", "maestranza", "centro_nos", "epilogo"):
        base = os.path.join(ROOT, "levels", d)
        if os.path.isdir(base):
            out += [os.path.join(base, f) for f in sorted(os.listdir(base)) if f.endswith(".tscn")]
    return out


def main() -> int:
    check = "--check" in sys.argv
    obligatorias = json.load(open(os.path.join(ROOT, "tools", "detail_rooms.json"), encoding="utf-8")).get("salas", [])
    fallas = []
    print("%-34s %6s %6s %6s %8s %7s" % ("sala", "nodos", "props", "tipos", "manchas", "camaras"))
    for p in salas():
        rel = os.path.relpath(p, os.path.join(ROOT, "levels")).replace(".tscn", "")
        m = medir(p)
        marca = ""
        if rel in obligatorias:
            malos = [k for k, v in MINIMOS.items() if m[k] < v]
            if malos:
                fallas.append((rel, malos))
            marca = "  <-- OBLIGATORIA" + ("  FALLA: " + ",".join(malos) if malos else "  ok")
        print("%-34s %6d %6d %6d %8d %7d%s" % (rel, m["nodos"], m["props"], m["tipos"], m["manchas"], m["camaras"], marca))
    if check and fallas:
        print("\nSalas por debajo del estándar de detalle:")
        for rel, malos in fallas:
            print("  -", rel, malos)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
