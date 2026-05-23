# Psych Engine Lua Reference

This file is your working Psych Engine Lua library. It is designed to be large, practical, and easy to expand while you learn.
Use it as both a cheat sheet and a reference system for engine hooks, functions, helpers, and usage patterns.

## What this system gives you

- A big, centralized Lua reference for Psych Engine modding.
- A reusable helper module file with wrapper functions.
- Workspace-level VS Code snippets so function names show up with descriptions.
- Workspace settings to help Lua tooling recognize engine globals.

## How to use it

1. Open `docs/PSYCH-ENGINE-LUA-REFERENCE.md` whenever you need a function explanation.
2. Use the helper file at `docs/psych_engine_lib.lua` for reusable utilities.
3. Type function names like `makeLuaSprite`, `setProperty`, or `runTimer` in VS Code and pick the snippet.
4. Add any new engine function you learn to this file so it stays complete.

## Engine event hooks

Psych Engine calls these global functions automatically from your Lua script.

- `function onCreate()`
  - Runs once when the scene begins.
  - Best place to create sprites, load animations, and initialize variables.
- `function onCreatePost()`
  - Runs after `onCreate()`.
  - Use for adjustments after initial creation.
- `function update(elapsed)`
  - Runs every frame before the engine updates objects.
  - `elapsed` is time since the last frame.
- `function onUpdate(elapsed)`
  - Equivalent to `update` in many scripts.
- `function onUpdatePost(elapsed)`
  - Runs after update logic each frame.
- `function onStepHit()`
  - Runs every music step.
  - Good for syncing visuals or actions to note steps.
- `function onBeatHit()`
  - Runs every beat.
  - Use for pulse animations and beat-based movement.
- `function onCountdownTick(counter)`
  - Runs during the countdown before the song starts.
- `function onStartCountdown()`
  - Runs when the countdown begins.
  - If you want to block the song start, return `Function_Stop`.
- `function onSongStart()`
  - Runs when the song actually starts playing.
- `function onEvent(name, value1, value2)`
  - Runs on custom events triggered by charts, code, or Haxe.
- `function opponentNoteHit(id, noteData, noteType, isSustainNote)`
  - Runs when the opponent hits a note.
- `function goodNoteHit(id, noteData, noteType, isSustainNote)`
  - Runs when the player hits a note successfully.
- `function noteMiss(id, noteData, noteType, isSustainNote)`
  - Runs when the player misses a note.
- `function onTweenCompleted(tag)`
  - Runs when any tween with the given tag finishes.
- `function onTimerCompleted(tag, loops, loopsLeft)`
  - Runs when a timer expires.
- `function onMoveCamera(focus)`
  - Runs whenever the camera target changes.
- `function onGameOver()`
  - Runs when the player reaches zero health.
  - Return `Function_Stop` to prevent the game over screen.
- `function onGameOverStart()`
  - Runs when the game over screen begins.
- `function onGameOverConfirm(retry)`
  - Runs when the player confirms retry or exit on game over.
  - `retry` is false when pressing Esc.
- `function onNextDialogue(line)`
  - Runs when the next dialogue line starts.
- `function onSkipDialogue(line)`
  - Runs when a dialogue line is skipped.
- `function onPause()`
  - Runs when the player pauses.
  - Return `Function_Stop` to block pausing.
- `function onResume()`
  - Runs when the game resumes.
- `function onCustomSubstateCreatePost(name)`
  - Runs after a custom substate is created.
- `function onCustomSubstateUpdate(name, elapsed)`
  - Runs while a custom substate is active.
- `function onCustomSubstateUpdatePost(name, elapsed)`
  - Runs after a custom substate update.
- `function onCustomSubstateDestroy(name)`
  - Runs when a custom substate closes.
- `function onSpawnNote(id, noteData, noteType, isSustainNote, strumTime)`
  - Runs when a note is spawned (before it appears on screen).
  - Useful for modifying note properties or adding custom behavior.
