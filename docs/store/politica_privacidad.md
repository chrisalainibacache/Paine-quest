# Política de privacidad — Paine

**Estado:** borrador para revisión; no publicar hasta completar todos los campos [CONFIRMAR] y comprobar que coincide con el AAB final.  
**Fecha de entrada en vigor:** [CONFIRMAR: AAAA-MM-DD]  
**Desarrollador o responsable:** [CONFIRMAR: nombre legal o razón social]  
**Correo de privacidad y soporte:** [CONFIRMAR: correo público]  
**URL pública de esta política:** [CONFIRMAR: URL HTTPS]

## Versión en español

### 1. Alcance y estado de la aplicación

Paine es un juego de terror y supervivencia para Android. Esta política distingue entre la compilación de desarrollo actual y una futura versión de publicación.

La compilación candidata revisada en el PR #9 del paquete P1 (versión de proyecto 0.8.4) usa un proveedor de anuncios simulado para pruebas y no integra actualmente el SDK real de Google Mobile Ads (AdMob). Por tanto, ese proveedor de pruebas no solicita anuncios reales ni transmite datos a una red publicitaria.

La versión de publicación prevista podría integrar Google Mobile Ads y Google User Messaging Platform (UMP). Las secciones siguientes describen ese tratamiento **solo si esos SDK se incorporan y activan en el AAB distribuido**. Antes de publicar, el responsable debe comprobar la versión exacta del SDK, sus adaptadores, permisos y configuración. Si AdMob no se incorpora, se debe retirar la descripción condicional y actualizar la ficha de Seguridad de los datos.

### 2. Información que guarda el propio juego

El juego guarda localmente en el almacenamiento privado de la aplicación:

- Progreso de la partida y datos necesarios para continuar desde un guardado.
- Preferencias locales, como volúmenes de audio y opciones gráficas.

Estos datos se mantienen en el dispositivo. El juego no opera un sistema de cuentas, no requiere iniciar sesión y no dispone de un servidor propio para sincronizar partidas. El juego no recibe directamente números de tarjetas ni credenciales de pago. En la compilación revisada tampoco hay una compra integrada para quitar anuncios.

El usuario puede borrar esos datos mediante las opciones de Android para borrar el almacenamiento de la aplicación o desinstalándola. Al hacerlo puede perder su progreso local.

### 3. Datos tratados por Google Mobile Ads, si se integra

Si la versión de publicación incorpora el SDK de Google Mobile Ads, el SDK puede recopilar y compartir automáticamente, según su versión y configuración, categorías como:

- **Dirección IP:** puede utilizarse para estimar una ubicación general o aproximada.
- **Interacciones con la aplicación:** por ejemplo, inicio de la aplicación, interacciones y visualizaciones de anuncios.
- **Diagnósticos:** información técnica sobre inicio, rendimiento, bloqueos o errores.
- **Identificadores del dispositivo u otros identificadores:** por ejemplo, identificador de publicidad de Android, App Set ID u otros identificadores que el SDK documente para la versión integrada.

Estos datos pueden utilizarse para entregar y medir publicidad, análisis, seguridad y prevención del fraude. Pueden ser tratados por Google y compartidos con proveedores o socios publicitarios según la solicitud de anuncio y la configuración de mediación que finalmente se utilice. [CONFIRMAR: SDK, versión, adaptadores y socios que se incluirán en el AAB final.]

**Importante:** no debe afirmarse que la recopilación ocurre únicamente cuando una persona termina de ver un anuncio recompensado. La documentación del SDK describe datos que pueden recopilarse automáticamente cuando el SDK está integrado y funciona, aunque el usuario no complete una visualización concreta.

Google documenta cifrado de datos en tránsito para el SDK. La recopilación del identificador de publicidad puede depender de la disponibilidad del identificador, de la configuración del dispositivo y de las opciones de consentimiento. El juego no utiliza GPS como mecánica y no necesita conocer la ubicación precisa para funcionar; confirmar que el manifiesto Android del AAB final no incorpore permisos de ubicación innecesarios. Una ubicación general podría inferirse de la dirección IP tratada por el SDK.

### 4. Consentimiento y opciones de privacidad

Si se integra AdMob, el juego utilizará UMP para solicitar y registrar las opciones de consentimiento cuando corresponda. La implementación deberá:

