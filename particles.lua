particlesApplied = false

function onStartCountdown()
    if shadersEnabled then
        debugPrint('Loading Particles Shader')
        runHaxeCode([[
            game.initLuaShader('particles');
        ]])

        makeLuaSprite('particlesShader')
        setSpriteShader('particlesShader', 'particles')

        runHaxeCode([[
            var particlesFilter = new ShaderFilter(game.getLuaObject("particlesShader").shader);
            game.camGame.setFilters([particlesFilter]);
        ]])

        setShaderFloat('particlesShader', 'time', 0.0)
        setShaderVec2('particlesShader', 'res', screenWidth, screenHeight)
        setShaderVec2('particlesShader', 'particleXY', screenWidth / 2.0, screenHeight / 2.0)
        setShaderVec3('particlesShader', 'particleColor', 0.8, 0.2, 1.0)
        setShaderVec2('particlesShader', 'particleDirection', 0.3, -1.0)
        setShaderFloat('particlesShader', 'particleZoom', 1.0)
        setShaderFloat('particlesShader', 'particlealpha', 0.8)
        setShaderInt('particlesShader', 'layers', 6)

        particlesApplied = true
    end
end

function onUpdatePost(elapsed)
    if particlesApplied then
        setShaderFloat('particlesShader', 'time', getSongPosition() / 1000.0)
    end
end
