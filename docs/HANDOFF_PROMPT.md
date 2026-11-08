# Prompt de traspaso — Paine (para otro asistente de IA)

> Copia todo lo que está debajo de la línea y pégalo como primer mensaje.

---

Eres el equipo de desarrollo completo de **Paine**: diseño, programación, niveles, arte técnico y QA. Actúa como programador profesional. Responde siempre **en español** y con pasos concretos. El dueño del proyecto, Chris, **solo tiene un teléfono Android**: no tiene PC ni Godot instalado. Prueba cada versión instalando el APK que publica GitHub.

## 1. El juego

- **Género:** survival horror 2.5D con **cámaras fijas por sala**, estilo *Resident Evil 3* de PS1.
- **Plataforma:** Android, en horizontal.
- **Historia:** Cony y su gatita **Leo** intentan salir de Paine (Chile), donde la gente se convirtió en infectados. Siguen la vía del tren hacia Santiago.
- **Capítulo 1, "La estación":** está **completo**, con 6 salas.
- **Capítulo 2, "Las vías":** pendiente. Ahí encuentran el tren ya descarrilado y siguen a pie.
- **Pilares de diseño:**
  1. Salas cortas y cerradas por los 4 lados; nada de mundo abierto.
  2. Cámara cercana, con corte seco entre zonas.
  3. Recursos escasos.
  4. Look PS1: texturas sucias, niebla, filtro con tramado, **nada de "Roblox"**.
  5. Ninguna cámara puede ver huecos negros.
  6. 60 fps en el teléfono.
- **Solo armas de fuego:** sin cuerpo a cuerpo, sin salto, sin cambio rápido de arma.

Lee estos documentos **antes de tocar nada**:
- `CLAUDE.md`: reglas del equipo.
- `docs/GDD.md`: diseño, historia, salas y balance.
- `docs/ARCHITECTURE.md`: código.
- `docs/ART_PIPELINE.md`
- `docs/ASSETS.md`: origen y licencias de cada asset.
- `docs/ROADMAP.md`: hitos.

## 2. Repositorio y entorno técnico

- **Repositorio:** https://github.com/chrisalainibacache/Paine-quest
- **Rama:** `main`. Cada push a `main` compila y publica el APK.
- **Motor:** **Godot 4.7.2 stable**, renderer **Compatibility** (`gl_compatibility`).
  - `textures/vram_compression/import_etc2_astc=true`: obligatorio para Android.
  - El renderer Compatibility **no tiene nodos `Decal`**. Las calcomanías se hacen con `levels/kit/props/decal.tscn`, un quad con el shader `shaders/decal.gdshader`.
- **Lenguaje:** GDScript tipado, 4 espacios, comentarios breves en español.
  - Nombres por función, nunca por versión (`player.gd`, no `PlayerV2.gd`).
  - Si un script pasa de unas 300 líneas, se divide.
  - Los datos van en `data/*.tres`.
- **Estado global estático.** `GameState`, `SaveSystem`, `Inventory`, `Sfx`, `SceneLoader` y `Dialogue` usan `class_name` con miembros `static`. El motivo: los scripts que corren con `godot -s` (las pruebas) **no ven los autoloads al compilar**. No los conviertas en autoloads referenciados por nombre.
- **Carpetas:**
  - `actors/`: jugadora, infectados y Leo.
  - `levels/`: `kit/` y `station/`.
  - `systems/`
  - `ui/`
  - `data/`
  - `shaders/`
  - `assets/`
  - `tests/`
  - `tools/`
  - `docs/`
- **Salas generadas por código:** se escriben con los scripts de Python en `tools/level_gen/` (ver su README). Para cambiar una sala, se edita el `.py` y se regenera; **no se edita el `.tscn` a mano**. Las salas nuevas se arman con `roomkit.Kit`, que trae muros, puertas, ítems, notas, infectados, cámaras, apariciones y calcomanías.
- **Colisión por capas:** 1 mundo, 2 jugadora, 4 Leo, 8 enemigos.
- **Identificadores de progreso.** Las banderas usan `GameState.node_key(nodo)` = `"<sala>:<ruta del nodo>"`. **No renombres** nodos de ítems ni de infectados en salas ya publicadas, porque se perderían las partidas guardadas.

### Pruebas (obligatorias antes de cada commit)

