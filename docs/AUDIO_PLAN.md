# Plan de audio — Paine

**Estado hoy:** todos los sonidos se **sintetizan por código** (`systems/sfx.gd`, 22 kHz, 24 sonidos).
No hay archivos de audio, ni música, ni ambiente por sala, ni buses de volumen. Suena a "juguete".
**Meta:** sonido de survival horror real: armas con peso, infectados creíbles, puertas con
carácter, ambiente que da miedo y una banda sonora escasa y melancólica (el juego es la última
aventura de Leo: tensión, pero también ternura).

## 1. Reparto (importante)
- **ChatGPT escribe el código y las pruebas** (cargador de audio, buses, director de música/ambiente).
  Puede trabajar **sin los archivos**: el cargador usa el sonido sintetizado cuando falta el `.ogg`.
- **Claude consigue, recorta, normaliza y sube los `.ogg`** (ChatGPT no puede subir binarios).
  Fuentes: OpenGameArt (CC0 / CC-BY), incompetech (CC-BY 4.0) y archive.org. Todo con licencia
  libre y anotado en `CREDITS.md`. Nadie "oye" el resultado en el servidor: **Chris decide por oído
  en el teléfono**; Claude solo verifica duración, nivel (LUFS) y que no haya cortes.
- **Contrato de nombres** (para que código y archivos se encuentren sin hablar):
  - `res://assets/audio/sfx/<nombre>.ogg` o variantes `<nombre>_1.ogg`, `<nombre>_2.ogg`… (se elige una al azar)
  - `res://assets/audio/music/<pista>.ogg`
  - `res://assets/audio/ambience/<ambiente>.ogg`

## 2. Presupuesto
APK actual ≈ 70 MB. Audio **≤ 10 MB** en total: SFX mono 22–32 kHz (q3), ambientes mono 32 kHz
(q2), música estéreo 44,1 kHz (q3) en lazos cortos (45–90 s). Carga bajo demanda (no precargar la música).

## 3. Buses (`default_bus_layout.tres`)
`Master` → `Sfx`, `Music`, `Ambience`, `Ui`. Valores iniciales: Sfx 0 dB, Music −8 dB, Ambience −10 dB,
Ui −6 dB. Todos los `Sfx.play()` van al bus `Sfx` (menús al `Ui`). Preparar el control de volumen
(sliders en la mochila o en el título) en un ticket posterior.

## 4. Hoja de sonidos (SFX)
Los nombres con `*` ya existen en el juego (se reemplazan sin tocar quien llama). Los demás son nuevos.

**Armas** (cada disparo con 2–3 variantes; cortos, secos, con cola de eco de sala):
`shot*` (pistola 9 mm), `mauser` (C96, más seco), `shotgun*`, `rifle*`, `assault` (ráfaga corta),
`launcher*`, `bazooka`, `explosion*` (con retumbo grave), `click*` (gatillo vacío), `reload*` (cargador),
`shell_drop` (casquillo en el piso), `weapon_equip` (sacar arma de la mochila).

**Infectados** (graves, húmedos, *no* "gritos de película"; 3–4 variantes de cada):
`groan*` (largo), `groan_short*`, `groan_far` (apagado, lejano), `bite*`, `hit*` (bala que impacta),
`fall*` (cuerpo cae), `death` (último estertor), `rise` (se levanta del suelo), `chase` (cuando corre a
ráfagas, el infectado rápido: jadeo gutural), `heavy_step` (pasos del pesado), `hiss*` (Leo bufa).
**Isabella:** `hurt*`, `hurt_low` (en Peligro), `breath_low` (respiración cansada, en Peligro).

**Puertas y objetos:** `door*` (madera, con crujido; 3 variantes), `door_metal` (reja/portón), `locked*`
(picaporte trabado), `unlock*` (llave y candado), `gate_chain` (cadena), `pickup*`, `page*`, `typewriter*`
(tecla + campanilla), `menu*` (clic suave), `heal` (comer / curarse), `radio_static` (radio de Paz).

**Animales:** `meow*` (Leo, 3 variantes tiernas), `purr` (ronroneo, para el epílogo), `bark*`, `bark_deep*`
(Kiara y Nala), `growl_dog` (gruñido).

**Reservados para la criatura** (no implementar aún; los usará una futura escena): `creature_door_smash`
(puerta rota a lo lejos), `creature_roar_far` (rugido apagado), `creature_step_far`.

## 5. Ambientes (lazos de 20–40 s, `Ambience`, uno por sala; `Room.ambience`)
`station_night` (viento, farol de sodio zumbando, goteo lejano) · `waiting_room` (reloj parado, zumbido
fluorescente) · `office` (silencio de oficina, madera) · `service_corridor` (tubería, eco) · `storeroom`
(frío, algo húmedo) · `tracks_night` (grillos lejanos, viento sobre la vía, metal enfriándose) ·
`fire_wreck` (fuego crepitando, metal que cruje) · `train_interior` (traqueteo ausente: silencio hueco,
vidrios) · `underpass` (eco, goteo, el apagón) · `switch_house` (calma de amanecer: pájaros tímidos) ·
`day_fields` (Buin de día: viento, moscas, pájaros que *no* están) · `bridge_river` (río crecido) ·
`military` (radio lejana, lona) · `barn` (madera, polillas).

