// https://www.shadertoy.com/view/XsVSW1  with some modifications

#pragma header
uniform float value;
vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
vec2 iResolution = openfl_TextureSize;

void main()
{
    vec2 p = fragCoord.xy/iResolution.xy - 0.5;

      // cartesian to polar coordinates
      float r = length(p);
      float a = atan(p.y, p.x);
  
    // distort
    if(value == 0.0) {
        vec2 guh = fragCoord.xy/iResolution.xy - 0.5;
        r = length(guh);
    } else {
        r = r*r* value; // bulge
    }
  
    p = r * vec2(cos(a), sin(a));
  
    vec4 color = flixel_texture2D(bitmap, p + 0.5);
    gl_FragColor = color;
}