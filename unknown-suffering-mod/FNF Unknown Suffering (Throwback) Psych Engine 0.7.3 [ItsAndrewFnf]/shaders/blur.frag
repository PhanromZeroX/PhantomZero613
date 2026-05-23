#pragma header
uniform float iTime;
uniform float directions;
uniform float quality;
uniform float size;
void main(){
vec2 uv=openfl_TextureCoordv;
vec2 radius=size/openfl_TextureSize.xy;
vec4 color=flixel_texture2D(bitmap,uv);
float stepDir=6.28318530718/directions;
float stepQual=1.0/quality;
for(float d=0.0;d<6.28318530718;d+=stepDir){
for(float i=stepQual;i<1.001;i+=stepQual){
color+=flixel_texture2D(bitmap,uv+vec2(cos(d),sin(d))*radius*i);
}}
color/=quality*directions+1.0;
gl_FragColor=color;
}