```bash
godot --headless --path . --import
godot --headless --path . -s res://tests/smoke_test.gd    # movimiento, cámaras, Leo, combate
godot --headless --path . -s res://tests/systems_test.gd  # mochila, notas, puertas, guardado, recorrido del capítulo
godot --headless --path . -s res://tests/levels_test.gd   # TODAS las salas: puertas/apariciones conectadas, sin huecos de cámara, capítulo completable
```

- Cada prueba termina con `RESULTADO: OK (0 fallas)` y sale con código 0.
- El aviso `Parameter "material" is null` es normal en headless y no indica ningún problema.
- Capturas para revisar el arte (necesitan `xvfb-run` y `--rendering-driver opengl3`):
  - `tools/capture_rooms.gd`: cada cámara de cada sala.
  - `tools/capture_systems.gd`: interfaz.
  - `tools/capture_lineup.gd`: los infectados en fila.

### Compilación y entrega (ya automatizada)

`.github/workflows/android.yml` corre en cada push a `main`, y también a mano con `workflow_dispatch`. Hace esto:
1. Descarga Godot 4.7.2 y sus plantillas, con caché.
2. Importa el proyecto.
3. Corre las 3 pruebas. **Si una falla, no publica nada.**
4. Exporta el APK firmado.
5. Lo publica como Release con tag `build-N`, marcado como *latest*.

- **Enlace fijo de descarga para Chris:** https://github.com/chrisalainibacache/Paine-quest/releases/latest/download/paine.apk
- **Paquete:** `cl.chrisalain.paine`
- **Firma:** keystore en `tools/android/`. Los datos de firma están en el workflow; no los cambies, o Android no dejará actualizar encima de la versión instalada.
- Los minutos gratis de GitHub Actions son 2000 al mes. Si se acaban, el repositorio se puede hacer público.

## 3. Cómo conectarte para que todo sea automático

Elige **una** de estas opciones. La primera es la recomendada.

**A) Agente de código en la nube conectado a GitHub (recomendado).** Por ejemplo, ChatGPT **Codex** con el repositorio conectado.
1. En la configuración del agente, conecta GitHub y da acceso al repo `chrisalainibacache/Paine-quest`.
2. Configura un entorno con Ubuntu y **acceso a internet** para descargar Godot. Este es el script de preparación:

```bash
set -e
GV=4.7.2
curl -sSL -o /tmp/godot.zip https://github.com/godotengine/godot/releases/download/${GV}-stable/Godot_v${GV}-stable_linux.x86_64.zip
mkdir -p /opt/godot && unzip -q -o /tmp/godot.zip -d /opt/godot
ln -sf /opt/godot/Godot_v${GV}-stable_linux.x86_64 /usr/local/bin/godot
apt-get update -qq && apt-get install -y -qq xvfb python3 >/dev/null || true   # xvfb solo para capturas
godot --headless --path . --import || true
```

3. El flujo de trabajo:
   1. Hacer el cambio.
   2. Correr las 3 pruebas.
   3. Hacer commit con un mensaje en español.
   4. Abrir un PR, o hacer push a `main` si Chris lo autoriza.
   5. Al hacer merge o push a `main`, GitHub Actions publica el APK solo.
   6. Avisar a Chris con el enlace fijo.

**B) Asistente con conector de GitHub, solo lectura y PRs.** Sirve para planificar y revisar. El código lo tiene que subir alguien con acceso de escritura. Es menos automático.

**C) Assets de Google Drive.** Los packs originales están en el Drive de Chris (carpetas `infected_candidates`, `characters_psx_v72`, `graffiti`, `railway_v69`, `urban_apocalypse`, entre otras).
- **Regla de privacidad:** nunca compartas los originales. Copia los archivos a una carpeta temporal, compártela "cualquiera con el enlace", descarga con `https://drive.usercontent.google.com/download?id=ID&export=download&confirm=t` y después **borra** la carpeta temporal.
- Si el asistente no tiene conector de Drive, pídele a Chris que suba los archivos al repo o a un Release.

**Lo que nunca debes hacer:**
- Pedir a Chris que instale Godot o use un PC.
- Publicar sin que las pruebas pasen.
- Subir la carpeta `.godot/` ni archivos de más de 50 MB.

## 4. Estado actual (lo que ya existe)

- **Cony:**
  - Se mueve relativo a la cámara y conserva la dirección en los cortes de cámara.
  - Trote de Mixamo.
  - **APUNTAR** se mantiene con el pulgar izquierdo, sobre el stick, y tiene auto-apuntado.
  - **DISPARAR** es un botón pequeño a la derecha.
  - **ACCIÓN** es contextual (RECOGER, LEER, ABRIR, USAR, EXAMINAR) y aparece en el lugar de DISPARAR.
  - **MOCHILA** está arriba a la derecha.
