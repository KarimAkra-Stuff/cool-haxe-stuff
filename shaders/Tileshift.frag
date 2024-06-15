#pragma header
 
// I am hardcoding the constants like a jerk
	
uniform float bluramount;
uniform float center;
const float stepSize = 0.004;
const float steps = 3.0;
 
const float minOffs = (float(steps-1.0)) / -2.0;
const float maxOffs = (float(steps-1.0)) / +2.0;
 
void main() {
	float amount;
	vec4 blurred;
		
	// Work out how much to blur based on the mid point 
	amount = pow((openfl_TextureCoordv.y * center) * 2.0 - 1.0, 2.0) * bluramount;
		
	// This is the accumulation of color from the surrounding pixels in the texture
	blurred = vec4(0.0, 0.0, 0.0, 1.0);
		
	// From minimum offset to maximum offset
	for (float offsX = minOffs; offsX <= maxOffs; ++offsX) {
		for (float offsY = minOffs; offsY <= maxOffs; ++offsY) {
 
			// copy the coord so we can mess with it
			vec2 temp_tcoord = openfl_TextureCoordv.xy;
 
			//work out which uv we want to sample now
			temp_tcoord.x += offsX * amount * stepSize;
			temp_tcoord.y += offsY * amount * stepSize;
 
			// accumulate the sample 
			blurred += flixel_texture2D(bitmap, temp_tcoord);
		}
	} 
		
	// because we are doing an average, we divide by the amount (x AND y, hence steps * steps)
	blurred /= float(steps * steps);
 
	// return the final blurred color
	gl_FragColor = blurred;
}