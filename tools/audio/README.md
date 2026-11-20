# Herramientas de audio

Corren en el servidor (Python 3 + `ffmpeg` + `oggenc` de vorbis-tools + `numpy`; el 7z de la biblioteca
de armas necesita `pip install py7zr`). **No se usan en el teléfono.** Resultado: `assets/audio/sfx/*.ogg`
(mono, 32 kHz, Vorbis q3), siguiendo el contrato de nombres de `docs/AUDIO_PLAN.md`.

- `shots.py` — cortar disparos de un archivo largo (`explore`), recortar, normalizar y exportar `.ogg`.
- `build_weapons.py` — arma los sonidos de armas (disparos, explosiones, recargas, mecánica) desde los
  bancos CC0 de OpenGameArt. `AUDIO_RAW=/ruta/raw python3 tools/audio/build_weapons.py`.
- Fuentes (todas **CC0**, ver `CREDITS.md`): descargar cada página de OpenGameArt en `raw/<página>/` y
  descomprimir los `.zip` como `<carpeta>_x` (el `.7z` de la biblioteca de armas va en
  `raw/firearms/`, solo las armas usadas).

Lo que **no** se puede hacer desde el servidor: oír el resultado. Cada tanda se aprueba por oído en el teléfono.
