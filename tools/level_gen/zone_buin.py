import sys, os
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
# Mapa de zona de Buin (cap. 3): 11 salas, hub = estación. Se genera aquí para no editar el .tres a mano.
NAMES = {"bridge": "Puente del Maipo", "checkpoint": "Control militar", "station": "Estación de Buin", "warehouse": "Bodega agrícola",
         "field": "Potrero", "vineyard": "Viña Santa Rosa", "shed": "Galpón de la viña", "canal_riego": "Canal de riego",
         "caseta_bomba": "Caseta de bombas", "patio_cosecha": "Patio de cosecha", "pasarela_vina": "Pasarela de la viña"}
GRID = {"bridge": (0, 0), "checkpoint": (1, 0), "warehouse": (0, 1), "station": (1, 1), "field": (2, 1), "canal_riego": (3, 1),
        "patio_cosecha": (0, 2), "vineyard": (2, 2), "caseta_bomba": (3, 2), "pasarela_vina": (1, 3), "shed": (2, 3)}
# (origen, destino, key_item, lock_id, one_way)
DOORS = [
    ("bridge", "checkpoint", "", "", False), ("checkpoint", "bridge", "", "", False), ("checkpoint", "station", "", "", False),
    ("station", "checkpoint", "", "", False), ("station", "warehouse", "", "", False), ("station", "field", "", "", False),
    ("station", "caseta_bomba", "", "buin_shortcut_pump_station", True),
    ("warehouse", "station", "", "", False), ("warehouse", "field", "", "", False), ("warehouse", "patio_cosecha", "", "", False),
    ("field", "station", "", "", False), ("field", "vineyard", "", "", False), ("field", "warehouse", "", "", False),
    ("field", "canal_riego", "", "", False), ("field", "checkpoint", "", "", False),
    ("vineyard", "field", "", "", False), ("vineyard", "shed", "shed_key", "shed_door", False), ("vineyard", "pasarela_vina", "", "", False),
    ("shed", "vineyard", "", "", False), ("shed", "patio_cosecha", "", "buin_shortcut_patio_shed", True),
    ("canal_riego", "field", "", "", False), ("canal_riego", "caseta_bomba", "", "buin_canal", False),
    ("canal_riego", "pasarela_vina", "", "buin_shortcut_walkway_canal", True),
    ("caseta_bomba", "canal_riego", "", "", False), ("caseta_bomba", "station", "", "buin_shortcut_pump_station", True),
    ("patio_cosecha", "warehouse", "", "", False), ("patio_cosecha", "pasarela_vina", "", "", False),
    ("patio_cosecha", "shed", "", "buin_shortcut_patio_shed", True),
    ("pasarela_vina", "vineyard", "", "", False), ("pasarela_vina", "patio_cosecha", "", "", False),
    ("pasarela_vina", "canal_riego", "", "buin_shortcut_walkway_canal", True),
]
# En el mapa solo se anota el atajo desde el lado que lo abre.
DOORS = [d for d in DOORS if not (d[0] == "station" and d[1] == "caseta_bomba") and not (d[0] == "shed" and d[1] == "patio_cosecha")
         and not (d[0] == "canal_riego" and d[1] == "pasarela_vina")]
out = ['[gd_resource type="Resource" script_class="ZoneMapData" load_steps=2 format=3]', "",
       '[ext_resource type="Script" path="res://data/zones/zone_map_data.gd" id="1_map"]', "", "[resource]",
       'script = ExtResource("1_map")', 'id = "buin"', 'display_name = "BUIN"', 'map_item_id = "map_buin"', "grid_size = Vector2i(4, 4)",
       "rooms = Array[Dictionary]([", ]
blocks = []
for rid, (gx, gy) in GRID.items():
    ds = [d for d in DOORS if d[0] == rid]
    conns = ", ".join('"%s"' % d[1] for d in ds)
    doors = ", ".join('{"label": "%s", "target": "%s", "key_item_id": "%s", "lock_id": "%s", "one_way": %s}' % (NAMES[d[1]], d[1], d[2], d[3], str(d[4]).lower()) for d in ds)
    blocks.append('{\n"id": "%s",\n"name": "%s",\n"scene_path": "res://levels/buin/%s.tscn",\n"grid_position": Vector2i(%d, %d),\n"connections": PackedStringArray(%s),\n"doors": Array[Dictionary]([%s])\n}' % (rid, NAMES[rid], rid, gx, gy, conns, doors))
out.append(",\n".join(blocks))
out.append("])")
open(REPO + "/data/zones/buin.tres", "w").write("\n".join(out) + "\n")
print("zona buin ok")
