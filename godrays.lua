godraysApplied = false

function onStartCountdown()
    if shadersEnabled then
        debugPrint('Loading God Rays Shader')
        runHaxeCode([[
            game.initLuaShader('godrays');
        ]])

        makeLuaSprite('godraysShader')
        setSpriteShader('godraysShader', 'godrays')

        runHaxeCode([[
            var godraysFilter = new ShaderFilter(game.getLuaObject("godraysShader").shader);
            game.camGame.setFilters([godraysFilter]);
        ]])

        setShaderFloat('godraysShader', 'Exposure', 0.5)
        setShaderVec2('godraysShader', '_LightPos', screenWidth / 2, screenHeight / 2)

        godraysApplied = true
    end
end

function onUpdatePost(elapsed)
    if godraysApplied then
        -- Update light position to follow center or a character
        setShaderVec2('godraysShader', '_LightPos', screenWidth / 2, screenHeight / 2)
    end
end
