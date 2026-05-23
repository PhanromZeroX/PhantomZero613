-- psych_engine_globals.lua
-- Psych Engine global API stubs for editor autocomplete and hover documentation.
-- This file is included in the Lua workspace library for inline support.

---@class PsychHelper
---@field docs table<string, string>
---@field examples table<string, string>
---@field config table<string, any>
---@field eventHandlers table<string, fun[]> 
---@field help fun(name: string)
---@field explain fun(name: string)
---@field list fun()
---@field flashCamera fun(cameraName: string, color: string, duration: number, forced: boolean, fadeOut: boolean)
---@field setShaderUniform fun(shaderName: string, propertyName: string, value: any)
---@field customizeNoteType fun(noteType: string, texture: string)
---@field makeScoreScreen fun(bgTag: string, textTag: string, bgPath: string, x: number, y: number, fontSize: number, color: string)
---@field makeDebugConsole fun(tag: string, x: number, y: number, fontSize: number, color: string)
---@field updateDebugText fun(tag: string, text: string)
---@field toggleDebug fun(enabled: boolean)
---@field debugLog fun(message: string)
---@field warn fun(message: string)
---@field bindEvent fun(name: string, callback: fun(name: string, value1: string, value2: string))
---@field dispatchEvent fun(name: string, value1: string, value2: string)

---@type PsychHelper
Psych = {}

---@param tag string
---@param imagePath string
---@param x number
---@param y number
function makeLuaSprite(tag, imagePath, x, y) end

---@param tag string
---@param imagePath string
---@param x number
---@param y number
function makeAnimatedLuaSprite(tag, imagePath, x, y) end

---@param tag string
---@param foreground boolean
function addLuaSprite(tag, foreground) end

---@param tag string
---@param animName string
---@param prefix string
---@param frameRate number
---@param loop boolean
function addAnimationByPrefix(tag, animName, prefix, frameRate, loop) end

---@param tag string
---@param animName string
---@param forced boolean
function objectPlayAnimation(tag, animName, forced) end

---@param tag string
---@param scaleX number
---@param scaleY number
function scaleObject(tag, scaleX, scaleY) end

---@param tag string
---@param camera string
function setObjectCamera(tag, camera) end

---@param tag string
---@param width number
---@param height number
---@param color string
function makeGraphic(tag, width, height, color) end

---@param property string
---@param value any
function setProperty(property, value) end

---@param property string
---@return any
function getProperty(property) end

---@param group string
---@param index number
---@param property string
---@param value any
function setPropertyFromGroup(group, index, property, value) end

---@param group string
---@param index number
---@param property string
---@return any
function getPropertyFromGroup(group, index, property) end

---@param tag string
---@param property string
---@param value any
function setPropertyLuaSprite(tag, property, value) end

---@param hex string
---@return number
function getColorFromHex(hex) end

---@param tag string
---@param target string
---@param value number
---@param duration number
---@param easing string
function doTweenX(tag, target, value, duration, easing) end

---@param tag string
---@param target string
---@param value number
---@param duration number
---@param easing string
function doTweenY(tag, target, value, duration, easing) end

---@param tag string
---@param target string
---@param value number
---@param duration number
---@param easing string
function doTweenAlpha(tag, target, value, duration, easing) end

---@param tag string
---@param target string
---@param value number
---@param duration number
---@param easing string
function doTweenAngle(tag, target, value, duration, easing) end

---@param tag string
---@param target string
---@param value number
---@param duration number
---@param easing string
function doTweenZoom(tag, target, value, duration, easing) end

---@param tag string
---@param time number
---@param loops number
function runTimer(tag, time, loops) end

---@param tag string
function cancelTimer(tag) end

---@param name string
---@param value1 string
---@param value2 string
function triggerEvent(name, value1, value2) end

---@param soundTag string
---@param volume number
function playSound(soundTag, volume) end

