# Estado de Paine para retomar (noviembre 2026)

Resumen para continuar en un chat nuevo sin perder contexto. Léelo junto con `CLAUDE.md`, `docs/GDD.md`,
`docs/ROADMAP.md`, `docs/AUDIO_PLAN.md` y `docs/CHATGPT_LOG.md`.

## Qué es y cómo se prueba
Survival horror 2.5D de cámaras fijas (estilo RE3 PS1), Godot 4.7.2, Android horizontal. Chris prueba en un
Redmi 13C; no tiene PC. **APK siempre desde GitHub** (descargar por Telegram/chat falló):
https://github.com/chrisalainibacache/Paine-quest/releases/latest/download/paine.apk (~78 MB, build-70 al escribir esto).
Cada push a `main` compila y publica el APK. Responder en español, con pasos concretos.

## Historia (canon, ver GDD §2)
Isabella (antes "Cony") y su gata **Leo** (en secreto la gata que murió: es su última aventura) viajan desde Paine
hacia Santiago a buscar a su hermana **Paz** (antes "Javiera"). Cap. 1 estación (6 salas), cap. 2 las vías (6),
cap. 3 Buin (7, con Kiara y Nala). Faltan cap. 4 La Maestranza (San Bernardo, donde trabaja Paz), cap. 5 Santiago /
Centro de Nos y epílogo «Para Leo». **Skull**: criatura que busca a Isabella, nunca se ve (cinemática de puerta que
estalla al empezar el cap. 2, ticket T9); no se relaciona con el pasajero del asiento 15; habrá encuentro (propuesta: cap. 4).

## Decisiones abiertas (esperan a Chris)
- **Por qué partió todo** (origen de la infección / el pasajero del asiento 15 / vagón del Centro de Nos): sin decidir.
  Opciones propuestas: A experimento que se escapó, B contagio previo ocultado, C conexión personal con la familia.
  Bloquea las notas del cap. 4 y 5.
- Cinemática de Skull: ¿en vivo (ticket T9, ChatGPT) o render HD con el método de `render_cinematic.gd`?
- Cierre del cap. 4 y papel de Paz: propuestas en `docs/CHATGPT_LOG.md` (sin confirmar por Chris).

## Lo hecho recientemente
Cámaras planificadas (`tools/plan_cameras.gd`, auditoría `audit_cameras.gd`); flechas ▼ y letreros en puertas
(`Door.LABELS`); cartel de lugar al entrar; pistas de Leo con acción concreta; modo Moderno por defecto; bisel en cajas;
tren detallado; pantalla DIAG en la mochila; **bug del export** (textos vacíos en el APK) arreglado con
`export/convert_text_resources_to_binary=false` + `tools/export_probe.gd` en CI.
**Audio real** (≈6,8 MB, `docs/AUDIO_PLAN.md`): armas, infectados, puertas/objetos, 14 ambientes, 6 pistas de música
(Kevin MacLeod CC BY 4.0: exige créditos en el juego → T10). **Cinemática de apertura** (video Theora 7,5 s +
título, una vez por partida nueva, `ui/cinematic/video_cinematic.gd`).

## Cómo trabajamos con ChatGPT (supervisado por Claude)
ChatGPT implementa tickets en ramas `chatgpt/<ID>-tema` + PR; Claude revisa y fusiona con *squash*. Canal único:
`docs/CHATGPT_LOG.md`. No puede correr Godot ni subir binarios (los `.ogg`/video los sube Claude). El workflow
«Pruebas en PR» corre tests, auditoría de cámaras y export. **Un verde solo cuenta si no hay `SCRIPT ERROR`**
(`tools/run_tests.sh`). Cola: T9 (cinemática Skull), T10 (créditos), T11 (conectar sonidos/música que faltan),
T6 (pruebas de puertas), T1–T3 (capítulos 4, 5, epílogo; texto), D (implementar cap. 4: bloqueado hasta «APROBADO D»).

## Reglas y trampas
- Salas: editar `tools/level_gen/*.py` y regenerar (`tools/level_gen/regenerar_todo.sh`); nunca el `.tscn` a mano.
- Cámaras tras tocar geometría: `plan_cameras.gd` → regenerar → `audit_cameras.gd`. Fondos prerenderizados solo cap. 1:
  cambiar sus cámaras obliga a re-renderizar (`update grafica.txt`).
- Tests: `GODOT=... ./tools/run_tests.sh`. Una falla intermitente de `smoke` (disparos de pistola) aparece a veces en la
  primera corrida tras importar; no se ha podido reproducir a voluntad.
- No poner nombres de modelos en commits; no mezclar nada del trabajo/empresa de Chris; originales del Drive son privados.
- Pendiente de prueba de Chris en el teléfono: armas, infectados, puertas, ambientes y música (oído suyo), cinemática de apertura.
