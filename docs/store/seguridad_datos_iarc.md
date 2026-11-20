# Seguridad de los datos e IARC — borrador para Play Console

**Estado:** propuesta de respuestas; no copiar al formulario definitivo hasta auditar el AAB, SDK y adaptadores de publicación.  
**Aplicación:** Paine (Android).  
**Proyecto revisado:** 0.8.4.  
**Fecha de revisión documental:** 2026-11-20.

## 1. Dos estados que no deben confundirse

| Estado | Publicidad | Respuesta preliminar en Play Console |
|---|---|---|
| Compilación candidata del PR #9 | Usa DebugAdProvider simulado; no integra el SDK real de AdMob. | El proveedor simulado no envía datos a una red publicitaria. Confirmar el manifiesto y todos los SDK del AAB de desarrollo antes de declarar «no recopila». |
| Versión de publicación prevista | Si se integra Google Mobile Ads/AdMob y se solicitan anuncios recompensados. | Declarar que la aplicación contiene anuncios y que el SDK puede recopilar/compartir los datos que documenta. |

**Corrección importante:** el encargo inicial decía que el identificador publicitario y los datos del dispositivo se tratarían «solo si el jugador ve anuncios». No conviene responder así sin matices. La divulgación oficial de Google Mobile Ads describe recopilación automática de datos mientras el SDK está integrado y funciona. No debe limitarse la declaración al momento en que una persona termina de ver un anuncio.

La versión de SDK documentada en la página consultada es 25.5.0; la versión efectiva al publicar puede ser otra. Repetir esta auditoría después de integrar el SDK y todos sus adaptadores.

## 2. Borrador de Seguridad de los datos

### 2.1 Datos propios del juego

| Dato | Tratamiento actual | ¿Se envía a un servidor de Paine? | Respuesta preliminar |
|---|---|---|---|
| Partida guardada y progreso | Almacenamiento privado local de la aplicación. | No. | No se declara como dato recopilado/compartido por el desarrollador si permanece únicamente en el dispositivo. |
| Preferencias de audio y gráficos | Archivo local de ajustes. | No. | No se declara como dato recopilado/compartido por el desarrollador si permanece únicamente en el dispositivo. |
| Cuenta, perfil o credenciales | No hay sistema de cuentas ni inicio de sesión. | No. | No hay datos de cuenta que declarar. |
| Compras | Google Play Billing no está integrado en la compilación revisada. | No aplica actualmente. | No declarar compra integrada hasta implementar y probar Billing. |

### 2.2 Datos del SDK de Google Mobile Ads, si se integra

La siguiente tabla es una **propuesta de clasificación** basada en la divulgación del SDK. La clasificación exacta debe revisarse en el formulario vigente de Play Console y contra la versión/adaptadores reales del AAB.

| Dato documentado por Google Mobile Ads | Categoría probable en Seguridad de los datos | ¿Recopilado? | ¿Compartido? | Finalidades que deben revisarse |
|---|---|---:|---:|---|
| Dirección IP; puede estimar ubicación general | Ubicación aproximada, si Play Console la clasifica así. | Sí, si el SDK lo recopila en la configuración final. | Sí, según divulgación del SDK. | Publicidad, análisis, seguridad y prevención del fraude. |
| Interacciones con la aplicación: inicios, interacciones y vistas de anuncios | Actividad de la aplicación → interacciones con la aplicación. | Sí. | Sí. | Publicidad, análisis y prevención del fraude. |
| Diagnósticos: inicio, rendimiento, bloqueos y errores | Información y rendimiento de la aplicación → diagnósticos. | Sí. | Sí. | Análisis, seguridad y prevención del fraude. |
| Identificadores de dispositivo/cuenta, incluidos Advertising ID y App Set ID según disponibilidad | Identificadores de dispositivo u otros identificadores. | Sí, según disponibilidad/configuración; algunos identificadores pueden ser opcionales. | Sí, según divulgación del SDK. | Publicidad, análisis y prevención del fraude. |

**Respuestas propuestas para el formulario, una vez integrado AdMob:**

1. **¿La aplicación recopila o comparte datos de usuario?** Sí, por el SDK publicitario integrado. Los datos locales de partida no se envían por el juego.
2. **¿Se comparten datos con terceros?** Sí. Google/AdMob y los destinatarios que correspondan a la configuración real de anuncios y mediación.
3. **¿Los datos se cifran en tránsito?** La divulgación del SDK indica cifrado en tránsito. Verificar que el AAB final usa la versión oficial y conexiones HTTPS.
4. **¿El usuario puede solicitar eliminación?** No existen cuentas de Paine. El usuario puede borrar datos locales al borrar el almacenamiento/desinstalar y restablecer el identificador publicitario desde Android. No prometer la eliminación de datos internos de Google que Paine no controla.
5. **¿La recopilación es opcional?** No marcar todos los datos como opcionales por el hecho de que el anuncio sea recompensado. Algunos datos pueden recopilarse automáticamente al operar el SDK. Confirmar cada campo y ajuste en la versión final.
6. **¿Se recopila ubicación precisa?** El juego no necesita GPS para funcionar. La IP puede permitir estimar ubicación general; confirmar la clasificación que corresponda en Play Console.
7. **¿Hay cuentas o contenido de usuario?** No hay cuentas, chat, mensajería, multijugador ni contenido generado por usuarios en la compilación revisada.
8. **¿La aplicación contiene anuncios?** Sí para el AAB que integre AdMob y muestre anuncios. No confundirlo con el proveedor simulado de desarrollo.

