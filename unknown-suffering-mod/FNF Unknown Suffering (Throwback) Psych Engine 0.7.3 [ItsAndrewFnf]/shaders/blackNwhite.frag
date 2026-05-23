#pragma header
uniform float iTime;
float rand(float x){return fract(sin(x)*43758.5453);}
float triangle(float x){return abs(1.0-mod(abs(x),2.0))*2.0-1.0;}
void main(){
vec2 uv=openfl_TextureCoordv;
float t=floor(iTime*16.0)/16.0;
vec2 p=uv;
p+=vec2(triangle(p.y*rand(t)*4.0)*rand(t*1.9)*0.015,triangle(p.x*rand(t*3.4)*4.0)*rand(t*2.1)*0.015);
p+=vec2(rand(p.x*3.1+p.y*8.7)*0.01,rand(p.x*1.1+p.y*6.7)*0.01);
vec4 base=flixel_texture2D(bitmap,uv);
vec4 edges=1.0-(base/flixel_texture2D(bitmap,p));
gl_FragColor=vec4(base.r)/vec4(length(edges));
}