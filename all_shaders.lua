-- Combined shader script: heatwave + glow (characters) + vhs + beat bounce
shadersLoaded = false
glowCharsApplied = false

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
    debugPrint('All Shaders: heatwave + glow chars + vhs loaded!')
end

function onUpdatePost(elapsed)
    if shadersLoaded then
        setShaderFloat('heatwaveShader', 'time', getSongPosition() / 1000.0)
        setShaderFloat('vhsShader', 'time', getSongPosition() / 1000.0)
    end
end

-- Medium camera bounce synced to beat
local defaultZoom = 1.0
local bounceZoom = 1.03
local bounceDecay = 0.06

function onBeatHit()
    -- Medium bounce: quick zoom in on every beat, decays back
    setProperty('camGame.zoom', bounceZoom)
    doTweenZoom('camBounce', 'camGame', defaultZoom, bounceDecay, 'quadOut')
end
