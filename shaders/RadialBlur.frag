// https://www.shadertoy.com/view/XsfSDs with some modifications

#pragma header
vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
vec2 iResolution = openfl_TextureSize;
uniform float strength;
uniform float xPos;
uniform float yPos;
uniform float zoom; // idfk what to call this shit


void main()
{
	vec2 pos = vec2(xPos, yPos); 
	vec2 center = pos / iResolution.xy;
	float blurStart = zoom;
	float blurWidth = blurStart * 0.1;

	
	vec2 uv = fragCoord.xy / iResolution.xy;
	
	uv -= center;
	float precompute = blurWidth * (1.14 / strength);
	
	vec4 color = vec4(0.0);
	for(float i = 0.0; i < strength; i++)
	{
		float scale = blurStart + (float(i)* precompute);
		color += flixel_texture2D(bitmap, uv * scale + center);
	}
	
	
	color /= float(strength);
	
	gl_FragColor = color;
}