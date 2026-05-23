# 11 - Performance Optimization Recipe

## Overview
This recipe covers optimization techniques for Psych Engine Lua scripts, ensuring smooth performance even with complex mods and effects.

## Key Concepts
- Efficient update loops
- Memory management
- Conditional execution
- Performance monitoring

## Example Code

```lua
-- Performance Optimization Example
local updateCounter = 0
local performanceMode = false

function onCreate()
    -- Initialize performance monitoring
    makeLuaText('fpsCounter', 'FPS: 60', 10, 10)
    setTextSize('fpsCounter', 20)
    setObjectCamera('fpsCounter', 'other')
    addLuaText('fpsCounter')
    
    -- Preload assets
    precacheImage('heavyEffect1')
    precacheImage('heavyEffect2')
    precacheSound('intenseSound')
end

function onUpdate(elapsed)
    updateCounter = updateCounter + 1
    
    -- Throttle expensive operations
    if updateCounter % 3 == 0 then  -- Every 3rd frame
        updateExpensiveEffects(elapsed)
    end
    
    -- Conditional updates based on game state
    if not inGameOver and not paused then
        updateGameplayEffects(elapsed)
    end
    
    -- Performance mode toggle
    if getProperty('health') < 0.3 then
        performanceMode = true
        disableHeavyEffects()
    elseif getProperty('health') > 0.7 then
        performanceMode = false
        enableHeavyEffects()
    end
    
    -- Update FPS counter (throttled)
    if updateCounter % 30 == 0 then
        local fps = math.floor(1 / elapsed)
        setTextString('fpsCounter', 'FPS: ' .. fps)
    end
end

function updateExpensiveEffects(elapsed)
    -- Expensive particle effects
    if not performanceMode then
        -- Only run if not in performance mode
        for i = 1, 10 do
            local particleX = math.random(0, 1280)
            local particleY = math.random(0, 720)
            -- Create particle effect
        end
    end
end

function updateGameplayEffects(elapsed)
    -- Core gameplay effects that always run
    -- These should be optimized
    local health = getHealth()
    local alpha = health * 0.5 + 0.5
    setProperty('healthBar.alpha', alpha)
end

function disableHeavyEffects()
    -- Turn off non-essential effects
    setProperty('bgParticles.visible', false)
    setProperty('ambientLights.alpha', 0)
    -- Cancel heavy timers
    cancelTimer('particleSpawner')
end

function enableHeavyEffects()
    -- Re-enable effects when safe
    setProperty('bgParticles.visible', true)
    setProperty('ambientLights.alpha', 1)
    -- Restart timers
    runTimer('particleSpawner', 0.1, 0)
end

function onBeatHit()
    -- Use beat hits for rhythmic effects instead of every frame
    if not performanceMode then
        triggerEvent('Screen Shake', '0.1,0.05', '0,0')
    end
end

function onTimerCompleted(tag)
    if tag == 'particleSpawner' and not performanceMode then
        -- Spawn particles on timer instead of every frame
        spawnParticle()
    end
end

function spawnParticle()
    -- Efficient particle spawning
    local particleTag = 'particle' .. getProperty('particleCount')
    makeLuaSprite(particleTag, 'particleImage', math.random(0, 1280), -50)
    setObjectCamera(particleTag, 'game')
    addLuaSprite(particleTag, false)
    
    -- Animate and remove
    doTweenY(particleTag .. 'Fall', particleTag, 770, 3, 'linear')
    runTimer(particleTag .. 'Cleanup', 3.1)
end
```

## Learning Tips
- Use modulo operations to throttle frame-based operations
- Preload assets in `onCreate()` to avoid loading stutters
- Disable effects during low-performance situations
- Monitor FPS and adjust effects dynamically
- Use timers and beat hits instead of constant updates where possible

## Common Patterns
- Frame throttling: `if updateCounter % n == 0 then`
- Conditional execution: Check game state before expensive operations
- Performance modes: Scale back effects when FPS drops
- Asset preloading: `precacheImage()` and `precacheSound()`
- Efficient cleanup: Remove unused sprites and cancel timers