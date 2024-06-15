#pragma header

uniform float brightness;
uniform float contrast;

void main()
{
	vec4 col = flixel_texture2D(bitmap, openfl_TextureCoordv);
	col.rgb = col.rgb * contrast;
	col.rgb = col.rgb + brightness;

	gl_FragColor = col;
}