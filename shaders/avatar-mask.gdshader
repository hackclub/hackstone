shader_type canvas_item;

// Declare the screen texture
uniform sampler2D screen_texture : hint_screen_texture;

void fragment() {
    // Sample the mask texture
    vec4 mask_color = texture(TEXTURE, UV);

    // Sample the screen texture (what's currently rendered beneath this shader)
    vec4 screen_color = texture(screen_texture, SCREEN_UV);

    // Choose your blend mode:
	//COLOR = screen_color;
    // Normal blending (just display the mask)
    COLOR = mask_color;

    // Additive blending
    //COLOR = mask_color + screen_color;

    // Subtractive blending
    //COLOR = screen_color - mask_color;

    // Multiplicative blending
	if(mask_color.a != 1.0) {
	    COLOR = screen_color;
	} else {
		COLOR = screen_color * mask_color;
	}
}