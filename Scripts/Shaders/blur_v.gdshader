shader_type canvas_item;

uniform float u_sigma : hint_range(1.0, 50.0) = 10.0;

float gaussian(float x, float s) {
	return exp(-0.5 * (x*x) / (s*s));
}

void fragment() {
	vec2 texel = SCREEN_PIXEL_SIZE;
	vec4 sum = vec4(0.0);
	float total = 0.0;

	const int R = 15;

	for (int i = -R; i <= R; i++) {
		float w = gaussian(float(i), u_sigma);
		vec2 uv = UV + vec2(0.0, float(i) * texel.y);
		sum += texture(TEXTURE, uv) * w;
		total += w;
	}

	COLOR = sum / total;
}