- `function onEndSong()`
  - Runs when the song ends.
  - Return `Function_Stop` to prevent transition, `Function_Continue` to allow it.
- `function startCountdown()`
  - Begin the countdown early.
- `function exitSong(skipTransition)`
  - Exit the current song and return to menu.
  - `skipTransition = true` skips the transition animation.
- `function loadSong(name, difficultyNum)`
  - Load a different song.
  - `difficultyNum` is the difficulty index (0 = easy, 1 = normal, etc.).
- `function restartSong(skipTransition)`
  - Restart the current song.
  - `skipTransition = true` skips the transition animation.

## Core engine functions

This is the biggest practical section. These are the Lua functions Psych Engine exposes at runtime.

### Sprite and object creation

- `makeLuaSprite(tag, imagePath, x, y)`
  - Create a normal sprite object.
  - Example: `makeLuaSprite('bg', 'stage/bg', -400, -200)`.
- `makeAnimatedLuaSprite(tag, imagePath, x, y)`
  - Create a sprite that can play animations.
- `addLuaSprite(tag, foreground)`
  - Add a sprite to the scene.
  - `foreground = true` places it in the HUD layer.
- `addAnimationByPrefix(tag, animName, prefix, frameRate, loop)`
  - Assign an animation sequence to an animated sprite.
- `objectPlayAnimation(tag, animName, forced)`
  - Play an animation on a sprite.
- `playAnim(tag, animName, forced)`
  - Alias for `objectPlayAnimation`.
- `scaleObject(tag, scaleX, scaleY)`
  - Resize a sprite.
- `setObjectCamera(tag, camera)`
  - Control what camera layer the sprite uses.
  - Most uses: `'game'`, `'other'`, `'hud'`.
- `makeGraphic(tag, width, height, color)`
  - Create a simple colored rectangle.
- `makeLuaText(tag, text, x, y)`
  - Create text to display on-screen.
- `setTextSize(tag, size)`
  - Change text size after creating it.
- `setTextColor(tag, color)`
  - Set text color.
- `addLuaText(tag)`
  - Add the text object to the scene.
- `luaSpriteExists(tag)`
  - Check if a sprite exists before touching it.

### Properties and object access

- `setProperty(propertyName, value)`
  - Set almost any engine property.
  - Example: `setProperty('gf.alpha', 0.5)`.
- `getProperty(propertyName)`
  - Read an engine property.
  - Example: `local currentY = getProperty('boyfriend.y')`.
- `setPropertyFromGroup(group, index, propertyName, value)`
  - Set a property for objects in a collection group.
  - Example: `setPropertyFromGroup('playerStrums', 2, 'x', 900)`.
- `getPropertyFromGroup(group, index, propertyName)`
  - Read from group objects.
- `setPropertyLuaSprite(tag, propertyName, value)`
  - Set a property on a specific Lua-created sprite.
- `getColorFromHex(hex)`
  - Convert a hex string to an internal color value.
  - Example: `setProperty('bg.color', getColorFromHex('FF0000'))`.

### Tweens and motion

- `doTweenX(tag, target, value, duration, easing)`
  - Tween a value on the X axis.
- `doTweenY(tag, target, value, duration, easing)`
  - Tween a value on the Y axis.
- `doTweenAlpha(tag, target, value, duration, easing)`
  - Tween opacity.
- `doTweenAngle(tag, target, value, duration, easing)`
  - Tween rotation.
- `doTweenZoom(tag, target, value, duration, easing)`
  - Tween camera zoom or object zoom.
- `stopTweens(tag)`
  - Stop tweens by tag.

### Timers, events, and sounds

- `runTimer(tag, time, loops)`
  - Start a timer that calls `onTimerCompleted`.
- `cancelTimer(tag)`
  - Cancel a running timer.
- `triggerEvent(name, value1, value2)`
  - Trigger built-in or custom events.
- `playSound(soundTag, volume)`
  - Play a sound effect.
