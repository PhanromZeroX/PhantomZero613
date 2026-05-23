# 07 - Custom Event Patterns Recipe

## Overview
This recipe covers creating and using custom events in Psych Engine to trigger complex behaviors, synchronize animations, and create interactive mod elements.

## Key Concepts
- Custom event creation with `triggerEvent`
- Event parameter passing
- Conditional logic in event handlers
- Chaining events for complex sequences

## Example Code

```lua
-- Custom Event Patterns Example
function onCreate()
    -- Set up initial state
    setProperty('customCounter', 0)
end

function onStepHit()
    -- Trigger custom events based on step
    if curStep == 128 then
        triggerEvent('CustomShake', '0.5, 0.1', '')
    elseif curStep == 256 then
        triggerEvent('CustomSpawn', 'enemy, 400, 300', '')
    elseif curStep == 384 then
        triggerEvent('CustomSequence', 'start', '')
    end
end

function onEvent(name, value1, value2)
    if name == 'CustomShake' then
        -- Parse parameters
        local intensity = tonumber(value1) or 0.5
        local duration = tonumber(value2) or 0.1
        
        -- Apply camera shake
        cameraShake('camGame', intensity, duration)
        cameraShake('camHUD', intensity * 0.5, duration)
        
    elseif name == 'CustomSpawn' then
        -- Spawn custom sprite
        local spriteType = value1
        local x = tonumber(value2) or 0
        local y = tonumber(value3) or 0
        
        makeLuaSprite(spriteType .. getProperty('customCounter'), spriteType, x, y)
        addLuaSprite(spriteType .. getProperty('customCounter'), false)
        setProperty('customCounter', getProperty('customCounter') + 1)
        
    elseif name == 'CustomSequence' then
        if value1 == 'start' then
            -- Start a sequence of events
            triggerEvent('CustomShake', '0.3, 0.2', '')
            runTimer('sequenceStep2', 0.5)
        end
    end
end

function onTimerCompleted(tag)
    if tag == 'sequenceStep2' then
        triggerEvent('CustomSpawn', 'effect, 600, 200', '')
        runTimer('sequenceStep3', 0.3)
    elseif tag == 'sequenceStep3' then
        triggerEvent('CustomShake', '0.1, 0.5', '')
    end
end
```

## Learning Tips
- Use `triggerEvent` to fire custom events with parameters
- Handle events in `onEvent` with conditional checks
- Parse string parameters using `tonumber()` for numbers
- Combine events with timers for sequenced actions
- Test event chains to ensure timing works correctly

## Common Patterns
- Parameter parsing: `local param = tonumber(value1) or default`
- Conditional event handling: `if name == 'EventName' then`
- Event sequencing: Use timers to chain multiple events
- Counter variables: Track spawned objects or states