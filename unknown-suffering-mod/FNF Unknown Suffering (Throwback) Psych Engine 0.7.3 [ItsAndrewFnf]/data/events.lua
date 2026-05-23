-- Compatibilidad Psych Engine 0.7.3
LuaDebugMode = true
camZoomingInterval = 0
local badAppleEnabled = false
local shakeCam = false
local bloomIntensity = 0

function onCreate()
    -- Barras cinemáticas en camOther (siempre arriba de todo)
    makeLuaSprite('cinematicBarTop', nil, 0, -screenHeight)
    makeGraphic('cinematicBarTop', screenWidth * 2, screenHeight, '000000')
    setObjectCamera('cinematicBarTop', 'other')
    addLuaSprite('cinematicBarTop', true)

    makeLuaSprite('cinematicBarBottom', nil, 0, screenHeight)
    makeGraphic('cinematicBarBottom', screenWidth * 2, screenHeight, '000000')
    setObjectCamera('cinematicBarBottom', 'other')
    addLuaSprite('cinematicBarBottom', true)
end

function cinematicBars(show, time, position)
    if show == nil then show = false end
    if time == nil then time = 1 end
    if position == nil then position = 3.35 end
    
    cancelTween('cinematicBarTopTween')
    cancelTween('cinematicBarBottomTween')

    local targetY = show and (-screenHeight + (screenHeight / 2 / position)) or -screenHeight
    local targetY2 = show and (screenHeight - (screenHeight / 2 / position)) or screenHeight
    
    doTweenY('cinematicBarTopTween', 'cinematicBarTop', targetY, time, 'quadOut')
    doTweenY('cinematicBarBottomTween', 'cinematicBarBottom', targetY2, time, 'quadOut')
end

function onStartCountdown()
    setProperty('introSoundsSuffix', '-m')
    setVar('camMove', false)
    camZoomingStrength = 0
    
    if shadersEnabled then
        -- Inicialización segura de shaders
        runHaxeCode([[
            game.initLuaShader('vhs');
            game.initLuaShader('bloom');
            game.initLuaShader('vcr');
            game.initLuaShader('chromAbb');
            game.initLuaShader('blackNwhite');
        ]])
    end

    makeLuaSprite('blackIntro')
    makeGraphic('blackIntro', screenWidth*4, screenHeight*4, '000000')
    setObjectCamera('blackIntro', 'other')
    setProperty('blackIntro.alpha', 0.5)
    addLuaSprite('blackIntro', true)

    makeLuaText('dontMiss', "DON'T MISS.", 0, 0, 0)
    setTextSize('dontMiss', 64)
    setTextAlignment('dontMiss', 'center')
    screenCenter('dontMiss')
    setObjectCamera('dontMiss', 'hud')
    setProperty('dontMiss.alpha', 0.001)
    addLuaText('dontMiss')
    
    cinematicBars(true, 0.01, 3.35)
end

function onUpdatePost(elapsed)
    local h = getHealth()
    if shakeCam and curBeat >= 68 then
        cameraShake('game', 0.01, 0.035)
        setProperty('iconP2.x', getProperty('iconP2.x') + (math.random() * 6 - 3))
    end

    if shadersEnabled then
        local d = getSongPosition() / 1000
        -- Actualización de tiempo para shaders
        setShaderFloat('vcrShader', 'iTime', d)
        setShaderFloat('bloomShader', 'iTime', d)
        
        if bloomIntensity > 0 then
            bloomIntensity = bloomIntensity - (1.5 * elapsed)
            setShaderFloat('bloomShader', 'intensity', bloomIntensity)
        end
    end
    
    if badAppleEnabled then
        setHealth(0.1)
    end
end

-- Función corregida para Bad Apple
function badApple(enabled)
    badAppleEnabled = enabled
    if enabled then
        setProperty('bg.visible', false)
        if luaSpriteExists('shadow') then setProperty('shadow.visible', false) end
        setProperty('gf.alpha', 0.001)
        
        -- Texto de aviso
        setProperty('dontMiss.alpha', 0.6)
        doTweenAlpha('dontMissFade', 'dontMiss', 0, 1.7, 'quadOut')
        
        -- Cambiar colores a negro (Silueta)
        local chars = {'boyfriend', 'dad', 'iconP1', 'iconP2'}
        for _, val in ipairs(chars) do
            setProperty(val .. '.color', getColorFromHex('000000'))
        end
        
        -- Fondo blanco mediante Haxe
        runHaxeCode([[
            game.camGame.bgColor = 0xFFFFFFFF;
        ]])
    else
        runHaxeCode([[
            game.camGame.bgColor = 0xFF000000;
        ]])
        setProperty('bg.visible', true)
        if luaSpriteExists('shadow') then setProperty('shadow.visible', true) end
        setProperty('gf.alpha', 1)
        
        local chars = {'boyfriend', 'dad', 'iconP1', 'iconP2'}
        for _, val in ipairs(chars) do
            setProperty(val .. '.color', getColorFromHex('FFFFFF'))
        end
    end
end

-- Mantener el resto de tus eventos curBeat igual...
-- Asegúrate de llamar a cinematicBars y badApple como lo hacías antes.