---@param soundTag string
function stopSound(soundTag) end

---@param soundTag string
---@param duration number
function soundFadeOut(soundTag, duration) end

---@param tag string
---@param text string
---@param x number
---@param y number
function makeLuaText(tag, text, x, y) end

---@param tag string
---@param size number
function setTextSize(tag, size) end

---@param tag string
---@param color string
function setTextColor(tag, color) end

---@param tag string
function addLuaText(tag) end

---@param tag string
function removeLuaSprite(tag, destroy) end

---@param className string
---@param property string
---@param value any
function setPropertyFromClass(className, property, value) end

---@param className string
---@param property string
---@return any
function getPropertyFromClass(className, property) end

---@param tag string
---@return boolean
function luaSpriteExists(tag) end

---@param propertyName string
---@return number
function getSongPosition() end

---@alias CameraName "game" | "hud" | "other"

---@param duration number
---@param strength number
function cameraMoveTo(x, y, duration, easing) end

function onCreate() end
function onCreatePost() end
function onUpdate(elapsed) end
function onUpdatePost(elapsed) end
function onStepHit() end
function onBeatHit() end
function onCountdownTick(counter) end
function onStartCountdown() end
function onSongStart() end
function onEvent(name, value1, value2) end
function onTimerCompleted(tag, loops, loopsLeft) end
function onTweenCompleted(tag) end
function opponentNoteHit(id, noteData, noteType, isSustainNote) end
function goodNoteHit(id, noteData, noteType, isSustainNote) end
function noteMiss(id, noteData, noteType, isSustainNote) end
function onMoveCamera(focus) end
function onGameOver() end
function onGameOverStart() end
function onGameOverConfirm(retry) end
function onNextDialogue(line) end
function onSkipDialogue(line) end
function onPause() end
function onResume() end
function onCustomSubstateCreatePost(name) end
function onCustomSubstateUpdate(name, elapsed) end
function onCustomSubstateUpdatePost(name, elapsed) end
function onCustomSubstateDestroy(name) end
function onDestroy() end

---@param name string
function startCountdown() end

---@param skipTransition boolean
function exitSong(skipTransition) end

---@param name string
---@param difficultyNum number
function loadSong(name, difficultyNum) end

---@param skipTransition boolean
function restartSong(skipTransition) end

---@param sound string
---@param volume number
---@param loop boolean
function playMusic(sound, volume, loop) end

---@param name string
function precacheMusic(name) end

---@param value number
function addHits(value) end

---@param value number
function setScore(value) end

---@param value number
function setMisses(value) end

---@param value number
function setHits(value) end

---@param value number
function setHealth(value) end

---@param value number
function addHealth(value) end

---@param tag string
---@param time number
function setSoundTime(tag, time) end

---@param tag string
---@return number
function getSoundPitch(tag) end

---@param name string
---@param property string
---@param value any
function cameraFlash(name, property, value) end

---@param camera string
---@param color string
---@param duration number
---@param forced boolean
---@param fadeOut boolean
function cameraFade(camera, color, duration, forced, fadeOut) end

---@param path string
---@param ignoreModFolders boolean
function getTextFromFile(path, ignoreModFolders) end

---@param folder string
---@return table
function directoryFileList(folder) end

---@param str string
---@param start string
---@return boolean
function stringStartsWith(str, start) end

---@param str string
---@param ending string
---@return boolean
function stringEndsWith(str, ending) end

---@param str string
---@param delimiter string
---@return table
function stringSplit(str, delimiter) end

---@param str string
---@return string
function stringTrim(str) end

---@param button string
---@return boolean
function mouseClicked(button) end

---@param button string
---@return boolean
function mousePressed(button) end

---@param button string
---@return boolean
function mouseReleased(button) end

---@param key string
---@return boolean
function keyboardJustPressed(key) end

---@param key string
---@return boolean
function keyboardPressed(key) end

