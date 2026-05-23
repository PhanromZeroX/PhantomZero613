# Psych Engine Shader Reference

A focused shader guide for Psych Engine v0.7.3 and v1.0.4.

## Shader basics

Shaders are stored in `mods/shaders/` or `assets/shaders/` and usually use a `.frag` file.
Use `initLuaShader()` to load them and `setSpriteShader()` to apply them.

```lua
initLuaShader('chromaticAberration')
setSpriteShader('bg', 'chromaticAberration')
```

## Common shader functions

- `initLuaShader(shaderName)`
- `setSpriteShader(spriteTag, shaderName)`
- `setShaderFloat(shaderName, propertyName, value)`
- `setShaderBool(shaderName, propertyName, value)`
- `setShaderInt(shaderName, propertyName, value)`
- `setShaderFloatArray(shaderName, propertyName, values)`
- `setShaderSampler2D(shaderName, propertyName, texturePath)`

## Popular shader uniforms

- `time` — time progress, great for animation
- `intensity` — overall strength
- `threshold` — brightness threshold for glow
- `rOffset`, `gOffset`, `bOffset` — channel offsets
- `noise` — film/static amount
- `distortion` — image bending amount
- `waveSpeed`, `waveFrequency`, `waveAmplitude` — heat distortion control
- `blurAmount` — blur radius
- `contrast`, `brightness` — color correction
- `radius`, `softness` — vignette shape
- `density`, `weight`, `decay`, `exposure` — godrays parameters

## Common shader effect templates

### Chromatic aberration

```lua
initLuaShader('chromaticAberration')
setSpriteShader('camGame', 'chromaticAberration')
setShaderFloat('chromaticAberration', 'rOffset', 0.01)
setShaderFloat('chromaticAberration', 'gOffset', 0.005)
setShaderFloat('chromaticAberration', 'bOffset', 0.0)
```

### Bloom/glow

```lua
initLuaShader('bloom')
setSpriteShader('bg', 'bloom')
setShaderFloat('bloom', 'intensity', 0.65)
setShaderFloat('bloom', 'threshold', 0.85)
```

### VHS / noise

```lua
initLuaShader('vhs')
setSpriteShader('camGame', 'vhs')
setShaderFloat('vhs', 'time', getSongPosition() * 0.001)
setShaderFloat('vhs', 'noise', 0.15)
setShaderFloat('vhs', 'distortion', 0.08)
```

### Heat wave

```lua
initLuaShader('heatWave')
setSpriteShader('camGame', 'heatWave')
setShaderFloat('heatWave', 'waveSpeed', 1.2)
setShaderFloat('heatWave', 'waveFrequency', 5.0)
setShaderFloat('heatWave', 'waveAmplitude', 0.025)
```

### Grayscale / contrast

```lua
initLuaShader('blackNwhite')
setSpriteShader('camHUD', 'blackNwhite')
setShaderFloat('blackNwhite', 'intensity', 1.0)
```

## GLSL shader template

```glsl
#pragma header

void main() {
    vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
    // modify color here
    gl_FragColor = color;
}
```

## Shader usage tips

- Initialize shaders in `onCreate()`.
- Apply shaders to the camera or to individual sprites.
- Use `getSongPosition()` to animate shader uniforms over time.
- Keep loops and conditionals minimal inside GLSL for better performance.
- Remember shaders may require runtime support and can be disabled by engine settings.

## Platform compatibility

Shaders are usually available only when the game is built with runtime shader support. In Psych Engine this means the shader system is enabled for non-Flash, system builds with mods allowed (`!flash && MODS_ALLOWED && sys`).

## When to use shaders

- Visual atmosphere: VHS, chromatic aberration, heat distortions.
- HUD effects: bloom and fade transitions.
- Gameplay feedback: screen distortion during low health or intense moments.
- Performance caution: always test shader-heavy scenes on your target platform.
