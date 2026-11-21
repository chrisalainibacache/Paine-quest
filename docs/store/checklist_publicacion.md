# Checklist de publicación en Google Play — Paine

**Estado:** plan de trabajo; los elementos [CONFIRMAR] requieren decisión de Chris.  
**Roles:** Chris = responsable/desarrollador; Claude = implementación y builds; ChatGPT = documentación, auditoría y preparación de textos.

## 1. Cuenta, identidad y titularidad

- [ ] **Chris** — Confirmar si la cuenta de Play Console será personal o de organización.
- [ ] **Chris** — Completar verificación de identidad, perfil de pagos y datos legales solicitados por Google.
- [ ] **Chris** — Confirmar nombre legal del titular, correo público de soporte, teléfono y país de la cuenta.
- [ ] **Chris** — Confirmar fecha de creación de la cuenta personal, si corresponde; determina si aplica el requisito de prueba cerrada.
- [ ] **Chris** — Revisar la tarifa de registro vigente directamente en Play Console. [CONFIRMAR importe actual; no usar cifras antiguas sin verificar.]
- [ ] **Chris** — Confirmar titularidad del nombre Paine y disponibilidad del nombre de ficha.
- [ ] **ChatGPT** — Mantener los borradores de política, ficha, Seguridad de los datos e IARC actualizados con las decisiones confirmadas.

## 2. Licencias y repositorio

- [ ] **Chris** — Resolver los recursos rojos de docs/store/licencias_activos.md: modelos infectados PSX y Heavy Weapons Pack. Obtener licencia comercial verificable o decidir su retirada.
- [ ] **Chris** — Resolver los recursos amarillos con prohibición de redistribución: Mixamo, Atomic Realm y JashiPSX.
- [ ] **Chris** — Decidir si privatiza el repositorio o si retira los archivos fuente restringidos y limpia el historial. No se cambiará la visibilidad sin autorización.
- [ ] **Claude** — No reemplazar ni borrar assets por iniciativa propia; cualquier cambio de contenido necesita aprobación de Chris.
- [ ] **ChatGPT** — Actualizar la tabla de licencias cuando Chris entregue pruebas o decisiones.

**Dependencia crítica:** no declarar todos los recursos comercialmente despejados mientras existan filas rojas.

## 3. Firma, compilación y AAB

- [ ] **Claude** — Preparar un keystore nuevo para producción y configurar Play App Signing.
- [ ] **Claude** — Generar y validar el AAB firmado de release; comprobar instalación, arranque, orientación horizontal, guardado y controles táctiles.
- [ ] **Claude** — Configurar versionCode, versionName, identificador de paquete y requisitos de API objetivo vigentes al momento de subir.
- [ ] **Chris** — Guardar el keystore, alias y contraseñas en un lugar seguro fuera del repositorio.
- [ ] **Claude** — Usar secretos seguros para CI si la firma se automatiza; no incluir contraseñas ni claves privadas en commits, artefactos públicos o logs.
- [ ] **Claude** — No reutilizar la clave/contraseña que el inventario interno identifica como expuesta en el repositorio o en export_presets.cfg. Generar una clave nueva.
- [ ] **ChatGPT** — Revisar el checklist de release y comprobar que no se documenten secretos.

## 4. Política, privacidad y publicidad

- [ ] **Chris** — Confirmar nombre legal del responsable, correo público de privacidad/soporte, país y datos de contacto.
- [ ] **Chris** — Elegir una URL HTTPS pública y estable para alojar la política; debe ser accesible sin iniciar sesión y no ser un PDF.
- [ ] **ChatGPT** — Finalizar la política ES/EN cuando estén completos los datos del responsable y el SDK real.
- [ ] **Claude** — Añadir el enlace a la política dentro de la aplicación y comprobar que abre correctamente.
- [ ] **Chris** — Crear/confirmar la cuenta de AdMob y las unidades publicitarias, si se mantiene la decisión de integrar anuncios reales.
- [ ] **Claude** — Integrar Google Mobile Ads y UMP; usar IDs de prueba en desarrollo y no servir anuncios reales durante pruebas internas.
- [ ] **Claude** — Implementar actualización de consentimiento, formularios requeridos, canRequestAds y acceso a opciones de privacidad cuando corresponda.
- [ ] **ChatGPT** — Reauditar los datos del SDK y sus adaptadores después de la integración; actualizar la política y Seguridad de los datos.
- [ ] **Chris** — Confirmar si habrá compra para quitar anuncios. No declarar compras integradas hasta que Google Play Billing esté implementado.
- [ ] **Chris** — Confirmar países/regiones donde se publicará y las configuraciones de consentimiento aplicables.

**Dependencia crítica:** no completar Seguridad de los datos ni declarar «Contiene anuncios» hasta conocer el SDK/adaptadores exactos del AAB final.

## 5. Ficha y recursos gráficos

