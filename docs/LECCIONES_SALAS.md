# Lecciones para armar salas (aprendidas con Chris, noviembre 2026) — LEER ANTES DE TOCAR UNA SALA

Estas reglas salen de errores reales que Chris vio en el teléfono. Cualquier sala nueva o cambiada **debe** cumplirlas.

## 1. Lógica del lugar (lo que más molesta al jugador)
1. **Toda llegada y toda salida tiene algo visible**: una puerta (`k.door_frame`), un portón, un túnel (`tunnels.carve`) o un hueco con camino. Isabella **nunca** aparece pegada a un muro liso ni «atraviesa una pared».
2. **Al aire libre no hay muros**: usa `buin_common.open_field(...)` (cerco bajo, portones, camino que sigue afuera, árboles, cerros, cielo). Los muros son para trincheras, galpones e interiores.
3. **Las vías nunca mueren en una pared**: acaban en un túnel, un tope de vía o siguen. Si se bifurcan, hay un cambio de vía con palanca (ver `track_north.py`).
4. **Un tren no atraviesa muros.** Un vagón entra a un túnel o queda entero dentro de la sala. Nada «medio metido» en la pared.
5. **Causa y efecto**: si algo arde, hay humo/brasas coherentes con la hora; si algo se cerró (reja, portón), quien lo cerró tiene sentido en la historia y nadie lo pasó por ahí antes.
6. **Todo paso tiene su explicación en el texto**: las pistas de Leo (acción concreta) y las notas deben coincidir con lo que se ve (nombres de puertas, flecha amarilla).

## 2. Escala y medidas
- Isabella mide 1,75 m. Una puerta mide ≥ 2 m. **Los trenes reales miden 20–24 m**: no uses el prop `train_wagon` (14 m, de cajas) en salas nuevas; los trenes reales los pone Claude al renderizar (`docs/trenes/plan_integracion.md`).
- Una sala con trenes necesita ~26 m de largo; las demás 14–20 m. El pasillo caminable no baja de ~2,5 m.

## 3. Cámaras y renderizado (esto lo hace Claude: tú dejas la sala lista y avisas)
- **No inventes cámaras definitivas.** Deja 2–3 `k.camera(...)` provisorias; Claude corre `tools/plan_cameras.gd` y renderiza los fondos.
- La cámara ve hasta **30 m** (`far`). Cielo, cerros y suelo exterior deben estar **a menos de ~16 m del borde de la sala** y ser sólidos (si no, `tests/levels_test.gd` falla con «no ve huecos»).
- Si cambias una sala **prerenderizada** (capítulo 1, `track_north`, `derailed_train`), **hay que volver a renderizarla**: avisa en el registro.

## 4. Código y generadores
- Las salas **no se editan a mano**: se edita `tools/level_gen/<sala>.py` y se regenera (`python3 tools/level_gen/<sala>.py`, o `regenerar_todo.sh`). Sube el `.tscn` **y** el generador.
- **Sube también los archivos `.uid`** de todo script nuevo (Godot los crea al importar).
- Scripts ≤ ~300 líneas. Datos en `data/*.tres`.
- En las pruebas **no esperes un número fijo de cuadros**: espera la condición (`for i in 240: if condición: break; await _frames(1)`). Una prueba intermitente cuesta horas.
- Nunca declares «funciona» sin `Pruebas en PR` en verde **y** sin `SCRIPT ERROR` en el log.

## 5. Herramientas que ya existen (úsalas en el PR y en el registro)
| Herramienta | Para qué |
| --- | --- |
| `tools/audit_spawns.gd` | Detecta llegadas pegadas a un muro sin puerta. |
| `tools/audit_cameras.gd` | Isabella nunca queda tapada ni fuera de cuadro (CI: ≤ 4 % de puntos malos). |
| `tools/plan_cameras.gd` | Planifica cámaras (Claude). |
| `tools/capture_rooms.gd` | Capturas de cada cámara (Claude, necesita Godot). |

## 6. Modelos de sala (copia su estilo)
`tools/level_gen/derailed_train.py` (vías, trenes, túnel, puertas), `track_north.py` (desvío, túneles, puerta de servicio), `buin_field.py` y
`buin_vineyard.py` (campo abierto), `buin_common.py` (helpers), `roomkit.py` (API).