### 2.3 Consentimiento UMP

Antes de producción, Claude debe integrar UMP y comprobar como mínimo:

- Actualización de la información de consentimiento en cada inicio.
- Presentación de los formularios requeridos.
- Solicitudes de anuncios condicionadas al estado de consentimiento y a la señal canRequestAds.
- Acceso visible a opciones de privacidad cuando UMP lo requiera.
- Pruebas en regiones con y sin requisito de consentimiento.
- Coherencia entre el SDK, sus adaptadores, la política de privacidad y las respuestas de Seguridad de los datos.

La integración de UMP no sustituye la obligación del desarrollador de declarar todos los datos de todos los SDK.

## 3. Borrador del cuestionario IARC

Las respuestas siguientes son una guía basada en el contenido documentado del juego. El formulario exacto puede variar y la clasificación final la calcula IARC por territorio. No introducir respuestas definitivas sin revisar el AAB completo, incluidos todos los diálogos, escenas, recursos y anuncios.

| Tema del cuestionario | Respuesta propuesta | Evidencia / punto por confirmar |
|---|---|---|
| Tipo de producto | Juego. | Aplicación de juego para Android. |
| Violencia | Sí. | Combate con armas de fuego contra enemigos humanoides infectados. |
| Frecuencia de violencia | Frecuente durante los encuentros y tramos de combate. [CONFIRMAR intensidad y frecuencia en la versión final.] | Revisar todos los capítulos incluidos en el AAB. |
| Sangre o lesiones | Sí, hay efectos y elementos visuales de sangre. [CONFIRMAR nivel de detalle y frecuencia.] | No declarar gore extremo ni desmembramiento si no aparece en el build. |
| Miedo / terror | Sí; elemento central y frecuente. | Atmósfera oscura, infectados, tensión, persecución y sustos. |
| Lenguaje ofensivo | [CONFIRMAR tras revisar todos los diálogos y textos del juego.] | No inferir «ninguno» solo porque el GDD no lo enumere. |
| Desnudez o contenido sexual | No identificado en el contenido revisado; confirmar con el AAB completo. | Revisar modelos, texturas, cinemáticas y textos. |
| Alcohol, tabaco o drogas | No identificado en el contenido revisado; confirmar. | Revisar objetos, diálogos y escenas. |
| Juego de azar | No identificado. | Confirmar que no se incorporen minijuegos o mecánicas de apuesta. |
| Interacción entre usuarios / contenido generado por usuarios | No en la compilación revisada. | No hay chat, multijugador ni publicación de contenido. |
| Anuncios | Sí si AdMob está integrado en el AAB de publicación. | Anuncios recompensados opcionales; no confundir con el proveedor simulado. |
| Compras dentro de la aplicación | No en la compilación revisada. [CONFIRMAR si se incorpora Google Play Billing para quitar anuncios.] | No declarar una compra que todavía no existe. |
| Público objetivo | Adultos; no dirigido a niños. | La clasificación final la determina IARC; no prometer una categoría concreta. |

### 3.1 Decisiones que Chris debe confirmar

- [CONFIRMAR] Revisión del contenido final para intensidad/frecuencia de violencia y sangre.
- [CONFIRMAR] Revisión de todos los diálogos para lenguaje ofensivo.
- [CONFIRMAR] Revisión completa de desnudez, sexualidad, alcohol, tabaco y drogas.
- [CONFIRMAR] Si el primer AAB tendrá AdMob, mediación y UMP.
- [CONFIRMAR] Si habrá compra integrada para quitar anuncios.
- [CONFIRMAR] Audiencia objetivo y países de distribución.

## 4. Referencias oficiales

- Google Play — Seguridad de los datos y divulgaciones: https://support.google.com/googleplay/android-developer/answer/10787469?hl=es
- Google Mobile Ads SDK — divulgación de datos: https://developers.google.com/admob/android/privacy/play-data-disclosure?hl=es
- Google UMP — consentimiento: https://developers.google.com/admob/android/privacy?hl=es
- Google Play — cuestionario y clasificación de contenido: https://support.google.com/googleplay/android-developer/answer/9859655?hl=es
- Google Play — declaración de anuncios: https://support.google.com/googleplay/android-developer/answer/9859455?hl=es

**Regla de cierre:** no enviar Seguridad de los datos ni IARC hasta que el AAB de publicación, la lista de SDK/adaptadores, la política de privacidad y las respuestas del formulario describan exactamente el mismo producto.
