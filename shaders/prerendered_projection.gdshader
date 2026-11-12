// Fondo prerenderizado: la geometría de la sala no se ilumina; muestra el píxel
// de la imagen renderizada desde la misma cámara (SCREEN_UV). Así los personajes
// 3D quedan tapados por columnas y muros, pero lo que se ve es la "foto".
// La imagen es 21:9 y se recorta a lo ancho según la pantalla (cámara con altura fija).
shader_type spatial;
render_mode unshaded, fog_disabled, shadows_disabled;

uniform sampler2D background : source_color, filter_linear, repeat_disable;
uniform float screen_aspect = 1.7777778;
uniform float image_aspect = 2.3333333;

void fragment() {
    vec2 uv = SCREEN_UV;
    uv.x = 0.5 + (uv.x - 0.5) * screen_aspect / image_aspect;
    ALBEDO = texture(background, uv).rgb;
}
