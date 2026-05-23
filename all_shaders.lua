-- Combined shader script: heatwave (characters + icons) + glow (characters + icons)
shadersLoaded = false
glowCharsApplied = false

function onStartCountdown()
    if not shadersEnabled then
        debugPrint('All Shaders: shaders not enabled')
        return
    end

    debugPrint('All Shaders: Initializing...')

-- Initialize shaders
    runHaxeCode([[
        game.initLuaShader('heatwave');
        game.initLuaShader('glow');
        game.initLuaShader('vcr');
    ]])

    -- Heatwave shader setup (applied to camHUD)
    makeLuaSprite('heatwaveShader')
    setSpriteShader('heatwaveShader', 'heatwave')

    setShaderFloat('heatwaveShader', 'strength', 0.5)
    setShaderFloat('heatwaveShader', 'speed', 0.5)
    setShaderFloat('heatwaveShader', 'time', 0.0)

    -- VCR shader setup (applied to camGame)
    makeLuaSprite('vcrShader')
    setSpriteShader('vcrShader', 'vcr')

    setShaderFloat('vcrShader', 'time', 0.0)

    -- Apply heatwave to camHUD, VCR to camGame
    runHaxeCode([[
        var heatFilter = new ShaderFilter(game.getLuaObject('heatwaveShader').shader);
        var vcrFilter = new ShaderFilter(game.getLuaObject('vcrShader').shader);
        game.camHUD.setFilters([heatFilter]);
        game.camGame.setFilters([vcrFilter]);
    ]])

    -- Glow shader setup (characters + icons)
    makeLuaSprite('glowShaderChars')
    setSpriteShader('glowShaderChars', 'glow')
    makeLuaSprite('glowShaderIcons')
    setSpriteShader('glowShaderIcons', 'glow')

    runHaxeCode([[
        var glowChars = game.getLuaObject('glowShaderChars').shader;
        var glowIcons = game.getLuaObject('glowShaderIcons').shader;
        if (game.dad != null) game.dad.shader = glowChars;
        if (game.boyfriend != null) game.boyfriend.shader = glowChars;
        if (game.iconP2 != null) game.iconP2.shader = glowIcons;
        if (game.iconP1 != null) game.iconP1.shader = glowIcons;
    ]])

    setShaderFloat('glowShaderChars', 'dim', 1.2)
    setShaderFloat('glowShaderChars', 'size', 1.5)
    setShaderFloat('glowShaderIcons', 'dim', 1.2)
    setShaderFloat('glowShaderIcons', 'size', 1.5)

    glowCharsApplied = true

    shadersLoaded = true
    debugPrint('All Shaders: heatwave + glow chars loaded!')
end

function onUpdatePost(elapsed)
    if shadersLoaded then
        setShaderFloat('heatwaveShader', 'time', getSongPosition() / 1000.0)
        setShaderFloat('vcrShader', 'time', getSongPosition() / 1000.0)
    end
end
