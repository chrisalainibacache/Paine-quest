# Relevo para Claude — P15 capítulo 1
Fecha: 2026-11-26
Rama: `chatgpt/P15-cap1`
PR: #25
Estado: **DOCUMENTACIÓN DE RELEVO; P15 NO TERMINADO NI VALIDADO**

## Alcance que debe respetarse
Leer primero `docs/CHATGPT_ENCARGO_LARGO.md`, sección «ACTUALIZACIÓN DE PRIORIDADES (2026-11-26, tarde)», y después el apartado P15. Leer completos `docs/GUION_FINAL.md` y `docs/ESTANDAR_DETALLE.md`. Fuente de diseño de estación: `docs/zonas/cap1_estacion.md`.

Prioridades obligatorias:
1. La estación debe ser un hub no lineal con tres alas: Boletería/Oficina; Servicios/Bodega; Máquinas/Cabina. Los tres objetos de paso abren el portón sur.
2. Cada sala creada o rehecha debe alcanzar el detalle del andén norte y añadirse a `tools/detail_rooms.json`.
3. Kiara y Nala fueron eliminadas del canon: no deben aparecer en notas, pistas, diálogos ni textos.
4. No modificar `main`; trabajar únicamente en `chatgpt/P15-cap1` y PR #25.
5. Generar escenas desde los generadores; no editar manualmente escenas `.tscn`.

## P15 — lista de cierre

### A. Regeneración e integridad
- [ ] Ejecutar `python3 tools/level_gen/regenerar_todo.sh` en la rama P15.
- [ ] Revisar diferencias generadas y confirmar que cada escena corresponde a su generador.
- [ ] No declarar regeneración hasta que la ejecución termine correctamente.

### B. Hub, salas y detalle visual
- [ ] Revisar las 10 salas: 6 existentes reformadas y 4 nuevas (`oficina_jefe`, `banos`, `sala_maquinas`, `cabina_senales`).
- [ ] Confirmar grafo de tres alas, bucles, atajos, retroceso premiado y opcionales.
- [ ] Agregar las 10 salas a `tools/detail_rooms.json` según el contrato de detalle.
- [ ] Ejecutar `python3 tools/audit_detail.py --check`.
- [ ] Umbrales por sala: ≥150 nodos, ≥40 props, ≥14 tipos distintos, ≥15 decals/manchas y ≥4 cámaras.
- [ ] Si la auditoría falla, completar la geometría/props mediante generadores; registrar los fallos exactos.
- [ ] Replanificar cámaras de las salas reformadas y nuevas; Claude debe renderizar/revisar fondos con la tubería de `docs/ART_PIPELINE.md` y compararlos visualmente con el andén norte.

### C. Puzzles y estado persistente
- [ ] Caja fuerte de boletería: código 0712 y dos pistas.
- [ ] Dos fusibles (baños y oficina) activan tablero de sala de máquinas, compuerta eléctrica y `door_cabina_sur`.
- [ ] Palancas de cabina en el orden indicado por el diagrama de la oficina.
- [ ] Casillero 04 del pasillo entrega `gate_key`; registrar la pista «04».
- [ ] `office_key` en el abrigo de la oficina.
- [ ] Pestillo pasillo→bodega con barra caída.
- [ ] Dos puertas unidireccionales funcionan como atajos.
- [ ] Guardado/carga conserva los puzzles resueltos; `puzzle_lab` sigue verde.
- [ ] Un commit por puzzle, siguiendo el contrato del encargo.

### D. Objetos, rutas y balance
- [ ] `map_station` dentro de un archivador de `oficina_jefe`, nunca en el piso.
- [ ] Notas con textos exactos de `docs/zonas/cap1_estacion.md`.
- [ ] Pistas N1/N2/N3 de Leo por sala; sin flechas amarillas permanentes dentro de la zona.
- [ ] Prueba de alcanzabilidad demuestra dos rutas diferentes hasta `anden_sur` y que cada llave se obtiene antes de la puerta que la exige.
- [ ] Añadir pruebas (no eliminar pruebas existentes): 10 salas cargables, spawns cubiertos por cámara, destinos de puertas válidos, mapa coherente, puzzles persistentes.
- [ ] Revisar munición/curación: total del capítulo no aumenta más de 30% respecto del total previo.
- [ ] Verificar enemigos según diseño: dos infectados comunes al volver con pistola, uno dormido, uno fingiendo y Don Héctor.
- [ ] Estimar duración: primera partida 25–35 min con ayuda; identificar bloqueos que impidan terminar corriendo hacia adelante.

### E. Integración técnica y validación
- [ ] Importar el proyecto en Godot 4.7.2 y confirmar/importar los UID requeridos para `bar_latch.gd`, `cistern_valve.gd`, `vending_noise.gd` si aún corresponde.
- [ ] Integrar `VendingNoise.attenuate_footstep_radius` con `Noise.make` de P14 cuando la dependencia esté disponible; si P14 no está en la base, documentar y no introducir una dependencia rota.
- [ ] Validar el sonido de máquina en Android.
- [ ] Ejecutar el CI de PR #25 en el HEAD actual y revisar los logs completos.
- [ ] Buscar literalmente `SCRIPT ERROR`; cualquier aparición bloquea el OK.
- [ ] Confirmar los workflows verdes en el commit actual, no en un commit anterior.
- [ ] Probar en Android las rutas A y B, un atajo, la caja fuerte y los fusibles.
- [ ] Actualizar `docs/ROADMAP.md`, `docs/GDD.md` y `docs/CHATGPT_LOG.md`.
- [ ] Cerrar el paquete con tabla de no linealidad: hub, tres alas, objetos de paso, dos rutas por objetivo, dos bucles, dos atajos, ≥3 zonas que se abren al volver, ≥2 opcionales con recompensa y referencia a la prueba de alcanzabilidad.
- [ ] Convertir PR #25 de borrador a listo solo cuando las validaciones requeridas estén resueltas o explícitamente aceptadas por Claude.

## Límite de la revisión actual
Esta nota es un relevo de tareas basado en el encargo y las prioridades vigentes. **No afirma** que se haya ejecutado el regenerador, el audit, la importación de Godot, el CI del HEAD actual ni una prueba Android. Esas ejecuciones deben quedar respaldadas por sus resultados reales.

## Qué debe reportar Claude al terminar
1. SHA del HEAD validado.
2. Lista de comandos ejecutados y resultados.
3. Salida de `audit_detail.py --check` y cualquier excepción aprobada.
4. Estado de CI y confirmación de cero `SCRIPT ERROR`.
5. Evidencia de rutas alcanzables y balance de recursos.
6. Revisión visual de cámaras/fondos frente al andén norte.
7. Lista de bloqueos restantes; no escribir «P15 terminado» si queda alguno de los criterios de cierre sin validar.
