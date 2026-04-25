-- Combined shader script: heatwave + glow + vhs
shadersLoaded = false

function onStartCountdown()
    if not shadersEnabled then
        debugPrint('All Shaders: shaders not enabled')
        return
    end

    debugPrint('All Shaders: Initializing...')

    -- Initialize all three shaders
    runHaxeCode([[
        game.initLuaShader('heatwave');
        game.initLuaShader('glow');
        game.initLuaShader('vhs');
    ]])

    -- Heatwave shader setup
    makeLuaSprite('heatwaveShader')
    setSpriteShader('heatwaveShader', 'heatwave')

    runHaxeCode([[
        var heatFilter = new ShaderFilter(game.getLuaObject("heatwaveShader").shader);
        game.camGame.setFilters([heatFilter]);
    ]])

    setShaderFloat('heatwaveShader', 'strength', 0.5)
    setShaderFloat('heatwaveShader', 'speed', 0.5)
    setShaderFloat('heatwaveShader', 'time', 0.0)

    -- Glow shader setup (camHUD)
    makeLuaSprite('glowShaderHUD')
    setSpriteShader('glowShaderHUD', 'glow')

    runHaxeCode([[
        var glowFilter = new ShaderFilter(game.getLuaObject("glowShaderHUD").shader);
        game.camHUD.setFilters([glowFilter]);
    ]])

    setShaderFloat('glowShaderHUD', 'dim', 0.8)
    setShaderFloat('glowShaderHUD', 'size', 3.0)

    -- VHS shader setup
    makeLuaSprite('vhsShader')
    setSpriteShader('vhsShader', 'vhs')

    runHaxeCode([[
        var vhsFilter = new ShaderFilter(game.getLuaObject("vhsShader").shader);
        game.camGame.filters.push(vhsFilter);
    ]])

    setShaderFloat('vhsShader', 'time', 0.0)
    setShaderFloat('vhsShader', 'noiseIntensity', 0.5)
    setShaderFloat('vhsShader', 'colorOffsetIntensity', 1.0)

    shadersLoaded = true
    debugPrint('All Shaders: heatwave + glow + vhs loaded!')
end

function onUpdatePost(elapsed)
    if shadersLoaded then
        setShaderFloat('heatwaveShader', 'time', getSongPosition() / 1000.0)
        setShaderFloat('vhsShader', 'time', getSongPosition() / 1000.0)
    end
end
