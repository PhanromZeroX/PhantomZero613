-- Psych Engine Global Declarations
-- This file declares all Psych Engine globals to prevent IDE warnings

---@type boolean
shadersEnabled = true

---@type number
screenWidth = 1280

---@type number
screenHeight = 720

---@type number
curBeat = 0

---@type number
curStep = 0

---@type number
curSection = 0

---@type boolean
mustHitSection = false

---@type boolean
altAnim = false

---@type boolean
gfSection = false

---@type number
bpm = 120

---@type number
scrollSpeed = 1.0

---@type string
version = "1.0.4"

---@type number
startingSongPos = 0

-- Psych Engine Functions
---@param shaderName string
---@return nil
function initLuaShader(shaderName) end

---@param target string
---@param shaderName string
---@return nil
function setSpriteShader(target, shaderName) end

---@param spriteName string
---@param uniform string
---@param value number
---@return nil
function setShaderFloat(spriteName, uniform, value) end

---@param spriteName string
---@param uniform string
---@param value integer
---@return nil
function setShaderInt(spriteName, uniform, value) end

---@param spriteName string
---@param uniform string
---@param x number
---@param y number
---@return nil
function setShaderVec2(spriteName, uniform, x, y) end

---@param spriteName string
---@param uniform string
---@param x number
---@param y number
---@param z number
---@return nil
function setShaderVec3(spriteName, uniform, x, y, z) end

---@param id string
---@param image string
---@param x number
---@param y number
---@return nil
function makeLuaSprite(id, image, x, y) end

---@param id string
---@param graphic string
---@param width integer
---@param height integer
---@param color string
---@return nil
function makeGraphic(id, graphic, width, height, color) end

---@param id string
---@param inGroup? boolean
---@return nil
function addLuaSprite(id, inGroup) end

---@param id string
---@param animName string
---@param prefix string
---@param framerate? integer
---@param loop? boolean
---@return nil
function addAnimationByPrefix(id, animName, prefix, framerate, loop) end

---@param id string
---@param anim string
---@param force? boolean
---@return nil
function objectPlayAnimation(id, anim, force) end

---@param tweenName string
---@param target string
---@param endValue number
---@param duration number
---@param ease string
---@return nil
function doTweenX(tweenName, target, endValue, duration, ease) end

---@param tweenName string
---@param target string
---@param endValue number
---@param duration number
---@param ease string
---@return nil
function doTweenY(tweenName, target, endValue, duration, ease) end

---@param tweenName string
---@param target string
---@param endValue number
---@param duration number
---@param ease string
---@return nil
function doTweenAlpha(tweenName, target, endValue, duration, ease) end

---@param tweenName string
---@param target string
---@param endValue number
---@param duration number
---@param ease string
---@return nil
function doTweenZoom(tweenName, target, endValue, duration, ease) end

---@return number
function getSongPosition() end

---@param variable string
---@return any
function getVar(variable) end

---@param variable string
---@param value any
---@return nil
function setVar(variable, value) end

---@param property string
---@return any
function getProperty(property) end

---@param property string
---@param value any
---@return nil
function setProperty(property, value) end

---@param message string
---@vararg string
---@return nil
function debugPrint(message, ...) end

---@param code string
---@return nil
function runHaxeCode(code) end

---@param camera string
---@param intensity number
---@param duration number
---@return nil
function cameraShake(camera, intensity, duration) end

---@param tag string
---@return nil
function cancelTween(tag) end

-- Psych Engine Callbacks
---@return nil
function onCreate() end

---@return nil
function onCreatePost() end

---@return nil
function onUpdate(elapsed) end

---@return nil
function onUpdatePost(elapsed) end

---@return nil
function onStartCountdown() end

---@return nil
function onSongStart() end

---@return nil
function onBeatHit() end

---@return nil
function onStepHit() end

---@return nil
function onSectionHit() end

---@return nil
function onEvent(eventName, value1, value2) end

---@param membersIndex integer
---@param noteData integer
---@param noteType string
---@param isSustainNote boolean
---@return nil
function goodNoteHit(membersIndex, noteData, noteType, isSustainNote) end

---@param membersIndex integer
---@param noteData integer
---@param noteType string
---@return nil
function noteMiss(membersIndex, noteData, noteType) end

---@param tag string
---@return nil
function onTweenCompleted(tag) end

---@param tag string
---@return nil
function onTimerCompleted(tag) end

---@return nil
function onDestroy() end
