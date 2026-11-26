# Estándar de detalle de las salas (2026-11-26)

**Pedido de Chris:** todo el juego debe tener **el mismo nivel de detalle que el comienzo**, cuando Isabella aparece en el **andén norte**.
Hoy **solo el andén norte lo cumple**; el resto de las salas tiene entre 2 y 29 props y se ve vacío (La Maestranza: 2–6 props por sala).

## Referencia medida (`python3 tools/audit_detail.py`)
| | Andén norte (referencia) | Mínimo exigido por sala |
| --- | --- | --- |
| Nodos de la escena | 180 | **≥ 150** |
| Props instanciados | 44 | **≥ 40** |
| Tipos distintos de prop | 15 | **≥ 14** |
| Manchas / suciedad / decals | 29 | **≥ 15** |
| Cámaras (zonas) | 6 | **≥ 2** (las pone el planificador; las salas grandes necesitan más) |

La herramienta **falla** (`--check`) si una sala de `tools/detail_rooms.json` no llega. **Toda sala nueva o rehecha se agrega a esa lista** el mismo día que se crea (el CI la corre).

## Qué significa «el mismo detalle» (además de los números)
1. **Cada rincón cuenta algo**: desorden con causa (maletas, un termo, un casco, un cartel arrancado, sangre seca con trayectoria), no props repetidos en fila.
2. **Capas**: suelo (con juntas, charcos, manchas), muros (carteles, grietas, cables, tuberías), techo/estructura (vigas, luminarias), objetos grandes, objetos pequeños, **objeto interactivo claramente legible** (que no se pierda en el detalle).
3. **Texto en el mundo**: ≥ 4 carteles/rótulos/etiquetas por sala (`k.label`), coherentes con el guion.
4. **Luz con intención**: ≥ 2 fuentes de color distinto (sodio, fluorescente, emergencia, fuego) y un punto oscuro; sin salas «planas».
5. **Mismo render que el andén norte**: **todas las cámaras prerenderizadas** con la tubería de `docs/ART_PIPELINE.md` (Forward+ con niebla, sombras y suelo mojado cuando corresponda), **mismo tamaño y compresión** (WebP). Esto lo hace Claude; la geometría y los props los hace quien arma la sala.
6. **Interiores con forma**: salas en L/U con **muros interiores, columnas, mostradores, escalones**; nada de caja vacía.
7. **No repetir** la misma sala con otro nombre: cada una tiene un tema visual distinto (boletería ≠ oficina ≠ cabina).

## Cómo se cumple (flujo)
1. Quien arma la sala usa los props de `tools/level_gen/props*.py`, `buin_props.py`, `train_props.py`, `station_props.py` y **crea los que falten** como piezas generadas (no `.tscn` a mano).
2. `python3 tools/audit_detail.py` muestra la sala; si falta, se agrega detalle **antes** de pedir cámaras.
3. Claude planifica cámaras, renderiza fondos y revisa en capturas **al lado del andén norte**.
4. Si una sala no se parece al andén norte en la captura, **no se da por terminada** aunque pase los números.

## Herramienta lista: `tools/level_gen/detail.py` (Claude, 2026-11-26)
Una llamada viste una sala con zócalo, pilastras, vigas, ventanas con reja, tuberías, lámparas colgantes, extintor, reloj, mobiliario por **tema**
(`workshop`, `infirmary`, `locker`, `guard`, `corridor`, `office`, `storage`), suciedad en muros y piso y rótulos:

```python
import detail
detail.dress(k, -6, 6, -4, 4, 4.4, theme="workshop", seed=3, avoid=[(x, z, 0.6), ...])  # medidas reales; avoid = objetos propios de la sala
```
Piezas nuevas de utilería (en `tools/level_gen/props3.py`): `locker_row`, `shelf_unit`, `workbench`, `cot`, `oil_barrel`, `notice_board`, `extinguisher`, `pipe_rack`, `filing_cabinet`, `office_desk`, `cable_drum`, `tire`, `ladder`, `hanging_lamp`.
**Efecto medido:** las 7 salas de La Maestranza pasaron de 2–6 props a **38–43** y de ~55 a **~140 nodos** con esta llamada (ya la usan vía `maestranza_common.create_room(..., theme=...)`).
Úsala **y además** agrega detalle propio de cada sala (objetos con historia, carteles, desorden con causa): la herramienta pone la base, no el carácter. Si necesitas una pieza que falta, **créala en `props3.py`** (no a mano en `.tscn`).

## Variedad de tamaño, forma y altura (pedido de Chris, 2026-11-26)
«Casi todas las salas tienen las mismas dimensiones»: **ya no.** Reglas para toda zona nueva o rehecha:
- **Tamaños distintos**: mezcla pasillos largos y angostos (20 × 4–6 m), galpones altos (techo 6+ m), salitas (8 × 6 m) y salas grandes. **Ninguna zona tiene más de 2 salas de la misma medida.**
- **Verticalidad en ≥ 40 % de las salas**: **escaleras**, **balcones/entrepisos**, **pasarelas**, desniveles. Con `tools/level_gen/vertical.py`: `stairs(...)`, `balcony(...)`, `partition(...)`, `block_corner(...)` (sala en L). Medidas reales; la rampa de colisión de la escalera es invisible y el balcón tiene baranda con colisión. `tests/vertical_test.gd` demuestra que Isabella sube y no cae.
- **Recorridos con vistas**: pasar por un balcón que mira a otra sala, o una pasarela que cruza sobre un patio, es parte del diseño del hub (ver `docs/GUION_FINAL.md` §2): arriba va un objeto opcional.
- **Ejemplos hechos (La Maestranza):** `maestranza_acceso` (17 × 8, pasarela de vigilancia a 2,6 m con escalera), `maestranza_taller` (15 × 10, techo 6,4 m, entrepiso a 2,8 m), `maestranza_pasillo_cuarentena` (22 × 8, pasillo largo), `maestranza_guardia` (10 × 7), `maestranza_puesto_sanitario` (14 × 10). Se crean con `maestranza_common.create_room(..., size=(ancho, fondo), height=...)`.

## Fondos prerenderizados: estado (2026-11-26)
Las salas reformadas del capítulo 1 (`waiting_room`, `ticket_office`, `service_corridor`, `storeroom`, `south_platform`) y las nuevas (`oficina_jefe`, `banos`, `sala_maquinas`, `cabina_senales`) **no tienen fondo prerenderizado** (se borraron los viejos: tenían el mismo nombre de cámara y se habrían pintado sobre la geometría nueva). Se muestran con el 3D en vivo, que ya cumple el estándar de detalle. **Se renderizan cuando ChatGPT cierre P15** (geometría y cámaras definitivas): `docs/…/update grafica.txt` §4. **Regla:** al cambiar la geometría o las cámaras de una sala con fondos, borrar `assets/backgrounds/<sala>/` en el mismo commit hasta volver a renderizar.
