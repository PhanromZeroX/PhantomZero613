# Psych Engine Lua Code Skeletons

A set of code skeletons for Psych Engine Lua scripts, from large full-script templates to small reusable patterns.

Use these templates when you want a complete structure that already includes all major hooks, event handling, and comment guides.

## How to use

1. Copy the code skeleton into your script file.
2. Replace placeholder names and values with your own assets, events, and logic.
3. Keep the comments until your script is working, then remove or change them as needed.
4. Use the explanation sections below to understand what each part does.

---

## Full Script Skeleton

```lua
local Psych = require('psych_engine_lib') -- Require the helper module if you want reusable wrappers and utilities.

-- [state] Persistent values that drive behavior across frames and hooks.
local songStarted = false
local noteJumpSpeed = 1.0

function onCreate()
    -- [scene] Create background art and assign it to the game camera.
    makeLuaSprite('bg', 'stage/background', -400, -200)
    scaleObject('bg', 1.1, 1.1)
    addLuaSprite('bg', false)
    setObjectCamera('bg', 'game')

    -- [precache] Preload audio so sounds are ready when triggered.
    precacheSound('sfx-hit')
    precacheSound('sfx-boom')

    -- [hud] Create runtime text that updates when the player scores.
    makeLuaText('scoreText', 'Score: 0', 16, 16)
    setTextSize('scoreText', 28)
    addLuaText('scoreText')
end

function onCreatePost()
    -- [post-creation] This runs after the scene is built and the camera has been initialized.
    setProperty('camGame.zoom', 1.05)
    setProperty('camHUD.alpha', 1)
end

function onUpdate(elapsed)
    -- [frame] Keep this light. Use it for input, movement, and fast updates.
    if keyboardJustPressed('SPACE') then
        playSound('sfx-hit', 0.8)
    end

    -- [timing] Use getSongPosition() to trigger behavior at specific music times.
    local songPos = getSongPosition()
    if songPos > 10000 and not songStarted then
        songStarted = true
        runTimer('firstEffect', 0.5)
    end
end

function onBeatHit()
    -- [beat] Beat-synced effects are great for pulsing camera or triggering animations.
    cameraShake('camGame', 0.02, 0.1)
end

function onStepHit()
    -- [step] Use curStep for choreography tied to chart timing.
    if curStep == 128 then
        setProperty('bg.alpha', 0.5)
    end
end

function onEvent(name, value1, value2)
    -- [events] Custom and built-in events come through this hook.
    if name == 'Flash' then
        cameraFlash('camGame', value1, tonumber(value2))
    elseif name == 'Spawn' then
        -- value1 = object name, value2 = behavior or extra argument
    end
end

function onTimerCompleted(tag)
    -- [timer] Use tagged timers to separate delayed actions.
    if tag == 'firstEffect' then
        doTweenAlpha('bgFade', 'bg', 0, 1, 'quadOut')
    end
end

function goodNoteHit(id, noteData, noteType, isSustainNote)
    -- [player note] Reward the player or update UI on note success.
    addHealth(0.015)
    setTextString('scoreText', 'Score: ' .. getProperty('songScore'))
end

function noteMiss(id, noteData, noteType, isSustainNote)
    -- [miss] Punish misses with a screen effect or health loss.
    cameraShake('camGame', 0.03, 0.2)
end

function onDestroy()
    -- [cleanup] Remove temporary sprites and stop effects.
    removeLuaSprite('bg', true)
end
```

### Why this structure works

- `local Psych = require('psych_engine_lib')` loads helper utilities so you can use `Psych.makeSprite`, `Psych.trigger`, and more.
- `onCreate()` should create sprites, preload sounds, and set up the initial UI.
- `onCreatePost()` is ideal for any adjustments that require the scene to already exist.
- `onUpdate(elapsed)` is your main loop. Keep it efficient and avoid expensive operations inside it.
- `onBeatHit()` and `onStepHit()` are perfect for timing effects to music.
- `onEvent()` is the single place custom events arrive from charts and other scripts.
- `onTimerCompleted()` lets you delay actions cleanly without blocking the game.
- `goodNoteHit()` and `noteMiss()` are the main response hooks for gameplay feedback.
- `onDestroy()` helps remove objects if the script is unloaded or the song ends.

### Key notes for this template

- Use `tonumber(value2)` whenever you expect a numeric event parameter.
- `curStep` is a built-in variable from Psych Engine representing the current step number.
- `setProperty('camGame.zoom', 1.05)` changes the game camera zoom; the HUD camera stays separate.
- Keep `onUpdate()` cheap: many things are better inside `onBeatHit()` or `onStepHit()`.

---

## Shader Effect Skeleton

