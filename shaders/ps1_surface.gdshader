// Superficie de escenario estilo PS1 (muros, pisos, techos).
// Ver docs/ART_PIPELINE.md:
//  1. Triplanar en coordenadas del mundo: cualquier pieza, de cualquier tamaño o
//     rotación, recibe la textura sin estirarse y las uniones coinciden.
//  2. Anti-repetición: una segunda muestra rotada y a otra escala, más un ruido
//     grande que aclara/oscurece por metros. Dos muros iguales no se ven iguales.
//  3. Suciedad automática en la parte baja de los muros.
shader_type spatial;
render_mode diffuse_lambert, specular_disabled;

uniform sampler2D albedo_tex : source_color, filter_nearest_mipmap, repeat_enable;
uniform vec3 tint : source_color = vec3(1.0);
// Metros que cubre una repetición de la textura.
uniform float tile_meters = 2.0;
// Mezcla de la segunda muestra (rompe el mosaico).
uniform float detail_mix : hint_range(0.0, 1.0) = 0.3;
// Variación grande de brillo/color.
uniform float macro_strength : hint_range(0.0, 1.0) = 0.3;
uniform float macro_scale = 0.35;
// Suciedad en la base de los muros.
uniform float grime_height = 1.1;
uniform float grime_strength : hint_range(0.0, 1.0) = 0.5;
uniform vec3 grime_color : source_color = vec3(0.32, 0.27, 0.2);
// Altura del piso de la sala (para la suciedad).
uniform float floor_y = 0.0;

varying vec3 world_pos;
varying vec3 world_normal;

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float value_noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p) {
    return value_noise(p) * 0.65 + value_noise(p * 2.7 + 13.1) * 0.35;
}

vec3 triplanar(vec3 p, vec3 w, float scale) {
    vec3 x = texture(albedo_tex, p.zy * scale).rgb;
    vec3 y = texture(albedo_tex, p.xz * scale).rgb;
    vec3 z = texture(albedo_tex, p.xy * scale).rgb;
    return x * w.x + y * w.y + z * w.z;
}

void vertex() {
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
    vec3 w = pow(abs(world_normal), vec3(4.0));
    w /= (w.x + w.y + w.z);
    float scale = 1.0 / tile_meters;

    vec3 base = triplanar(world_pos, w, scale);
    // Segunda muestra: escala distinta y desplazada; rompe el patrón repetido.
    vec3 alt = triplanar(world_pos.zyx * 1.0 + vec3(3.7, 1.3, 5.1), w.zyx, scale * 0.61);
    vec3 col = mix(base, alt, detail_mix * fbm(world_pos.xz * 0.5 + world_pos.y * 0.3));

    // Variación grande (por metros).
    vec2 mp = (world_pos.xz + world_pos.yy * vec2(0.7, -0.4)) * macro_scale;
    float macro = fbm(mp);
    col *= mix(1.0 - macro_strength, 1.0 + macro_strength * 0.6, macro);
    col = mix(col, col * vec3(1.06, 0.97, 0.88), smoothstep(0.4, 0.9, fbm(mp * 1.9 + 7.0)));

    // Suciedad en la base de muros (sólo superficies verticales).
    float vertical = 1.0 - abs(world_normal.y);
    float h = world_pos.y - floor_y;
    float grime = (1.0 - smoothstep(0.0, grime_height, h + (fbm(world_pos.xz * 2.0 + world_pos.y) - 0.5) * 0.5));
    col = mix(col, col * grime_color * 1.6, grime * grime_strength * vertical);

    ALBEDO = col * tint;
    ROUGHNESS = 1.0;
}
