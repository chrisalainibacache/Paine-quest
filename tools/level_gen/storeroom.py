import sys, math, os; sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
from roomkit import *
k = Kit("Storeroom", "Bodega")
k.env((0.02, 0.02, 0.025), (0.36, 0.36, 0.4), 0.7, (0.05, 0.05, 0.06), 0.05)
H = 3.2
k.shell(-3.5, 3.5, -3.0, 3.0, H, floor="concrete_floor", wall="bricks_wall", ceiling="concrete_wall")
k.door_frame("ToCorridor", -3.5, 1.6, "z", width=1.1, wall_side=1, panel="metal")
# Ventanuco alto con luz de luna (muro norte).
k.mesh("HighWindow", "Details", (1.6, 0.4, 0.02), k.emissive((0.35, 0.42, 0.55), 0.6), (-0.5, 2.7, -2.99))
for j in range(6):
    k.block("WindowBar%d" % j, "Details", (-1.2 + j * 0.28, 2.7, -2.97), (0.03, 0.4, 0.03), "metal", solid=False)
# Estanterías metálicas (muro norte).
for r, x0 in enumerate((-2.9, 0.1)):
    for i, y in enumerate((0.4, 1.1, 1.8)):
        k.block("Rack%d_Shelf%d" % (r, i), "Racks", (x0 + 1.0, y, -2.6), (2.0, 0.05, 0.6), "metal")
    for i, dx in enumerate((0.0, 2.0)):
        k.block("Rack%d_Post%d" % (r, i), "Racks", (x0 + dx, 1.1, -2.6), (0.06, 2.2, 0.6), "metal")
    for i, (dx, y, s) in enumerate([(0.4, 1.1, 0.4), (1.3, 1.1, 0.5), (0.6, 1.8, 0.45), (1.5, 0.4, 0.35)]):
        k.block("Rack%d_Box%d" % (r, i), "Racks", (x0 + dx, y + 0.025 + s / 2, -2.6), (s, s, s), "planks", solid=False)
# Cajas apiladas y sacos sobre un pallet (obstáculos).
k.prop("CrateA", "Props", "crate", (2.75, 0, -0.3), rot=(0, 0.1, 0))
k.prop("CrateB", "Props", "crate", (2.8, 0, 0.65), rot=(0, -0.2, 0))
k.prop("CrateC", "Props", "crate", (2.75, 0.9, 0.2), rot=(0, 0.3, 0))
k.block("Pallet", "Props", (0.0, 0.08, 0.7), (1.3, 0.16, 1.1), "wood")
k.block("Sacks", "Props", (0.0, 0.45, 0.7), (1.1, 0.6, 0.9), "gravel")
# Mesa con la llave del portón y el diario (rincón sureste).
k.block("TableTop", "Props", (3.05, 0.74, 1.85), (0.7, 0.05, 1.4), "wood")
for i, z in enumerate((1.25, 2.45)):
    k.block("TableLeg%d" % i, "Props", (3.05, 0.36, z), (0.6, 0.72, 0.06), "wood")
for i, (x, z, sz, seed) in enumerate([(1.8, -1.6, 1.6, 0.7), (-1.6, -0.4, 0.9, 3.3), (0.9, 2.2, 1.1, 5.1)]):
    k.prop("Stain%d" % i, "Props", "stain", (x, 0.012, z), rot=(0, seed, 0), scale=v3((sz, 1, sz)))
# Luces.
k.mesh("Bulb", "Lights", (0.1, 0.14, 0.1), k.emissive((1.0, 0.85, 0.6), 1.2), (0.3, H - 0.15, 0.0))
k.light("BulbLight", "Lights", (0.3, H - 0.35, 0.0), (1.0, 0.78, 0.5), 1.1, 6.5, flicker=True)
k.light("MoonLight", "Lights", (-0.5, 2.4, -2.2), (0.55, 0.65, 0.9), 0.5, 3.5)
# Interactuables.
k.door("DoorToCorridor", (-3.1, 0, 1.6), "res://levels/station/service_corridor.tscn", "from_storeroom")
k.pickup("GateKey", (3.0, 0.77, 1.55), "gate_key", rot=(0, 0.9, 0))
k.note("Diary", (3.05, 0.77, 2.2), "stationmaster_diary", paper_rot=(0, 1.4, 0))
k.pickup("Ammo", (-1.9, 0.43, -2.5), "ammo_9mm", 15, rot=(0, 0.3, 0))
k.pickup("Sushi", (0.9, 1.13, -2.5), "sushi", rot=(0, 0.2, 0))
k.examine("Sacks", (0.0, 0, 1.45), ["Sacos de ripio para la vía.", "Alguien se escondió detrás: hay un abrigo y una botella vacía."], reach=1.0)
# El guardia (infectado pesado), de cara a la pared.
k.infected("Guard", (2.4, 0.05, -2.2), yaw=math.pi, heavy=True)
# Calcomanías.
k.decal("GraffitiKm", "graffiti_km42", (-3.48, 1.9, -1.2), (2.8, 1.4), "+x", wear=0.45)
k.decal("BloodGuard", "blood_splatter_a", (2.7, 1.35, -2.98), 1.4, "+z", rot=0.3)
k.decal("HandTable", "blood_handprint", (3.48, 1.3, 0.35), 0.4, "-x", rot=0.5)
k.decal("HoleSouth", "wall_hole_b", (-1.8, 1.45, 2.98), 1.0, "-z")
k.decal("CracksSouth", "cracks", (1.0, 2.3, 2.98), 1.3, "-z")
k.decal("Oil", "oil_stain", (-1.5, 0.016, 0.7), 1.4, "up", rot=0.4)
k.decal("PoolGuard", "blood_pool", (2.0, 0.017, -1.55), 1.5, "up", rot=2.1)
k.decal("Drag", "blood_drag", (0.1, 0.018, -0.7), (3.0, 1.0), "up", rot=-0.5)
k.decal("Debris", "debris", (-2.5, 0.015, -1.6), 1.3, "up")
# Cámaras.
k.camera("West", (-1.6, 1.5, 0.0), (3.8, 3.0, 6.0), (3.2, 2.9, 2.7), (-2.5, 0.5, -0.9), fov=62)
k.camera("East", (1.9, 1.5, 0.0), (3.2, 3.0, 6.0), (-0.5, 2.9, 2.75), (2.8, 0.3, -0.2), fov=62)
k.spawn("from_corridor", (-2.7, 0.05, 1.6), (1, 0))
# Pistas de Leo: adonde guía a Cony cuando se queda quieta y qué le explica.
k.leo_hint('LeoKey', (2.4, 0, 1.55), ['Leo: Ahí, en la mesa: la llave del portón.', 'Leo: El que la cuida era don Héctor. Ya no es él, Cony. No le tengas pena.'], hide_item='gate_key')
k.save(REPO + "/levels/station/storeroom.tscn")
print("storeroom ok")
