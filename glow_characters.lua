glowCharsApplied = false

function onStartCountdown()
    if not shadersEnabled then
        debugPrint('Glow Characters: shaders not enabled')
        return
    end

    debugPrint('Glow Characters: Loading glow shader...')

    runHaxeCode([[
        game.initLuaShader('glow');
    ]])

    -- Character shader: weaker glow to avoid visible sprite box outline
    makeLuaSprite('glowShaderChars')
    setSpriteShader('glowShaderChars', 'glow')

    -- Icon shader: current strength (looks good on icons)
    makeLuaSprite('glowShaderIcons')
    setSpriteShader('glowShaderIcons', 'glow')

    -- Apply separate shader instances to characters and icons
    runHaxeCode([[
        var glowChars = game.getLuaObject('glowShaderChars').shader;
        var glowIcons = game.getLuaObject('glowShaderIcons').shader;
        if (game.dad != null) game.dad.shader = glowChars;
        if (game.boyfriend != null) game.boyfriend.shader = glowChars;
        if (game.iconP2 != null) game.iconP2.shader = glowIcons;
        if (game.iconP1 != null) game.iconP1.shader = glowIcons;
    ]])

    -- Weaker settings for characters (less blur spread, slightly higher dim)
    setShaderFloat('glowShaderChars', 'dim', 1.2)
    setShaderFloat('glowShaderChars', 'size', 1.5)

    -- Same weaker settings for icons
    setShaderFloat('glowShaderIcons', 'dim', 1.2)
    setShaderFloat('glowShaderIcons', 'size', 1.5)

    glowCharsApplied = true
    debugPrint('Glow Characters: Applied to opponent and player sprites!')
end