---@param key string
---@return boolean
function keyboardReleased(key) end

---@param x number
---@param y number
function addCameraScroll(x, y) end

---@param x number
---@param y number
function addCameraFollowPoint(x, y) end

---@return number
function getCameraScrollX() end

---@return number
function getCameraScrollY() end

---@return number
function getCameraFollowX() end

---@return number
function getCameraFollowY() end

---@param obj string
---@param pos string
function screenCenter(obj, pos) end

---@param obj1 string
---@param obj2 string
---@return boolean
function objectsOverlap(obj1, obj2) end

---@param obj string
---@param x number
---@param y number
---@return number
function getPixelColor(obj, x, y) end

---@param value number
function setRatingPercent(value) end

---@param value string
function setRatingName(value) end

---@param value string
function setRatingFC(value) end

---@param spriteTag string
---@param shaderName string
function setSpriteShader(spriteTag, shaderName) end

---@param shaderName string
---@param propertyName string
---@param value number
function setShaderFloat(shaderName, propertyName, value) end

---@param shaderName string
---@param propertyName string
---@param value boolean
function setShaderBool(shaderName, propertyName, value) end

---@param shaderName string
---@param propertyName string
---@param value number
function setShaderInt(shaderName, propertyName, value) end

---@param shaderName string
---@param propertyName string
---@param values table
function setShaderFloatArray(shaderName, propertyName, values) end

---@param shaderName string
---@param propertyName string
---@param texturePath string
function setShaderSampler2D(shaderName, propertyName, texturePath) end

---@param cameraName string
---@param color string
---@param duration number
---@param forced boolean
---@param fadeOut boolean
function Psych.flashCamera(cameraName, color, duration, forced, fadeOut) end

---@param shaderName string
---@param propertyName string
---@param value any
function Psych.setShaderUniform(shaderName, propertyName, value) end

---@param noteType string
---@param texture string
function Psych.customizeNoteType(noteType, texture) end

---@param bgTag string
---@param textTag string
---@param bgPath string
---@param x number
---@param y number
---@param fontSize number
---@param color string
function Psych.makeScoreScreen(bgTag, textTag, bgPath, x, y, fontSize, color) end

---@param tag string
---@param x number
---@param y number
---@param fontSize number
---@param color string
function Psych.makeDebugConsole(tag, x, y, fontSize, color) end

---@param tag string
---@param text string
function Psych.updateDebugText(tag, text) end

---@param enabled boolean
function Psych.toggleDebug(enabled) end

---@param message string
function Psych.debugLog(message) end

---@param message string
function Psych.warn(message) end

---@param name string
---@param callback fun(name: string, value1: string, value2: string)
function Psych.bindEvent(name, callback) end

---@param name string
---@param value1 string
---@param value2 string
function Psych.dispatchEvent(name, value1, value2) end


---@param tag string
---@param imagePath string
---@param x number
---@param y number
---@param foreground boolean
---@param scaleX number
---@param scaleY number
---@param camera CameraName
function Psych.makeSprite(tag, imagePath, x, y, foreground, scaleX, scaleY, camera) end

---@param tag string
---@param imagePath string
---@param x number
---@param y number
---@param animName string
---@param prefix string
---@param frameRate number
---@param loop boolean
---@param foreground boolean
---@param scaleX number
---@param scaleY number
---@param camera CameraName
function Psych.makeAnimatedSprite(tag, imagePath, x, y, animName, prefix, frameRate, loop, foreground, scaleX, scaleY, camera) end

---@param tag string
---@param foreground boolean
function Psych.addSprite(tag, foreground) end

---@param tag string
---@param animName string
---@param prefix string
---@param frameRate number
---@param loop boolean
function Psych.addAnimation(tag, animName, prefix, frameRate, loop) end

---@param tag string
---@param animName string
---@param forced boolean
function Psych.playAnimation(tag, animName, forced) end

