shader_type canvas_item; 
render_mode unshaded;

uniform sampler2D displace: source_color; 
uniform vec2 offset;
uniform float dispAmt: hint_range(0,1);
uniform float dispSize: hint_range(0.1, 5.0);
uniform sampler2D screen_texture : hint_screen_texture, repeat_enable, filter_nearest;

//void fragment()
//{
    //vec4 disp = texture(displace, SCREEN_UV * dispSize + offset);
    //disp = (disp - 0.5) * 2.0;  // map RGB values from [0, 1] to [-1, 1]
    //vec2 newUv = SCREEN_UV + disp.xy * dispAmt;
    //COLOR = texture(screen_texture, newUv);
//}

 //void fragment()
 //{
     //vec4 disp = texture(displace, SCREEN_UV * dispSize + offset);
 	//vec2 newUv = SCREEN_UV + disp.xy * dispAmt;
     //COLOR = texture(screen_texture, newUv);
 //}

void fragment()
{
    vec4 disp = texture(displace, SCREEN_UV * dispSize + offset);
    vec2 newUv = vec2(SCREEN_UV.x + disp.y * dispAmt, SCREEN_UV.y);
    COLOR = texture(screen_texture, newUv);
}