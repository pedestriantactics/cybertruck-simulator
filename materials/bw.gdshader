shader_type canvas_item;

uniform bool hide = false;
uniform vec4 color: source_color = vec4(1);
uniform float strength = 0.2;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment(){
	vec4 pixel = texture(SCREEN_TEXTURE, SCREEN_UV);
        COLOR = pixel;
	if (hide == false){ 
		
		vec3 grayscale_value = vec3(dot(pixel.rgb, vec3(0.299, 0.587, 0.114)));
		float range = 1.0 - step(distance(pixel.rgb, color.rgb), strength);
		COLOR.rgb = mix(pixel.rgb, grayscale_value, range);
	}
	
}