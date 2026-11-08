# Arte técnico: cómo se ven las salas

Objetivo: salas con look de **Resident Evil 3 (PS1)**, que no se vean repetidas ni
"de bloques", **sin huecos negros**, y sin tener que dibujar una textura distinta para
cada muro.

## 1. Kit modular sobre una grilla (cero huecos)

Todas las piezas de escenario se diseñan sobre una **grilla de 1 m** (altura de muro 3 m):

| Pieza | Tamaño |
| --- | --- |
| Muro | 1×3 m, 2×3 m, 4×3 m |
| Esquina interior / exterior | 3 m de alto |
| Muro con puerta / con ventana | 2×3 m |
| Piso / techo | 2×2 m, 4×4 m |
| Zócalo y cornisa | tiras de 2 m que tapan las uniones |

- Como todo encaja en la grilla, **las piezas siempre se tocan**: no quedan rendijas.
- Los muros **se solapan 2 cm** en las esquinas y los zócalos/cornisas tapan las uniones
  piso-muro y muro-techo (es el truco clásico).
- Cada sala tiene **techo o cielo de niebla**; lo que queda fuera de cámara se tapa con
  un "telón" (fachada plana con textura) en vez de dejar negro.
- Una prueba automática recorre cada sala y avisa si una cámara ve el vacío.

## 2. Pocas texturas, mucha variación

No hacemos un "diccionario gigante" de texturas. Cada superficie usa **3 capas** en un
solo shader:

1. **Textura base** (una por material: concreto, azulejo, ladrillo, metal, madera,
   grava). Se aplica con coordenadas del mundo (*triplanar*), así no importa cómo
   esté rotada o escalada la pieza: nunca se estira y las uniones coinciden.
2. **Variación grande (macro):** un ruido de baja frecuencia aclara/oscurece y tiñe un
   poco la textura a escala de metros. Así dos muros iguales no se ven idénticos y no
   aparece el patrón repetido en mosaico.
3. **Suciedad por altura:** el shader oscurece y ensucia automáticamente la parte baja
   de los muros (humedad, barro) y las esquinas, como en las fotos reales.

Encima, **calcomanías** (*decals*): manchas de sangre, grietas, carteles, grafitis,
charcos. Son pocas imágenes reutilizadas con rotación y escala distinta.

Resultado: con ~6 texturas base + ~10 calcomanías se arman todas las salas de los
capítulos 1 y 2 sin que se note la repetición.

## 3. Look PS1

- Texturas de **128–256 px** con filtro *nearest* (pixeles nítidos, no borrosos).
- Paleta sucia y cálida; luz de sodio naranja + relleno azul frío.
- **Niebla** densa: oculta el fondo y ahorra rendimiento.
- Filtro de pantalla: color de 15 bits con tramado (*dithering*) y resolución
  interna reducida.
- Vértices con leve "temblor" de PS1 (opcional, suave para no marear).
- Personajes low-poly con texturas pintadas; nada de colores planos sin textura.

## 4. Iluminación

- Luz ambiente baja + 1–3 luces puntuales por sala (lámparas visibles en la escena).
- Sombras solo de la luz principal, o sombras falsas (mancha oscura bajo personajes).
- Brillo emisivo en ventanas y letreros en vez de más luces reales.

## 5. Checklist antes de dar una sala por terminada

- [ ] Todas las piezas en la grilla de 1 m; zócalo y cornisa en las uniones.
- [ ] Ninguna cámara ve vacío negro (prueba automática).
- [ ] Al menos 3 calcomanías y 3 props que cuenten algo.
- [ ] ≤ 4 luces, ≤ 30k triángulos visibles.
- [ ] Probada en el teléfono a 60 fps.
