# Plan de monetización de Paine (Google Play)

> No es asesoría legal ni tributaria. Las reglas de Google cambian: **revisar la versión vigente** de cada requisito
> antes de publicar. Fecha de la auditoría: noviembre 2026.

## 1. Auditoría de licencias (lo primero: sin esto no se cobra ni se ponen anuncios)

**Semáforo:** 🟢 libre para uso comercial · 🟡 usable pero con condición · 🔴 licencia desconocida o dudosa.

| Recurso | Dónde | Licencia | Estado |
| --- | --- | --- | --- |
| Armas: escopeta, fusil de asalto, rifle | `assets/weapons/` | Quaternius, CC0 | 🟢 |
| Leo, Kiara, Nala, animaciones UAL | `assets/characters/{leo,dogs,animations}` | Quaternius, CC0 | 🟢 |
| Infectado «Male City Zombie» | `infected_city.glb` | Rikindle3D, CC0 | 🟢 |
| Texturas (ambientCG), modelos de relleno (Poly Haven), fondos prerenderizados | `assets/environment/`, `assets/backgrounds/` | CC0 | 🟢 |
| Sonidos (armas, infectados, puertas, ambientes) | `assets/audio/` | OpenGameArt, CC0 | 🟢 |
| Zombi con polera | `infected_shirt.glb` | Pixelhouse, **CC-BY 3.0** | 🟡 crédito visible en el juego |
| Música (6 pistas) | `assets/audio/music/` | Kevin MacLeod, **CC-BY 4.0** | 🟡 crédito visible en el juego |
| Isabella (modelo «Erika Archer» + animación de trote) | `assets/characters/cony/` | **Mixamo (Adobe)** | 🟡 Se puede usar en un juego comercial, **no redistribuir los archivos sueltos** (el repositorio es público) |
| Infectados PSX: común, pálido, obrero, quemado, pesado | `infected_psx_05`, `infected_pale`, `infected_worker`, `infected_burnt`, `character_monster_07` | Bajados gratis de itch.io; **sin README ni licencia en el Drive** | 🔴 |
| Calle: vehículos, barreras, conos | `assets/environment/atomic_realm_post_apocalyptic/` | Atomic Realm (itch.io): comercial ✔, redistribuir ✘ | 🟡 repositorio privado |
| Armas: Mauser, lanzagranadas, bazuca | `mauser.glb`, `grenade_launcher.glb`, `bazooka.glb` | Heavy Weapons Pack, bajado gratis de itch.io, sin archivo de licencia | 🔴 → se conservan hasta la compuerta previa a publicar |
| Grafitis y murales (6 + 2 PNG) | `assets/environment/graffiti/` | Nombres «paine/estacion»: hechos para el proyecto | 🟢 (Chris confirma) |
| Pistola, trenes, utilería, comida, munición, decals, afiche, follaje | `levels/kit/props/`, `tools/*` | Hechos por nosotros con código | 🟢 |
| Fuente | — | Fuente por defecto de Godot (Open Sans, OFL) | 🟢 |

**Dónde pega el 🔴 en el juego:** en modo *Moderno* (el predeterminado) siguen usando modelos PSX los infectados
**quemado** y **pesado**; en modo *Retro* los usan los siete. Las tres armas 🔴 están en la mochila desde el inicio.

### Hallazgos tras revisar los README originales del Drive (noviembre 2026)
Chris confirmó que **los packs se bajaron gratis desde itch.io** (con opción de donar; no donó). En itch.io «gratis» **no**
significa «sin condiciones»: cada autor pone su licencia. Lo que dicen los README que sí encontramos:

| Pack | Autor | Uso comercial | Editar | Redistribuir los archivos | Crédito |
| --- | --- | --- | --- | --- | --- |
| *Simple PSX Character* (`characters_psx_v72/psx_character`) | JashiPSX (itch.io) | ✔ sí | ✔ | ✘ **no**, ni modificado | Opcional, agradecido |
| *Post-Apocalyptic Assets Low poly* (`atomic_realm`: vehículos, barreras, conos de la calle) | Atomic Realm Assets (itch.io) | ✔ sí | ✔ | ✘ **no**, ni modificado | No exigido |
| Quaternius (varios) | Quaternius | ✔ CC0 | ✔ | ✔ | No exigido |

