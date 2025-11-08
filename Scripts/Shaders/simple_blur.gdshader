shader_type canvas_item;

uniform float blur_radius : hint_range(0.0, 20.0) = 4.0;

void fragment() {
    vec2 texel_size = SCREEN_PIXEL_SIZE * blur_radius;

    // A few symmetric sample offsets
    vec2 offsets[9] = vec2[](
        vec2(-1.0, -1.0), vec2(0.0, -1.0), vec2(1.0, -1.0),
        vec2(-1.0,  0.0), vec2(0.0,  0.0), vec2(1.0,  0.0),
        vec2(-1.0,  1.0), vec2(0.0,  1.0), vec2(1.0,  1.0)
    );

    float weights[9] = float[](
        0.075, 0.123, 0.075,
        0.123, 0.200, 0.123,
        0.075, 0.123, 0.075
    );

    vec4 sum = vec4(0.0);
    for (int i = 0; i < 9; i++) {
        vec2 uv_offset = offsets[i] * texel_size;
        sum += texture(TEXTURE, UV + uv_offset) * weights[i];
    }

    COLOR = sum;
}