- `stopSound(soundTag)`
  - Stop a sound effect.
- `soundFadeOut(soundTag, duration)`
  - Fade sound down over time.
- `playMusic(sound, volume, loop)`
  - Play background music.
- `precacheMusic(name)`
  - Preload music before playback.
- `addHits(value)`
  - Add to song hit counter and recalculate rating.
- `setScore(value)`
  - Set the current song score.
- `setMisses(value)`
  - Set the current miss count.
- `setHits(value)`
  - Set the current hit count.
- `setHealth(value)`
  - Set player health directly.
- `addHealth(value)`
  - Add health.
- `setSoundTime(tag, value)`
  - Set sound playback position.
- `getSoundPitch(tag)`
  - Read sound pitch if enabled.

### Camera and HUD control

- `setProperty('camGame.zoom', value)`
  - Control game camera zoom.
- `setProperty('camHUD.alpha', value)`
  - Hide or show HUD elements.
- `setProperty('defaultCamZoom', value)`
  - Change default camera zoom behavior.
- `setProperty('isCameraOnForcedPos', true/false)`
  - Force camera position locking.
- `cameraShake` is usually done with event triggers, e.g. `triggerEvent('Screen Shake', '0.2, 0.01', '0,0')`.

### Song / clock / timing helpers

- `getSongPosition()`
  - Current song position in milliseconds.
- `getSongTime()`
  - Alternate timing function in some engine versions.
- `setProperty('songLength', value)`
  - Override song length display.
- `getProperty('songLength')`
  - Read the current length value.
- `formatTime(ms)`
  - Convert ms into readable timer text.

### Utility functions

- `stringStartsWith(str, start)`
  - Check if string starts with substring.
- `stringEndsWith(str, end)`
  - Check if string ends with substring.
- `stringSplit(str, split)`
  - Split string by delimiter.
- `stringTrim(str)`
  - Remove whitespace from string.
- `getRandomInt(min, max, exclude)`
  - Get random integer in range, optionally excluding values.
- `getRandomFloat(min, max, exclude)`
  - Get random float in range, optionally excluding values.
- `getTextFromFile(path, ignoreModFolders)`
  - Read text file content.
- `directoryFileList(folder)`
  - List files in directory.

### Input functions

- `mouseClicked(button)`
  - Check if mouse button was just clicked.
- `mousePressed(button)`
  - Check if mouse button is pressed.
- `mouseReleased(button)`
  - Check if mouse button was just released.
- `keyboardJustPressed(key)`
  - Check if keyboard key was just pressed.
- `keyboardPressed(key)`
  - Check if keyboard key is pressed.
- `keyboardReleased(key)`
  - Check if keyboard key was just released.

### Sound control (v1.0.4+)

- `setSoundTime(tag, value)`
  - Set playback position of sound.
- `getSoundPitch(tag)`
  - Get pitch of sound (requires FLX_PITCH).

### Camera utilities

- `addCameraScroll(x, y)`
  - Add to camera scroll position.
- `addCameraFollowPoint(x, y)`
  - Add to camera follow position.
- `getCameraScrollX()`, `getCameraScrollY()`
  - Get camera scroll position.
- `getCameraFollowX()`, `getCameraFollowY()`
  - Get camera follow position.

### Object utilities

- `screenCenter(obj, pos)`
  - Center object on screen (pos = 'x', 'y', or 'xy').
- `objectsOverlap(obj1, obj2)`
  - Check if two objects overlap.
- `getPixelColor(obj, x, y)`
  - Get color of pixel at position in sprite.

### Rating functions

- `setRatingPercent(value)`
  - Set rating percentage.
- `setRatingName(value)`
  - Set rating name.
- `setRatingFC(value)`
  - Set rating FC status.

## Shaders and visual effects

Psych Engine supports GLSL shaders for advanced visual effects. Shaders are applied to sprites or the entire screen.

### Shader initialization

