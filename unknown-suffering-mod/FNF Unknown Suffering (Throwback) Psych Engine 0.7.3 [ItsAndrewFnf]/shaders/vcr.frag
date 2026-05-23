#pragma header
uniform float iTime;
uniform sampler2D iChannel1;
void main(){
vec2 uv=openfl_TextureCoordv;
vec2 look=uv;
float window=1./(1.+20.*(look.y-mod(iTime/4.,1.))*(look.y-mod(iTime/4.,1.)));
look.x+=sin(look.y*0.5+iTime)/100.*step(0.3,sin(iTime+4.*cos(iTime*4.)))*(1.+cos(iTime*80.))*window;
look.y=mod(look.y,1.);
vec3 video=flixel_texture2D(bitmap,look).rgb;
float vigAmt=3.+0.3*sin(iTime+5.*cos(iTime*5.));
video*=(1.3-vigAmt*(uv.y-0.5)*(uv.y-0.5))*(1.-vigAmt*(uv.x-0.5)*(uv.x-0.5));
video+=flixel_texture2D(iChannel1,vec2(1.,2.*cos(iTime))*iTime*8.+uv*2.).x*0.5;
gl_FragColor=vec4(video,flixel_texture2D(bitmap,uv).a);
}