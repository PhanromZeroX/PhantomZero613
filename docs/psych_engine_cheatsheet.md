# Psych Engine Lua Cheat Sheet

A compact, battle-tested guide for fast Psych Engine Lua coding. Use this for quick copy/paste and to learn the most common patterns.

## Quick Hooks

```lua
function onCreate()
    -- Setup anything before the song starts
end

function onCreatePost()
    -- Run after initial scene setup
end

function onUpdate(elapsed)
    -- Frame-by-frame logic
end

function onBeatHit()
    -- Beat-based effects
end

function onStepHit()
    -- Step-based timing
end

function onEvent(name, value1, value2)
    if name == 'MyEvent' then
        -- handle it
    end
end
```

## Common sprite patterns

```lua
makeLuaSprite('bg', 'stage/bg', -400, -200)
scaleObject('bg', 1.1, 1.1)
addLuaSprite('bg', false)

makeAnimatedLuaSprite('enemy', 'sprites/enemy', 800, 400)
addAnimationByPrefix('enemy', 'idle', 'Enemy Idle', 24, true)
addLuaSprite('enemy', false)
```

## Property access

```lua
setProperty('boyfriend.alpha', 0.5)
local x = getProperty('dad.x')
setPropertyFromGroup('notes', 0, 'alpha', 0.7)
```

## Tweening cheats

```lua
doTweenX('moveBG', 'bg', 0, 1.5, 'linear')
doTweenAlpha('fadeOut', 'bg', 0, 1.0, 'quadOut')
doTweenAngle('spin', 'enemy', 360, 2.0, 'expoOut')
```

## Timers and events

```lua
runTimer('spawnWave', 2.0, 1)

function onTimerCompleted(tag)
    if tag == 'spawnWave' then
        triggerEvent('Spawn Enemy', 'big', '')
    end
end
```

## Sound and music

```lua
playSound('sfx-hit', 0.8)
stopSound('sfx-hit')
soundFadeOut('sfx-hit', 0.5)
setSoundTime('music', 45)
```

## Camera and HUD

```lua
setProperty('camGame.zoom', 1.1)
setProperty('camHUD.alpha', 0.8)
cameraShake('camGame', 0.03, 0.2)
cameraFlash('camGame', 'FF0000', 0.3)
cameraFade('camHUD', '000000', 1.0, true)
```

## Shader shortcut

```lua
initLuaShader('vhs')
setSpriteShader('bg', 'vhs')
setShaderFloat('vhs', 'time', getSongPosition() * 0.001)
setShaderFloat('vhs', 'noise', 0.12)
```

## Performance tips

- Precache assets in `onCreate()` with `precacheImage()` and `precacheSound()`.
- Throttle expensive updates using `if frameCounter % 3 == 0 then ... end`.
- Disable heavy effects when FPS drops.
- Use `onBeatHit()` or `onStepHit()` instead of every frame when possible.

## Useful shortcuts

```lua
local health = getHealth()
local bpm = getProperty('bpm')
setProperty('health', health - 0.1)
local pos = getSongPosition()
```

## HScript note

HScript is supported by Psych Engine, but it is more advanced than Lua. Focus on Lua first, then learn HScript later if you want custom Haxe-side logic.
