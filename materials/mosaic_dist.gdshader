/*
	距離でピクセルサイズ変更シェーダー for Godot Engine by あるる（きのもと 結衣） @arlez80
	Distance Pixelize Shader for Godot Engine by Yui Kinomoto @arlez80

	MIT License
*/

shader_type canvas_item;
render_mode unshaded;

uniform float mosaic_scale = 5.0;
uniform float sampling_size = 8.0;
uniform float start_distance = 0.5;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;

void fragment( )
{
	float size = 1.0;
	vec2 depth_tex_size = vec2( textureSize( DEPTH_TEXTURE, 0 ) );
	float depth = textureLod( DEPTH_TEXTURE, floor( ( SCREEN_UV * depth_tex_size ) / sampling_size ) * sampling_size / depth_tex_size, 0.0 ).r;
	if( depth < 1.0 ) {
		vec4 upos = INV_PROJECTION_MATRIX * vec4( SCREEN_UV * 2.0 - 1.0, depth * 2.0 - 1.0, 1.0 );
		vec3 pixel_position = upos.xyz / upos.w;
		if( pixel_position.z <= -start_distance ) {
			size = ( pixel_position.z + start_distance ) * mosaic_scale;
		}
	}

	ivec2 p = ivec2( floor( FRAGCOORD.xy / size ) * size );
	ALBEDO = texelFetch( SCREEN_TEXTURE, p, 0 ).rgb;
	DEPTH = 0.0;
}
