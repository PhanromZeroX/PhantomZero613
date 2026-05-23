#pragma header

uniform float intensity; // Try 0.2 to 0.4

void main() {
    vec2 uv = openfl_TextureCoordv;
    
    // 1. Center the coordinates
    vec2 p = uv - 0.5;
    
    // 2. The "Bowl" Math
    // Instead of squaring the distance (which is a sphere), 
    // we use a parabolic curve to "sink" the middle.
    float r = length(p);
    p *= 1.0 - intensity * (r * r); 
    
    // 3. Move back
    vec2 final_uv = p + 0.5;
    
    // 4. Decimal-Safe Border Check
    if (final_uv.x < 0.0 || final_uv.x > 1.0 || final_uv.y < 0.0 || final_uv.y > 1.0) {
        gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
    } else {
        gl_FragColor = flixel_texture2D(bitmap, final_uv);
    }
}