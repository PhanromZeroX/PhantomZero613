precision mediump float;
uniform float u_time;
uniform float u_strength;
uniform float u_speed;
uniform vec2 u_resolution;

void main()
{
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float wave = sin((uv.y + u_time * 0.5) * 20.0 * u_speed) * 0.02 * u_strength;
    float heat = sin((uv.x + u_time * 0.7) * 12.0 * u_speed) * 0.015 * u_strength;
    vec2 offset = vec2(wave, heat);
    vec2 sampleUV = uv + offset;
    vec4 color = texture2D(uMainSampler, sampleUV);
    float distortion = smoothstep(0.1, 0.5, uv.y) * 0.25;
    color.rgb += vec3(distortion, distortion * 0.5, 0.0);
    gl_FragColor = color;
}
