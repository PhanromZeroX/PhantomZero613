-- psych_engine_lib.lua
-- A reusable Psych Engine Lua helper library for v0.7.3 and v1.0.4.
-- Copy this file into your mod scripts folder or require it from your script folder.

local Psych = {}

Psych.config = {
    defaultCamera = 'game',
    overlayCamera = 'other',
    debug = true,
}

Psych.eventHandlers = {}

Psych.docs = {
    makeSprite = "Psych.makeSprite(tag, imagePath, x, y, foreground, scaleX, scaleY, camera) - Create and add a sprite in one call.",
    makeAnimatedSprite = "Psych.makeAnimatedSprite(tag, imagePath, x, y, animName, prefix, frameRate, loop, foreground, scaleX, scaleY, camera) - Create an animated sprite and add it.",
    addSprite = "Psych.addSprite(tag, foreground) - Add an existing sprite to the scene.",
    addAnimation = "Psych.addAnimation(tag, animName, prefix, frameRate, loop) - Add an animation to an animated sprite.",
    playAnimation = "Psych.playAnimation(tag, animName, forced) - Play an animation on a sprite.",
    scaleSprite = "Psych.scaleSprite(tag, scaleX, scaleY) - Scale a sprite by x and y.",
    setSpriteCamera = "Psych.setSpriteCamera(tag, camera) - Set a sprite's camera layer.",
    setSpriteVisible = "Psych.setSpriteVisible(tag, visible) - Show or hide a sprite.",
    setSpriteAlpha = "Psych.setSpriteAlpha(tag, alpha) - Set a sprite's alpha transparency.",
    removeSprite = "Psych.removeSprite(tag, destroy) - Remove a sprite from the scene.",
    hasSprite = "Psych.hasSprite(tag) - Check if a Lua sprite exists.",
    setProp = "Psych.setProp(property, value) - Set any engine property by name.",
    getProp = "Psych.getProp(property) - Read any engine property by name.",
    setGroupProp = "Psych.setGroupProp(group, index, property, value) - Set a value on a group member.",
    getGroupProp = "Psych.getGroupProp(group, index, property) - Read a value from a group member.",
    setClassProp = "Psych.setClassProp(className, property, value) - Set a property on an engine class.",
    getClassProp = "Psych.getClassProp(className, property) - Read a class property.",
    setSpriteProp = "Psych.setSpriteProp(tag, property, value) - Set a property on a Lua sprite.",
    getColor = "Psych.getColor(hex) - Convert a hex color string into an engine color value.",
    tweenX = "Psych.tweenX(tag, target, value, duration, easing) - Tween a value on the X axis.",
    tweenY = "Psych.tweenY(tag, target, value, duration, easing) - Tween a value on the Y axis.",
    tweenAlpha = "Psych.tweenAlpha(tag, target, value, duration, easing) - Tween opacity over time.",
    tweenAngle = "Psych.tweenAngle(tag, target, value, duration, easing) - Tween rotation.",
    tweenZoom = "Psych.tweenZoom(tag, target, value, duration, easing) - Tween zoom if supported by engine version.",
    runTimer = "Psych.runTimer(tag, time, loops) - Start a timer that calls onTimerCompleted.",
    cancelTimer = "Psych.cancelTimer(tag) - Cancel a timer if the engine supports it.",
    trigger = "Psych.trigger(name, value1, value2) - Trigger a custom or built-in event.",
    screenShake = "Psych.screenShake(duration, strength) - Run a screen shake event.",
    playSound = "Psych.playSound(tag, volume) - Play a sound effect.",
    stopSound = "Psych.stopSound(tag) - Stop a sound effect.",
    fadeOutSound = "Psych.fadeOutSound(tag, duration) - Fade out a sound effect.",
    setCameraZoom = "Psych.setCameraZoom(value) - Set the game camera zoom.",
    setDefaultCameraZoom = "Psych.setDefaultCameraZoom(value) - Set the default camera zoom.",
    setHUDAlpha = "Psych.setHUDAlpha(value) - Set the HUD transparency.",
    forceCameraPosition = "Psych.forceCameraPosition(enabled) - Lock or unlock the forced camera position.",
    makeText = "Psych.makeText(tag, text, x, y, fontSize, color) - Create text and add it to the screen.",
    setText = "Psych.setText(tag, text) - Update a text object string.",
    setTextSize = "Psych.setTextSize(tag, size) - Change text size.",
    setTextColor = "Psych.setTextColor(tag, color) - Change text color.",
    makeOverlay = "Psych.makeOverlay(tag, width, height, hexColor, alpha, camera) - Create a full-screen overlay.",
    showOverlay = "Psych.showOverlay(tag, visible) - Show or hide an overlay.",
    initShader = "Psych.initShader(shaderName) - Initialize a GLSL shader from shaders folder.",
    setSpriteShader = "Psych.setSpriteShader(spriteTag, shaderName) - Apply a shader to a sprite.",
    setShaderFloat = "Psych.setShaderFloat(shaderName, propertyName, value) - Set float uniform in shader.",
    setShaderBool = "Psych.setShaderBool(shaderName, propertyName, value) - Set boolean uniform in shader.",
    setShaderInt = "Psych.setShaderInt(shaderName, propertyName, value) - Set integer uniform in shader.",
    setShaderFloatArray = "Psych.setShaderFloatArray(shaderName, propertyName, values) - Set float array uniform.",
    setShaderSampler2D = "Psych.setShaderSampler2D(shaderName, propertyName, texturePath) - Set texture sampler uniform.",
    stringStartsWith = "Psych.stringStartsWith(str, start) - Check if string starts with substring.",
    stringEndsWith = "Psych.stringEndsWith(str, end) - Check if string ends with substring.",
    stringSplit = "Psych.stringSplit(str, split) - Split string by delimiter.",
    stringTrim = "Psych.stringTrim(str) - Remove whitespace from string.",
    getRandomInt = "Psych.getRandomInt(min, max, exclude) - Get random integer in range.",
    getRandomFloat = "Psych.getRandomFloat(min, max, exclude) - Get random float in range.",
    getTextFromFile = "Psych.getTextFromFile(path, ignoreModFolders) - Read text file content.",
    directoryFileList = "Psych.directoryFileList(folder) - List files in directory.",
    mouseClicked = "Psych.mouseClicked(button) - Check mouse click.",
    mousePressed = "Psych.mousePressed(button) - Check mouse press.",
    mouseReleased = "Psych.mouseReleased(button) - Check mouse release.",
    keyboardJustPressed = "Psych.keyboardJustPressed(key) - Check key press.",
    keyboardPressed = "Psych.keyboardPressed(key) - Check key hold.",
    keyboardReleased = "Psych.keyboardReleased(key) - Check key release.",
    setSoundTime = "Psych.setSoundTime(tag, value) - Set sound playback position (v1.0.4+).",
    getSoundPitch = "Psych.getSoundPitch(tag) - Get sound pitch (v1.0.4+).",
    addCameraScroll = "Psych.addCameraScroll(x, y) - Add to camera scroll.",
    addCameraFollowPoint = "Psych.addCameraFollowPoint(x, y) - Add to camera follow.",
    getCameraScrollX = "Psych.getCameraScrollX() - Get camera scroll X.",
    getCameraScrollY = "Psych.getCameraScrollY() - Get camera scroll Y.",
    getCameraFollowX = "Psych.getCameraFollowX() - Get camera follow X.",
    getCameraFollowY = "Psych.getCameraFollowY() - Get camera follow Y.",
    screenCenter = "Psych.screenCenter(obj, pos) - Center object on screen.",
    objectsOverlap = "Psych.objectsOverlap(obj1, obj2) - Check object overlap.",
    getPixelColor = "Psych.getPixelColor(obj, x, y) - Get pixel color from sprite.",
    setRatingPercent = "Psych.setRatingPercent(value) - Set rating percentage.",
    setRatingName = "Psych.setRatingName(value) - Set rating name.",
    setRatingFC = "Psych.setRatingFC(value) - Set rating FC status.",
    debugProp = "Psych.debugProp(property) - Print an engine property for debugging.",
    log = "Psych.log(message) - Print a library debug message.",
    clamp = "Psych.clamp(value, min, max) - Clamp a number between min and max.",
    lerp = "Psych.lerp(start, stop, amount) - Linearly interpolate between two values.",
    help = "Psych.help(name) - Print documentation for a helper function.",
    explain = "Psych.explain(name) - Print documentation and example usage for a helper function.",
    list = "Psych.list() - Print the list of available helper functions.",
    flashCamera = "Psych.flashCamera('camGame', 'FF0000', 0.3, false, true)",
    setShaderUniform = "Psych.setShaderUniform('bloom', 'intensity', 0.75)",
    customizeNoteType = "Psych.customizeNoteType('Custom', 'customNoteTexture')",
    makeScoreScreen = "Psych.makeScoreScreen('menuBG', 'finalScore', 'menu/background', 200, 160, 32, 'FFFFFF')",
    makeDebugConsole = "Psych.makeDebugConsole('debugConsole', 20, 20, 18, 'FF0000')",
    updateDebugText = "Psych.updateDebugText('debugConsole', 'Current FPS: ' .. getProperty('fps'))",
    toggleDebug = "Psych.toggleDebug(true)",
    bindEvent = "Psych.bindEvent('HealthDrain', function(name, value1, value2) print('drain=' .. value1) end)",
    dispatchEvent = "Psych.dispatchEvent('HealthDrain', '0.1', '')",
}

