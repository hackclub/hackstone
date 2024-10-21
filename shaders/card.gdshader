shader_type spatial;

uniform sampler2D base_texture : source_color; // The texture underneath
uniform sampler2D overlay_texture : source_color; // The overlay texture with transparency

void fragment() {
    // Sample the base texture
    vec4 base_color = texture(base_texture, UV);

    // Sample the overlay texture
    vec4 overlay_color = texture(overlay_texture, UV);

    // Use the alpha channel of the overlay to blend it with the base texture
    float overlay_alpha = overlay_color.a;

    // The final color is a combination of base and overlay, using overlay's alpha for blending
    vec4 final_color = mix(base_color, overlay_color, overlay_alpha);

    // Output the final color
    ALBEDO = final_color.rgb;
    ALPHA = final_color.a;
}