-- Psych Engine Modding Example Script
-- Demonstrates shaders, sprites, tweens, and callbacks

-- ===== SHADER SETUP =====
heatwaveApplied = false
particlesApplied = false

function onStartCountdown()
    if shadersEnabled then
        -- Initialize heatwave shader for camera
        debugPrint('Loading Heatwave Shader')
        runHaxeCode([[
            game.initLuaShader('heatwave');
        ]])

        makeLuaSprite('heatwaveShader')
        setSpriteShader('heatwaveShader', 'heatwave')

        runHaxeCode([[
            var heatFilter = new ShaderFilter(game.getLuaObject("heatwaveShader").shader);
            game.camGame.setFilters([heatFilter]);
        ]])

        setShaderFloat('heatwaveShader', 'strength', 0.5)
        setShaderFloat('heatwaveShader', 'speed', 0.5)
        setShaderFloat('heatwaveShader', 'time', 0.0)
        heatwaveApplied = true

        -- Initialize particles shader
        debugPrint('Loading Particles Shader')
        runHaxeCode([[
            game.initLuaShader('particles');
        ]])

        makeLuaSprite('particlesShader')
        setSpriteShader('particlesShader', 'particles')

        runHaxeCode([[
            var particlesFilter = new ShaderFilter(game.getLuaObject("particlesShader").shader);
            game.camGame.setFilters([particlesFilter]);
        ]])

        setShaderVec2('particlesShader', 'res', screenWidth, screenHeight)
        setShaderVec2('particlesShader', 'particleXY', screenWidth / 2.0, screenHeight / 2.0)
        setShaderVec3('particlesShader', 'particleColor', 0.8, 0.2, 1.0)
        setShaderVec2('particlesShader', 'particleDirection', 0.3, -1.0)
        setShaderFloat('particlesShader', 'particleZoom', 1.0)
        setShaderFloat('particlesShader', 'particlealpha', 0.8)
        setShaderInt('particlesShader', 'layers', 6)
        setShaderFloat('particlesShader', 'time', 0.0)
        particlesApplied = true
    end
end

-- ===== SPRITE CREATION =====
function onCreate()
    debugPrint('Creating custom stage elements')
    
    -- Create a background sprite with fade-in tween
    makeLuaSprite('bg', 'stages/YOUR_STAGE_NAME/stage', -600.0, -300.0)
    addLuaSprite('bg', false)
    setProperty('bg.alpha', 0.0)
    doTweenAlpha('bgFade', 'bg', 1.0, 1.5, 'linear')
    
    -- Create animated overlay
    makeAnimatedLuaSprite('overlay', 'stages/YOUR_STAGE_NAME/overlay', 0.0, 0.0)
    addAnimationByPrefix('overlay', 'loop', 'overlay', 24, true)
    objectPlayAnimation('overlay', 'loop', true)
    addLuaSprite('overlay', true)
    setProperty('overlay.alpha', 0.6)
end

-- ===== UPDATE LOOP =====
function onUpdatePost(elapsed)
    -- Update shader uniforms
    if heatwaveApplied then
        setShaderFloat('heatwaveShader', 'time', getSongPosition() / 1000.0)
    end
    
    if particlesApplied then
        setShaderFloat('particlesShader', 'time', getSongPosition() / 1000.0)
    end
    
    -- Example: Scale background based on beat
    if mustHitSection == false then
        setProperty('bg.scale.x', 0.95 + (getSectionProperty('bpm') * 0.0001))
    end
end

-- ===== CALLBACK EVENTS =====
function onBeatHit()
    debugPrint('Beat: ' .. curBeat)
    
    -- Bounce animation on beat
    if curBeat % 2 == 0 then
        doTweenY('bgBounce', 'bg', getProperty('bg.y') + 20.0, 0.2, 'linear')
    end
end

function onStepHit()
    -- You can check for specific steps here
    if curStep == 64 then
        debugPrint('Section 2 started!')
    end
end

-- ===== NOTE EVENTS =====
function goodNoteHit(membersIndex, noteData, noteType, isSustainNote)
    debugPrint('Good Note Hit! Data: ' .. noteData)
    -- noteData: 0=LEFT, 1=DOWN, 2=UP, 3=RIGHT
    
    -- Example: Different effects per arrow
    if noteData == 0 then
        cameraShake('camGame', 0.005, 0.1)
    elseif noteData == 3 then
        doTweenZoom('noteZoom', 'camGame', 1.1, 0.1, 'linear')
    end
end

function noteMiss(membersIndex, noteData, noteType)
    debugPrint('Note Missed! Data: ' .. noteData)
    cameraShake('camGame', 0.015, 0.2)
end

-- ===== CUSTOM EVENTS =====
function eventTest(value1, value2)
    debugPrint('Custom event triggered!', 'Value1: ' .. tostring(value1), 'Value2: ' .. tostring(value2))
    
    -- Example event logic
    if value1 == '1' then
        doTweenZoom('eventZoom', 'camHUD', 1.2, 0.5, 'linear')
    end
end

function stageChange(value1, value2)
    debugPrint('Stage changed to: ' .. tostring(value1))
    -- Handle stage transition effects here
end

-- ===== TWEEN CALLBACKS =====
function onTweenCompleted(tag)
    debugPrint('Tween completed: ' .. tag)
    
    if tag == 'bgFade' then
        debugPrint('Background fade-in complete')
    elseif tag == 'bgBounce' then
        -- Return to normal position
        doTweenY('bgReturn', 'bg', getProperty('bg.y') - 20.0, 0.2, 'linear')
    elseif tag == 'eventZoom' then
        -- Reset zoom
        doTweenZoom('zoomReset', 'camHUD', 1.0, 0.3, 'linear')
    end
end

-- ===== TIMER CALLBACKS =====
function onTimerCompleted(tag)
    debugPrint('Timer completed: ' .. tag)
    
    if tag == 'example_timer' then
        -- Trigger something after timer
        cameraShake('camGame', 0.01, 0.2)
    end
end

-- ===== SECTION/SONG LOGIC =====
function onSectionHit()
    debugPrint('Section Hit! Section: ' .. curSection)
end

function onSongStart()
    debugPrint('Song Started!')
    -- Clear any startup timers/tweens
    cancelTween('bgFade')
end

-- ===== CLEANUP =====
function onDestroy()
    debugPrint('Destroying script resources')
    -- Cleanup happens automatically but you can add extra logic here
end