Psych.examples = {
    makeSprite = "Psych.makeSprite('bg', 'stage/background', -400, -200, false, 1.1, 1.1, 'game')",
    makeAnimatedSprite = "Psych.makeAnimatedSprite('bug', 'enemies/bug', 600, 500, 'fly', 'Bug', 24, true, false, 1, 1, 'game')",
    trigger = "Psych.trigger('Flash Camera', '0.4', '0')",
    screenShake = "Psych.screenShake(0.3, 0.02)",
    runTimer = "Psych.runTimer('intro', 1)",
    makeText = "Psych.makeText('scoreText', 'Score: 0', 20, 20, 28, 'FFFFFF')",
    makeOverlay = "Psych.makeOverlay('introFade', 1280, 720, '000000', 1, 'other')",
    initShader = "Psych.initShader('bloom')",
    setSpriteShader = "Psych.setSpriteShader('character', 'bloom')",
    setShaderFloat = "Psych.setShaderFloat('bloom', 'intensity', 0.5)",
    stringStartsWith = "Psych.stringStartsWith('hello world', 'hello')",
    getRandomInt = "Psych.getRandomInt(1, 10)",
    mouseClicked = "if Psych.mouseClicked('left') then print('Clicked!') end",
    setSoundTime = "Psych.setSoundTime('music', 30)",
    addCameraScroll = "Psych.addCameraScroll(10, 0)",
    screenCenter = "Psych.screenCenter('mySprite', 'xy')",
    setRatingPercent = "Psych.setRatingPercent(0.95)",
    tweenAlpha = "Psych.tweenAlpha('bg', 'bg', 0.5, 0.4, 'linear')",
    setCameraZoom = "Psych.setCameraZoom(1.1)",
}

