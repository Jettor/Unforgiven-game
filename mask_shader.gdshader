shader_type canvas_item;

uniform sampler2D sc_textre: hint_screen_texture;

void fragment() {
	COLOR = vec4(texture(sc_textre, SCREEN_UV).rgb, texture(TEXTURE, UV).a);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
