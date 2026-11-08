# Firma del APK

`paine.keystore` firma todos los APK que compila GitHub Actions. Usar siempre la
misma llave permite instalar cada versión **encima** de la anterior en el teléfono
(sin desinstalar ni perder la partida).

- Alias: `paine` · Contraseña: `paine-android`
- Sólo sirve para instalar el juego a mano (no para Google Play).
- Si el repositorio se hace público, mover la llave a un *secret* de GitHub
  y crear otra para Google Play.