function Psych.explain(name)
    Psych.help(name)
    local example = Psych.examples[name]
    if example then
        print('Example: ' .. example)
    end
end

function Psych.help(name)
    if not name then
        print('Psych.help(name) - pass a function name to get help. Example: Psych.help("makeSprite")')
        return
    end

    local doc = Psych.docs[name]
    if doc then
        print(doc)
    else
        print('No documentation available for: ' .. tostring(name))
    end
end

function Psych.list()
    print('Psych helper functions:')
    for name in pairs(Psych.docs) do
        print('- ' .. name)
    end
end

-- Sprite creation helpers.
function Psych.makeSprite(tag, imagePath, x, y, foreground, scaleX, scaleY, camera)
    makeLuaSprite(tag, imagePath, x or 0, y or 0)
    if scaleX or scaleY then
        scaleObject(tag, scaleX or 1, scaleY or 1)
    end
    if camera then
        setObjectCamera(tag, camera)
    end
    addLuaSprite(tag, foreground or false)
end

function Psych.makeAnimatedSprite(tag, imagePath, x, y, animName, prefix, frameRate, loop, foreground, scaleX, scaleY, camera)
    makeAnimatedLuaSprite(tag, imagePath, x or 0, y or 0)
    addAnimationByPrefix(tag, animName or 'idle', prefix or animName or 'anim', frameRate or 24, loop == nil and true or loop)
    if scaleX or scaleY then
        scaleObject(tag, scaleX or 1, scaleY or 1)
    end
    if camera then
        setObjectCamera(tag, camera)
    end
    addLuaSprite(tag, foreground or false)
end

function Psych.addSprite(tag, foreground)
    addLuaSprite(tag, foreground or false)
end

function Psych.addAnimation(tag, animName, prefix, frameRate, loop)
    addAnimationByPrefix(tag, animName, prefix, frameRate or 24, loop == nil and true or loop)
end

function Psych.playAnimation(tag, animName, forced)
    objectPlayAnimation(tag, animName, forced or false)
end

function Psych.scaleSprite(tag, scaleX, scaleY)
    scaleObject(tag, scaleX or 1, scaleY or 1)
end

function Psych.setSpriteCamera(tag, camera)
    setObjectCamera(tag, camera)
end

function Psych.setSpriteVisible(tag, visible)
    setProperty(tag .. '.visible', visible)
end

function Psych.setSpriteAlpha(tag, alpha)
    setProperty(tag .. '.alpha', alpha)
end

function Psych.removeSprite(tag, destroy)
    removeLuaSprite(tag, destroy == nil and false or destroy)
end

function Psych.hasSprite(tag)
    return luaSpriteExists(tag)
end

-- Property helpers.
function Psych.setProp(property, value)
    setProperty(property, value)
end

function Psych.getProp(property)
    return getProperty(property)
end

function Psych.setGroupProp(group, index, property, value)
    setPropertyFromGroup(group, index, property, value)
end

function Psych.getGroupProp(group, index, property)
    return getPropertyFromGroup(group, index, property)
end

function Psych.setClassProp(className, property, value)
    setPropertyFromClass(className, property, value)
end

function Psych.getClassProp(className, property)
    return getPropertyFromClass(className, property)
end

function Psych.setSpriteProp(tag, property, value)
    setPropertyLuaSprite(tag, property, value)
end

function Psych.getColor(hex)
    return getColorFromHex(hex)
end

-- Tween helpers.
function Psych.tweenX(tag, target, value, duration, easing)
    doTweenX(tag, target, value, duration, easing or 'linear')
end

function Psych.tweenY(tag, target, value, duration, easing)
    doTweenY(tag, target, value, duration, easing or 'linear')
end

function Psych.tweenAlpha(tag, target, value, duration, easing)
    doTweenAlpha(tag, target, value, duration, easing or 'linear')
end

function Psych.tweenAngle(tag, target, value, duration, easing)
    doTweenAngle(tag, target, value, duration, easing or 'linear')
end

function Psych.tweenZoom(tag, target, value, duration, easing)
    if doTweenZoom then
        doTweenZoom(tag, target, value, duration, easing or 'linear')
    end
end

-- Timer / event / sound helpers.
function Psych.runTimer(tag, time, loops)
    runTimer(tag, time, loops)
end

function Psych.cancelTimer(tag)
    if cancelTimer then
        cancelTimer(tag)
    end
end

function Psych.trigger(name, value1, value2)
    triggerEvent(name, value1 or '', value2 or '')
end

function Psych.screenShake(duration, strength)
    triggerEvent('Screen Shake', tostring(duration) .. ',' .. tostring(strength), '0,0')
end

function Psych.playSound(tag, volume)
    if volume then
        playSound(tag, volume)
    else
        playSound(tag)
    end
end

function Psych.stopSound(tag)
    if stopSound then
        stopSound(tag)
    end
end

function Psych.fadeOutSound(tag, duration)
    if soundFadeOut then
        soundFadeOut(tag, duration)
    end
