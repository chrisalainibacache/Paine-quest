// Superficie de escenario para el modo gráfico Moderno.
// Misma lógica que ps1_surface (triplanar en el mundo, anti-repetición, suciedad)
// pero con filtrado suave, relieve (mapa normal) y rugosidad (brillos).
// Para el teléfono: color triplanar (6 muestras) y normal/rugosidad solo en el
// eje dominante (2 muestras); las salas son casi todo cajas alineadas.
shader_type spatial;
render_mode diffuse_lambert, specular_schlick_ggx;

uniform sampler2D albedo_tex : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D normal_tex : hint_normal, filter_linear_mipmap, repeat_enable;
uniform sampler2D rough_tex : hint_roughness_gray, filter_linear_mipmap, repeat_enable;
uniform vec3 tint : source_color = vec3(1.0);
uniform float tile_meters = 2.0;
uniform float detail_mix : hint_range(0.0, 1.0) = 0.3;
uniform float macro_strength : hint_range(0.0, 1.0) = 0.3;
uniform float macro_scale = 0.35;
uniform float grime_height = 1.1;
uniform float grime_strength : hint_range(0.0, 1.0) = 0.5;
uniform vec3 grime_color : source_color = vec3(0.32, 0.27, 0.2);
uniform float floor_y = 0.0;
// Fuerza del relieve y ajuste de la rugosidad.
uniform float normal_strength : hint_range(0.0, 2.0) = 1.0;
uniform float roughness_min : hint_range(0.0, 1.0) = 0.35;
uniform float roughness_max : hint_range(0.0, 1.0) = 1.0;

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
    vec3 n = normalize(world_normal);
    vec3 w = pow(abs(n), vec3(4.0));
    w /= (w.x + w.y + w.z);
    float scale = 1.0 / tile_meters;

    vec3 base = triplanar(world_pos, w, scale);
    vec3 alt = triplanar(world_pos.zyx + vec3(3.7, 1.3, 5.1), w.zyx, scale * 0.61);
    vec3 col = mix(base, alt, detail_mix * fbm(world_pos.xz * 0.5 + world_pos.y * 0.3));

    vec2 mp = (world_pos.xz + world_pos.yy * vec2(0.7, -0.4)) * macro_scale;
    float macro = fbm(mp);
    col *= mix(1.0 - macro_strength, 1.0 + macro_strength * 0.6, macro);
    col = mix(col, col * vec3(1.06, 0.97, 0.88), smoothstep(0.4, 0.9, fbm(mp * 1.9 + 7.0)));

    float vertical = 1.0 - abs(n.y);
    float h = world_pos.y - floor_y;
    float grime = (1.0 - smoothstep(0.0, grime_height, h + (fbm(world_pos.xz * 2.0 + world_pos.y) - 0.5) * 0.5));
    float dirt = grime * grime_strength * vertical;
    col = mix(col, col * grime_color * 1.6, dirt);

    // Eje dominante: UV, tangente y bitangente en el mundo.
    vec3 an = abs(n);
    vec2 uv;
    vec3 t;
    vec3 b;
    if (an.x >= an.y && an.x >= an.z) {
        uv = world_pos.zy;
        t = vec3(0.0, 0.0, 1.0);
        b = vec3(0.0, 1.0, 0.0);
    } else if (an.y >= an.z) {
        uv = world_pos.xz;
        t = vec3(1.0, 0.0, 0.0);
        b = vec3(0.0, 0.0, 1.0);
    } else {
        uv = world_pos.xy;
        t = vec3(1.0, 0.0, 0.0);
        b = vec3(0.0, 1.0, 0.0);
    }
    uv *= scale;
    // El normal puede venir comprimido en dos canales: se reconstruye z.
    vec2 nxy = (texture(normal_tex, uv).rg * 2.0 - 1.0) * normal_strength;
    // La textura crece hacia abajo en V: se invierte la componente vertical.
    nxy.y = -nxy.y;
    float nz = sqrt(max(1.0 - dot(nxy, nxy), 0.0));
    vec3 wn = normalize(t * nxy.x + b * nxy.y + n * nz);
    NORMAL = normalize((VIEW_MATRIX * vec4(wn, 0.0)).xyz);

    float r = texture(rough_tex, uv).r;
    ALBEDO = col * tint;
    // La suciedad es mate.
    ROUGHNESS = mix(mix(roughness_min, roughness_max, r), 1.0, dirt);
}
