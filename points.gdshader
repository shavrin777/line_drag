shader_type spatial;
render_mode unshaded;

uniform float point_size : hint_range(0.1, 128.0, 0.1);

void vertex() {
	POINT_SIZE = point_size;
}

void fragment() {
	ALBEDO = COLOR.rgb;
}