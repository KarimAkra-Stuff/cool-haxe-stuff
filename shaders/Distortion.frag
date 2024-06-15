#pragma header
//gives the character a glitchy, distorted outline
uniform float uTime;

/**
 * How fast the waves move over time
 */
uniform float uSpeed;

/**
 * Number of waves over time
 */
uniform float uFrequency;

/**
 * How much the pixels are going to stretch over the waves
 */
uniform float uWaveAmplitude;
vec2 sineWave(vec2 pt)
{
    float x = 0.0;
    float y = 0.0;
    
    float offsetX = sin(pt.x * uFrequency + uTime * uSpeed) * (uWaveAmplitude / pt.x * pt.y);
    float offsetY = sin(pt.y * uFrequency - uTime * uSpeed) * (uWaveAmplitude);
    pt.x += offsetX; // * (pt.y - 1.0); // <- Uncomment to stop bottom part of the screen from moving
    pt.y += offsetY;
    return vec2(pt.x + x, pt.y + y);
}
vec4 makeBlack(vec4 pt)
{
    return vec4(0, 0, 0, pt.w);
}
void main()
{
    vec2 uv = sineWave(openfl_TextureCoordv);
    gl_FragColor = makeBlack(flixel_texture2D(bitmap, uv)) + flixel_texture2D(bitmap,openfl_TextureCoordv);
}