- Actualizar la información de consentimiento al iniciar la aplicación.
- Mostrar el formulario requerido antes de solicitar anuncios cuando la normativa o la configuración lo exijan.
- Respetar el resultado de consentimiento antes de solicitar anuncios.
- Ofrecer un punto de entrada a las opciones de privacidad cuando UMP lo indique.

La disponibilidad de estas opciones depende de la integración final. [CONFIRMAR: implementación de UMP, regiones habilitadas y ubicación del acceso a opciones de privacidad.]

### 5. Cuentas, compras y servicios de terceros

Paine no requiere crear una cuenta y no incorpora chat, mensajería entre jugadores ni contenido generado por usuarios.

La compilación revisada no integra Google Play Billing ni una compra de eliminación de anuncios. Si en el futuro se añade una compra dentro de la aplicación, el pago será procesado mediante Google Play Billing; esta política y la declaración de Seguridad de los datos deberán actualizarse para describir los datos de transacción que reciba el desarrollador.

No se debe añadir mediación publicitaria, analítica, informes de fallos u otro SDK sin revisar previamente sus datos, finalidades, destinatarios y obligaciones de declaración.

### 6. Conservación y eliminación

- **Partida y preferencias locales:** permanecen en el dispositivo hasta que la persona borre los datos de la aplicación o la desinstale.
- **Datos del SDK publicitario:** si AdMob se integra, sus periodos de conservación y eliminación se regirán por la documentación y controles de Google y por la configuración efectiva del servicio. Paine no controla los plazos internos de Google. [CONFIRMAR: versión y configuración final del SDK.]
- **Cuentas:** no hay cuentas de Paine que eliminar.

La persona puede restablecer o limitar el identificador de publicidad desde los ajustes de privacidad de Android, sujeto a la versión del sistema operativo. Para ejercer derechos sobre datos tratados directamente por el desarrollador, puede escribir al correo indicado al inicio. Para datos tratados por Google, también deberá utilizar los controles y canales de privacidad de Google.

### 7. Menores y clasificación por edades

Paine está diseñado para un público adulto por su ambientación de terror, enemigos humanoides, armas y violencia. No está dirigido a niños. La clasificación final por edades será la que resulte del cuestionario IARC y de las clasificaciones aplicables en cada territorio; no se debe anunciar una edad concreta antes de completar ese proceso.

[CONFIRMAR: audiencia objetivo configurada en Play Console y clasificación final.]

### 8. Seguridad

El juego mantiene las partidas y preferencias en el almacenamiento privado de la aplicación. No opera una base de datos propia en línea. Si se incorpora AdMob, el tratamiento y la seguridad de los datos transmitidos por ese SDK dependerán también de las medidas técnicas y políticas de Google. Ningún sistema puede garantizar seguridad absoluta.

### 9. Cambios y contacto

Esta política se actualizará cuando cambien el juego, los SDK, las finalidades o las obligaciones legales. La fecha de vigencia se actualizará en la parte superior.

Para consultas de privacidad, solicitudes relacionadas con datos controlados por el desarrollador o reportes, contactar a:

**[CONFIRMAR: nombre del responsable]**  
**[CONFIRMAR: correo público de contacto]**  
**[CONFIRMAR: país y domicilio comercial, si corresponde]**

---

## English version

### 1. Scope and app status

Paine is an Android survival-horror game. This policy distinguishes the current development build from a future release build.

The P1 candidate build reviewed in PR #9 (project version 0.8.4) uses a simulated ad provider for testing and does not currently integrate the real Google Mobile Ads (AdMob) SDK. The test provider does not request real ads or transmit data to an advertising network.

The planned release may integrate Google Mobile Ads and Google User Messaging Platform (UMP). The following sections describe that processing **only if those SDKs are included and enabled in the distributed AAB**. Before release, the developer must verify the exact SDK version, adapters, permissions and configuration. If AdMob is not included, the conditional description must be removed and the Play Data Safety form updated.

### 2. Information stored by the game itself

The game stores the following information locally in the app's private storage:

- Game progress and information required to resume a saved game.
- Local preferences, such as audio volume and graphics settings.

This information remains on the device. The game does not operate an account system, does not require sign-in and does not run its own server to synchronize saves. The game does not directly receive payment-card numbers or payment credentials. The reviewed build also has no integrated purchase to remove ads.

Users can delete this information through Android's app-storage settings or by uninstalling the app. This may permanently remove local game progress.

### 3. Data processed by Google Mobile Ads, if integrated