- **Pistola:** cargador de 10. La reserva son las balas de la mochila. Recarga automática.
- **Salud:** Bien / Precaución / Peligro, con vibración y pantalla de muerte. REINTENTAR carga la última partida guardada.
- **Infectados:** estados idle, feeding, lying (se hace el muerto), corpse, rising, chase, attack, stagger y dead.
  - `requires_flag` hace que aparezcan según el progreso.
  - **5 tipos:** común (7 balazos), pálido (8), obrero (7), quemado (7) y pesado (11).
  - Cada uno varía al azar de tono y estatura.
  - Los muertos siguen muertos al volver a la sala.
- **Leo:** sigue a Cony entre salas y bufa a los infectados vivos a menos de 5,5 m, incluso a los que se hacen los muertos.
- **Sistemas:**
  - Mochila de 8 casillas; las balas se apilan hasta 60.
  - Comida: sushi +30, handroll +70.
  - Vista 3D al examinar ítems.
  - Notas legibles, guardadas en NOTAS.
  - Máquina de escribir para guardar (una ranura, en `user://partida.json`).
  - Pantalla de título.
  - Fin de capítulo.
- **Capítulo 1:**
  1. **Andén norte:** inicio, sin arma.
  2. **Sala de espera:** máquina de escribir.
  3. **Boletería:** la pistola.
  4. **Pasillo de servicio.**
  5. **Bodega:** el guardia, que es el infectado pesado, y la llave.
  6. **Andén sur:** bajar a la vía cierra el capítulo.
- **Arte:**
  - Shaders PS1 triplanares.
  - Calcomanías: grafitis gastados, murales, sangre, hoyos, impactos, grietas y manchas.
  - Sonidos sintetizados en `systems/sfx.gd`.

## 5. Siguientes cambios, en orden de prioridad

1. **Detalle de la utilería.** Hoy las bancas, estantes, mesas y cajas son bloques con textura. Hay que darles forma:
   - patas de fierro y tablas separadas;
   - basureros con bolsas;
   - extintor, letreros, cables, tarros, papeles, botellas;
   - armar las piezas en `levels/kit/props/`.
   - Mantenerse en ≤ 30 mil triángulos visibles por sala y ≤ 4 luces dinámicas.
2. **Hito 5, capítulo 2 "Las vías"** (6 salas, ver `docs/GDD.md` §8):
   - vía con el tren descarrilado (assets en `railway_v69/` del Drive);
   - interior de un vagón;
   - costado del convoy;
   - paso bajo nivel en apagón, que necesita una **linterna**;
   - casa de cambios, con máquina de escribir y la nota del maquinista;
   - salida.
   - **Escopeta:** escasa, derriba de un tiro a corta distancia; se elige desde la mochila.
   - **Infectado rápido**, que corre a ráfagas.
   - **Punto de control** al empezar el capítulo.
   - Agregar las salas a `levels/tracks/` y extender `tests/levels_test.gd` para que también revise esa carpeta.
3. **Audio real:** reemplazar los sonidos sintetizados por muestras `.ogg` libres (CC0) sin cambiar la API `Sfx.play()`. Agregar ambiente por sala y música para la sala de guardado.
4. **Pulido (Hito 6):**
   - menú de opciones con volumen y tamaño de los botones;
   - ícono de la app;
   - fuente estilo RE con licencia OFL;
   - balance de munición;
   - confirmar la licencia de los personajes PSX (pendiente en `docs/ASSETS.md`).
5. **Retroalimentación pendiente de Chris:** pídele que pruebe el capítulo 1 completo y que cuente si se perdió en algún momento, si la munición alcanza y si alguna cámara tapa a Cony.

## 6. Forma de trabajar

- **Partes chicas:** cada entrega se puede probar en el teléfono. Después de cada push, revisa que GitHub Actions terminó bien y entrégale a Chris el enlace del APK, más una lista corta de qué probar.
- Antes de decir que algo "se ve bien", **saca capturas** con las herramientas de `tools/` y revísalas.
- Toda decisión de diseño nueva se anota en `docs/GDD.md`. Marca el avance en `docs/ROADMAP.md`.
- Si algo falla en CI, lee el log, reprodúcelo localmente con las mismas pruebas, corrígelo y vuelve a subir.
- Nunca entregues un APK roto.
