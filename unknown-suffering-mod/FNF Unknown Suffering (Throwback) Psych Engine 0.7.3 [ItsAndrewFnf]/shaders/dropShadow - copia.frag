#pragma header
uniform vec4 overlayColor;
uniform vec4 satinColor;
uniform vec4 innerShadowColor;
uniform float innerShadowAngle;
uniform float innerShadowDistance;
void main(){
vec2 uv=openfl_TextureCoordv;
vec4 c=flixel_texture2D(bitmap,uv);
c.rgb=mix(c.rgb,c.rgb*satinColor.rgb,satinColor.a)*c.a;
float ox=cos(innerShadowAngle);
float oy=sin(innerShadowAngle);
vec2 dist=vec2(ox,oy)*innerShadowDistance/openfl_TextureSize.xy/5.0;
for(int i=0;i<5;i++){
vec4 col=flixel_texture2D(bitmap,uv+dist*float(i));
c.rgb=mix(c.rgb,c.rgb/(1.0-innerShadowColor.rgb*(1.0-col.a)),innerShadowColor.a*(1.0-col.a));
}
c.rgb=mix(c.rgb,max(c.rgb,overlayColor.rgb),overlayColor.a)*c.a;
gl_FragColor=c;
}