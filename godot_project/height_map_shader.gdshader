shader_type spatial;
render_mode unshaded;

uniform sampler2D height_map;
uniform sampler2D albedo;

void vertex() {
	VERTEX.y += texture(height_map, UV).r * 1.0;
}

void fragment() {
	ALBEDO = texture(albedo, UV).xyz;
	//ALBEDO = vec3(1.0);
	
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
