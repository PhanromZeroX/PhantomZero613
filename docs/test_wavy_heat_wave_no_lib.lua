function onCreate()
    -- Create a fullscreen overlay for the shader effect.
    makeLuaSprite('heatWaveOverlay', '', 0, 0)
    makeGraphic('heatWaveOverlay', 1280, 720, '000000')
    setObjectCamera('heatWaveOverlay', 'game')
    setProperty('heatWaveOverlay.alpha', 0.35)
    addLuaSprite('heatWaveOverlay', true)

    -- Load and apply the shader.
    initLuaShader('wavyheatwave')
    setSpriteShader('heatWaveOverlay', 'wavyheatwave')

    -- Set shader uniforms for medium wave speed.
    setShaderFloat('wavyheatwave', 'u_strength', 0.10)
    setShaderFloat('wavyheatwave', 'u_speed', 1.0)
    setShaderFloat('wavyheatwave', 'u_time', 0.0)
    setShaderFloatArray('wavyheatwave', 'u_resolution', {1280, 720})

    -- Optional debug info.
    makeLuaText('shaderDebug', 'Heat wave active', 10, 10)
    setTextSize('shaderDebug', 18)
    setTextColor('shaderDebug', 'FFFFFF')
    setObjectCamera('shaderDebug', 'other')
    addLuaText('shaderDebug')
end

function onUpdate(elapsed)
    local currentTime = getSongPosition() / 1000
    setShaderFloat('wavyheatwave', 'u_time', currentTime)
    setTextString('shaderDebug', 'Heat wave speed: medium\nTime: ' .. string.format('%.2f', currentTime))
end