**Consecuencia importante:** ambos packs permiten usarlos en un juego comercial, **pero prohíben redistribuir los archivos**.
Hoy el repositorio **es público** y contiene esos `.glb`/`.fbx`: eso sí es redistribuir. No afecta el APK en sí (el juego los
usa «dentro del proyecto», como cualquier juego), pero **hay que hacer el repositorio privado** (o sacar esos archivos y
limpiar el historial). Los packs *Character_Monster/Killer* (`infected_pale`, `infected_worker`, `infected_burnt`, `character_monster_07`),
*Infected_PSX_05* y el *Heavy Weapons Pack* **siguen sin README/licencia en el Drive**: hay que ubicar su página de itch.io.

**Los grafitis y murales:** sus nombres (`wall_graffiti_paine_v72`, `estacion_paine_*`, `game__graffiti_*`) indican que se hicieron
para este proyecto (no vienen de un pack con nombre de autor). Se tratan como propios; Chris confirma si los generó/pidió él.

### Decisiones de Chris y de Claude (2026-11-20)
- **Modelo de ingresos:** juego gratis con **anuncios con recompensa opcionales** (munición, curativo, continuar) + compra
  opcional «quitar anuncios». Decidido por Chris.
- **Grafitis y murales:** son del proyecto (Chris) → 🟢.
- **Armas pesadas (Mauser, lanzagranadas, bazuca) y modelos PSX sin README:** Chris teme que rearmarlas se vean feas.
  **Decisión de Claude: se conservan.** Todos los packs de itch.io cuyo README sí se encontró permiten uso comercial; por eso es
  muy probable que estos también. Condiciones: (1) repositorio **privado** ya; (2) **compuerta antes de publicar**: ubicar las
  páginas de itch.io de estos packs (Chris) y anotar su licencia en `docs/store/licencias_activos.md`; si alguna prohíbe el uso
  comercial, **solo entonces** se reemplaza ese recurso por CC0 (no antes); (3) crédito en la pantalla de créditos.

### Qué necesito que confirme Chris (solo él lo sabe)
1. **Pack PSX de personajes** (`characters_psx_v72`, `infected_candidates`): ¿lo compraste o lo bajaste gratis? ¿De dónde? ¿Tienes la factura o la página?
2. **Heavy Weapons Pack**: ¿de dónde salió? ¿Es de pago? ¿Qué licencia dice la página?
3. **Grafitis y murales**: ¿los hicimos nosotros (generados con código) o los bajaste de algún lado?
Si la página del pack dice «uso comercial permitido en juegos», se anota la licencia y queda 🟢 (aun así hay que **sacar los
archivos del repositorio público**, porque casi todas las licencias de pago prohíben redistribuirlos sueltos).

### Plan B si no se puede confirmar (reemplazo por CC0; lo hace Claude, sin costo)
- **Infectados:** usar `infected_city` (CC0) y `infected_shirt` (CC-BY) con variantes de color, tamaño y textura
  (quemado = carbonizado, pálido = piel clara, pesado = más ancho y grande, soldado = con casco). Modo Retro usa los mismos
  modelos con el filtro PS1. Costo: ~1 día de trabajo y se ve un poco distinto.
- **Armas:** Mauser desde un modelo CC0 de Poly Haven (`service_pistol` u otro), y lanzagranadas/bazuca armados con piezas,
  como ya se hizo con la pistola.
- **Grafitis:** regenerarlos con código (`tools/make_decals.gd`).
- **Repositorio:** si algo 🔴 estuvo público, hay que **limpiar el historial de git** o crear un repositorio nuevo sin él.