end

-- Camera / HUD helpers.
function Psych.setCameraZoom(value)
    setProperty('camGame.zoom', value)
end

function Psych.setDefaultCameraZoom(value)
    setProperty('defaultCamZoom', value)
end

function Psych.setHUDAlpha(value)
    setProperty('camHUD.alpha', value)
end

function Psych.forceCameraPosition(enabled)
    setProperty('isCameraOnForcedPos', enabled)
end

function Psych.makeText(tag, text, x, y, fontSize, color)
    makeLuaText(tag, text or '', x or 0, y or 0)
    setTextSize(tag, fontSize or 32)
    setTextColor(tag, color or 'FFFFFF')
    addLuaText(tag)
end

function Psych.setText(tag, text)
    setTextString(tag, text)
end

function Psych.setTextSize(tag, size)
    setTextSize(tag, size)
end

function Psych.setTextColor(tag, color)
    setTextColor(tag, color)
end

function Psych.makeOverlay(tag, width, height, hexColor, alpha, camera)
    makeLuaSprite(tag, '', 0, 0)
    makeGraphic(tag, width or 1280, height or 720, hexColor or '000000')
    setObjectCamera(tag, camera or 'other')
    setProperty(tag .. '.alpha', alpha or 1)
    addLuaSprite(tag, true)
end

function Psych.showOverlay(tag, visible)
    setProperty(tag .. '.visible', visible)
end

-- Shader helpers.
function Psych.initShader(shaderName)
    initLuaShader(shaderName)
end

function Psych.setSpriteShader(spriteTag, shaderName)
    setSpriteShader(spriteTag, shaderName)
end

function Psych.setShaderFloat(shaderName, propertyName, value)
    setShaderFloat(shaderName, propertyName, value)
end

function Psych.setShaderBool(shaderName, propertyName, value)
    setShaderBool(shaderName, propertyName, value)
end

function Psych.setShaderInt(shaderName, propertyName, value)
    setShaderInt(shaderName, propertyName, value)
end

function Psych.setShaderFloatArray(shaderName, propertyName, values)
    setShaderFloatArray(shaderName, propertyName, values)
end

function Psych.setShaderSampler2D(shaderName, propertyName, texturePath)
    setShaderSampler2D(shaderName, propertyName, texturePath)
end

-- Utility helpers.
function Psych.stringStartsWith(str, start)
    return stringStartsWith(str, start)
end

function Psych.stringEndsWith(str, endStr)
    return stringEndsWith(str, endStr)
end

function Psych.stringSplit(str, split)
    return stringSplit(str, split)
end

function Psych.stringTrim(str)
    return stringTrim(str)
end

function Psych.getRandomInt(min, max, exclude)
    return getRandomInt(min, max, exclude)
end

function Psych.getRandomFloat(min, max, exclude)
    return getRandomFloat(min, max, exclude)
end

function Psych.getTextFromFile(path, ignoreModFolders)
    return getTextFromFile(path, ignoreModFolders)
end

function Psych.directoryFileList(folder)
    return directoryFileList(folder)
end

-- Input helpers.
function Psych.mouseClicked(button)
    return mouseClicked(button)
end

function Psych.mousePressed(button)
    return mousePressed(button)
end

function Psych.mouseReleased(button)
    return mouseReleased(button)
end

function Psych.keyboardJustPressed(key)
    return keyboardJustPressed(key)
end

function Psych.keyboardPressed(key)
    return keyboardPressed(key)
end

function Psych.keyboardReleased(key)
    return keyboardReleased(key)
end

-- Advanced sound helpers (v1.0.4+).
function Psych.setSoundTime(tag, value)
    if setSoundTime then
        setSoundTime(tag, value)
    end
end

function Psych.getSoundPitch(tag)
    if getSoundPitch then
        return getSoundPitch(tag)
    else
        return 1
    end
end

-- Camera utility helpers.
function Psych.addCameraScroll(x, y)
    addCameraScroll(x or 0, y or 0)
end

function Psych.addCameraFollowPoint(x, y)
    addCameraFollowPoint(x or 0, y or 0)
end

function Psych.getCameraScrollX()
    return getCameraScrollX()
end

function Psych.getCameraScrollY()
    return getCameraScrollY()
end

function Psych.getCameraFollowX()
    return getCameraFollowX()
end

function Psych.getCameraFollowY()
    return getCameraFollowY()
end

-- Object utility helpers.
function Psych.screenCenter(obj, pos)
    screenCenter(obj, pos)
end

function Psych.objectsOverlap(obj1, obj2)
    return objectsOverlap(obj1, obj2)
end

function Psych.getPixelColor(obj, x, y)
    return getPixelColor(obj, x, y)
end

-- Rating helpers.
function Psych.setRatingPercent(value)
    setRatingPercent(value)
end

function Psych.setRatingName(value)
    setRatingName(value)
end

function Psych.setRatingFC(value)
    setRatingFC(value)
end

-- Debug and math helpers.
function Psych.debugProp(property)
    print(property .. ' = ' .. tostring(getProperty(property)))
end

function Psych.log(message)
    print('[Psych] ' .. tostring(message))
end

function Psych.debugLog(message)
    if Psych.config.debug then
        print('[Psych DEBUG] ' .. tostring(message))
    end
end

function Psych.warn(message)
    print('[Psych WARN] ' .. tostring(message))
end

