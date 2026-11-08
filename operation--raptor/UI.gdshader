
shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform float contrast : hint_range(0.5, 2.0) = 20;

void fragment() {
    vec3 color = texture(screen_texture, SCREEN_UV).rgb;

    color = (color - 0.5) * contrast + 0.5;

    COLOR = vec4(clamp(color, 0.0, 1.0), 1.0);
}
