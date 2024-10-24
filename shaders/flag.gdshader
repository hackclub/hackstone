shader_type spatial;
render_mode cull_disabled;

uniform vec4 color : source_color;

uniform sampler2D albedo_texture : source_color;
uniform sampler2D normalmap_texture : hint_normal;
uniform sampler2D noise_texture : source_color;

uniform float speed = .1;
uniform float strength = .1;

float calculate_displacement(vec2 uv) {
	vec2 scaled_uv = uv * vec2(.5);
	float noise = texture(noise_texture, scaled_uv + vec2(-TIME * speed, 0.0)).r;
	return (noise * 1.5) * strength;
}

void vertex() {
	float displacement = calculate_displacement(UV);
	VERTEX += vec3(displacement, displacement, displacement);
}

void fragment() {
	float displacement = calculate_displacement(UV);
	ALBEDO = mix(texture(albedo_texture, UV).rbg, vec3(displacement, 0, 0), 0.1);
//	ALBEDO = vec3(displacement, 0, 0);

	//vec4 cape = texture(albedo_texture, UV);
//
	//ALBEDO = cape.rgb;
	//ALBEDO = vec3(sin(TIME));
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