function Psych.flashCamera(cameraName, color, duration, forced, fadeOut)
    cameraFlash(cameraName or 'camGame', color or 'FFFFFF', duration or 0.2, forced or false, fadeOut or false)
end

function Psych.setShaderUniform(shaderName, propertyName, value)
    if type(value) == 'boolean' then
        Psych.setShaderBool(shaderName, propertyName, value)
    elseif type(value) == 'number' then
        Psych.setShaderFloat(shaderName, propertyName, value)
    elseif type(value) == 'table' then
        Psych.setShaderFloatArray(shaderName, propertyName, value)
    else
        local num = tonumber(value)
        if num then
            Psych.setShaderFloat(shaderName, propertyName, num)
        else
            Psych.setShaderInt(shaderName, propertyName, 0)
        end
    end
end

function Psych.customizeNoteType(noteType, texture)
    for i = 0, getProperty('unspawnNotes.length')-1 do
        if getPropertyFromGroup('unspawnNotes', i, 'noteType') == noteType then
            setPropertyFromGroup('unspawnNotes', i, 'texture', texture or '')
        end
    end
end

function Psych.makeScoreScreen(bgTag, textTag, bgPath, x, y, fontSize, color)
    makeLuaSprite(bgTag or 'menuBG', bgPath or 'menu/background', 0, 0)
    setObjectCamera(bgTag or 'menuBG', 'other')
    addLuaSprite(bgTag or 'menuBG', true)
    Psych.makeText(textTag or 'finalScore', 'Final Score: 0', x or 200, y or 160, fontSize or 32, color or 'FFFFFF')
    setObjectCamera(textTag or 'finalScore', 'other')
end

function Psych.makeDebugConsole(tag, x, y, fontSize, color)
    Psych.makeText(tag or 'debugConsole', '', x or 20, y or 20, fontSize or 18, color or 'FF0000')
    setObjectCamera(tag or 'debugConsole', 'other')
    Psych.config.debug = true
end

function Psych.updateDebugText(tag, text)
    if type(text) ~= 'string' then
        text = tostring(text)
    end
    if not pcall(setTextString, tag, text) then
        Psych.warn('Debug text tag not found: ' .. tostring(tag))
    end
end

function Psych.toggleDebug(enabled)
    if enabled == nil then
        Psych.config.debug = not Psych.config.debug
    else
        Psych.config.debug = enabled
    end
end

function Psych.bindEvent(name, callback)
    if not Psych.eventHandlers[name] then
        Psych.eventHandlers[name] = {}
    end
    table.insert(Psych.eventHandlers[name], callback)
end

function Psych.dispatchEvent(name, value1, value2)
    local handlers = Psych.eventHandlers[name]
    if not handlers then
        return
    end
    for _, callback in ipairs(handlers) do
        callback(name, value1, value2)
    end
end

function Psych.clamp(value, minValue, maxValue)
    if value < minValue then
        return minValue
    elseif value > maxValue then
        return maxValue
    end
    return value
end

Psych.ideaTemplates = {
    ["screen shake effect"] = {
        description = "Add a screen shake effect on beat hits",
        code = [[
function onBeatHit()
    Psych.screenShake(0.3, 0.02)
end
]]
    },
    ["health drain mechanic"] = {
        description = "Gradually drain player health over time",
        code = [[
function onUpdate(elapsed)
    if getProperty('health') > 0.1 then
        addHealth(-0.001 * elapsed)
    end
end
]]
    },
    ["custom note effects"] = {
        description = "Add special effects when hitting custom notes",
        code = [[
function goodNoteHit(id, noteData, noteType, isSustainNote)
    if noteType == 'Fire' then
        Psych.flashCamera('camGame', 'FF6600', 0.2)
        Psych.playSound('fire_hit', 0.6)
    elseif noteType == 'Ice' then
        Psych.screenShake(0.1, 0.01)
        setProperty('camGame.zoom', getProperty('camGame.zoom') + 0.05)
    end
end
]]
    },
    ["dynamic camera follow"] = {
        description = "Make camera follow player with smooth movement",
        code = [[
function onUpdate(elapsed)
    local playerX = getProperty('boyfriend.x') + 100
    local playerY = getProperty('boyfriend.y') + 100
    setProperty('camFollow.x', playerX)
    setProperty('camFollow.y', playerY)
end
]]
    },
    ["score multiplier system"] = {
        description = "Add score multipliers based on combo",
        code = [[
local comboMultiplier = 1
local comboCount = 0

function goodNoteHit(id, noteData, noteType, isSustainNote)
    comboCount = comboCount + 1
    if comboCount >= 10 then
        comboMultiplier = 2
    elseif comboCount >= 25 then
        comboMultiplier = 3
    end
    
    local baseScore = 100
    local finalScore = baseScore * comboMultiplier
    addScore(finalScore)
end

function noteMiss(id, noteData, noteType, isSustainNote)
    comboCount = 0
    comboMultiplier = 1
end
]]
    },
    ["background animation"] = {
        description = "Create animated background with multiple layers",
        code = [[
function onCreate()
    Psych.makeSprite('bg1', 'stage/layer1', -400, -200, false, 1, 1, 'game')
    Psych.makeSprite('bg2', 'stage/layer2', -400, -200, false, 1.1, 1.1, 'game')
    Psych.makeSprite('bg3', 'stage/layer3', -400, -200, false, 1.2, 1.2, 'game')
end

function onUpdate(elapsed)
    setProperty('bg1.x', getProperty('bg1.x') + 0.5)
    setProperty('bg2.x', getProperty('bg2.x') + 1)
    setProperty('bg3.x', getProperty('bg3.x') + 1.5)
end
]]
    },
    ["pause menu overlay"] = {
        description = "Create a custom pause menu with options",
        code = [[
local paused = false

function onCreate()
    Psych.makeOverlay('pauseBG', 1280, 720, '000000', 0.7, 'other')
    Psych.makeText('pauseTitle', 'PAUSED', 500, 200, 48, 'FFFFFF')
    setObjectCamera('pauseTitle', 'other')
    Psych.makeText('resumeText', 'Press ENTER to Resume', 450, 300, 24, 'FFFFFF')
    setObjectCamera('resumeText', 'other')
end

function onUpdate(elapsed)
    if keyboardJustPressed('ENTER') then
        paused = not paused
        setProperty('pauseBG.alpha', paused and 0.7 or 0)
        setProperty('pauseTitle.visible', paused)
        setProperty('resumeText.visible', paused)
    end
end
]]
    },
    ["particle effect system"] = {
        description = "Simple particle system for effects",
        code = [[
local particles = {}

function onCreate()
    for i = 1, 10 do
        local particle = 'particle' .. i
        Psych.makeSprite(particle, 'effects/particle', math.random(-200, 1280), math.random(-200, 720), true, 0.5, 0.5, 'game')
        particles[i] = {tag = particle, vx = math.random(-5, 5), vy = math.random(-5, 5)}
    end
end

function onUpdate(elapsed)
    for _, p in ipairs(particles) do
        setProperty(p.tag .. '.x', getProperty(p.tag .. '.x') + p.vx)
        setProperty(p.tag .. '.y', getProperty(p.tag .. '.y') + p.vy)
        setProperty(p.tag .. '.alpha', getProperty(p.tag .. '.alpha') - 0.01)
    end
end
]]
    }
}

