glowLoaded = false

function onCreate()
    if shadersEnabled then
        debugPrint('Running Shaders')
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

        glowLoaded = true
    end
end

