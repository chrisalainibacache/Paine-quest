# Auditoría de licencias de recursos — Paine

**Estado:** inventario documental para publicación comercial. No modifica, elimina ni reemplaza recursos del juego.  
**Fuentes internas:** docs/MONETIZACION.md, CREDITS.md y los archivos LICENSE.txt distribuidos junto a los recursos.  
**Criterio:** 🟢 licencia identificada y condición atendida; 🟡 condición o riesgo operativo pendiente; 🔴 licencia desconocida o evidencia insuficiente: [CONFIRMAR] antes de publicar.

## 1. Modelos, personajes, animaciones, armas y entorno

| Recurso / uso en el juego | Autor / fuente | Licencia y condición conocida | Evidencia en el repositorio | Estado y acción |
|---|---|---|---|---|
| Animaciones UAL1/UAL2 usadas por personajes | Quaternius | CC0; uso comercial y modificación permitidos. | assets/characters/animations/LICENSE.txt | 🟢 Conservar licencia y créditos de referencia. |
| Modelos de Leo y otros animales/perros | Quaternius | CC0. | assets/characters/leo/LICENSE.txt; assets/characters/dogs/LICENSE.txt | 🟢 Sin atribución obligatoria; mantener registro. |
| Escopeta, rifle de asalto y rifle de francotirador | Quaternius | CC0. | assets/weapons/LICENSE.txt | 🟢 Sin atribución obligatoria. |
| Modelo Male City Zombie | Rikindle3D | CC0. | assets/characters/infected/LICENSE.txt | 🟢 Mantener la referencia de autor. |
| Textura de camiseta del zombi | Pixelhouse | CC BY 3.0; exige atribución y enlace a la licencia, indicando cambios si los hubo. | assets/characters/infected/LICENSE.txt; CREDITS.md | 🟡 La atribución está incluida en CREDITS; verificar que siga accesible en la versión publicada. |
| Texturas de entorno | ambientCG | CC0. | assets/environment/textures/LICENSE.txt; assets/environment/textures_modern/LICENSE.txt | 🟢 Mantener archivos de licencia y registro. |
| Modelos y recursos de entorno de Poly Haven | Poly Haven | CC0 según el inventario interno. | docs/MONETIZACION.md | 🟢 Confirmar que cada archivo usado corresponde al recurso citado en el inventario. |
| Personaje Isabella / Erika Archer | Mixamo (Adobe) | Uso en juegos permitido según la referencia interna; no redistribuir los archivos fuente sueltos. | assets/characters/cony/LICENSE.txt y docs/MONETIZACION.md | 🟡 El repositorio está documentado como público. Antes de mantener los archivos fuente en un repositorio público, privatizarlo o retirar los archivos y limpiar su historial. No cambiar la visibilidad sin autorización de Chris. |
| Animación de trote de Cony | Mixamo (Adobe) | Uso en juegos permitido según la referencia interna; no redistribuir el archivo fuente suelto. | assets/characters/animations/LICENSE.txt; docs/MONETIZACION.md | 🟡 Mismo bloqueo operativo: resolver la exposición del repositorio público. |
| Simple PSX Character | JashiPSX | La referencia interna indica uso comercial y modificación permitidos, pero no redistribución de archivos fuente; crédito opcional. | docs/MONETIZACION.md y README del paquete | 🟡 Confirmar que los archivos concretos del proyecto corresponden a ese paquete y resolver la exposición del repositorio público. |
| Modelos infectados PSX: infected_psx_05, infected_pale, infected_worker, infected_burnt y variantes relacionadas | Paquetes PSX de itch.io; autor/licencia por confirmar | No se encontró un archivo de licencia suficiente para confirmar permiso comercial y de redistribución. | docs/MONETIZACION.md; assets/characters/infected/LICENSE.txt | 🔴 [CONFIRMAR] Obtener página/archivo de licencia y conservar evidencia. La decisión de mantener los modelos no equivale a una licencia comercial verificada. No reemplazar los recursos automáticamente. |
| Mauser, lanzagranadas y bazuca del Heavy Weapons Pack | Heavy Weapons Pack; autor/licencia por confirmar | No se encontró licencia suficiente en el paquete revisado. | assets/weapons/LICENSE.txt; docs/MONETIZACION.md | 🔴 [CONFIRMAR] Obtener permiso comercial y condiciones de redistribución antes de publicar. No reemplazar los recursos automáticamente. |
| Pack de entorno postapocalíptico de Atomic Realm | Atomic Realm / itch.io | La referencia interna indica uso comercial permitido y modificación permitida, pero prohíbe redistribuir los archivos fuente sueltos. | README del paquete y docs/MONETIZACION.md | 🟡 Resolver el repositorio público: privatizarlo o retirar los archivos y limpiar historial. No cambiar la visibilidad sin autorización. |
| Tipografía Open Sans usada por el proyecto | Open Sans / SIL | SIL Open Font License (OFL). | Referencia de fuente incluida en el inventario de Godot. | 🟢 Conservar el texto OFL y comprobar que la versión incluida corresponde a la licencia. |
| Tipografía Josefin Sans usada en el título/interfaz | Typemade / Google Fonts | SIL Open Font License (OFL); permite uso comercial y modificación bajo sus condiciones. | Fuente incorporada al proyecto; conservar el archivo OFL correspondiente a la versión incluida. | 🟢 Mantener licencia y procedencia en el inventario. |
| Locomotora diésel y vagón ferroviario | tevy.dev | CC0 según ficha y descarga revisadas por Claude; uso comercial y modificación permitidos. | Modelos integrados en assets/trains/; fichas de investigación en docs/trenes/. | 🟢 Conservar referencia CC0 y registro de procedencia. |
| Coche de pasajeros ferroviario | grab3d.com | CC0 según ficha y descarga revisadas por Claude; uso comercial y modificación permitidos. | Modelo integrado en assets/trains/; ficha de investigación en docs/trenes/. | 🟢 Conservar referencia CC0 y registro de procedencia. |
| Fondo de la pantalla de título generado con IA | Generación asistida por IA para Paine | Términos de uso y derechos aplicables pendientes de confirmar para la herramienta/modelo y el plan utilizados. | assets/backgrounds/ y registro de producción visual. | 🟡 [CONFIRMAR] Documentar herramienta, versión, términos vigentes y condiciones de uso comercial antes de publicar. |
| Props, grafitis, murales y elementos dibujados/modelados expresamente para Paine | Christopher Ibacache / producción propia | Obra propia según confirmación interna. | docs/MONETIZACION.md | 🟢 Mantener la declaración de autoría y separar claramente cualquier textura de terceros. |