---@param tag string
---@param scaleX number
---@param scaleY number
function Psych.scaleSprite(tag, scaleX, scaleY) end

---@param tag string
---@param camera CameraName
function Psych.setSpriteCamera(tag, camera) end

---@param tag string
---@param visible boolean
function Psych.setSpriteVisible(tag, visible) end

---@param tag string
---@param alpha number
function Psych.setSpriteAlpha(tag, alpha) end

---@param tag string
---@param destroy boolean
function Psych.removeSprite(tag, destroy) end

---@param tag string
---@return boolean
function Psych.hasSprite(tag) end

---@param property string
---@param value any
function Psych.setProp(property, value) end

---@param property string
---@return any
function Psych.getProp(property) end

---@param group string
---@param index number
---@param property string
---@param value any
function Psych.setGroupProp(group, index, property, value) end

---@param group string
---@param index number
---@param property string
---@return any
function Psych.getGroupProp(group, index, property) end

---@param className string
---@param property string
---@param value any
function Psych.setClassProp(className, property, value) end

---@param className string
---@param property string
---@return any
function Psych.getClassProp(className, property) end

---@param tag string
---@param property string
---@param value any
function Psych.setSpriteProp(tag, property, value) end

---@param hex string
---@return number
function Psych.getColor(hex) end

---@param tag string
---@param target string
---@param value number
---@param duration number
---@param easing string
function Psych.tweenX(tag, target, value, duration, easing) end

---@param tag string
---@param target string
---@param value number
---@param duration number
---@param easing string
function Psych.tweenY(tag, target, value, duration, easing) end

---@param tag string
---@param target string
---@param value number
---@param duration number
---@param easing string
function Psych.tweenAlpha(tag, target, value, duration, easing) end

---@param tag string
---@param target string
---@param value number
---@param duration number
---@param easing string
function Psych.tweenAngle(tag, target, value, duration, easing) end

---@param tag string
---@param target string
---@param value number
---@param duration number
---@param easing string
function Psych.tweenZoom(tag, target, value, duration, easing) end

---@param tag string
---@param time number
---@param loops number
function Psych.runTimer(tag, time, loops) end

---@param tag string
function Psych.cancelTimer(tag) end

---@param name string
---@param value1 string
---@param value2 string
function Psych.trigger(name, value1, value2) end

---@param duration number
---@param strength number
function Psych.screenShake(duration, strength) end

---@param tag string
---@param volume number
function Psych.playSound(tag, volume) end

---@param tag string
function Psych.stopSound(tag) end

---@param tag string
---@param duration number
function Psych.fadeOutSound(tag, duration) end

---@param value number
function Psych.setCameraZoom(value) end

---@param value number
function Psych.setDefaultCameraZoom(value) end

---@param value number
function Psych.setHUDAlpha(value) end

---@param enabled boolean
function Psych.forceCameraPosition(enabled) end

---@param tag string
---@param text string
---@param x number
---@param y number
---@param fontSize number
---@param color string
function Psych.makeText(tag, text, x, y, fontSize, color) end

---@param tag string
---@param text string
function Psych.setText(tag, text) end

---@param tag string
---@param size number
function Psych.setTextSize(tag, size) end

---@param tag string
---@param color string
function Psych.setTextColor(tag, color) end

---@param tag string
---@param width number
---@param height number
---@param hexColor string
---@param alpha number
---@param camera CameraName
function Psych.makeOverlay(tag, width, height, hexColor, alpha, camera) end

---@param tag string
---@param visible boolean
function Psych.showOverlay(tag, visible) end

---@param property string
function Psych.debugProp(property) end

---@param message string
function Psych.log(message) end

---@param value number
---@param minValue number
---@param maxValue number
---@return number
function Psych.clamp(value, minValue, maxValue) end

---@param startValue number
---@param endValue number
---@param amount number
---@return number
function Psych.lerp(startValue, endValue, amount) end

return Psych