- [ ] **ChatGPT** — Mantener la ficha ES/EN dentro de los límites de título, descripción breve y descripción larga.
- [ ] **Chris** — Aprobar título, descripción, categoría, etiquetas, audiencia, países y precio.
- [ ] **Claude** — Preparar icono de aplicación de 512 × 512 px.
- [ ] **Claude** — Preparar gráfico destacado de 1024 × 500 px.
- [ ] **Claude** — Capturar entre 2 y 8 pantallas reales en horizontal; no usar escenas, enemigos ni funciones que no estén en el AAB.
- [ ] **Chris** — Aprobar capturas, icono y gráfico destacado.
- [ ] **Chris** — Confirmar que la ficha declara anuncios si el AAB incluye AdMob.
- [ ] **Chris** — Confirmar precio gratuito y países de lanzamiento en Play Console.

## 6. Clasificación, Seguridad de los datos e IARC

- [ ] **Chris** — Revisar el AAB final y contestar con veracidad las preguntas sobre violencia, sangre, miedo, lenguaje, sexualidad, drogas, apuestas y público objetivo.
- [ ] **ChatGPT** — Ajustar el borrador IARC a las respuestas y al contenido real confirmado.
- [ ] **Claude** — Entregar inventario exacto de SDK, versiones, adaptadores, permisos y manifiesto del AAB.
- [ ] **ChatGPT** — Mapear los datos reales del SDK a las categorías de Seguridad de los datos.
- [ ] **Chris** — Completar y enviar los formularios de Play Console.
- [ ] **Chris** — Revisar la clasificación regional que genere IARC; no anunciar una edad antes del resultado.

## 7. Pruebas internas y cerradas

- [ ] **Claude** — Preparar AAB de prueba y canal interno/cerrado.
- [ ] **Chris** — Reclutar testers reales y coordinar sus pruebas.
- [ ] **Chris** — Si la cuenta es personal y fue creada después del 13-11-2023, verificar el requisito vigente de al menos 12 testers inscritos continuamente durante 14 días antes de solicitar acceso a producción.
- [ ] **ChatGPT** — Preparar guion de pruebas y recopilar feedback funcional, de controles, rendimiento y compatibilidad.
- [ ] **Claude** — Corregir fallos bloqueantes y entregar nuevo AAB.
- [ ] **Chris** — Solicitar acceso a producción cuando Play Console lo habilite. Cumplir el mínimo de testers no garantiza aprobación automática.

## 8. Precio, países y obligaciones fiscales

- [ ] **Chris** — Confirmar países de distribución y disponibilidad por región.
- [ ] **Chris** — Confirmar precio final. La propuesta de trabajo es juego gratuito con anuncios recompensados opcionales; validar si se mantiene.
- [ ] **Chris** — Completar el perfil de pagos y datos bancarios que solicite Google.
- [ ] **Chris** — Consultar con un contador en Chile el tratamiento tributario de ingresos de Google Play/AdMob, documentación y declaraciones aplicables.
- [ ] **ChatGPT** — Organizar la información y preguntas para el contador; no sustituye asesoría tributaria.
- [ ] **Chris** — Confirmar si publica como persona natural o mediante una entidad.

## 9. Envío y mantenimiento

- [ ] **Claude** — Verificar que el AAB final coincide con la ficha, permisos, SDK, política, anuncios y formularios.
- [ ] **Chris** — Revisar la ficha completa y enviar la aplicación a revisión.
- [ ] **Chris** — Atender solicitudes de Google Play y conservar los registros de aprobación.
- [ ] **Claude** — Mantener builds reproducibles y preparar correcciones posteriores.
- [ ] **ChatGPT** — Mantener documentación, créditos y auditoría de licencias al día.

## 10. Dependencias principales

1. **Licencias y repositorio** → resolver antes de considerar despejada la publicación comercial.
2. **Cuenta y titularidad** → necesarias para completar Play Console, pagos y verificación.
3. **Contacto y URL de privacidad** → necesarios para publicar la política y enlazarla en la aplicación.
4. **Cuenta/IDs de AdMob** → necesarios antes de integrar anuncios reales.
5. **AdMob + UMP integrados** → necesarios antes de cerrar Seguridad de los datos, declaración de anuncios y política final.
6. **AAB firmado y contenido final** → necesarios para responder IARC y probar el juego real.
7. **Icono, gráfico y capturas** → necesarios para completar la ficha.
8. **Testers y prueba cerrada** → necesarios si la política de la cuenta lo exige.
9. **Países, precio y perfil fiscal** → necesarios antes del lanzamiento y cobro.

## 11. Referencias oficiales

- Prueba cerrada para cuentas personales nuevas: https://support.google.com/googleplay/android-developer/answer/14151465?hl=es
- Ficha de Play Store: https://support.google.com/googleplay/android-developer/answer/9859152?hl=es
- Seguridad de los datos: https://support.google.com/googleplay/android-developer/answer/10787469?hl=es
- Clasificación IARC: https://support.google.com/googleplay/android-developer/answer/9859655?hl=es
- Google Mobile Ads SDK y divulgación de datos: https://developers.google.com/admob/android/privacy/play-data-disclosure?hl=es
- UMP: https://developers.google.com/admob/android/privacy?hl=es

**Regla de publicación:** no enviar el AAB mientras haya licencias rojas sin resolver, campos de contacto [CONFIRMAR], diferencias entre SDK y Seguridad de los datos, o una política de privacidad que no coincida con el comportamiento real de la aplicación.