## 2. Audio de terceros

Los efectos de sonido que aparecen en CREDITS.md se agrupan abajo para facilitar la revisión. El inventario interno indica que los efectos procedentes de OpenGameArt se distribuyen bajo CC0; conservar las referencias individuales del archivo CREDITS.md y verificar que cada archivo usado corresponda a la entrada citada.

| Grupo y recursos acreditados | Fuente / licencia declarada | Estado |
|---|---|---|
| Armas y explosiones: The Free Firearm Sound Library; Muffled Distant Explosion; 25 CC0 Bang/Firework SFX; Explosion; Synthesized explosion; 100 CC0 SFX; Gun reload sounds; Handgun Reload Sound Effect; Shotgun Reload Sound Effects; 2 Gun Reloads. | OpenGameArt; CC0 según el inventario interno y CREDITS.md. | 🟢 Conservar CREDITS.md y las referencias originales. |
| Infectados, criaturas y daño: Zombies Sound Pack; Zombie Moans 01; Zombie/Skeleton/Monster Voice Effects; Hungry Ghoul; Zombie moans; 80 CC0 Creature SFX; Ripping Into Meat; 8 Wet Squish/Slurp Impacts; Impact; Female Hurt Grunts & Groans. | OpenGameArt; CC0 según el inventario interno y CREDITS.md. | 🟢 Conservar CREDITS.md y las referencias originales. |
| Puertas, objetos e interfaz: Door Open/Close Set; Door open; Door close; Iron Door; 100 CC0 Metal and Wood SFX; Item Pickup/Key; Typewriter sounds; Book Flip Sounds; 10 Book Page Flips; Chain winch sounds; 7 Eating Crunches; 10 Clicks and Switches; Static. | OpenGameArt; CC0 según el inventario interno y CREDITS.md. | 🟢 Conservar CREDITS.md y las referencias originales. |
| Ambientes: Wind/wind1; Crickets Ambient Noise; The Shop; Loopable Dungeon Ambience; Dripping water loop; 4 Atmospheric ghostly loops; Fireplace Sound loop; Ambient Bird Sounds; Sea and river wave sounds; Ghostly Humming. | OpenGameArt; CC0 según el inventario interno y CREDITS.md. | 🟢 Conservar CREDITS.md y las referencias originales. |
| Música: Echoes of Time v2; The House of Leaves; Unseen Horrors; Night of Chaos; Echoes of Time; Satiate. | Kevin MacLeod; CC BY 4.0. Exige atribución, enlace a la licencia e indicar cambios si corresponde. | 🟡 CREDITS.md incluye atribución; verificar que la pantalla de créditos siga incluida y legible en la versión de publicación. |

## 3. Riesgos y decisiones de publicación

1. **Recursos rojos:** no se deben declarar comercialmente despejados hasta recibir y archivar evidencia de licencia o autorización. Chris ha decidido mantenerlos por ahora; esa decisión no elimina el riesgo jurídico.
2. **Recursos amarillos con prohibición de redistribución:** el inventario interno indica que el repositorio es público. Antes de mantener esos archivos fuente allí, Chris debe decidir si privatiza el repositorio o si se retiran los archivos y se limpia el historial. Esta auditoría no cambia la visibilidad del repositorio.
3. **Atribuciones CC BY:** conservar CREDITS.md y la pantalla de créditos en el AAB. No eliminar créditos de Pixelhouse ni Kevin MacLeod.
4. **CC0:** mantener una copia de las licencias y procedencia aunque no sea obligatoria la atribución.
5. **Nuevos SDK o assets:** cualquier incorporación requiere actualizar esta tabla y revisar la licencia antes de integrar.

## 4. Referencias

- Inventario de monetización y licencias: docs/MONETIZACION.md.
- Créditos del juego: CREDITS.md.
- Licencias de recursos: assets/**/LICENSE.txt.
- Creative Commons CC0: https://creativecommons.org/publicdomain/zero/1.0/
- Creative Commons Attribution 3.0: https://creativecommons.org/licenses/by/3.0/
- Creative Commons Attribution 4.0: https://creativecommons.org/licenses/by/4.0/
- SIL Open Font License: https://openfontlicense.org/

**No se ha modificado ningún recurso ni se ha cambiado la visibilidad del repositorio.**
