shader_type spatial;

uniform vec3 target_pos;

void vertex()
{
	vec2 offset = VERTEX.xz;
	vec3 center = mix(vec3(0.0), target_pos, VERTEX.y - 0.5);
	vec3 left = normalize(cross(target_pos, vec3(0.0, 1.0, 0.0)));
	vec3 up = normalize(cross(target_pos, left));
	vec3 dist = left * offset.x - up * offset.y;
	NORMAL = dist;
	VERTEX = center + dist;
}

void fragment() {
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
