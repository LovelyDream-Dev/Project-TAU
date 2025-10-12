shader_type canvas_item;

uniform float brightness : hint_range(0.0, 2.0) = 1.0;

void fragment() {
	vec4 textureColor = texture(TEXTURE, UV);
	COLOR = textureColor * vec4(vec3(brightness), 1.0);
}