function Psych.suggestIdea(description)
    print('=== Psych Engine Idea Suggestions ===')
    print('Looking for ideas related to: "' .. description .. '"')
    print('')
    
    local found = false
    for name, template in pairs(Psych.ideaTemplates) do
        if string.find(string.lower(name), string.lower(description)) or 
           string.find(string.lower(template.description), string.lower(description)) then
            print('🎯 IDEA: ' .. name)
            print('   ' .. template.description)
            print('   Code suggestion:')
            print(template.code)
            print('')
            found = true
        end
    end
    
    if not found then
        print('No exact matches found. Here are some popular ideas:')
        print('')
        for name, template in pairs(Psych.ideaTemplates) do
            print('• ' .. name .. ' - ' .. template.description)
        end
        print('')
        print('Try: Psych.suggestIdea("screen shake") or Psych.suggestIdea("health")')
    end
end

function Psych.buildFromIdea(ideaName, customParams)
    local template = Psych.ideaTemplates[string.lower(ideaName)]
    if not template then
        Psych.warn('Idea template not found: ' .. ideaName)
        Psych.suggestIdea(ideaName)
        return
    end
    
    local code = template.code
    
    -- Apply custom parameters if provided
    if customParams then
        for param, value in pairs(customParams) do
            code = string.gsub(code, '%' .. param .. '%', value)
        end
    end
    
    print('=== Generated Code for: ' .. ideaName .. ' ===')
    print(code)
    print('')
    print('Copy this code into your script and customize the values!')
end

function Psych.quickTemplate(templateType, params)
    local templates = {
        sprite = [[
Psych.makeSprite('${tag}', '${image}', ${x}, ${y}, ${foreground}, ${scaleX}, ${scaleY}, '${camera}')
]],
        animated = [[
Psych.makeAnimatedSprite('${tag}', '${image}', ${x}, ${y}, '${animName}', '${prefix}', ${fps}, ${loop}, ${foreground}, ${scaleX}, ${scaleY}, '${camera}')
]],
        tween = [[
Psych.tween${type}('${tag}', '${target}', ${value}, ${duration}, '${easing}')
]],
        event = [[
function onEvent(name, value1, value2)
    if name == '${eventName}' then
        ${action}
    end
end
]],
        timer = [[
function onCreate()
    Psych.runTimer('${tag}', ${time})
end

function onTimerCompleted(tag)
    if tag == '${tag}' then
        ${action}
    end
end
]],
        shader = [[
Psych.initShader('${shaderName}')
Psych.setSpriteShader('${spriteTag}', '${shaderName}')
Psych.setShaderFloat('${shaderName}', '${uniform}', ${value})
]]
    }
    
    local template = templates[templateType]
    if not template then
        Psych.warn('Template type not found: ' .. templateType)
        print('Available templates: sprite, animated, tween, event, timer, shader')
        return
    end
    
    -- Apply parameters
    if params then
        for k, v in pairs(params) do
            template = string.gsub(template, '%${' .. k .. '}%', v)
        end
    end
    
    print('=== Quick Template: ' .. templateType .. ' ===')
    print(template)
    print('')
    print('Replace the ${variables} with your values!')
end

function Psych.combineIdeas(idea1, idea2, customCode)
    local template1 = Psych.ideaTemplates[string.lower(idea1)]
    local template2 = Psych.ideaTemplates[string.lower(idea2)]
    
    if not template1 or not template2 then
        Psych.warn('One or both ideas not found')
        return
    end
    
    print('=== Combined Ideas: ' .. idea1 .. ' + ' .. idea2 .. ' ===')
    print('-- Combined from: ' .. template1.description .. ' + ' .. template2.description)
    print('')
    print(template1.code)
    print('')
    print('-- Plus --')
    print('')
    print(template2.code)
    
    if customCode then
        print('')
        print('-- Custom integration code --')
        print(customCode)
    end
    
    print('')
    print('Merge these ideas together in your script!')
