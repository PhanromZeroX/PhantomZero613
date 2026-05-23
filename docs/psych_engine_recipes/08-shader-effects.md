# 08 - Shader Effects Recipe

## Overview
This recipe covers implementing GLSL shader effects in Psych Engine, including bloom, chromatic aberration, and custom visual distortions for enhanced mod visuals.

## Key Concepts
- Shader initialization and application
- Uniform parameter control
- Dynamic shader updates based on game state
- Combining multiple shaders

## Example Code

```lua
-- Shader Effects Example
function onCreate()
    -- Initialize shaders
    initLuaShader('bloom')
    initLuaShader('chromaticAberration')
    initLuaShader('vhs')
    
    -- Apply bloom to background
    setSpriteShader('bg', 'bloom')
    setShaderFloat('bloom', 'intensity', 0.3)
    setShaderFloat('bloom', 'threshold', 0.8)
    
    -- Apply chromatic aberration to characters
    setSpriteShader('boyfriend', 'chromaticAberration')
    setShaderFloat('chromaticAberration', 'rOffset', 0.005)
    setShaderFloat('chromaticAberration', 'gOffset', 0.002)
    setShaderFloat('chromaticAberration', 'bOffset', 0.0)
end

function onUpdate(elapsed)
    -- Dynamic VHS effect based on health
    local health = getHealth()
    local distortion = (1 - health) * 0.1
    setShaderFloat('vhs', 'time', getSongPosition() * 0.001)
    setShaderFloat('vhs', 'noise', distortion)
    setShaderFloat('vhs', 'distortion', distortion * 2)
end

function onBeatHit()
    -- Pulse bloom on beat
    if curBeat % 4 == 0 then
        setShaderFloat('bloom', 'intensity', 0.6)
        runTimer('bloomReset', 0.2)
    end
end

function onTimerCompleted(tag)
    if tag == 'bloomReset' then
        setShaderFloat('bloom', 'intensity', 0.3)
    end
end

function onEvent(name, value1, value2)
    if name == 'Change Chromatic' then
        local intensity = tonumber(value1) or 0.01
        setShaderFloat('chromaticAberration', 'rOffset', intensity)
        setShaderFloat('chromaticAberration', 'gOffset', intensity * 0.5)
    end
end
```

## Learning Tips
- Always initialize shaders in `onCreate()` before applying them
- Use `setShaderFloat` for most parameters; check shader code for uniform names
- Update shader values in `onUpdate()` for dynamic effects
- Combine shaders on different sprites for layered effects
- Test shader performance, as complex shaders can impact FPS

## Common Patterns
- Health-based distortion: `distortion = (1 - health) * multiplier`
- Time-based animation: `setShaderFloat('shader', 'time', getSongPosition() * speed)`
- Beat-synced pulses: Use `onBeatHit()` with timers for resets
- Event-triggered changes: Custom events to modify shader parameters