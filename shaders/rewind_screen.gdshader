shader_type canvas_item;
render_mode unshaded;

uniform float strength : hint_range(0.0, 1.0) = 0.0;
uniform vec4 tint : source_color = vec4(0.34, 0.52, 1.0, 1.0);

void fragment() {
	vec2 uv = UV;
	float edge = smoothstep(0.85, 0.15, length(uv - vec2(0.5)));
	float scan = sin(uv.y * 240.0 - TIME * 42.0) * 0.5 + 0.5;
	float a = (0.07 + 0.20 * (1.0 - edge) + 0.025 * scan) * strength;
	COLOR = vec4(tint.rgb, a);
}
