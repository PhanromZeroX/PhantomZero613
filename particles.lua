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

        setShaderFloat('particlesShader', 'time', 0)
        setShaderFloat('particlesShader', 'res', screenWidth)
        setShaderFloat('particlesShader', 'res', screenHeight)
        setShaderFloat('particlesShader', 'particleXY', screenWidth / 2)
        setShaderFloat('particlesShader', 'particleXY', screenHeight / 2)
        setShaderFloat('particlesShader', 'particleColor', 0.8)
        setShaderFloat('particlesShader', 'particleColor', 0.2)
        setShaderFloat('particlesShader', 'particleColor', 1.0)
        setShaderFloat('particlesShader', 'particleDirection', 0.3)
        setShaderFloat('particlesShader', 'particleDirection', -1.0)
        setShaderFloat('particlesShader', 'particleZoom', 1.0)
        setShaderFloat('particlesShader', 'particlealpha', 0.8)
        setShaderInt('particlesShader', 'layers', 6)

        particlesApplied = true
    end
end

function onUpdatePost(elapsed)
    if particlesApplied then
        setShaderFloat('particlesShader', 'time', getSongPosition() / 1000)
    end
end