- `initLuaShader(shaderName)`
  - Load a shader from the `shaders/` folder.
  - Example: `initLuaShader('chromaticAberration')`.
- `setSpriteShader(spriteTag, shaderName)`
  - Apply a shader to a specific sprite.
- `setShaderBool(shaderName, propertyName, value)`
  - Set a boolean uniform in the shader.
- `setShaderFloat(shaderName, propertyName, value)`
  - Set a float uniform in the shader.
- `setShaderFloatArray(shaderName, propertyName, values)`
  - Set a float array uniform.
- `setShaderInt(shaderName, propertyName, value)`
  - Set an integer uniform.
- `setShaderSampler2D(shaderName, propertyName, texturePath)`
  - Set a texture sampler uniform.

### Common shader effects

- **Chromatic Aberration**: Separates RGB channels for a distorted effect.
  - Uniforms: `rOffset`, `gOffset`, `bOffset` (floats).
- **Bloom**: Adds glow to bright areas.
  - Uniforms: `intensity` (float), `threshold` (float).
- **VHS/Distortion**: Simulates old TV effects.
  - Uniforms: `time` (float), `noise` (float), `distortion` (float).
- **Heat Wave**: Creates wavy distortion.
  - Uniforms: `waveSpeed` (float), `waveFrequency` (float), `waveAmplitude` (float).
- **Black and White**: Converts to grayscale.
  - Uniforms: `intensity` (float, 0-1).
- **Drop Shadow**: Adds shadow behind sprites.
  - Uniforms: `shadowColor` (vec3), `shadowOffset` (vec2), `shadowAlpha` (float).
- **Godrays**: Sunbeam effect.
  - Uniforms: `density` (float), `weight` (float), `decay` (float), `exposure` (float).
- **Blur**: Gaussian blur effect.
  - Uniforms: `blurAmount` (float), `direction` (vec2).
- **Contrast**: Adjusts image contrast.
  - Uniforms: `contrast` (float), `brightness` (float).
- **Vignette**: Darkens edges.
  - Uniforms: `radius` (float), `softness` (float), `color` (vec3).

### Shader usage patterns

- **Applying to sprites**:
  ```lua
  initLuaShader('bloom')
  setSpriteShader('character', 'bloom')
  setShaderFloat('bloom', 'intensity', 0.5)
  ```

- **Screen-wide effects**:
  ```lua
  initLuaShader('chromaticAberration')
  setSpriteShader('camGame', 'chromaticAberration')  -- Apply to camera
  setShaderFloat('chromaticAberration', 'rOffset', 0.01)
  setShaderFloat('chromaticAberration', 'gOffset', 0.005)
  setShaderFloat('chromaticAberration', 'bOffset', 0.0)
  ```

- **Dynamic shader updates**:
  ```lua
  function onUpdate(elapsed)
      setShaderFloat('vhs', 'time', getSongPosition() * 0.001)
  end
  ```

- **Combining shaders**: Apply multiple shaders to the same sprite for complex effects.

### Shader file structure

Shaders are placed in `mods/shaders/` or `assets/shaders/`. Each shader has:
- `.frag` file: Fragment shader code (GLSL).
- `.vert` file: Vertex shader code (optional, defaults used if missing).

Example `.frag` for a simple color tint:
```glsl
#pragma header

void main() {
    vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
    color.rgb *= vec3(1.0, 0.5, 0.5);  // Tint red
    gl_FragColor = color;
}
```

### Advanced shader techniques

- **Time-based animations**: Use `u_time` or pass song position.
- **Texture sampling**: Use `flixel_texture2D` for sprite textures.
- **Uniform arrays**: For complex data like color palettes.
- **Conditional effects**: Use `if` statements in GLSL for dynamic behavior.
- **Performance**: Shaders run on GPU, but complex ones can impact FPS.

## Classes, groups, and engine collections

Psych Engine exposes engine internals through property strings and grouped access.

