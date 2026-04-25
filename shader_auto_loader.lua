-- Shader Auto-Loader for FNF Psych Engine
-- For Cataclysm song - Call initShaders() in onCreate()
-- Supports: glow, heatwave, saturation, vhs, warp shaders

local shaders = {}

function initShaders()
    local shaderNames = {"glow", "heatwave", "saturation", "vhs", "warp"}
    
    for i, name in ipairs(shaderNames) do
        makeLuaSprite(name .. "Shader")
        setSpriteShader(name .. "Shader", name)
        shaders[name] = name .. "Shader"
    end
end

function applyShaderToCamera(shaderName, camera)
    if shaders[shaderName] then
        runHaxeCode([[
            setVar("
 shaderName 
Filter, new ShaderFilter(game.getLuaObject( shaders[shaderName] ).shader));
        ]])
        
        if camera == "game" then
            runHaxeCode([[game.camGame.filters.push(getVar(" shaderName Filter));]])
        elseif camera == "hud" then
            runHaxeCode([[game.camHUD.filters.push(getVar(" shaderName Filter));]])
        end
    end
end

function setShaderFloat(shaderName, param, value)
    if shaders[shaderName] then
        setShaderFloat(shaders[shaderName], param, value)
    end
end
