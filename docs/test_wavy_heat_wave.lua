local Psych = require('docs/psych_engine_lib')

function onCreate()
    -- Create a fullscreen overlay that the shader will distort.
    Psych.makeOverlay('heatWaveOverlay', 1280, 720, '000000', 0.35, 'game')

    -- Initialize and apply the heat wave shader.
    Psych.initShader('wavyHeatWave')
    Psych.setSpriteShader('heatWaveOverlay', 'wavyHeatWave')

    -- Configure shader values.
    Psych.setShaderFloat('wavyHeatWave', 'u_strength', 0.10)
    Psych.setShaderFloat('wavyHeatWave', 'u_speed', 1.8)
    Psych.setShaderFloat('wavyHeatWave', 'u_time', 0)

    -- Add a small debug overlay so you can see the shader progress.
    Psych.makeDebugConsole('shaderDebug', 20, 20, 18, 'FFFFFF')
    Psych.toggleDebug(true)
end

function onUpdate(elapsed)
    local t = getSongPosition() / 1000
    Psych.setShaderUniform('wavyHeatWave', 'u_time', t)
    Psych.updateDebugText('shaderDebug', 'Heat wave time: ' .. string.format('%.2f', t))
end
