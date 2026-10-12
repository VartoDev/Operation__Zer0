shader_type canvas_item;

uniform float scanline_count : hint_range(10.0, 1980.0) = 15400.0;
uniform float aberration : hint_range(0.0, 0.1) = 0.003;
uniform float contrast : hint_range(0.5, 3.0) = 3.50;
uniform float distortion : hint_range(0.0, 0.5) = 0.1;
uniform float grain_strength : hint_range(0.0, 0.1) = 0.93;
uniform float pixel_size : hint_range(1.0, 32.0) = 116.0; // Je höher, desto pixeliger (1.0 = normal)

// Godot 4 benötigt diesen genauen Hinweis, um die gerenderte 3D-Welt zu fangen
uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;

// Pseudo-zufällige Rauschfunktion basierend auf Pixel-Koordinaten und Zeit
float noise(vec2 co) {
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 1143758.5453);
}

vec2 uv_curve(vec2 uv) {
    uv = uv * 2.0 - 1.0;
    uv.x *= 1.0 + pow(abs(uv.y) * distortion, 2.0);
    uv.y *= 1.0 + pow(abs(uv.x) * distortion, 2.0);
    return uv * 0.5 + 0.5;
}

void fragment() {
    // 1. Pixelation-Effekt berechnen (Pixel künstlich vergrößern)
    // Holt die echte Auflösung des Bildschirms ab
    vec2 text_size = vec2(textureSize(screen_tex, 0)); 
    // Teilt das Bild in feste Rasterblöcke auf
    vec2 pixelated_uv = floor(SCREEN_UV * (text_size / pixel_size)) / (text_size / pixel_size);

    // 2. Die normale Linsenkrümmung auf die pixeligen Koordinaten anwenden
    vec2 curved_uv = uv_curve(pixelated_uv);
    
    if (curved_uv.x < 0.0 || curved_uv.x > 1.0 || curved_uv.y < 0.0 || curved_uv.y > 1.0) {
        COLOR = vec4(0.0, 0.0, 0.0, 1.0);
    } else {
        // Holt die Farben aus der screen_tex mit den verpixelten, gekrümmten UVs
        float r = texture(screen_tex, vec2(curved_uv.x + aberration, curved_uv.y)).r;
        float g = texture(screen_tex, curved_uv).g;
        float b = texture(screen_tex, vec2(curved_uv.x - aberration, curved_uv.y)).b;
        
        vec3 color = vec3(r, g, b);
        
        // Berechnet die analogen Scanlines
        float scanline = sin(curved_uv.y * scanline_count * PI * 2.0);
        scanline = (scanline + 1.0) / 2.0;
        scanline = mix(0.7, 1.0, scanline);
        color *= scanline;
        
        // Berechnet das Sensor-Rauschen (nutzt auch die Pixel-UVs für groberes Rauschen)
        float grain = (noise(curved_uv + TIME) - 0.5) * grain_strength;
        color += vec3(grain);
        
        COLOR = vec4(color, 1.0);
    }
}