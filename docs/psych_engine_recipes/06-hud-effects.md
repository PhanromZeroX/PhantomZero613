# 06 - HUD Effects Recipe

## Overview
This recipe demonstrates how to create dynamic HUD (Heads-Up Display) effects in Psych Engine, including health bar animations, score counters, and visual feedback elements.

## Key Concepts
- HUD manipulation using `setProperty` and `getProperty`
- Animation tweens for smooth transitions
- Custom event handling for HUD updates

## Example Code

```lua
-- HUD Effects Example
function onCreate()
    -- Create a custom HUD element (e.g., a pulsing health bar)
    makeLuaSprite('healthPulse', nil, 0, 0)
    setObjectCamera('healthPulse', 'hud')
    addLuaSprite('healthPulse', true)
    
    -- Set initial properties
    setProperty('healthPulse.alpha', 0.5)
    setProperty('healthPulse.scale.x', 1.0)
    setProperty('healthPulse.scale.y', 1.0)
end

function onUpdate(elapsed)
    -- Pulse effect based on health
    local health = getProperty('health')
    local pulseScale = 1.0 + (math.sin(getSongPosition() * 0.01) * 0.1 * (1 - health))
    
    setProperty('healthPulse.scale.x', pulseScale)
    setProperty('healthPulse.scale.y', pulseScale)
    setProperty('healthPulse.alpha', 0.3 + (health * 0.4))
end

function onBeatHit()
    -- Flash HUD on beat
    doTweenAlpha('hudFlash', 'camHUD', 0.8, 0.1, 'quadOut')
    runTimer('hudFlashReset', 0.2)
end

function onTimerCompleted(tag)
    if tag == 'hudFlashReset' then
        doTweenAlpha('hudFlashReset', 'camHUD', 1.0, 0.3, 'quadIn')
    end
end
```

## Learning Tips
- Use `setObjectCamera('sprite', 'hud')` to place elements on the HUD layer
- Combine `onUpdate` with math functions for dynamic effects
- `doTweenAlpha` and similar functions create smooth transitions
- Test effects at different health levels to ensure they feel responsive

## Common Patterns
- Health-based scaling: `scale = 1.0 + (health * multiplier)`
- Beat-synced flashes: Use `onBeatHit()` for rhythmic feedback
- Timer-based resets: Combine `runTimer` with `onTimerCompleted`