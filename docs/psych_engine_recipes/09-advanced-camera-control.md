# 09 - Advanced Camera Control Recipe

## Overview
This recipe explores advanced camera manipulation techniques, including custom camera paths, zoom effects, and multi-camera setups for cinematic mod experiences.

## Key Concepts
- Camera property manipulation
- Custom camera positioning
- Zoom and angle control
- Camera shake and tweening

## Example Code

```lua
-- Advanced Camera Control Example
function onCreate()
    -- Set up custom camera properties
    setProperty('cameraSpeed', 1.5)
    setProperty('defaultCamZoom', 0.9)
    
    -- Create a custom camera sprite for effects
    makeLuaSprite('cameraOverlay', '', 0, 0)
    setObjectCamera('cameraOverlay', 'other')
    addLuaSprite('cameraOverlay', true)
end

function onUpdate(elapsed)
    -- Custom camera follow with offset
    if mustHitSection then
        setProperty('camFollow.x', getMidpointX('boyfriend') + 150)
        setProperty('camFollow.y', getMidpointY('boyfriend') - 100)
    else
        setProperty('camFollow.x', getMidpointX('dad') - 150)
        setProperty('camFollow.y', getMidpointY('dad') - 100)
    end
end

function onBeatHit()
    -- Dynamic zoom on beats
    if curBeat % 8 == 0 then
        setProperty('camGame.zoom', getProperty('camGame.zoom') + 0.1)
        doTweenZoom('zoomReset', 'camGame', getProperty('defaultCamZoom'), 0.6, 'backOut')
    elseif curBeat % 4 == 0 then
        setProperty('camGame.zoom', getProperty('camGame.zoom') + 0.05)
        doTweenZoom('zoomReset', 'camGame', getProperty('defaultCamZoom'), 0.3, 'quadOut')
    end
end

function onStepHit()
    -- Camera angle effects on specific steps
    if curStep == 256 then
        doTweenAngle('cameraTwist', 'camGame', 5, 0.5, 'quadInOut')
        runTimer('angleReset', 1.0)
    elseif curStep == 512 then
        -- Force camera position for cinematic moment
        setProperty('isCameraOnForcedPos', true)
        setProperty('camFollow.x', 640)
        setProperty('camFollow.y', 360)
        runTimer('releaseCamera', 4.0)
    end
end

function onTimerCompleted(tag)
    if tag == 'angleReset' then
        doTweenAngle('angleReset', 'camGame', 0, 0.5, 'quadOut')
    elseif tag == 'releaseCamera' then
        setProperty('isCameraOnForcedPos', false)
    end
end

function onEvent(name, value1, value2)
    if name == 'Camera Focus' then
        local target = value1
        local duration = tonumber(value2) or 1.0
        
        if target == 'bf' then
            doTweenX('focusX', 'camFollow', getMidpointX('boyfriend'), duration, 'smoothStepInOut')
            doTweenY('focusY', 'camFollow', getMidpointY('boyfriend'), duration, 'smoothStepInOut')
        elseif target == 'dad' then
            doTweenX('focusX', 'camFollow', getMidpointX('dad'), duration, 'smoothStepInOut')
            doTweenY('focusY', 'camFollow', getMidpointY('dad'), duration, 'smoothStepInOut')
        end
    end
end
```

## Learning Tips
- Use `camFollow.x` and `camFollow.y` for custom camera positioning
- `setProperty('isCameraOnForcedPos', true)` locks camera for cinematics
- Combine `doTweenZoom` with beat detection for rhythmic zooms
- Camera angles can create dynamic, disorienting effects
- Test camera changes to ensure they don't break gameplay visibility

## Common Patterns
- Section-based following: Check `mustHitSection` for camera targets
- Beat-synced zooms: Use modulo operations on `curBeat`
- Forced positioning: For cutscenes or special moments
- Tweened focus: Smooth camera transitions between targets