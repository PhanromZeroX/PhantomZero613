-- Multi-Shader Effect Script for Psych Engine
-- Activates: heatDistortion, dust, and heatlight (on both camGame and camHUD)

function onCreate()
    -- Load and apply Heat Distortion shader
    initLuaShader("heatDistortion")
    camGame:addShader(heatDistortion)
    
    -- Load and apply Dust shader
    initLuaShader("dust")
    camGame:addShader(dust)
    
    -- Load and apply Heat Light shader to both cameras
    initLuaShader("heatlight")
    camGame:addShader(heatlight)
    camHUD:addShader(heatlight)
    
    -- Load and apply Icon Shader to HUD
    initLuaShader("iconshader")
    camHUD:addShader(iconshader)
    
    debugPrint("All shaders loaded and applied successfully!")
end

function onUpdate(elapsed)
    -- Update shader uniforms if needed
    -- Uncomment and modify as needed:
    
    -- heatDistortion.strength = 1.0
    -- heatDistortion.time = getSongPosition() / 1000
    
    -- dust.time = getSongPosition() / 1000
    
    -- heatlight.time = getSongPosition() / 1000
    -- heatlight.threshold = 0.5
    
    -- Optimize iconshader for tablet performance
    if iconshader ~= nil then
        iconshader.ratio = 0.15  -- Very low blend ratio to reduce GPU load
        iconshader.minBrightness = 0.5  -- Higher threshold = fewer pixels processed
    end
end

function onDestroy()
    -- Clean up shaders if needed
    debugPrint("Shader script destroyed")
end
