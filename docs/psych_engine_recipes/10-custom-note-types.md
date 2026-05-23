# 10 - Custom Note Types Recipe

## Overview
This recipe demonstrates creating and handling custom note types in Psych Engine, allowing for unique gameplay mechanics and visual feedback beyond standard notes.

## Key Concepts
- Custom note type registration
- Note hit/miss handling
- Visual customization
- Gameplay modifiers per note type

## Example Code

```lua
-- Custom Note Types Example
function onCreate()
    -- Register custom note types
    addLuaScript('custom_notetypes/healNote')
    addLuaScript('custom_notetypes/poisonNote')
    addLuaScript('custom_notetypes/teleportNote')
    
    -- Create visual indicators
    makeLuaText('noteTypeIndicator', '', 400, 100)
    setTextSize('noteTypeIndicator', 32)
    setTextColor('noteTypeIndicator', 'FFFFFF')
    setObjectCamera('noteTypeIndicator', 'hud')
    addLuaText('noteTypeIndicator')
end

function onUpdate(elapsed)
    -- Show upcoming note types
    local nextNoteType = getPropertyFromGroup('notes', 0, 'noteType')
    if nextNoteType then
        if nextNoteType == 'Heal Note' then
            setTextString('noteTypeIndicator', 'HEALING NOTE')
            setTextColor('noteTypeIndicator', '00FF00')
        elseif nextNoteType == 'Poison Note' then
            setTextString('noteTypeIndicator', 'POISON NOTE')
            setTextColor('noteTypeIndicator', 'FF0000')
        elseif nextNoteType == 'Teleport Note' then
            setTextString('noteTypeIndicator', 'TELEPORT NOTE')
            setTextColor('noteTypeIndicator', 'FFFF00')
        else
            setTextString('noteTypeIndicator', '')
        end
    end
end

function goodNoteHit(id, noteData, noteType, isSustainNote)
    if noteType == 'Heal Note' then
        -- Heal player
        setProperty('health', getProperty('health') + 0.2)
        playSound('heal', 0.6)
        
        -- Visual feedback
        setProperty('boyfriend.color', getColorFromHex('00FF00'))
        doTweenColor('bfHealColor', 'boyfriend', 'FFFFFF', 0.5, 'linear')
        
    elseif noteType == 'Poison Note' then
        -- Damage player over time
        setProperty('health', getProperty('health') - 0.1)
        runTimer('poisonDamage', 0.5, 3)
        playSound('poison', 0.6)
        
        -- Visual feedback
        setProperty('boyfriend.color', getColorFromHex('FF0000'))
        doTweenColor('bfPoisonColor', 'boyfriend', 'FFFFFF', 1.5, 'linear')
        
    elseif noteType == 'Teleport Note' then
        -- Teleport boyfriend
        local newX = math.random(200, 800)
        setProperty('boyfriend.x', newX)
        playSound('teleport', 0.8)
        
        -- Screen flash
        setProperty('camGame.alpha', 0.8)
        doTweenAlpha('teleportFlash', 'camGame', 1.0, 0.3, 'linear')
    end
end

function noteMiss(id, noteData, noteType, isSustainNote)
    if noteType == 'Heal Note' then
        -- Missed heal opportunity
        playSound('missHeal', 0.4)
        
    elseif noteType == 'Poison Note' then
        -- Avoided poison
        playSound('dodgePoison', 0.5)
        
    elseif noteType == 'Teleport Note' then
        -- Failed teleport
        playSound('teleportFail', 0.4)
        cameraShake('camGame', 0.02, 0.2)
    end
end

function onTimerCompleted(tag)
    if tag == 'poisonDamage' then
        setProperty('health', getProperty('health') - 0.05)
    end
end
```

## Learning Tips
- Create separate Lua files in `custom_notetypes/` for each note type
- Use `addLuaScript()` to load note type handlers
- Check `noteType` parameter in hit/miss functions
- Custom note types need chart editor support to place them
- Test thoroughly to ensure balance and fun factor

## Common Patterns
- Healing notes: Restore health on hit, penalty on miss
- Damage notes: Apply damage over time or instantly
- Special effect notes: Trigger unique mechanics like teleportation
- Visual indicators: Show upcoming note types to player