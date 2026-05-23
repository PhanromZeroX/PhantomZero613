#pragma header
uniform float intensity;
void main(){
vec4 col=flixel_texture2D(bitmap,openfl_TextureCoordv);
gl_FragColor=col*(intensity+1.0);
}