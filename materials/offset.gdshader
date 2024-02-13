shader_type canvas_item; 
render_mode unshaded;

uniform sampler2D displace: source_color; 
uniform float dispAmt: hint_range(0,0.1);
uniform float abberationAmt: hint_range(0,0.1);
uniform float dispSize: hint_range(0.1, 2.0);
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment()
{
    vec4 disp = texture(displace, SCREEN_UV * dispSize);
    vec2 newUv = SCREEN_UV + disp.xy * dispAmt;
    COLOR = texture(screen_texture, newUV);
}