## 2. Cómo ganar dinero (recomendación)
**Modelo A (recomendado para empezar): gratis + anuncios con recompensa, solo opcionales.** Botón «VER ANUNCIO → +munición» o
«+curación» cuando quedan pocas. Sin anuncios obligatorios ni entre salas (rompen el miedo). Compra opcional **«Quitar anuncios y
recibir un paquete de ayuda»** (pago único).
**Modelo B: de pago** (pago único, sin anuncios). Más limpio y sin depender de que Google acepte anuncios en un juego con
violencia, pero casi nadie baja un juego pagado de un desconocido.
**Cuánto se puede ganar (honesto):** ingreso ≈ jugadores activos al día × anuncios vistos por jugador × valor de cada anuncio.
En Latinoamérica un anuncio con recompensa paga **del orden de 1 a 3 dólares por cada mil vistas**. Con 500 jugadores al día
viendo 2 anuncios, serían **~2 dólares al día**. Es un ingreso pequeño hasta que haya miles de jugadores; el ingreso depende de
**traer jugadores**, no de los anuncios. *(Cifras orientativas, no garantizadas.)*
**Sobre «anuncios de armas o munición»:** no se puede elegir qué anuncios salen, y Google **prohíbe anunciar venta de armas
reales**. La munición y las armas **dentro del juego** se pueden vender/regalar como recompensa (eso sí es posible).
**Riesgo de anuncios:** los juegos con violencia gráfica pueden recibir menos anuncios o de menor valor. Plan alternativo:
otra red de anuncios (AppLovin, Unity Ads) o el modelo B.

## 3. Requisitos de Google Play (verificar vigentes)
- Cuenta de desarrollador (pago único, ~25 USD) con verificación de identidad.
- **Paquete AAB** (no APK): hay que activar la compilación Gradle de Godot y firmar con **llave nueva y privada**.
  *Hoy la llave está en el repositorio público con su contraseña: no usarla para Google Play.*
- Nivel de API objetivo vigente, **política de privacidad** (URL pública), formulario **Seguridad de los datos**, **clasificación
  de contenido** (violencia: será de adultos), declaración de anuncios.
- Si la cuenta es personal y nueva: **prueba cerrada con testers** (hoy ~12 personas, 14 días) antes de publicar.
- Si hay anuncios y se distribuye en la UE: **mensaje de consentimiento** (UMP). Se puede restringir a países.
- **Ficha**: nombre, descripción corta y larga (español; idealmente también inglés), ícono 512×512 (hoy **falta**),
  gráfico de 1024×500, 2 a 8 capturas, video opcional.
- **Pagos**: AdMob paga por transferencia; piden datos fiscales. Para Chile conviene **consultar a un contador** (declaración
  de ingresos / boleta).

## 4. Trabajo técnico (quién lo hace)
| # | Tarea | Quién | Depende de |
| --- | --- | --- | --- |
| M1 | Confirmar licencias 🔴 y, si no se puede, reemplazar (Plan B) | Chris responde; Claude reemplaza | — |
| M2 | Pantalla de **créditos** + enlace a política de privacidad en el título (T10) | ChatGPT | — |
| M3 | **Política de privacidad** y términos (borrador en español + inglés) | ChatGPT (texto) | M4 |
| M4 | Decidir modelo A o B | Chris | — |
| M5 | Textos de la **ficha** de Google Play + respuestas borrador de Seguridad de datos y clasificación | ChatGPT | M4 |
| M6 | **Ícono** 512×512 y gráfico de funciones 1024×500 | Claude (se generan con el motor) | — |
| M7 | Compilación **AAB** + llave privada + CI | Claude | M1 |
| M8 | Integración de **AdMob** (anuncio con recompensa) + consentimiento | Claude | M4, M7 |
| M9 | Menú de **opciones** (volúmenes, créditos, privacidad) | ChatGPT (código) | T10 |
| M10 | Capturas y video de la ficha | Claude | — |
| M11 | Prueba cerrada 14 días con testers | Chris (consigue los testers) | M7 |
| M12 | Publicación y primera revisión | Chris + Claude | todo |

**Orden sugerido:** M1 → (M2, M3, M5, M6 en paralelo) → M7 → M8 → M11 → M12. Tiempo realista: 3 a 6 semanas, dominado por la
prueba cerrada y la revisión de Google.
