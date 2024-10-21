shader_type spatial;

uniform vec4 albedo_color  = vec4(1.0, 1.0, 1.0, 1.0); // Albedo (diffuse color)
uniform vec4 emissive_color  = vec4(0.0, 0.0, 0.0, 1.0); // Emissive (self-illumination color)
uniform sampler2D albedo_texture;
uniform sampler2D emissive_texture;

void fragment() {
    // Get the albedo color from the texture (if provided) or fallback to albedo_color
    vec4 tex_albedo = texture(albedo_texture, UV);
    vec4 final_albedo = tex_albedo * albedo_color;

    // Get the emissive color from the texture (if provided) or fallback to emissive_color
    vec4 tex_emissive = texture(emissive_texture, UV);
    vec4 final_emissive = tex_emissive * emissive_color;

    // Set the fragment albedo (diffuse color)
    ALBEDO = final_albedo.rgb;
}