#pragma header

const float scale = 1.0;
uniform bool lockAlpha;

void main()
{
	if (mod(floor(openfl_TextureCoordv.y * openfl_TextureSize.y / scale), 2.0) == 0.0 ){
		float bitch = 1.0;
	
		vec4 texColor = flixel_texture2D(bitmap, openfl_TextureCoordv);
		if (lockAlpha) bitch = texColor.a;
		gl_FragColor = vec4(0.0, 0.0, 0.0, bitch);
	}else{
		gl_FragColor = flixel_texture2D(bitmap, openfl_TextureCoordv);
	}
}