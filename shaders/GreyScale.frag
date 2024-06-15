#pragma header

uniform float uAlpha;
void main()
{
	vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
	float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114));
	gl_FragColor = vec4(vec3(gray), color.a * uAlpha);
}