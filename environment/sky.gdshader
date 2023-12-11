shader_type sky;

uniform vec3 skyColor : source_color;
uniform vec3 horizonColor : source_color;
uniform float horizonHeight = 0;
uniform float horizonSplit = 0.05;

void sky() {
	float col = clamp((EYEDIR.y-horizonHeight) / horizonSplit, 0.0, 1.0);
	vec3 finalColor = mix(horizonColor,skyColor,col);
	COLOR = finalColor;
}