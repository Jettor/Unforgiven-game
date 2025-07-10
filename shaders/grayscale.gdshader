shader_type canvas_item;

uniform sampler2D hst : hint_screen_texture;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 col = texture(hst, SCREEN_UV);
	float grey = dot(col.rgb, vec3(0.299, 0.587, 0.114));
	COLOR = vec4(vec3(grey), col.a);
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
