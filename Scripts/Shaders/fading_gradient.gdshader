shader_type canvas_item;

uniform vec4 color1 : source_color = vec4(1.0, 0.0, 0.5, 1.0);
uniform vec4 color2 : source_color = vec4(0.0, 0.7, 1.0, 1.0);
uniform float speed : hint_range(-2.0, 2.0) = 0.3;
uniform float angle : hint_range(0.0, 360.0) = 0.0;
uniform bool overlay_texture = true;

void fragment() {
	// Gradient direction
	float rad = radians(angle);
	vec2 dir = vec2(cos(rad), sin(rad));

	// Moving position along the gradient
	float t = dot(UV, dir) + TIME * speed;

	// Smooth looping gradient using sin (0 → 1 → 0)
	float smooth_t = 0.5 + 0.5 * sin(t * 2.0 * 3.1415926);

	// Interpolate colors
	vec4 grad_color = mix(color1, color2, smooth_t);

	// Apply gradient to texture if desired
	if (overlay_texture) {
		vec4 tex_color = texture(TEXTURE, UV);
		COLOR = tex_color * grad_color;
	} else {
		COLOR = grad_color;
	}
}
