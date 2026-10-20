
shader_type canvas_item;

uniform float scanline_count : hint_range(10.0, 1920.0) = 540.0;
uniform float contrast : hint_range(0.5, 3.0) = 1.0;
uniform float distortion : hint_range(0.0, 0.5) = 0.1;
uniform float grain_strength : hint_range(0.0, 0.1) = 0.03;
uniform float blur_strength : hint_range(0.0, 2.0, 0.05) = 0.65;
uniform float glitch_strength : hint_range(0.0, 0.08, 0.001) = 0.022;
uniform float glitch_frequency : hint_range(1.0, 30.0, 1.0) = 12.0;

uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap, repeat_disable;

float noise(vec2 co) {
    return fract(
        sin(dot(co, vec2(12.9898, 12.233))) * 20000.5453
    );
}

float hash21(vec2 p) {
    return fract(
        sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123
    );
}

vec2 uv_curve(vec2 uv) {
    uv = uv * 2.0 - 1.0;
    uv.x *= 1.0 + pow(abs(uv.y) * distortion, 2.0);
    uv.y *= 1.0 + pow(abs(uv.x) * distortion, 2.0);
    return uv * 0.5 + 0.5;
}

vec3 sample_screen(vec2 uv) {
    return texture(
        screen_tex,
        clamp(uv, vec2(0.001), vec2(0.999))
    ).rgb;
}

vec3 blurred_screen(vec2 uv, vec2 offset) {
    vec3 color = sample_screen(uv) * 4.0;

    color += sample_screen(uv + vec2(offset.x, 0.0)) * 2.0;
    color += sample_screen(uv - vec2(offset.x, 0.0)) * 2.0;
    color += sample_screen(uv + vec2(0.0, offset.y)) * 2.0;
    color += sample_screen(uv - vec2(0.0, offset.y)) * 2.0;

    color += sample_screen(uv + offset);
    color += sample_screen(uv - offset);
    color += sample_screen(uv + vec2(offset.x, -offset.y));
    color += sample_screen(uv + vec2(-offset.x, offset.y));

    return color / 16.0;
}

void fragment() {
    vec2 target_resolution = vec2(400.0, 400.0);

    vec2 pixelated_uv = (
        floor(SCREEN_UV * target_resolution) + vec2(0.5)
    ) / target_resolution;

    float frame_id = floor(TIME * glitch_frequency);

    float glitch_trigger = step(
        0.88,
        hash21(vec2(frame_id, 17.0))
    );

    float secondary_trigger = step(
        0.94,
        hash21(vec2(frame_id, 98.4))
    );

    float band_center = hash21(vec2(frame_id, 31.7));

    float band_size = mix(
        0.004,
        0.035,
        hash21(vec2(frame_id, 4.3))
    );

    float glitch_band = 1.0 - smoothstep(
        band_size,
        band_size + 0.003,
        abs(SCREEN_UV.y - band_center)
    );

    float second_center = hash21(vec2(frame_id, 62.8));

    float second_size = mix(
        0.0015,
        0.008,
        hash21(vec2(frame_id, 23.6))
    );

    float second_band = 1.0 - smoothstep(
        second_size,
        second_size + 0.0015,
        abs(SCREEN_UV.y - second_center)
    );

    float line_shift = (
        hash21(vec2(frame_id, 7.4)) - 0.5
    ) * 2.0;

    float secondary_shift = (
        hash21(vec2(frame_id, 44.2)) - 0.5
    ) * 2.0;

    float active_glitch = glitch_band * glitch_trigger;
    float active_secondary = second_band * secondary_trigger;

    pixelated_uv.x += line_shift
        * glitch_strength
        * active_glitch;

    pixelated_uv.x += secondary_shift
        * glitch_strength
        * 0.35
        * active_secondary;

    vec2 curved_uv = uv_curve(pixelated_uv);

    if (
        curved_uv.x < 0.0 ||
        curved_uv.x > 1.0 ||
        curved_uv.y < 0.0 ||
        curved_uv.y > 1.0
    ) {
        COLOR = vec4(0.0, 0.0, 0.0, 1.0);
    } else {
        vec2 blur_offset = (
            vec2(1.0) / target_resolution
        ) * blur_strength;

        vec3 color = blurred_screen(
            curved_uv,
            blur_offset
        );

        float glitch_mask = clamp(
            active_glitch + active_secondary,
            0.0,
            1.0
        );

        float static_noise = noise(vec2(
            floor(SCREEN_UV.x * 420.0),
            frame_id + floor(SCREEN_UV.y * 900.0)
        ));

        color += vec3(
            (static_noise - 0.5) * 0.18 * glitch_mask
        );

        float glitch_flicker = (
            hash21(vec2(frame_id, 55.0)) - 0.5
        ) * 0.22;

        color += vec3(
            glitch_flicker * glitch_mask
        );

        color = clamp(
            (color - 0.5) * contrast + 0.5,
            0.0,
            1.0
        );

        float scanline = sin(
            curved_uv.y * scanline_count * PI * 2.0
        );

        scanline = (scanline + 1.0) / 2.0;
        scanline = mix(0.7, 1.0, scanline);

        color *= scanline;

        float grain = noise(
            floor(curved_uv * target_resolution)
            + vec2(TIME * 17.0, TIME * 11.0)
        ) * grain_strength;

        color += vec3(
            grain - grain_strength * 0.5
        );

        COLOR = vec4(
            clamp(color, 0.0, 1.0),
            1.0
        );
    }
}
