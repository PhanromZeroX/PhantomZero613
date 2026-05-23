-- Psych Engine Shader Library
-- Helper functions for working with shaders

local Shaders = {}

---Activate a shader with common parameters
---@param shaderName string Shader name (without .frag)
---@param spriteId string Sprite ID to apply to
---@param uniforms table Key-value pairs of uniform names and values
---@param camera string|nil Target camera ('camGame' or 'camHUD', default 'camGame')
---@return nil
function Shaders.activate(shaderName, spriteId, uniforms, camera)
    camera = camera or 'camGame'
    uniforms = uniforms or {}
    
    -- Initialize shader
    runHaxeCode([[
        game.initLuaShader(']]..shaderName..[[');
    ]])
    
    -- Create sprite for shader
    makeLuaSprite(spriteId)
    setSpriteShader(spriteId, shaderName)
    
    -- Apply to camera
    runHaxeCode([[
        var shaderFilter = new ShaderFilter(game.getLuaObject(']]..spriteId..[[').shader);
        game.]]..camera..[[.setFilters([shaderFilter]);
    ]])
    
    -- Set uniforms
    for uniform, value in pairs(uniforms) do
        if type(value) == 'number' then
            setShaderFloat(spriteId, uniform, value)
        elseif type(value) == 'table' then
            if #value == 2 then
                setShaderVec2(spriteId, uniform, value[1], value[2])
            elseif #value == 3 then
                setShaderVec3(spriteId, uniform, value[1], value[2], value[3])
            end
        end
    end
end

---Create a time-animated shader (updates with song position)
---@param shaderName string Shader name
---@param spriteId string Sprite ID
---@param uniforms table Initial uniforms
---@param timeUniform string|nil Uniform that receives time (default 'time')
---@return function Callback for onUpdatePost
function Shaders.createAnimated(shaderName, spriteId, uniforms, timeUniform)
    timeUniform = timeUniform or 'time'
    Shaders.activate(shaderName, spriteId, uniforms)
    
    -- Return callback for use in onUpdatePost
    return function()
        setShaderFloat(spriteId, timeUniform, getSongPosition() / 1000)
    end
end

---Preset: Heatwave shader
---@param spriteId string Sprite ID (default 'heatwaveShader')
---@param strength number Wave strength 0-1 (default 0.5)
---@param speed number Animation speed (default 0.5)
---@return function Update callback
function Shaders.heatwave(spriteId, strength, speed)
    spriteId = spriteId or 'heatwaveShader'
    strength = strength or 0.5
    speed = speed or 0.5
    
    return Shaders.createAnimated('heatwave', spriteId, {
        strength = strength,
        speed = speed,
        time = 0
    })
end

---Preset: Particles shader
---@param spriteId string Sprite ID (default 'particlesShader')
---@param color table RGB color {r, g, b} (default purple {0.8, 0.2, 1.0})
---@param layers integer Layer count (default 6)
---@return function Update callback
function Shaders.particles(spriteId, color, layers)
    spriteId = spriteId or 'particlesShader'
    color = color or {0.8, 0.2, 1.0}
    layers = layers or 6
    
    return Shaders.createAnimated('particles', spriteId, {
        time = 0,
        res = {screenWidth, screenHeight},
        particleXY = {screenWidth / 2, screenHeight / 2},
        particleColor = color,
        particleDirection = {0.3, -1.0},
        particleZoom = 1.0,
        particlealpha = 0.8,
        layers = layers
    })
end

---Preset: Glow shader
---@param spriteId string Sprite ID (default 'glowShader')
---@param dim number Brightness 0-1 (default 0.8)
---@param size number Glow size (default 3.0)
---@return nil
function Shaders.glow(spriteId, dim, size)
    spriteId = spriteId or 'glowShader'
    dim = dim or 0.8
    size = size or 3.0
    
    Shaders.activate('glow', spriteId, {
        dim = dim,
        size = size
    }, 'camHUD')
end

return Shaders