```lua
function onCreate()
    -- [shader init] Load the GLSL shader from assets/shaders.
    initLuaShader('vhs')

    -- [overlay] Create a full-screen sprite to hold the shader effect.
    makeLuaSprite('shaderOverlay', '', 0, 0)
    setObjectCamera('shaderOverlay', 'other')
    setSpriteShader('shaderOverlay', 'vhs')
    addLuaSprite('shaderOverlay', true)
end

function onUpdate(elapsed)
    -- [time] Convert song position to seconds to drive animated shader uniforms.
    local time = getSongPosition() * 0.001
    setShaderFloat('vhs', 'time', time)

    -- [tune] Update shader properties from Lua every frame.
    setShaderFloat('vhs', 'noise', 0.08)
    setShaderFloat('vhs', 'scanline', 0.5)
end
```

### Why this skeleton is useful

- `initLuaShader('vhs')` loads the shader file named `vhs.glsl` or `vhs.frag`.
- `setObjectCamera('shaderOverlay', 'other')` keeps the effect on a separate overlay camera.
- `setShaderFloat()` updates uniforms dynamically so the effect animates.
- Use `getSongPosition() * 0.001` to convert milliseconds into seconds for smooth shader motion.

### Tuning tips

- Use smaller `noise` values for subtle effects and larger values for stronger distortion.
- If your shader has boolean flags, use `setShaderBool('vhs', 'enabled', true)`.
- Update only the uniforms you need each frame to save performance.

---

## Custom Event Handler Skeleton

```lua
function onEvent(name, value1, value2)
    if name == 'HealthDrain' then
        -- [safe parse] Convert the event value to a number. If it fails, use a default.
        local drain = tonumber(value1) or 0.1
        addHealth(-drain)
    elseif name == 'CameraZoom' then
        -- [zoom] Use event value1 for desired zoom amount.
        local zoom = tonumber(value1) or 1.05
        doTweenZoom('zoomTween', 'camGame', zoom, 0.4, 'expoOut')
    elseif name == 'SetText' then
        -- [text] Use value1 as the text object tag and value2 as the new text.
        setTextString(value1, value2)
    end
end
```

### Why this skeleton is important

- Events are a central communication channel for Psy-Charts, custom UI, and stage logic.
- `name` is the event identifier and must match the event string exactly.
- `value1` and `value2` are always strings, so use `tonumber()` when you need numbers.
- Group event names with comments to keep your logic readable.

---

## Timer Logic Skeleton

```lua
function onCreate()
    -- [timers] Start delayed events. A tag is used to identify the timer later.
    runTimer('spawnWave', 2.5)
    runTimer('cameraReset', 1.0)
end

function onTimerCompleted(tag)
    if tag == 'spawnWave' then
        -- [wave] Trigger a custom event once the delay finishes.
        triggerEvent('SpawnEnemy', 'big', '')
    elseif tag == 'cameraReset' then
        -- [reset] Smoothly return the camera zoom to normal.
        doTweenZoom('resetZoom', 'camGame', 1.0, 0.5, 'linear')
    end
end
```

### Why this skeleton is useful

- `runTimer()` lets you delay behavior without using busy loops.
- `onTimerCompleted()` receives the timer tag so one function can handle many timers.
- Use descriptive tags like `spawnWave` and `cameraReset` for clarity.
- Timers are ideal for opening cutscenes, delayed attacks, and staggered effects.

---

## Small Reusable Skeletons

### Sprite setup with comments

```lua
-- create a sprite, scale it, add it to the scene, and assign the game camera
makeLuaSprite('bg', 'stage/background', -400, -200)
scaleObject('bg', 1.1, 1.1)
addLuaSprite('bg', false)
setObjectCamera('bg', 'game')
```

### Animation setup

```lua
-- create an animated sprite, add a looping animation, and add it to the scene
makeAnimatedLuaSprite('enemy', 'sprites/enemy', 400, 300)
addAnimationByPrefix('enemy', 'idle', 'Enemy Idle', 24, true)
addLuaSprite('enemy', false)
```

### Camera effect helper

```lua
-- quick camera FX for impact and emphasis
cameraShake('camGame', 0.03, 0.2)
cameraFlash('camGame', 'FFFFFF', 0.3)
setProperty('camGame.zoom', 1.05)
```

### Text HUD skeleton

```lua
-- create a visible score text object in the top-left corner
makeLuaText('scoreText', 'Score: 0', 16, 16)
setTextSize('scoreText', 26)
setTextColor('scoreText', 'FFFFFF')
addLuaText('scoreText')
```

### Input check skeleton

```lua
-- first press detection
if keyboardJustPressed('SPACE') then
    -- action on first press
end

-- continuous hold detection
if keyboardPressed('LEFT') then
    -- continuous behavior while held
end
```

### Custom note hook skeleton

```lua
function goodNoteHit(id, noteData, noteType, isSustainNote)
    -- This runs when the player hits a note successfully
end

function noteMiss(id, noteData, noteType, isSustainNote)
    -- This runs when the player misses a note
end
```

### Simple shader update skeleton

```lua
function onUpdate(elapsed)
    -- animate shader values every frame
    setShaderFloat('shaderName', 'time', getSongPosition() * 0.001)
    setShaderFloat('shaderName', 'intensity', 0.5)
end
```

