#pragma header

void main()
{
	vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
	vec2 iResolution = openfl_TextureSize;
	vec2 uv = fragCoord/iResolution.xy;
    vec3 color = flixel_texture2D(bitmap,uv).xyz;
	gl_FragColor = vec4(1.0 - color,1.0);
}