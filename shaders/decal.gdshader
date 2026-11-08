// Calcomanía: grafiti, sangre, hoyos, grietas o manchas pegadas a un muro o al
// piso (el renderer Compatibility no tiene Decal). Va en un QuadMesh a 1-2 cm
// de la superficie. `wear` gasta la pintura con ruido (grafitis viejos).
shader_type spatial;
render_mode blend_mix, depth_draw_never, cull_disabled, diffuse_lambert, specular_disabled;

uniform sampler2D albedo_tex : source_color, filter_nearest, repeat_disable;
uniform vec4 tint : source_color = vec4(1.0);
uniform float opacity : hint_range(0.0, 1.0) = 1.0;
uniform float wear : hint_range(0.0, 1.0) = 0.0;
uniform float seed = 0.0;

float hash(vec2 p) {
    return fract(sin(dot(p + seed, vec2(127.1, 311.7))) * 43758.5453);
}

float value_noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x),
               mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x), f.y);
}

void fragment() {
    vec4 t = texture(albedo_tex, UV);
    float n = value_noise(UV * vec2(18.0, 9.0)) * 0.55 + value_noise(UV * vec2(64.0, 32.0)) * 0.45;
    // Pintura gastada: el ruido decide qué partes se descascararon.
    float kept = wear > 0.0 ? smoothstep(wear * 0.7, wear * 0.7 + 0.18, n) : 1.0;
    ALBEDO = t.rgb * tint.rgb * (0.82 + n * 0.22);
    ALPHA = t.a * tint.a * opacity * kept;
    ROUGHNESS = 0.9;
}
