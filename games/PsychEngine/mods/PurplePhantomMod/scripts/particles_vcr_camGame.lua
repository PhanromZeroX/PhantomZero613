-- Particles + VCR Shader for camGame (Debug Version)
-- Uses cataclysm particles.frag (small size)
-- Toggle L key. Force shadersEnabled if needed.

local vcrShaderObj = 'vcrShader'
local particlesShaderObj = 'particlesShader'
local particlesVCREnabled = false
local currentColorIndex = 1
local colorCycleTimer = 0
local particlesXY = {x = 0, y = 0}
local particlesDir = {x = 0, y = 0}

local colors = {
    {1.0, 0.0, 0.0},  -- Red
    {0.0, 0.0, 1.0},  -- Blue
    {1.0, 0.93, 0.82} -- Cream Yellow
}

function onCreate()
    debugPrint('Particles VCR: Script loaded')
    -- Force shaders enabled
    setPropertyFromClass('ClientPrefs', 'shaders', true)
    debugPrint('Particles VCR: ClientPrefs.shaders forced true')
end

function onStartCountdown()
    debugPrint('Particles VCR: onStartCountdown - shadersEnabled=' .. tostring(shadersEnabled))

    -- Safe shader init with try-catch
    local vcrInitOk = pcall(function()
        runHaxeCode([[
            try {
                game.initLuaShader('vcr');
                setVar('vcr_init_ok', true);
                trace('VCR shader init OK');
            } catch(e) {
                setVar('vcr_init_ok', false);
                trace('VCR init failed: ' + e);
            }
        ]])
    end)

    local particlesInitOk = pcall(function()
        runHaxeCode([[
            try {
                game.initLuaShader('particles');
                setVar('particles_init_ok', true);
                trace('Particles shader init OK');
            } catch(e) {
                setVar('particles_init_ok', false);
                trace('Particles init failed: ' + e);
            }
        ]])
    end)

    if not getVar('vcr_init_ok') then
        debugPrint('Particles VCR: VCR init failed - check shaders/vcr.frag in mod/assets')
        return
    end
    if not getVar('particles_init_ok') then
        debugPrint('Particles VCR: Particles init failed - ensure cataclysm/shaders/particles.frag accessible')
        return
    end

    -- VCR shader
    makeLuaSprite(vcrShaderObj, nil)
    setSpriteShader(vcrShaderObj, 'vcr')
    setShaderFloat(vcrShaderObj, 'time', 0.0)

    -- Particles
    makeLuaSprite(particlesShaderObj, nil)
    makeGraphic(particlesShaderObj, screenWidth, screenHeight, '000000')
    setSpriteShader(particlesShaderObj, 'particles')
    -- Defaults + initial red
    setShaderFloat(particlesShaderObj, 'time', 0)
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

    -- Apply stack to camGame
    local applyOk = pcall(function()
        runHaxeCode([[
            try {
                var vcrFilter = new ShaderFilter(game.getLuaObject(']]..vcrShaderObj..[[').shader);
                var particlesFilter = new ShaderFilter(game.getLuaObject(']]..particlesShaderObj..[[').shader);
                game.camGame.setFilters([vcrFilter, particlesFilter]);
                setVar('filters_ok', true);
                trace('Filters applied OK');
            } catch(e) {
                setVar('filters_ok', false);
                trace('Filters failed: ' + e);
            }
        ]])
    end)

    if getVar('filters_ok') then
        particlesVCREnabled = true
        debugPrint('Particles VCR: Fully enabled! Colors cycling, check console for traces.')
    else
        debugPrint('Particles VCR: Filter apply failed')
    end
end

function onUpdate(elapsed)
    if particlesVCREnabled then
        if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.L') then
            particlesVCREnabled = false
            runHaxeCode([[
                try {
                    game.camGame.setFilters([]);
                } catch(e) {
                    trace('Clear filters failed: ' + e);
                }
            ]])
            debugPrint('Particles VCR: Disabled (L pressed)')
        end
    else
        if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.L') then
            particlesVCREnabled = true
            -- Re-apply
            runHaxeCode([[
                try {
                    var vcrFilter = new ShaderFilter(game.getLuaObject(']]..vcrShaderObj..[[').shader);
                    var particlesFilter = new ShaderFilter(game.getLuaObject(']]..particlesShaderObj..[[').shader);
                    game.camGame.setFilters([vcrFilter, particlesFilter]);
                    trace('Toggle re-apply OK');
                } catch(e) {
                    trace('Toggle failed: ' + e);
                }
            ]])
            debugPrint('Particles VCR: Re-enabled (L pressed)')
        end
    end
end

function onUpdatePost(elapsed)
    if particlesVCREnabled then
        local songPos = getSongPosition() / 1000

        setShaderFloat(vcrShaderObj, 'time', songPos)
        setShaderFloat(particlesShaderObj, 'time', songPos)

        -- Color cycle
        colorCycleTimer = colorCycleTimer + elapsed
        if colorCycleTimer > 3.0 then
            currentColorIndex = ((currentColorIndex % 3) + 1)
            colorCycleTimer = 0
            local col = colors[currentColorIndex]
            setShaderFloat(particlesShaderObj, 'particleColor.x', col[1])
            setShaderFloat(particlesShaderObj, 'particleColor.y', col[2])
            setShaderFloat(particlesShaderObj, 'particleColor.z', col[3])
            debugPrint('Particles color #' .. currentColorIndex .. ' applied')
        end

        -- Animate emission
        particlesXY.x = particlesXY.x + math.sin(songPos * 0.5) * 20 * elapsed
        particlesXY.y = particlesXY.y + math.cos(songPos * 0.3) * 15 * elapsed
        particlesXY.x = math.max(-screenWidth/2, math.min(screenWidth/2, particlesXY.x))
        particlesXY.y = math.max(-screenHeight/2, math.min(screenHeight/2, particlesXY.y))
        setShaderFloat(particlesShaderObj, 'particleXY.x', particlesXY.x)
        setShaderFloat(particlesShaderObj, 'particleXY.y', particlesXY.y)

        particlesDir.x = 0.2 + math.sin(songPos) * 0.3
        particlesDir.y = 0.1 + math.cos(songPos * 1.1) * 0.4
        setShaderFloat(particlesShaderObj, 'particleDirection.x', particlesDir.x)
        setShaderFloat(particlesShaderObj, 'particleDirection.y', particlesDir.y)
    end
end

function onDestroy()
    runHaxeCode([[
        try {
            game.camGame.setFilters([]);
        } catch(e) {}
    ]])
end

