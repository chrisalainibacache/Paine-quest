# Diseño de zonas — índice y reglas comunes

Estado: documentos de diseño P10; **no son implementación**. Los generadores, recursos y escenas los prepara Claude después de revisar cada zona. La fuente narrativa es `docs/GUION.md`; las decisiones de diseño se contrastan con `docs/GDD.md` y `docs/REDISENO_NIVELES.md`.

## Entregas

| Documento | Zona | Estado |
| --- | --- | --- |
| [Catálogo de puzzles](catalogo_puzzles.md) | Plantillas reutilizables para las cinco zonas | P10-a |
| [Capítulo 1 — Estación de Paine](cap1_estacion.md) | 10 salas, bucles, caja fuerte, fusibles y llave oculta | P10-b |
| `cap2_vias.md` | Capítulo 2 — Las vías | Pendiente P10-c |
| `cap3_buin.md` | Capítulo 3 — Buin | Pendiente P10-d |
| `cap4_maestranza.md` | Capítulo 4 — La Maestranza y jefe del patio | Pendiente P10-e |
| `cap5_centro_nos.md` | Capítulo 5 — Centro de Nos | Pendiente P10-f |
| `epilogo.md` | Epílogo «Para Leo» | Pendiente P10-g |
| `guia_de_jugada.md` | Recorrido completo, guardados y economía global | Pendiente P10-h |
| `notas_nuevas_indice.md` | Índice de documentos y pistas nuevas | Pendiente P10-i |

## Contrato mínimo para cada zona

Cada documento de zona debe contener los 12 apartados del encargo P10: resumen; grafo y mapa ASCII; conexiones; objetos/llaves; al menos 6 puzzles de 4 tipos; pistas N1/N2/N3 de Leo; mapa de zona; enemigos y recursos; textos exactos de notas; cámaras y aspecto; variante cooperativa; checklist final.

- Diseñar **8–12 salas**, normalmente de 6–10 m por lado. Cada sala tiene al menos dos conexiones, salvo como máximo dos rincones sin salida.
- Dibujar al menos dos bucles, dos rutas hacia los objetivos importantes y dos atajos que se abren desde el lado opuesto.
- No colocar llaves u objetos clave a simple vista en el suelo. Deben estar en contenedores, muebles, cadáveres, tras un puzzle o en un objeto registrable.
- Cada puzzle incluye dos pistas con ubicación exacta, solución, resultado, fallo y variante cooperativa si corresponde.
- Todo recurso clave debe poder obtenerse antes de que una puerta lo exija. Revisar el grafo como problema de alcanzabilidad, no solo como narrativa.
- Pistas de Leo: N1 orientación no verbal; N2 vaga (máximo 12 palabras); N3 solución explícita solo al pulsar AYUDA. No hay flechas amarillas permanentes dentro de la zona.
- Los textos respetan el orden temporal de `docs/GUION.md`, no explican el origen de la infección, nadie dice el nombre interno de la criatura y el vagón del Centro de Nos sigue sellado durante el capítulo 4.
- No usar cruces rojas/blancas como símbolo médico; el rombo con pulso de Ignacia es propio.
- Medidas y cámaras son propuestas de render, no coordenadas definitivas. Claude planifica cámaras y prerenders; nunca editar salas ni escenas a mano desde estos documentos.

## Convención de identificadores

- IDs de sala en `snake_case`, estables aunque cambie el nombre visible.
- IDs de puzzle: `capN_<zona>_<objeto_o_mecanica>`.
- IDs de puerta: `door_<origen>_<destino>`; ID de cerradura: `lock_<objeto>`.
- Banderas de estado propuestas: `puzzle:<id>:solved`, `puzzle:<id>:failed_count`, `puzzle:<id>:step:<n>`, `taken:<room>:<node>`, `unlocked:<lock_id>`, `visited:<room>`.
- Un puzzle persistente debe guardar únicamente el estado necesario para restaurarlo: resuelto, código validado (no el texto del input), piezas instaladas, posiciones de palancas, intentos si cambian el reto, y objetos ya reclamados.
- Los recursos de mapa deben registrar ID, nombre visible, coordenada de cuadrícula, conexiones y puerta/llave asociada. El estado visitado/pendiente se deriva del guardado; no duplicar el grafo en el save.

## Prueba de diseño obligatoria

Antes de entregar una zona, simular al menos dos rutas distintas desde el spawn hasta cada objetivo principal. Para cada ruta, listar qué objetos/pistas se obtienen antes de cada puerta. Una llave que solo se alcanza después de su propia cerradura es una cadena imposible y obliga a rediseñar el grafo.

