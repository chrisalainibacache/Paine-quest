# Assets

Estado de los assets necesarios para el capítulo 1. Los packs del proyecto anterior
están en Google Drive (`assets/` del proyecto Forge) y se migran aquí pack por pack,
revisando licencia y peso.

Leyenda: ✅ lo tenemos · ⚠️ lo tenemos pero hay que revisar/adaptar · ❌ falta

## Personajes

| Asset | Estado | Origen / nota |
| --- | --- | --- |
| Cony (modelo con rig Mixamo) | ⚠️ | `models/Erika_Walking.fbx` + `psx_character/`. Revisar cuál es la versión final. |
| Animaciones de Cony: idle, caminar, correr, apuntar pistola, disparar, recargar, recibir daño, morir | ⚠️ | `animations/` (Mixamo + UAL2). Falta apuntar/disparar/recargar/morir (Mixamo las tiene gratis). |
| Leo (gatita) | ✅ | Gato animado Quaternius (CC0) recoloreado gris: Idle, Walk, Run, Headbutt... |
| Infectado (modelo + rig) | ✅ | `infected/infected_psx_05.glb` (PSX, ~850 triángulos). Licencia del pack por confirmar. |
| Animaciones infectado | ✅ | Quaternius UAL2: Zombie_Idle/Walk/Scratch, LayToIdle, Consume, Hit_Knockback + UAL1: Hit_Chest, Death01. |
| Infectado rápido (cap. 2) | ⚠️ | Mismo rig con otra textura y animación de correr. |

## Escenarios (kits modulares)

| Zona | Estado | Origen / nota |
| --- | --- | --- |
| Estación (andén, muros, techos, bancas) | ⚠️ | `psx_buildings/`, `railway/`, `railway_v69/`, `signs/`. |
| Tren y vagones | ✅ | `railway_v69/` (locomotora, vagones b y c, vías). |
| Calle/callejón (vehículos, barreras, conos) | ✅ | `urban_apocalypse/`, `atomic_realm_post_apocalyptic/`. |
| Interior de vagón | ⚠️ | Se arma con el kit modular + asientos de `railway_v69/`. |
| Paso bajo nivel / casa de cambios | ⚠️ | Kit modular de concreto + props. |
| Texturas PS1 (concreto, grafiti, grava, metal) | ✅ | `textures/`, `materials/`. |

## Armas e ítems

| Asset | Estado | Origen / nota |
| --- | --- | --- |
| Pistola | ✅ | Low poly hecha con piezas (`actors/player/pistol.tscn`). |
| Escopeta | ❌ | Pendiente (capítulo 2). |
| Íconos de inventario | ✅ | `inventory/` (+ íconos vectoriales hechos en código). |
| Llaves, notas, comida | ⚠️ | Íconos sí; modelos 3D simples por hacer. |

## Interfaz

| Asset | Estado | Nota |
| --- | --- | --- |
| Stick virtual y botones | ✅ | `thumb-stick-*.png`, `icons/`. |
| Fuente estilo RE | ❌ | Buscar fuente libre (OFL). |
| Ícono de la app | ❌ | `icon.png` no está en el repo anterior. |

## Audio

| Asset | Estado | Nota |
| --- | --- | --- |
| Efectos (pasos, disparos, golpes, gemidos) | ⚠️ | Hoy se sintetizan en código. Mejor reemplazar por muestras reales (OGG). |
| Ambientes (viento, mina) | ⚠️ | Igual que arriba. |
| Música (sala de guardado, tensión) | ❌ | Falta. |

## Reglas para agregar assets

- Formatos: modelos `.glb`, texturas `.png`, audio `.ogg`.
- Texturas ≤ 512 px (estilo PS1 y memoria en Android).
- Cada pack lleva su licencia en un `LICENSE.txt` dentro de su carpeta.
- Binarios en git normal (sin LFS) mientras el total sea razonable; cada archivo < 50 MB.
