// Sombra redonda falsa bajo los personajes (como en PS1). Más barata que
// sombras reales y funciona en el renderer Compatibility.
shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, cull_disabled;

uniform float opacity : hint_range(0.0, 1.0) = 0.55;

void fragment() {
    float d = length(UV * 2.0 - 1.0);
    ALBEDO = vec3(0.0);
    ALPHA = (1.0 - smoothstep(0.35, 1.0, d)) * opacity;
}
