#pragma header
uniform float iTime;
void main(){
vec2 uv=openfl_TextureCoordv;
vec2 st=uv-0.5;
float a=atan(st.x,st.y);
float d=dot(st,st);
float dist=(sin(iTime*5.0)+1.0)*0.125;
vec2 p1=0.5+vec2(sin(a),cos(a))*sqrt(d)*(1.0-0.3*dist*d);
vec2 p2=0.5+vec2(sin(a),cos(a))*sqrt(d)*(1.0-0.15*dist*d);
vec2 p3=0.5+vec2(sin(a),cos(a))*sqrt(d)*(1.0-0.075*dist*d);
gl_FragColor=vec4(flixel_texture2D(bitmap,p1).r,flixel_texture2D(bitmap,p2).g,flixel_texture2D(bitmap,p3).b,flixel_texture2D(bitmap,uv).a);
}