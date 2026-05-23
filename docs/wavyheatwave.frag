precision mediump float;

uniform vec2 u_resolution;
uniform float u_time;
uniform float u_strength;
uniform float u_speed;
uniform sampler2D uMainSampler;

void main()
{
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float waveX = sin((uv.y + u_time * 0.9) * 10.0 * u_speed) * 0.03 * u_strength;
    float waveY = cos((uv.x + u_time * 1.1) * 8.0 * u_speed) * 0.025 * u_strength;
    vec2 offset = vec2(waveX, waveY);
    vec2 sampleUV = uv + offset;

    vec4 color = texture2D(uMainSampler, sampleUV);
    float heat = smoothstep(0.0, 0.4, uv.y) * 0.18;
    color.rgb += vec3(heat, heat * 0.5, 0.0);

    gl_FragColor = color;
}
