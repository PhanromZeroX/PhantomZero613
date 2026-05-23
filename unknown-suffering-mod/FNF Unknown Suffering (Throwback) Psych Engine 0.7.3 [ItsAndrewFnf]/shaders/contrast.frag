#pragma header
uniform float brightness;
uniform float contrast;
uniform float saturation;
void main(){
vec4 c=flixel_texture2D(bitmap,openfl_TextureCoordv);
float gray=dot(c.rgb,vec3(0.3086,0.6094,0.0820));
c.rgb=mix(vec3(gray),c.rgb,saturation);
c.rgb=c.rgb*contrast+vec3((1.0-contrast)*0.5);
c.rgb+=vec3(brightness);
gl_FragColor=c;
}