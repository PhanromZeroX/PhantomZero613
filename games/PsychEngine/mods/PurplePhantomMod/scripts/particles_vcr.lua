-- Improved Particles + VCR for camGame
-- Continuous spawn, bigger circle, pulsing bloom, color cycle, full wide screen
-- Toggle L key

local MAX_PARTICLES = 100
local SPAWN_INTERVAL = 0.1 -- continuous
local PARTICLE_SIZE = 12 -- bigger
local BLOOM_MAX_SCALE = 1.8

local particlesVCREnabled = false
local particleCount = 0
local colorIndex = 1
local spawnTimer = 0
local vcrShader = 'vcrShader'
local glowShader = 'glowShader' -- shared for particles

local colors = {'FF0000', '0000FF', 'FFFDD0'} -- red, blue, cream yellow

function onCreate()
    debugPrint('Particles VCR Improved: Loaded')
    setPropertyFromClass('ClientPrefs', 'shaders', true)
end

function onStartCountdown()
    debugPrint('Particles VCR: Starting - shadersEnabled=' .. tostring(shadersEnabled))
    
    -- Safe VCR init
    pcall(function()
        runHaxeCode([[
            game.initLuaShader('vcr');
            game.initLuaShader('glow');
        ]])
        makeLuaSprite(vcrShader, nil)
        setSpriteShader(vcrShader, 'vcr')
        setShaderFloat(vcrShader, 'time', 0)
        
        -- Apply VCR to camGame
        runHaxeCode([[
            var filter = new ShaderFilter(game.getLuaObject(']] .. vcrShader .. [[').shader);
            game.camGame.setFilters([filter]);
        ]])
    end)
    
    particlesVCREnabled = true
    debugPrint('Particles VCR: Ready - press L toggle')
end

function onUpdate(elapsed)
    if not particlesVCREnabled then
        if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.L') then
            particlesVCREnabled = true
            debugPrint('Particles VCR: Enabled')
        end
        return
    end
    
    if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.L') then
        particlesVCREnabled = false
        runHaxeCode('game.camGame.setFilters([]);')
        debugPrint('Particles VCR: Disabled')
        return
    end
    
    spawnTimer = spawnTimer + elapsed
    if spawnTimer >= SPAWN_INTERVAL and particleCount < MAX_PARTICLES then
        spawnParticle()
        spawnTimer = 0
    end
end

function spawnParticle()
    particleCount = particleCount + 1
    local id = 'partGlow' .. particleCount
    local col = colors[colorIndex]
    colorIndex = colorIndex + 1
    if colorIndex > 3 then colorIndex = 1 end
    
    -- Random full screen wide
    local x = math.random(-screenWidth/2, screenWidth * 1.5)
    local y = screenHeight + 100 -- off bottom
    
    makeLuaSprite(id, nil, x, y)
    makeGraphic(id, PARTICLE_SIZE, PARTICLE_SIZE, col)
    setObjectOrder(id, getObjectOrder('camHUD') + 1)
    scaleObject(id, 0.3, 0.3) -- initial small
    setProperty(id .. '.alpha', 0) -- initial invisible
    
    -- Glow bloom effect
    setSpriteShader(id, 'glow')
    setShaderFloat(id, 'dim', 1.2)
    setShaderFloat(id, 'size', 2.5) -- bloom size
    
    addLuaSprite(id, true) -- front
    
    -- Bloom pulse tween
    doTweenAlpha('bloomAlpha' .. particleCount, id, 1.0, 0.8, 'sineInOut')
    doTweenScale('bloomScale' .. particleCount, id, BLOOM_MAX_SCALE, 1.2, 'sineIn')
    
    -- Move up/off screen + fade out
    doTweenY('dieY' .. particleCount, id, -200, 3 + math.random() * 2, 'linear')
    runTimer('kill' .. particleCount, 4, 1)
end

function onTimerCompleted(tag)
    if string.find(tag, 'kill') then
        local id = string.match(tag, 'kill(%d+)')
        if id and getObjectFromTag('partGlow' .. id) then
            removeLuaSprite('partGlow' .. id, true)
            particleCount = particleCount - 1
        end
    end
end

function onUpdatePost(elapsed)
    if particlesVCREnabled then
        setShaderFloat(vcrShader, 'time', getSongPosition() / 1000)
    end
end

function onDestroy()
    runHaxeCode('game.camGame.setFilters([]);')
end

