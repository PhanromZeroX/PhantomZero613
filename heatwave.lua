shaderApplied = false
glowApplied = false

function onStartCountdown()
    if shadersEnabled then
        debugPrint('Loading Shader')
        runHaxeCode([[
            game.initLuaShader('heatwave');
        ]])

        makeLuaSprite('heatwaveShader')
        setSpriteShader('heatwaveShader', 'heatwave')

        runHaxeCode([[
            var heatFilter = new ShaderFilter(game.getLuaObject("heatwaveShader").shader);
            game.camGame.setFilters([heatFilter]);
        ]])

        setShaderFloat('heatwaveShader', 'strength', 0.5)
        setShaderFloat('heatwaveShader', 'speed', 0.5)
        setShaderFloat('heatwaveShader', 'time', 0)

        shaderApplied = true

        -- Load and apply glow shader
        debugPrint('Loading Glow Shader')
        runHaxeCode([[
            game.initLuaShader('glow');
        ]])

        makeLuaSprite('glowShader')
        setSpriteShader('glowShader', 'glow')

        runHaxeCode([[
            var glowFilter = new ShaderFilter(game.getLuaObject("glowShader").shader);
            game.camHUD.setFilters([glowFilter]);
        ]])

        setShaderFloat('glowShader', 'dim', 0.8)
        setShaderFloat('glowShader', 'size', 3.0)

        glowApplied = true
    end
end

function onUpdatePost(elapsed)
    if shaderApplied then
        setShaderFloat('heatwaveShader', 'time', getSongPosition() / 1000)
    end
end
