#pragma header
uniform float iTime;
void main(){
vec2 uv=openfl_TextureCoordv;
for(float i=0.;i<0.71;i+=0.1313){
float d=mod(iTime*i,1.7);
float o=sin(1.-tan(iTime*0.24*i))*0.005;
float e0=d-0.05;
float e1=d+0.05;
uv.x+=smoothstep(e0,d,uv.y)*o-smoothstep(d,e1,uv.y)*o;}
vec2 offsetR=vec2(sin(iTime)*0.0018,0.);
vec2 offsetG=vec2(cos(iTime*0.97)*0.00219,0.);
vec4 c;
c.r=flixel_texture2D(bitmap,uv+offsetR).r;
c.g=flixel_texture2D(bitmap,uv+offsetG).g;
c.b=flixel_texture2D(bitmap,uv).b;
c.a=1.;
gl_FragColor=c;
}