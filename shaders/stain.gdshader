// Mancha en el suelo (sangre seca, aceite, humedad). Se pone en un plano a ras
// del piso. El borde irregular sale de ruido, así que no necesita textura y
// cada mancha se ve distinta cambiando `seed`.
shader_type spatial;
render_mode blend_mix, depth_draw_never, cull_disabled, diffuse_lambert, specular_disabled;

uniform vec3 stain_color : source_color = vec3(0.12, 0.03, 0.02);
uniform float opacity : hint_range(0.0, 1.0) = 0.75;
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
    vec2 p = UV * 2.0 - 1.0;
    float n = value_noise(UV * 5.0) * 0.6 + value_noise(UV * 13.0) * 0.4;
    float d = length(p) + (n - 0.5) * 0.7;
    float a = 1.0 - smoothstep(0.55, 0.75, d);
    // Píxeles gruesos en el borde (estilo PS1).
    a = step(0.5, a + (hash(floor(UV * 48.0)) - 0.5) * 0.3);
    ALBEDO = stain_color * (0.8 + n * 0.4);
    ALPHA = a * opacity;
    ROUGHNESS = 0.6;
}
