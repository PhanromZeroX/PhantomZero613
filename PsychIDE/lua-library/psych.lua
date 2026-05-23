-- Psych Engine Main Library
-- Provides typed wrappers around Psych Engine functions with documentation

---@class PsychShader
---@field name string Shader identifier
---@field uniforms table Uniform variables

---@class PsychSprite
---@field id string Sprite identifier
---@field x number X position
---@field y number Y position
---@field shader PsychShader|nil Applied shader

-- ===== SHADER FUNCTIONS =====

---Initialize a Lua shader from shader files
---@param shaderName string Name without .frag extension (e.g., 'heatwave', 'particles')
---@return nil
function Psych.initLuaShader(shaderName)
    runHaxeCode([[
        game.initLuaShader(']]..shaderName..[[');
    ]])
end

---Apply a shader to a sprite or camera
---@param target string Sprite ID or camera name (e.g., 'camGame', 'heatwaveShader')
---@param shaderName string Shader to apply
---@return nil
function Psych.setSpriteShader(target, shaderName)
    setSpriteShader(target, shaderName)
end

---Set a float uniform in a shader
---@param spriteName string Sprite with the shader applied
---@param uniform string Uniform variable name
---@param value number Float value
---@return nil
function Psych.setShaderFloat(spriteName, uniform, value)
    setShaderFloat(spriteName, uniform, value)
end

---Set an integer uniform in a shader
---@param spriteName string Sprite with the shader applied
---@param uniform string Uniform variable name
---@param value integer Integer value
---@return nil
function Psych.setShaderInt(spriteName, uniform, value)
    setShaderInt(spriteName, uniform, value)
end

---Set a vec2 uniform in a shader
---@param spriteName string Sprite with the shader applied
---@param uniform string Uniform variable name
---@param x number X component
---@param y number Y component
---@return nil
function Psych.setShaderVec2(spriteName, uniform, x, y)
    setShaderVec2(spriteName, uniform, x, y)
end

---Set a vec3 uniform in a shader
---@param spriteName string Sprite with the shader applied
---@param uniform string Uniform variable name
---@param x number X component
---@param y number Y component
---@param z number Z component
---@return nil
function Psych.setShaderVec3(spriteName, uniform, x, y, z)
    setShaderVec3(spriteName, uniform, x, y, z)
end

-- ===== SPRITE FUNCTIONS =====

---Create a Lua sprite (not drawn yet)
---@param spriteId string Unique sprite identifier
---@param graphic string|nil Path to graphic (nil for invisible)
---@param x number|nil X position (default 0)
---@param y number|nil Y position (default 0)
---@return nil
function Psych.makeLuaSprite(spriteId, graphic, x, y)
    makeLuaSprite(spriteId, graphic, x or 0, y or 0)
end

---Create a solid color graphic
---@param spriteName string Sprite ID
---@param width number Width in pixels
---@param height number Height in pixels
---@param color string Hex color (e.g., 'FF0000' for red)
---@return nil
function Psych.makeGraphic(spriteName, width, height, color)
    makeGraphic(spriteName, width, height, color)
end

---Add sprite to the stage (make it visible)
---@param spriteId string Sprite to add
---@param inFront boolean|nil If true, render in front (default false)
---@return nil
function Psych.addLuaSprite(spriteId, inFront)
    addLuaSprite(spriteId, inFront or false)
end

---Apply shader filter to camera
---@param shaderObj string Sprite with shader applied
---@param camera string Target camera ('camGame' or 'camHUD')
---@return nil
function Psych.applyShaderToCamera(shaderObj, camera)
    runHaxeCode([[
        var filter = new ShaderFilter(game.getLuaObject(']]..shaderObj..[[').shader);
        game.]]..camera..[[.setFilters([filter]);
    ]])
end

-- ===== ANIMATION FUNCTIONS =====

---Tween a sprite's X position
---@param id string Tween ID
---@param target string Sprite to tween
---@param endValue number Target X value
---@param duration number Duration in seconds
---@param ease string|nil Easing function (default 'linear')
---@return nil
function Psych.doTweenX(id, target, endValue, duration, ease)
    doTweenX(id, target, endValue, duration, ease or 'linear')
end

---Tween a sprite's Y position
---@param id string Tween ID
---@param target string Sprite to tween
---@param endValue number Target Y value
---@param duration number Duration in seconds
---@param ease string|nil Easing function (default 'linear')
---@return nil
function Psych.doTweenY(id, target, endValue, duration, ease)
    doTweenY(id, target, endValue, duration, ease or 'linear')
end

-- ===== UTILITY FUNCTIONS =====

---Debug print to console
---@param text string Message to print
---@return nil
function Psych.debug(text)
    debugPrint(text)
end

---Get the current song position in milliseconds
---@return number Song position
function Psych.songPos()
    return getSongPosition()
end

---Get/set a variable in the game state
---@param varName string Variable name
---@param value any|nil If provided, sets the variable
---@return any Current/new value
function Psych.var(varName, value)
    if value ~= nil then
        setVar(varName, value)
        return value
    else
        return getVar(varName)
    end
end

return Psych
