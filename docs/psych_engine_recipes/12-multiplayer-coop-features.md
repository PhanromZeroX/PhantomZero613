# 12 - Multiplayer and Co-op Features Recipe

## Overview
This recipe explores implementing multiplayer/co-op features in Psych Engine mods, including shared health, turn-based mechanics, and synchronized effects.

## Key Concepts
- Shared state management
- Turn-based gameplay
- Synchronized animations
- Multiplayer event handling

## Example Code

```lua
-- Multiplayer/Co-op Features Example
local isPlayerTurn = true
local sharedHealth = 1.0
local turnTimer = 0

function onCreate()
    -- Set up multiplayer UI
    makeLuaText('turnIndicator', 'YOUR TURN', 400, 50)
    setTextSize('turnIndicator', 40)
    setTextColor('turnIndicator', 'FFFF00')
    setObjectCamera('turnIndicator', 'hud')
    addLuaText('turnIndicator')
    
    makeLuaText('sharedHealthText', 'Shared Health: 100%', 400, 100)
    setTextSize('sharedHealthText', 24)
    setTextColor('sharedHealthText', 'FFFFFF')
    setObjectCamera('sharedHealthText', 'hud')
    addLuaText('sharedHealthText')
    
    -- Initialize shared health
    sharedHealth = 1.0
    updateSharedHealthDisplay()
end

function onUpdate(elapsed)
    turnTimer = turnTimer + elapsed
    
    -- Turn switching logic
    if turnTimer > 10.0 then  -- 10 second turns
        switchTurns()
        turnTimer = 0
    end
    
    -- Update turn indicator
    local timeLeft = math.ceil(10.0 - turnTimer)
    if isPlayerTurn then
        setTextString('turnIndicator', 'YOUR TURN - ' .. timeLeft .. 's')
        setTextColor('turnIndicator', '00FF00')
    else
        setTextString('turnIndicator', 'OPPONENT TURN - ' .. timeLeft .. 's')
        setTextColor('turnIndicator', 'FF0000')
    end
end

function switchTurns()
    isPlayerTurn = not isPlayerTurn
    
    if isPlayerTurn then
        -- Enable player controls
        setProperty('cpuControlled', false)
        setProperty('boyfriend.alpha', 1.0)
        setProperty('dad.alpha', 0.5)
        
        -- Visual feedback
        cameraFlash('camGame', '00FF00', 0.3)
        playSound('turnSwitch', 0.6)
        
    else
        -- Disable player controls, enable AI
        setProperty('cpuControlled', true)
        setProperty('boyfriend.alpha', 0.5)
        setProperty('dad.alpha', 1.0)
        
        -- Visual feedback
        cameraFlash('camGame', 'FF0000', 0.3)
        playSound('turnSwitch', 0.6)
    end
end

function goodNoteHit(id, noteData, noteType, isSustainNote)
    if isPlayerTurn then
        -- Successful hits restore shared health
        sharedHealth = math.min(sharedHealth + 0.05, 1.0)
        updateSharedHealthDisplay()
        
        -- Visual feedback
        setProperty('boyfriend.color', getColorFromHex('00FF00'))
        doTweenColor('bfHitColor', 'boyfriend', 'FFFFFF', 0.3, 'linear')
    end
end

function noteMiss(id, noteData, noteType, isSustainNote)
    if isPlayerTurn then
        -- Misses damage shared health
        sharedHealth = math.max(sharedHealth - 0.1, 0.0)
        updateSharedHealthDisplay()
        
        -- Visual feedback
        setProperty('boyfriend.color', getColorFromHex('FF0000'))
        doTweenColor('bfMissColor', 'boyfriend', 'FFFFFF', 0.5, 'linear')
        
        -- Check for game over
        if sharedHealth <= 0 then
            triggerEvent('Game Over', '', '')
        end
    end
end

function opponentNoteHit(id, noteData, noteType, isSustainNote)
    if not isPlayerTurn then
        -- Opponent hits also affect shared health
        sharedHealth = math.min(sharedHealth + 0.03, 1.0)
        updateSharedHealthDisplay()
    end
end

function updateSharedHealthDisplay()
    local healthPercent = math.floor(sharedHealth * 100)
    setTextString('sharedHealthText', 'Shared Health: ' .. healthPercent .. '%')
    
    -- Color based on health
    if sharedHealth > 0.6 then
        setTextColor('sharedHealthText', '00FF00')
    elseif sharedHealth > 0.3 then
        setTextColor('sharedHealthText', 'FFFF00')
    else
        setTextColor('sharedHealthText', 'FF0000')
    end
    
    -- Update actual health bar
    setProperty('health', sharedHealth)
end

function onBeatHit()
    -- Synchronized effects for both players
    if curBeat % 4 == 0 then
        cameraShake('camGame', 0.01, 0.1)
        cameraShake('camHUD', 0.005, 0.1)
    end
end

function onEvent(name, value1, value2)
    if name == 'Force Turn Switch' then
        switchTurns()
        turnTimer = 0
    elseif name == 'Shared Damage' then
        local damage = tonumber(value1) or 0.1
        sharedHealth = math.max(sharedHealth - damage, 0.0)
        updateSharedHealthDisplay()
    end
end
```

## Learning Tips
- Use shared variables for co-op mechanics
- Implement turn-based systems with timers
- Synchronize effects between players
- Provide clear visual feedback for turn changes
- Balance mechanics so both players contribute

## Common Patterns
- Turn timers: Use `onUpdate()` to track turn duration
- Shared resources: Health, score, or power-ups
- Visual indicators: Show whose turn it is clearly
- Synchronized events: Effects that happen for both players
- State management: Track multiplayer game state