end

-- Enhanced help system
function Psych.learningPath(step)
    local paths = {
        [1] = {
            title = "Step 1: Basic Sprites and Setup",
            tasks = {
                "Create your first sprite with Psych.makeSprite()",
                "Learn onCreate() and onUpdate() hooks",
                "Add basic properties with setProperty()",
                "Try Psych.help('makeSprite') for guidance"
            },
            example = "Psych.makeSprite('bg', 'stage/background', -400, -200, false, 1.1, 1.1, 'game')"
        },
        [2] = {
            title = "Step 2: Animation and Interaction",
            tasks = {
                "Add animations with Psych.makeAnimatedSprite()",
                "Handle input with keyboardJustPressed()",
                "Create timers with Psych.runTimer()",
                "Use onTimerCompleted() for delayed actions"
            },
            example = "if keyboardJustPressed('SPACE') then Psych.screenShake(0.3, 0.02) end"
        },
        [3] = {
            title = "Step 3: Events and Effects",
            tasks = {
                "Learn onEvent() for custom events",
                "Add camera effects with Psych.flashCamera()",
                "Create tweens with Psych.tweenX/Y/Alpha()",
                "Use Psych.trigger() to fire events"
            },
            example = "Psych.trigger('Flash Camera', '0.5', 'FFFFFF')"
        },
        [4] = {
            title = "Step 4: Advanced Features",
            tasks = {
                "Add shaders with Psych.initShader()",
                "Create custom note types",
                "Build debug consoles with Psych.makeDebugConsole()",
                "Use the event system with Psych.bindEvent()"
            },
            example = "Psych.bindEvent('CustomHit', function() Psych.debugLog('Custom note hit!') end)"
        }
    }
    
    local path = paths[step]
    if not path then
        print('=== Psych Engine Learning Path ===')
        print('Available steps: 1-4')
        print('')
        for i, p in ipairs(paths) do
            print(i .. '. ' .. p.title)
        end
        return
    end
    
    print('=== ' .. path.title .. ' ===')
    print('')
    print('Tasks to complete:')
    for i, task in ipairs(path.tasks) do
        print(i .. '. ' .. task)
    end
    print('')
    print('Example to try:')
    print(path.example)
    print('')
    print('Next: Psych.learningPath(' .. (step + 1) .. ')')
end

-- Quick reference system
function Psych.quickRef(category)
    local refs = {
        hooks = {
            "onCreate() - Setup sprites and initial state",
            "onCreatePost() - Run after scene setup",
            "onUpdate(elapsed) - Frame-by-frame logic",
            "onBeatHit() - Beat-based effects",
            "onStepHit() - Step-based timing",
            "onEvent(name, value1, value2) - Custom events",
            "goodNoteHit(id, data, type, sustain) - Player hits note",
            "noteMiss(id, data, type, sustain) - Player misses note",
            "onTimerCompleted(tag) - Timer callbacks"
        },
        sprites = {
            "Psych.makeSprite(tag, image, x, y, fg, sx, sy, cam)",
            "Psych.makeAnimatedSprite(tag, image, x, y, anim, prefix, fps, loop, fg, sx, sy, cam)",
            "Psych.setSpriteVisible(tag, visible)",
            "Psych.setSpriteAlpha(tag, alpha)",
            "Psych.removeSprite(tag, destroy)"
        },
        effects = {
            "Psych.screenShake(duration, strength)",
            "Psych.flashCamera(camera, color, duration, forced, fadeOut)",
            "Psych.tweenX/Y/Alpha/Angle(tag, target, value, duration, easing)",
            "Psych.setCameraZoom(value)",
            "cameraShake(camera, intensity, duration)"
        },
        audio = {
            "Psych.playSound(tag, volume)",
            "Psych.stopSound(tag)",
            "Psych.fadeOutSound(tag, duration)",
            "playMusic(sound, volume, loop)",
            "setSoundTime(tag, time)"
        },
        utilities = {
            "Psych.getProp(property)",
            "Psych.setProp(property, value)",
            "Psych.debugProp(property)",
            "Psych.log(message)",
            "getSongPosition()"
        }
    }
    
    local ref = refs[category]
    if not ref then
        print('=== Quick Reference Categories ===')
        print('Available: hooks, sprites, effects, audio, utilities')
        return
    end
    
    print('=== Quick Reference: ' .. category .. ' ===')
    for _, item in ipairs(ref) do
        print('• ' .. item)
    end
end