## 6. Música (3 a 5 pistas, lazos largos, `Music`)
Estilo: **ambient oscuro y escaso**, sin melodías pegajosas; nada épico. Unas pocas notas de piano o
cuerdas con mucho aire. Leo trae un tema aparte, **cálido y frágil**.
- `title` — melancólica, lenta; pantalla de título. · `explore_night` — drone grave, casi inaudible (cap. 1–2).
- `explore_day` — hueca y luminosa (cap. 3). · `tension` — pulso grave que crece cuando hay infectados
  persiguiendo; **corta** al morir el último. · `safe` — piano muy suave en la sala de la máquina de escribir.
- `leo` — tema de Leo (para el epílogo «Para Leo»). **Silencio es una herramienta:** sin música en
  los momentos de susto.

## 7. Director de audio (`systems/audio_director.gd`)
Un nodo en `main.tscn` (o clase con estado estático, como `Sfx`) que:
1. Al entrar a una sala, cambia el **ambiente** según `Room.ambience` (fundido cruzado ~1,5 s).
2. Elige la **música** por capítulo, y cambia a `tension` mientras algún infectado persigue a Isabella
   (histéresis: sube rápido, baja 6 s después de que no hay persecución); `safe` en la máquina de escribir.
3. Baja la música ~6 dB durante los diálogos de Leo y las notas.
4. Se detiene al abrir la mochila y al morir (con un fundido).
5. Se puede apagar en las pruebas (`AudioDirector.enabled = false`), como `Leo.guide_enabled`.

## 8. Cómo se entrega (tickets T7 y T8 en `docs/CHATGPT_LOG.md`)
- **T7 (código):** cargador `.ogg` con respaldo sintetizado + buses + `AudioDirector` + pruebas.
- **T8 (datos de salas):** `ambience` en `Room` y en los generadores `tools/level_gen/*.py` (+ regenerar).
- **Claude (assets):** sube los `.ogg` por tandas (armas → infectados → puertas → ambientes → música).
- **Criterio de listo:** `Pruebas en PR` en verde; el APK pesa ≤ 80 MB; Chris aprueba por oído.

## 9. Avance de Claude (assets)
- **Tanda 1 — armas (hecha):** `assets/audio/sfx/` tiene `shot_1..3` (pistola 9 mm), `mauser_1..2`,
  `shotgun_1..4`, `rifle_1..3`, `assault_1..2`, `launcher_1`, `bazooka_1`, `explosion_1..2`, `click_1..2`,
  `reload_1..3`, `reload_rifle_1`, `weapon_equip_1`, `shotgun_pump_1`, `shell_drop_1..2` (27 archivos, 0,25 MB).
- **Para T7:** los `.tres` de armas hoy usan `rifle`, `launcher` y `shot`. El cargador debe tener **alias**
  (`assault`→`rifle`, `bazooka`→`launcher`, `mauser`→`shot`) para el respaldo sintetizado, y después se
  cambian `assault_rifle.tres` (`assault`), `bazooka.tres` (`bazooka`) y `mauser.tres` (`mauser`) para que
  usen los archivos nuevos. Hasta que exista el cargador, estos `.ogg` no suenan.
- **Tanda 2 — infectados e Isabella (hecha):** `groan_1..4`, `groan_short_1..4`, `groan_far_1..2`, `chase_1..3`,
  `death_1..3`, `rise_1..2`, `bite_1..3`, `hit_1..4`, `fall_1..3`, `heavy_step_1..2`, `hurt_1..3`, `hurt_low_1..2`,
  `breath_low_1` (36 archivos, 0,33 MB). Hoy el juego usa `groan`, `groan_short`, `bite`, `hit`, `fall` y `hurt`;
  el resto (`chase`, `death`, `rise`, `heavy_step`, `hurt_low`, `breath_low`, `groan_far`) espera su uso en código
  (ticket futuro: que el infectado rápido use `chase`, el pesado `heavy_step`, etc.).
- **Tanda 3 — puertas y objetos (hecha):** `door_1..4` (abrir), `door_close_1..3`, `door_metal_1..2`, `locked_1..2`,
  `unlock_1..2`, `gate_chain_1..2`, `pickup_1..3`, `page_1..4`, `typewriter_1..5`, `menu_1..3`, `heal_1..2`,
  `radio_static_1` (33 archivos, 0,26 MB). El juego ya usa `door`, `locked`, `unlock`, `pickup`, `page`, `typewriter`
  y `menu`; `door_close`, `door_metal`, `gate_chain`, `heal` y `radio_static` esperan que el código los use.
- Siguientes tandas: animales (Leo, Kiara y Nala) → ambientes → música.