---

## Custom Note Type Skeleton

```lua
function onCreate()
    -- [custom note] create a custom note type if you want special behavior
    for i = 0, getProperty('unspawnNotes.length')-1 do
        if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'Custom' then
            setPropertyFromGroup('unspawnNotes', i, 'texture', 'customNoteTexture')
        end
    end
end

function goodNoteHit(id, noteData, noteType, isSustainNote)
    if noteType == 'Custom' then
        -- special bonus or effect for the custom note
        addHealth(0.02)
    end
end

function noteMiss(id, noteData, noteType, isSustainNote)
    if noteType == 'Custom' then
        -- custom miss behavior for this type
        cameraShake('camGame', 0.04, 0.25)
    end
end
```

### Menu / Score Screen Skeleton

```lua
function onCreate()
    -- [menu] Build a simple score or results screen overlay
    makeLuaSprite('menuBG', 'menu/background', 0, 0)
    setObjectCamera('menuBG', 'other')
    addLuaSprite('menuBG', true)

    makeLuaText('finalScore', 'Final Score: 0', 200, 160)
    setObjectCamera('finalScore', 'other')
    setTextSize('finalScore', 32)
    addLuaText('finalScore')
end

function onEndSong()
    -- [score] update the menu text when the song ends
    setTextString('finalScore', 'Final Score: ' .. getProperty('songScore'))
    return Function_Stop
end
```

### Multiplayer / Bot Mode Skeleton

```lua
function onCreate()
    -- [multiplayer] add an extra bot sprite or HUD indicator
    makeLuaSprite('botIcon', 'ui/bot', 1100, 30)
    setObjectCamera('botIcon', 'hud')
    addLuaSprite('botIcon', true)
end

function onUpdate(elapsed)
    -- [bot] simple bot decision loop using note positions or timing
    if getProperty('botPlay') then
        if getProperty('songMisses') < 3 then
            triggerEvent('BotAction', 'hit', '')
        end
    end
end
```

### Shader Composer Skeleton

```lua
function onCreate()
    initLuaShader('heat')
    initLuaShader('vhs')

    makeLuaSprite('shaderLayer', '', 0, 0)
    setObjectCamera('shaderLayer', 'other')
    setSpriteShader('shaderLayer', 'heat')
    addLuaSprite('shaderLayer', true)
end

function onUpdate(elapsed)
    local time = getSongPosition() * 0.001
    setShaderFloat('heat', 'time', time)
    setShaderFloat('heat', 'strength', 0.25)
    setShaderFloat('vhs', 'noise', 0.12)
end
```

### Debug / Test Harness Skeleton

```lua
local debugMode = true
local debugTimer = 0

function onUpdate(elapsed)
    if debugMode then
        debugTimer = debugTimer + elapsed
        if debugTimer > 1 then
            debugTimer = 0
            debugPrint('Debug: song pos=' .. getSongPosition())
        end
    end
end

function onEvent(name, value1, value2)
    if name == 'ToggleDebug' then
        debugMode = not debugMode
        debugPrint('Debug mode: ' .. tostring(debugMode))
    end
end
```

### How to improve helpers

- Add wrapper functions for recurring patterns like sprite creation, camera effects, and HUD updates.
- Create fallback helpers that check for missing engine functions and provide version-safe alternatives.
- Add `Psych.makeCustomNote()` and `Psych.spawnBotNote()` if you use those patterns often.
- Expose a `Psych.config` table so your scripts can change behavior without rewriting function calls.
- Keep helper names consistent: `make`, `set`, `trigger`, `play`, `tween`, `debug`.
- Build helper methods that are easy to search with `Psych.help()` and `Psych.explain()`.
- Use descriptive names so editor completion shows clear intent when you select the helper.

### Helper improvement ideas

- Add helper logging: `Psych.log('message')`, `Psych.debugLog('value')`, or `Psych.warn('message')`.
- Add shorthand wrappers: `Psych.flashCamera('camGame', color, duration)`.
- Add unified shader calls: `Psych.setShaderUniform(shader, name, value)`.
- Add a small event bus: `Psych.bindEvent(name, callback)` and `Psych.dispatchEvent(name, value1, value2)`.
- Make a debug console helper: `Psych.makeDebugConsole(tag, x, y, size, color)` and `Psych.updateDebugText(tag, text)`.
- Add `Psych.makeScoreScreen()` to quickly build menu/score overlays.
- Keep your helper docs in `Psych.docs` so `Psych.help()` can display the right hover-like guidance.

## Add whatever else you want

This file is designed to grow with your workflow. If you want more support, the next additions can include:

- `custom note type` code skeletons
- `multiplayer or bot mode` scaffolds
- `menu/score screen` and `stage transition` skeletons
- `full shader composer` templates for layer stacking
- `debug console / test mode` boilerplates
- `performance profiling` scripts with frame-skip control

If you want, I can also add a full `Psych Engine Lua project starter` file with all major hooks, comments, and placeholders in one copy/paste-ready block.
