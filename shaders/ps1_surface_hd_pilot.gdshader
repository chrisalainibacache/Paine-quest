// Variante experimental HD: conserva el albedo y la estética PS1 del shader base,
// añadiendo relieve triplanar en espacio mundo. No sustituye ps1_surface.gdshader.
shader_type spatial;
render_mode diffuse_lambert, specular_disabled;

uniform sampler2D albedo_tex : source_color, filter_nearest_mipmap, repeat_enable;
uniform sampler2D normal_tex : hint_normal, filter_nearest_mipmap, repeat_enable;
uniform vec3 tint : source_color = vec3(1.0);
uniform float tile_meters = 2.0;
uniform float detail_mix : hint_range(0.0, 1.0) = 0.3;
uniform float macro_strength : hint_range(0.0, 1.0) = 0.3;
uniform float macro_scale = 0.35;
uniform float grime_height = 1.1;
uniform float grime_strength : hint_range(0.0, 1.0) = 0.5;
uniform vec3 grime_color : source_color = vec3(0.32, 0.27, 0.2);
uniform float floor_y = 0.0;
// Mantener en 0 hasta validar el mapa y la iluminación en el dispositivo.
uniform float normal_strength : hint_range(0.0, 2.0) = 0.0;

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

vec3 triplanar_albedo(vec3 p, vec3 w, float scale) {
    vec3 x = texture(albedo_tex, p.zy * scale).rgb;
    vec3 y = texture(albedo_tex, p.xz * scale).rgb;
    vec3 z = texture(albedo_tex, p.xy * scale).rgb;
    return x * w.x + y * w.y + z * w.z;
}

// Convierte cada muestra tangente en una normal de mundo según su proyección.
// Los signos mantienen la orientación coherente en caras opuestas.
vec3 triplanar_normal(vec3 p, vec3 w, float scale, vec3 face_sign) {
    vec3 nx = texture(normal_tex, p.zy * scale).rgb * 2.0 - 1.0;
    vec3 ny = texture(normal_tex, p.xz * scale).rgb * 2.0 - 1.0;
    vec3 nz = texture(normal_tex, p.xy * scale).rgb * 2.0 - 1.0;

    vec3 world_x = vec3(nx.z * face_sign.x, -nx.y, nx.x * face_sign.x);
    vec3 world_y = vec3(ny.x, ny.z * face_sign.y, -ny.y);
    vec3 world_z = vec3(nz.x, nz.y, nz.z * face_sign.z);

    return normalize(world_x * w.x + world_y * w.y + world_z * w.z);
}

void vertex() {
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
    vec3 face_sign = sign(world_normal);
    vec3 w = pow(abs(world_normal), vec3(4.0));
    w /= max(w.x + w.y + w.z, 0.0001);
    float scale = 1.0 / max(tile_meters, 0.001);

    vec3 base = triplanar_albedo(world_pos, w, scale);
    vec3 alt = triplanar_albedo(world_pos.zyx + vec3(3.7, 1.3, 5.1), w.zyx, scale * 0.61);
    vec3 col = mix(base, alt, detail_mix * fbm(world_pos.xz * 0.5 + world_pos.y * 0.3));

    vec2 mp = (world_pos.xz + world_pos.yy * vec2(0.7, -0.4)) * macro_scale;
    float macro = fbm(mp);
    col *= mix(1.0 - macro_strength, 1.0 + macro_strength * 0.6, macro);
    col = mix(col, col * vec3(1.06, 0.97, 0.88), smoothstep(0.4, 0.9, fbm(mp * 1.9 + 7.0)));

    float vertical = 1.0 - abs(world_normal.y);
    float h = world_pos.y - floor_y;
    float grime = 1.0 - smoothstep(0.0, grime_height,
        h + (fbm(world_pos.xz * 2.0 + world_pos.y) - 0.5) * 0.5);
    col = mix(col, col * grime_color * 1.6, grime * grime_strength * vertical);

    ALBEDO = col * tint;
    ROUGHNESS = 1.0;

    if (normal_strength > 0.001) {
        vec3 mapped_world = triplanar_normal(world_pos, w, scale, face_sign);
        vec3 blended_world = normalize(mix(world_normal, mapped_world, normal_strength));
        NORMAL = normalize((VIEW_MATRIX * vec4(blended_world, 0.0)).xyz);
    }
}
