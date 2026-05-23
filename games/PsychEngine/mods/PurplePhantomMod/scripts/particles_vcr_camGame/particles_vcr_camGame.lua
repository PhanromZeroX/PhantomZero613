-- Particles + VCR Shader for camGame
-- Red, Blue, Cream Yellow cycling colors
-- Toggle with L key
-- Place in mod scripts folder for auto-load

particlesVCREnabled = false
vcrShaderObj = nil
particlesShaderObj = false
currentColorIndex = 1
colorCycleTimer = 0
particlesXY = {x=0, y=0}
particlesDir = {x=0, y=0}

local colors = {
    {1.0, 0.0, 0.0}, -- Red
    {0.0, 0.0, 1.0}, -- Blue
    {1.0, 0.93, 0.82} -- Cream Yellow
}

function onCreate()
    vcrShaderObj = 'vcrShader'
    particlesShaderObj = 'particlesShader'
end

function onStartCountdown()
    if not shadersEnabled then
        debugPrint('Particles VCR: shadersEnabled false')
        return
    end

    -- Init shaders
    runHaxeCode([[
        game.initLuaShader('vcr');
        game.initLuaShader('particles');
    ]])

    -- VCR shader
    makeLuaSprite(vcrShaderObj, nil)
    setSpriteShader(vcrShaderObj, 'vcr')
    setShaderFloat(vcrShaderObj, 'time', 0.0)

    -- Particles shader sprite (fullscreen overlay)
    makeLuaSprite(particlesShaderObj, nil)
    makeGraphic(particlesShaderObj, screenWidth, screenHeight, '000000')
    setSpriteShader(particlesShaderObj, 'particles')
    setShaderFloat(particlesShaderObj, 'time', 0.0)
    setShaderFloat(particlesShaderObj, 'res.x', screenWidth)
    setShaderFloat(particlesShaderObj, 'res.y', screenHeight)
    setShaderFloat(particlesShaderObj, 'particleXY.x', 0)
    setShaderFloat(particlesShaderObj, 'particleXY.y', 0)
    setShaderFloat(particlesShaderObj, 'particleColor.x', 1.0)
    setShaderFloat(particlesShaderObj, 'particleColor.y', 0.0)
    setShaderFloat(particlesShaderObj, 'particleColor.z', 0.0)
    setShaderFloat(particlesShaderObj, 'particleDirection.x', 0.5)
    setShaderFloat(particlesShaderObj, 'particleDirection.y', 0.3)
    setShaderFloat(particlesShaderObj, 'particleZoom', 1.0)
    setShaderFloat(particlesShaderObj, 'particlealpha', 0.8)
    setShaderFloat(particlesShaderObj, 'layers', 8)

    -- Apply both to camGame stack
    runHaxeCode([[
        var vcrFilter = new ShaderFilter(game.getLuaObject(']] .. vcrShaderObj .. [[').shader);
        var particlesFilter = new ShaderFilter(game.getLuaObject(']] .. particlesShaderObj .. [[').shader);
        game.camGame.setFilters([vcrFilter, particlesFilter]);
    ]])

    particlesVCREnabled = true
    debugPrint('Particles VCR: Enabled on camGame - cycling red/blue/cream yellow')
end

function onUpdate(elapsed)
    if particlesVCREnabled then
        if getPropertyFromClass('flixel.FlxG', 'keys.pressed.L') then
            particlesVCREnabled = false
            runHaxeCode('game.camGame.setFilters([]);')
            debugPrint('Particles VCR: Disabled')
            return
        end
    else
        if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.L') then
            particlesVCREnabled = true
            -- Re-apply (assumes shaders persist)
            runHaxeCode([[
                var vcrFilter = new ShaderFilter(game.getLuaObject(']] .. vcrShaderObj .. [[').shader);
                var particlesFilter = new ShaderFilter(game.getLuaObject(']] .. particlesShaderObj .. [[').shader);
                game.camGame.setFilters([vcrFilter, particlesFilter]);
            ]])
            debugPrint('Particles VCR: Re-enabled')
        end
    end
end

function onUpdatePost(elapsed)
    if particlesVCREnabled then
        local songPos = getSongPosition() / 1000.0

        -- Animate VCR
        setShaderFloat(vcrShaderObj, 'time', songPos)

        -- Animate particles
        setShaderFloat(particlesShaderObj, 'time', songPos)

        -- Cycle colors every 3 seconds
        colorCycleTimer = colorCycleTimer + elapsed
        if colorCycleTimer > 3.0 then
            currentColorIndex = currentColorIndex + 1
            if currentColorIndex > 3 then currentColorIndex = 1 end
            colorCycleTimer = 0

            local col = colors[currentColorIndex]
            setShaderFloat(particlesShaderObj, 'particleColor.x', col[1])
            setShaderFloat(particlesShaderObj, 'particleColor.y', col[2])
            setShaderFloat(particlesShaderObj, 'particleColor.z', col[3])
            debugPrint('Particles color: ' .. (currentColorIndex == 1 and 'Red' or currentColorIndex == 2 and 'Blue' or 'Cream Yellow'))
        end

        -- Animate position (random walk emission)
        particlesXY.x = particlesXY.x + (math.sin(songPos * 0.5) * 20 * elapsed)
        particlesXY.y = particlesXY.y + (math.cos(songPos * 0.3) * 15 * elapsed)
        particlesXY.x = math.max(-screenWidth/2, math.min(screenWidth/2, particlesXY.x))
        particlesXY.y = math.max(-screenHeight/2, math.min(screenHeight/2, particlesXY.y))
        setShaderFloat(particlesShaderObj, 'particleXY.x', particlesXY.x)
        setShaderFloat(particlesShaderObj, 'particleXY.y', particlesXY.y)

        -- Vary direction
        particlesDir.x = 0.2 + math.sin(songPos) * 0.3
        particlesDir.y = 0.1 + math.cos(songPos * 1.1) * 0.4
        setShaderFloat(particlesShaderObj, 'particleDirection.x', particlesDir.x)
        setShaderFloat(particlesShaderObj, 'particleDirection.y', particlesDir.y)
    end
end

function onDestroy()
    if particlesVCREnabled then
        runHaxeCode('game.camGame.setFilters([]);')
    end
end