If the release integrates the Google Mobile Ads SDK, the SDK may automatically collect and share categories of data depending on its version and configuration, including:

- **IP address:** which may be used to estimate a general or approximate location.
- **App interactions:** for example, app launches, interactions and ad views.
- **Diagnostics:** technical information about app startup, performance, crashes or errors.
- **Device or other identifiers:** for example, Android Advertising ID, App Set ID or other identifiers documented for the integrated SDK version.

This data may be used to deliver and measure advertising, analytics, security and fraud prevention. It may be processed by Google and shared with service providers or advertising partners depending on the ad request and any mediation configuration. [TO CONFIRM: exact SDK, version, adapters and partners included in the final AAB.]

**Important:** this policy must not claim that collection occurs only after a person finishes watching a rewarded ad. The SDK documentation describes data that may be collected automatically while the SDK is integrated and operating, even if the user does not complete a particular ad view.

Google documents encryption in transit for the SDK. Advertising ID collection may depend on identifier availability, device settings and consent choices. The game does not use GPS as a gameplay feature and does not need precise location to operate; verify that the final AAB manifest does not include unnecessary location permissions. The SDK may infer a general location from the IP address it processes.

### 4. Consent and privacy choices

If AdMob is integrated, the app will use UMP to request and record consent choices where applicable. The implementation must:

- Update consent information when the app starts.
- Show any required consent form before requesting ads when required by law or configuration.
- Respect the consent result before requesting ads.
- Provide an entry point to privacy options when UMP indicates one is required.

The availability of these controls depends on the final integration. [TO CONFIRM: UMP implementation, enabled regions and location of the privacy-options entry point.]

### 5. Accounts, purchases and third-party services

Paine does not require account creation and does not include chat, player-to-player messaging or user-generated content.

The reviewed build does not integrate Google Play Billing or an in-app purchase to remove ads. If an in-app purchase is added in the future, payment will be processed through Google Play Billing; this policy and the Data Safety declaration must be updated to describe any transaction data received by the developer.

No advertising mediation, analytics, crash-reporting or other SDK should be added without first reviewing its data, purposes, recipients and disclosure requirements.

### 6. Retention and deletion

- **Local saves and preferences:** remain on the device until the user clears the app's data or uninstalls it.
- **Advertising SDK data:** if AdMob is integrated, retention and deletion are governed by Google's documentation and controls and by the actual service configuration. Paine does not control Google's internal retention periods. [TO CONFIRM: final SDK version and configuration.]
- **Accounts:** Paine has no user accounts to delete.

Users may reset or limit the advertising identifier through Android privacy settings, subject to their Android version. To exercise rights regarding data controlled directly by the developer, users may contact the email shown at the top. For data processed by Google, users should also use Google's privacy controls and channels.

### 7. Children and age rating

Paine is designed for an adult audience because of its horror atmosphere, humanoid enemies, weapons and violence. It is not directed to children. The final age rating will be the result of the IARC questionnaire and the ratings applicable in each territory; a specific rating must not be advertised before that process is completed.

[TO CONFIRM: target audience configured in Play Console and final rating.]

### 8. Security

The game stores saves and preferences in the app's private storage. It does not operate its own online database. If AdMob is added, the security of data transmitted by that SDK also depends on Google's technical measures and policies. No system can guarantee absolute security.

### 9. Changes and contact

This policy will be updated when the game, SDKs, purposes or legal requirements change. The effective date will be updated at the top.

For privacy questions, requests concerning data controlled by the developer or reports, contact:

**[TO CONFIRM: responsible person's name]**  
**[TO CONFIRM: public contact email]**  
**[TO CONFIRM: country and business address, if applicable]**

---

## Fuentes oficiales y notas de publicación

- Google Play — requisitos de política de privacidad: https://support.google.com/googleplay/android-developer/answer/10144311?hl=es
- Google Mobile Ads SDK — divulgación de datos: https://developers.google.com/admob/android/privacy/play-data-disclosure?hl=es
- Google UMP — consentimiento y opciones de privacidad: https://developers.google.com/admob/android/privacy?hl=es

**Bloqueos antes de publicar:** completar los campos [CONFIRMAR], comprobar el SDK y adaptadores reales del AAB, publicar esta política en una URL HTTPS pública no PDF y enlazarla desde Play Console y dentro de la aplicación. Este documento es un borrador operativo, no asesoría jurídica.