- `ClientPrefs`, `PlayState`, `StoryMenuState` are often used in `setPropertyFromClass`.
- Use `setPropertyFromGroup('notes', i, property, value)` for notes.
- Use `setPropertyFromGroup('opponentStrums', index, property, value)` for strum line elements.

## Practical examples

### Simple background creation

```lua
function onCreate()
    makeLuaSprite('bg', 'stage/background', -400, -200)
    scaleObject('bg', 1.1, 1.1)
    addLuaSprite('bg', false)
end
```

### Animated sprite with loop

```lua
function onCreate()
    makeAnimatedLuaSprite('bug', 'sprites/bug', 600, 500)
    addAnimationByPrefix('bug', 'fly', 'Bug Fly', 24, true)
    addLuaSprite('bug', false)
end
```

### Tweening a sprite into view

```lua
function onStepHit()
    if curStep == 288 then
        doTweenX('bugMove', 'bug', 0, 7.5, 'linear')
    end
end
```

### Using groups to move note columns

```lua
function onUpdate()
    setPropertyFromGroup('opponentStrums', 0, 'x', 132)
    setPropertyFromGroup('playerStrums', 0, 'x', 675)
end
```

### Custom event handler

```lua
function onEvent(name, value1, value2)
    if name == 'Flash Screen' then
        setProperty('camHUD.alpha', 0.5)
    end
end
```

## Helper module pattern

The helper module in `docs/psych_engine_lib.lua` is built for reuse.
It wraps the engine API with helper functions and documents them with comments.

### Example usage

```lua
local Psych = require('psych_engine_lib')

function onCreate()
    Psych.makeSprite('bg', 'stage/bg', -400, -200, false, 1.1, 1.1, 'game')
    Psych.runTimer('intro', 1)
end

function onTimerCompleted(tag)
    if tag == 'intro' then
        Psych.trigger('Screen Shake', '0.3,0.005', '0,0')
    end
end
```

## VS Code autocomplete and docs

The workspace includes `.vscode/psych-engine.code-snippets` for common Psych Engine functions.
When you type a function name in a Lua file, VS Code can suggest completion snippets with descriptions.

If you want a Pylance-like experience in Lua, use a Lua language extension such as
`sumneko.lua` or `Lua for Visual Studio Code` and keep this reference nearby.

## Building your own function reference system

- Add new engine functions to this doc as you discover them.
- Use the helper module to keep repeated code clean.
- Create snippets for common patterns and hooks.
- Add comments inside `psych_engine_lib.lua` so the module itself becomes self-documenting.

## Useful Psych Engine functions to add later

- `setPropertyFromClass(className, propertyName, value)`
- `removeLuaSprite(tag, destroy)`
- `objectPlayAnimation(tag, animName, forced)`
- `setTextString(tag, text)`
- `getProperty('cameraSpeed')`
- `getProperty('songName')`

## Recommended workflow

1. Start by reading this file and copying small examples.
2. Create a mod script with only one hook.
3. Add one engine function at a time.
4. Use snippets to learn correct syntax.
5. Expand `docs/psych_engine_lib.lua` with your own helpers.

## Notes for Psych Engine v0.7.3 and v1.0.4

- Most basic Lua hooks are shared across both versions.
- Some helper functions may be named differently in older engine builds.
- Use example mods in `unknown-suffering-mod/` and `tmp_altstage_extract/` to compare exact engine behavior.

## How the library system works

- `docs/PSYCH-ENGINE-LUA-REFERENCE.md` is your main API reference.
- `.vscode/psych-engine.code-snippets` gives descriptive completion suggestions.
- `.vscode/settings.json` includes Lua workspace library configuration.
- `docs/psych_engine_lib.lua` is a reusable helper module you can require from your scripts.

## Keep this file growing

Whenever you learn a new engine function:

- Add the function name to the correct section.
- Add a short example.
- Add a snippet if you want completion support.
- Add a helper wrapper to `psych_engine_lib.lua` if the function is useful repeatedly.
