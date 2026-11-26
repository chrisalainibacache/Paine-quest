import sys, math, os; sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
from roomkit import *
import detail
# Arena de prueba del jefe (Skull): patio de maniobras con vagones como cobertura. Se llega desde el título (JEFE · PRUEBA).
# Reglas del combate: la embestida se esquiva apartándose; si choca con un vagón queda aturdido y recibe doble daño.
k = Kit("SkullArena", "Patio de maniobras", ambience="tracks_night")
k.env((0.06, 0.07, 0.09), (0.6, 0.64, 0.75), 1.5, (0.1, 0.11, 0.14), 0.012)
H = 6.0
k.shell(-11.0, 11.0, -7.0, 7.0, H, floor="gravel", wall="old_bricks_wall", ceiling="concrete_wall")
k.spawn("start", (-9.0, 0.05, 0.0), (1, 0))
# Cobertura: dos vagones atravesados y un tercero más al fondo (de costado) que sirve de «pared» para las embestidas.
k.prop("WagonA", "Props", "train_wagon_half", (-3.0, 0.0, -3.4), rot=(0, 0.0, 0))
k.prop("WagonB", "Props", "train_wagon_half", (1.5, 0.0, 3.6), rot=(0, 0.0, 0))
k.prop("WagonC", "Props", "train_wagon_half_wrecked", (6.5, 0.0, -2.4), rot=(0, math.pi / 2, 0))
for i, (x, z) in enumerate(((-6.5, 4.6), (-6.2, 5.0), (3.5, -5.6), (8.0, 4.8), (9.0, 4.4))):
    k.prop("Barrel%d" % i, "Props", "oil_barrel", (x, 0.0, z), rot=(0, 0.7 * i, 0))
k.prop("Sandbags", "Props", "sandbags", (-8.0, 0.0, -4.8), rot=(0, 0.3, 0))
for i, (x, z) in enumerate(((-6.0, -3.5), (-6.0, 3.5), (3.0, 0.0), (9.0, 0.0))):
    k.prop("ArenaLamp%d" % i, "Lights", "sodium_lamp", (x, H - 0.3, z))
k.pickup("ArenaAmmo", (-9.5, 0.0, -6.0), "ammo_9mm", 20)
k.pickup("ArenaShells", (-9.5, 0.0, 6.0), "ammo_shells", 8)
k.pickup("ArenaHeal", (-8.5, 0.0, 0.0), "sushi")
# El jefe aparece al fondo cuando Isabella se acerca.
k.s.node("BossEncounter", "Node3D", ".", position=v3((0.0, 0.0, 0.0)), script=k.s.res("res://levels/kit/boss_encounter.gd", "Script"),
         boss_data=k.s.res("res://data/enemies/skull.tres", "Resource"), spawn_position=v3((8.5, 0.05, 0.5)), trigger_radius="7.0")
k.camera("West", (-5.5, 3.0, 0.0), (11.0, 6.0, 14.0), (-1.0, 5.0, 6.4), (-5.5, 0.5, 0.0), fov=64)
k.camera("East", (5.5, 3.0, 0.0), (11.0, 6.0, 14.0), (1.0, 5.0, -6.4), (5.5, 0.5, 0.0), fov=64)
detail.dress(k, -10.7, 10.7, -6.7, 6.7, H, theme="storage", seed=99, avoid_rects=[(-4.5, 2.5, -5.2, -1.6), (-1.0, 4.0, 1.8, 5.4), (4.5, 8.7, -4.4, -0.4)])
k.save(REPO + "/levels/test/skull_arena.tscn")
print("skull_arena ok")
