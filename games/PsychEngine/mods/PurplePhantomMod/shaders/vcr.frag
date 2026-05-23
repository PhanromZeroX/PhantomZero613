#pragma header
uniform float iTime;

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void main(){
vec2 uv=openfl_TextureCoordv;
vec2 look=uv;
float window=1.0/(1.0+20.0*(look.y-mod(iTime/4.0,1.0))*(look.y-mod(iTime/4.0,1.0)));
look.x+=sin(look.y*0.5+iTime)/100.0*step(0.3,sin(iTime+4.0*cos(iTime*4.0)))*(1.0+cos(iTime*80.0))*window;
look.y=mod(look.y,1.0);
vec3 video=flixel_texture2D(bitmap,look).rgb;
float vigAmt=3.0+0.3*sin(iTime+5.0*cos(iTime*5.0));
video*=(1.3-vigAmt*(uv.y-0.5)*(uv.y-0.5))*(1.0-vigAmt*(uv.x-0.5)*(uv.x-0.5));
video+=rand(vec2(1.0,2.0*cos(iTime))*iTime*8.0+uv*2.0)*0.5;
gl_FragColor=vec4(video,flixel_texture2D(bitmap,uv).a);
}
