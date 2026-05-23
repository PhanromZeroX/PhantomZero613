#pragma header
uniform float Exposure;
uniform vec2 _LightPos;
void main(){
vec2 uv=openfl_TextureCoordv;
vec2 light=_LightPos;
float ar=openfl_TextureSize.x/openfl_TextureSize.y;
vec4 col=vec4(0.);
float decay=1.0;
float weight=0.02;
for(int i=0;i<50;i++){
vec2 uv2=mix(uv,light,float(i)/49.);
vec2 diff=(uv2-light)*vec2(ar,1.0);
float dist=clamp(length(diff),0.,1.);
float occ=1.0-dist*dist;
vec4 tex=flixel_texture2D(bitmap,uv2);
float k=1.0-tex.a;
vec4 fg=vec4(k,k,k,k);
vec4 bg=vec4(occ,occ,occ,occ);
col+=mix(fg,bg,k)*decay*weight;
decay*=0.98;
}
gl_FragColor=col*Exposure+flixel_texture2D(bitmap,uv);
}