// Filtro de pantalla estilo PlayStation 1: píxeles más gruesos, color de 15 bits
// con tramado Bayer 4x4 y viñeta. Va en una CanvasLayer por encima del 3D y
// por debajo de la interfaz.
shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_tex : hint_screen_texture, filter_nearest;
// Líneas verticales "virtuales" (la PS1 usaba 240).
uniform float target_lines = 300.0;
uniform float color_levels = 31.0;
uniform float vignette = 0.35;

float bayer4(vec2 p) {
    int x = int(mod(p.x, 4.0));
    int y = int(mod(p.y, 4.0));
    int i = x + y * 4;
    float m[16] = float[16](0.0, 8.0, 2.0, 10.0, 12.0, 4.0, 14.0, 6.0,
                            3.0, 11.0, 1.0, 9.0, 15.0, 7.0, 13.0, 5.0);
    return m[i] / 16.0;
}

void fragment() {
    vec2 screen_size = 1.0 / SCREEN_PIXEL_SIZE;
    float px = max(1.0, floor(screen_size.y / target_lines));
    vec2 cell = floor(FRAGCOORD.xy / px);
    vec2 uv = (cell * px + px * 0.5) * SCREEN_PIXEL_SIZE;
    vec3 c = texture(screen_tex, uv).rgb;
    c += (bayer4(cell) - 0.5) / color_levels;
    c = floor(c * color_levels + 0.5) / color_levels;
    vec2 v = SCREEN_UV - 0.5;
    c *= 1.0 - dot(v, v) * vignette * 2.0;
    COLOR = vec4(c, 1.0);
}