-- Guided template builder
function Psych.buildTemplate(templateName, options)
    local templates = {
        modchart = {
            description = "Build a basic modchart with camera movements and effects",
            steps = {
                "Create camera setup",
                "Add beat-based effects", 
                "Include note hit reactions",
                "Add cleanup"
            },
            code = [[
function onCreate()
    -- Camera setup
    Psych.setCameraZoom(1.0)
    Psych.setDefaultCameraZoom(1.0)
end

function onBeatHit()
    -- Beat effects
    if curBeat % 4 == 0 then
        Psych.screenShake(0.2, 0.01)
    end
    
    if curBeat % 8 == 0 then
        Psych.setCameraZoom(1.1)
        Psych.tweenZoom('zoomReset', 'camGame', 1.0, 0.5, 'quadOut')
    end
end

function goodNoteHit(id, noteData, noteType, isSustainNote)
    -- Note reactions
    if noteData == 0 then
        Psych.addCameraScroll(-10, 0)
    elseif noteData == 1 then
        Psych.addCameraScroll(0, -10)
    elseif noteData == 2 then
        Psych.addCameraScroll(10, 0)
    elseif noteData == 3 then
        Psych.addCameraScroll(0, 10)
    end
end

function onDestroy()
    -- Cleanup
    Psych.setCameraZoom(1.0)
end
]]
        },
        bossfight = {
            description = "Create a boss fight with health phases and special attacks",
            steps = {
                "Setup boss sprite and phases",
                "Add phase transitions",
                "Implement special attacks",
                "Create defeat/win conditions"
            },
            code = [[
local bossPhase = 1
local maxHealth = 2.0

function onCreate()
    -- Boss setup
    Psych.makeAnimatedSprite('boss', 'characters/boss', 800, 200, 'idle', 'Boss Idle', 24, true, false, 1.5, 1.5, 'game')
    maxHealth = getProperty('health') * 2
end

function onUpdate(elapsed)
    -- Phase system
    local currentHealth = getProperty('health')
    local healthPercent = currentHealth / maxHealth
    
    if healthPercent > 0.6 and bossPhase ~= 1 then
        bossPhase = 1
        Psych.log('Boss Phase 1')
    elseif healthPercent > 0.3 and healthPercent <= 0.6 and bossPhase ~= 2 then
        bossPhase = 2
        Psych.screenShake(0.5, 0.03)
        Psych.log('Boss Phase 2')
    elseif healthPercent <= 0.3 and bossPhase ~= 3 then
        bossPhase = 3
        Psych.flashCamera('camGame', 'FF0000', 0.5)
        Psych.log('Boss Phase 3 - Final')
    end
end

function onBeatHit()
    -- Attack patterns based on phase
    if bossPhase == 1 and curBeat % 4 == 0 then
        Psych.trigger('SpawnProjectile', 'normal', '')
    elseif bossPhase == 2 and curBeat % 2 == 0 then
        Psych.trigger('SpawnProjectile', 'fast', '')
    elseif bossPhase == 3 and curBeat % 1 == 0 then
        Psych.trigger('SpawnProjectile', 'explosive', '')
    end
end
]]
        },
        rhythmGame = {
            description = "Build a rhythm-based mini-game with scoring",
            steps = {
                "Setup rhythm elements",
                "Add timing windows",
                "Implement scoring system",
                "Create feedback effects"
            },
            code = [[
local score = 0
local combo = 0
local lastHitTime = 0

function onCreate()
    -- UI setup
    Psych.makeText('scoreText', 'Score: 0', 20, 20, 32, 'FFFFFF')
    Psych.makeText('comboText', 'Combo: 0', 20, 60, 24, 'FFFF00')
end

function onUpdate(elapsed)
    -- Rhythm checking
    local currentTime = getSongPosition()
    local beatPosition = currentTime % (60 / getProperty('bpm') * 1000)
    
    -- Perfect hit window
    if beatPosition < 50 or beatPosition > 950 then
        setProperty('scoreText.color', getColorFromHex('00FF00')) -- Green for perfect
    elseif beatPosition < 100 or beatPosition > 900 then
        setProperty('scoreText.color', getColorFromHex('FFFF00')) -- Yellow for good
    else
        setProperty('scoreText.color', getColorFromHex('FFFFFF')) -- White for ok
    end
end

function onBeatHit()
    -- Beat feedback
    Psych.screenShake(0.1, 0.005)
end

function goodNoteHit(id, noteData, noteType, isSustainNote)
    -- Scoring system
    local timingBonus = 1.0
    local currentTime = getSongPosition()
    local beatPosition = currentTime % (60 / getProperty('bpm') * 1000)
    
    if beatPosition < 50 or beatPosition > 950 then
        timingBonus = 2.0 -- Perfect
        Psych.flashCamera('camGame', '00FF00', 0.1)
    elseif beatPosition < 100 or beatPosition > 900 then
        timingBonus = 1.5 -- Good
        Psych.flashCamera('camGame', 'FFFF00', 0.1)
    end
    
    combo = combo + 1
    score = score + (100 * timingBonus * combo)
    
    setTextString('scoreText', 'Score: ' .. score)
    setTextString('comboText', 'Combo: ' .. combo)
end

function noteMiss(id, noteData, noteType, isSustainNote)
    -- Combo break
    combo = 0
    setTextString('comboText', 'Combo: 0')
    Psych.screenShake(0.2, 0.02)
end
]]
        }
    }
    
    local template = templates[templateName]
    if not template then
        print('=== Available Guided Templates ===')
        for name, t in pairs(templates) do
            print('• ' .. name .. ' - ' .. t.description)
        end
        print('')
        print('Usage: Psych.buildTemplate("modchart")')
        return
    end
    
    print('=== Guided Template: ' .. templateName .. ' ===')
    print(template.description)
    print('')
    print('Steps to build:')
    for i, step in ipairs(template.steps) do
        print(i .. '. ' .. step)
    end
    print('')
    print('Generated code:')
    print(template.code)
    print('')
    print('Customize this template for your needs!')
end

return Psych
