LuaDebugMode=true
local badAppleEnabled = false

function onCreate()
    createInstance('camOverlay','flixel.FlxCamera')
    callMethod('camOverlay.copyFrom',{instanceArg('camHUD')})
    callMethodFromClass('flixel.FlxG','cameras.add',{instanceArg('camOverlay'),false})
    callMethodFromClass('flixel.FlxG','cameras.remove',{instanceArg('camHUD'),false})
    callMethodFromClass('flixel.FlxG','cameras.add',{instanceArg('camHUD'),false})
    callMethodFromClass('flixel.FlxG','cameras.remove',{instanceArg('camOther'),false})
    callMethodFromClass('flixel.FlxG','cameras.add',{instanceArg('camOther'),false})
    setProperty('camOverlay.bgColor',0x0)

    -- Cinematic Bars configuradas en camHUD (se renderizan detrás de las notas por defecto)
    makeLuaSprite('cinematicBarTop',nil, 0, -screenHeight)
    makeGraphic('cinematicBarTop', screenWidth * 2, screenHeight, '000000')
    setObjectCamera('cinematicBarTop', 'camHUD')
    addLuaSprite('cinematicBarTop')

    makeLuaSprite('cinematicBarBottom',nil,0,screenHeight)
    makeGraphic('cinematicBarBottom', screenWidth * 2, screenHeight, '000000')
    setObjectCamera('cinematicBarBottom', 'camHUD')
    addLuaSprite('cinematicBarBottom')
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
    setVar('camMove',false)
    if shadersEnabled then
        makeLuaSprite('vhsShader')
        setSpriteShader('vhsShader','vhs')

        makeLuaSprite('vcrShader')
        setSpriteShader('vcrShader','vcr')

        makeLuaSprite('chromAbbShader')
        setSpriteShader('chromAbbShader','chromAbb')

        makeLuaSprite('bloomShader')
        setSpriteShader('bloomShader','bloom')

        makeLuaSprite('blackNwhiteShader')
        setSpriteShader('blackNwhiteShader','blackNwhite')

        runHaxeCode([[
            var vhs= new ShaderFilter(game.getLuaObject('vhsShader').shader);
            var blom= new ShaderFilter(game.getLuaObject('bloomShader').shader);
            game.camGame.setFilters([vhs,blom]);
        ]])
    end

    makeLuaSprite('blackIntro')
    makeGraphic('blackIntro',screenWidth*4,screenHeight*4,'000000')
    doTweenAlpha(_,'blackIntro',0.5,6,'quadInOut')
    addLuaSprite('blackIntro',true)

    makeLuaText('dontMiss', "DON'T MISS.")
    setTextSize('dontMiss', 64)
    setTextFont('dontMiss','MilkyNice.ttf')
    setTextColor('dontMiss','000000')
    setTextAlignment('dontMiss', 'center')
    screenCenter('dontMiss')
    setObjectCamera('dontMiss', 'camHUD')
    setProperty('dontMiss.alpha', 0.001)
    addLuaText('dontMiss')
    cinematicBars(true, 0.01, 3.35)
end

local bloomIntensity=0
function onUpdatePost()
    h=getHealth()
    if shakeCam and curBeat >= 68 then
        cameraShake('game',0.01, 0.035)
        setProperty('iconP2.x', getProperty('iconP2.x') + (math.random()*(h>= 1.8 and 14 or 6)-(h>= 1.8 and 7 or 3)))
    end
    if shadersEnabled then
        d=getSongPosition()/1000
        setShaderFloat('vcrShader','iTime',d)
        setShaderFloat('chromAbbShader','iTime',d)
        setShaderFloat('blackNwhiteShader','iTime',d)
        setShaderFloat('bloomShader','iTime',d)
        setShaderFloat('vhsShader','iTime',d)

        if badAppleEnabled then
            setHealth(0.1)
        end
        setProperty('boyfriend.idleSuffix',getHealth()<= 0.2 and '-scared' or '')
        if bloomIntensity <= 0 then return end
        bloomIntensity = bloomIntensity - 0.0225
        setShaderFloat('bloomShader','intensity',bloomIntensity)
    end
end

function onBeatHit()
    if curBeat == 108 or curBeat == 302 then
        cinematicBars(true, 0.3, 5)
    elseif curBeat == 110 or curBeat == 304 then
        cinematicBars(false, 0.3)
    elseif curBeat == 124 or curBeat == 318 then
        cinematicBars(true, 0.3, 5)
    elseif curBeat == 126 or curBeat == 320 then
        cinematicBars(false, 0.3)
    elseif curBeat == 132 then
        cameraFlash('hud', 'ffffff', 0.7)
        if shadersEnabled then
            bloomIntensity=4
            setShaderFloat('bloomShader','intensity',bloomIntensity)
        end
    elseif curBeat == 156 or curBeat == 350 then
        middleCam(true)
        setVar('camMove', false)
        cinematicBars(true, 3, 4)
    elseif curBeat == 164 or curBeat == 358 then
        middleCam(false)
        setVar('camMove', true)
        cinematicBars(false, 0.3)
    elseif curBeat == 176 or curBeat == 370 then
        middleCam(true)
        setVar('camMove', false)
    elseif curBeat == 278 or curBeat==310 or curBeat==342 or curBeat==535 or curBeat==547 or curBeat==558 or curBeat==567 or curBeat==603 or curBeat==627 or curBeat==667 or curBeat==701 then
        cameraSetTarget('boyfriend')
        setVar('camMove', false)
        runTimer('bluh',1)
    elseif curBeat == 294 or curBeat==326 or curBeat==541 or curBeat==553 or curBeat==563 or curBeat==571 or curBeat==615 or curBeat==635 or curBeat==691 then
        cameraSetTarget('dad')
        setVar('camMove', false)
        runTimer('bluh',1)
    end

    if curBeat==14 then
        doTweenAlpha('e','dad',0.2,0.2,'quadInOut')
        doTweenAlpha('ee','gf',0.8,0.2,'quadInOut')
        callMethod('iconP2.changeIcon',{'mouse-suffer'})
        if shadersEnabled then
            runHaxeCode([[
                game.iconP2.shader = game.dad.shader= game.gf.shader = game.getLuaObject('blackNwhiteShader').shader;
                setVar('v', new ShaderFilter(game.getLuaObject('vcrShader').shader));
                game.camGame.filters.push(getVar('v'));
            ]])
        end
        cinematicBars(true, 0.3, 5)
        shakeCam = true
    elseif curBeat==15 then
        startTween('wawa', 'dad', {alpha = 1}, 0.2, {ease = 'quadInOut', startDelay = 0.25})
        startTween('mayvbe', 'gf', {alpha = 0}, 0.2, {ease = 'quadInOut', startDelay = 0.25})
    elseif curBeat==16 then
        callMethod('iconP2.changeIcon',{'mouse'})
        if shadersEnabled then
            callMethod('camGame.filters.remove', {instanceArg('v')})
            runHaxeCode([[
                game.iconP2.shader = game.dad.shader= game.gf.shader =null;
            ]])
        end
        shakeCam = false
        cinematicBars(true, 0.7, 3.35)
    elseif curBeat==28 then
        callMethod('iconP2.changeIcon',{'mouse-suffer'})
        doTweenAlpha('ee','dad',0.4,1,'quadInOut')
        doTweenAlpha('eee','gf',0.6,1,'quadInOut')
        doTweenAlpha('eeee','blackIntro',0,0.5,'quadInOut')
        cinematicBars(true, 0.3, 5)
        shakeCam = true
        if shadersEnabled then
            runHaxeCode([[
                game.camGame.filters.push(getVar('v'));
                game.iconP2.shader = game.dad.shader= game.gf.shader = game.getLuaObject('blackNwhiteShader').shader;
            ]])
        end
    elseif curBeat==30 then
        cinematicBars(true, 0.7, 2)
    elseif curBeat==32 then
        cinematicBars(false, 0.4)
        if shadersEnabled then
            bloomIntensity=4
            setShaderFloat('bloomShader','intensity',bloomIntensity)
        end
        setProperty('isCameraOnForcedPos', true)
        doTweenX('camFollowX', 'camFollow', 1360, 1, 'quadInOut')
        doTweenY('camFollowY', 'camFollow', 840, 1, 'quadInOut')
    elseif curBeat==44 then
        doTweenAlpha('ee','dad',0.6,0.2,'quadInOut')
        doTweenAlpha('eee','gf',0.4,0.2,'quadInOut')
        callMethod('iconP2.changeIcon',{'mouse-suffer'})
        if shadersEnabled then
            runHaxeCode([[
                game.camGame.filters.push(getVar('v'));
                game.iconP2.shader = game.dad.shader= game.gf.shader = game.getLuaObject('blackNwhiteShader').shader;
            ]])
        end
    elseif curBeat==47 then
        startTween('wadaswa', 'dad', {alpha = 1}, 0.2, {ease = 'quadInOut', startDelay = 0.25})
        startTween('maadsyvbe', 'gf', {alpha = 0}, 0.2, {ease = 'quadInOut', startDelay = 0.25})
    elseif curBeat==48 then
        callMethod('iconP2.changeIcon',{'mouse'})
        if shadersEnabled then
            callMethod('camGame.filters.remove', {instanceArg('v')})
            runHaxeCode([[
                game.iconP2.shader = game.dad.shader= game.gf.shader =null;
            ]])
        end
    elseif curBeat==56 then
        cinematicBars(true, 1, 3.35)
        middleCam(true)
        callMethod('iconP2.changeIcon',{'mouse-suffer'})
        doTweenAlpha('ola','dad',0.8,1,'quadInOut')
        doTweenAlpha('miraka','gf',0.2,1,'quadInOut')
        if shadersEnabled then
            runHaxeCode([[
                game.camGame.filters.push(getVar('v'));
                game.iconP2.shader = game.dad.shader= game.gf.shader = game.getLuaObject('blackNwhiteShader').shader;
            ]])
        end
    elseif curBeat==60 then
    elseif curBeat==61 then
        startTween('xd', 'dad', {alpha = 1}, 0.2, {ease = 'quadInOut', startDelay = 0.25})
        startTween('dsa', 'gf', {alpha = 0}, 0.2, {ease = 'quadInOut', startDelay = 0.25})
    elseif curBeat==62 then
        callMethod('iconP2.changeIcon',{'mouse'})
        if shadersEnabled then
            callMethod('camGame.filters.remove', {instanceArg('v')})
            runHaxeCode([[
                game.iconP2.shader = game.dad.shader= game.gf.shader = null;
            ]])
        end
    elseif curBeat==63 then
        middleCam(false)
        cinematicBars(false, 1.5)
    elseif curBeat==64 then
        doTweenAlpha('mamamia','camHUD',0,0.7)
    elseif curBeat==68 then
        setVar('camMove',false)
        if shadersEnabled then
            bloomIntensity=4
            setShaderFloat('bloomShader','intensity',bloomIntensity)
        end
        cameraFlash('hud', 'ffffff', 0.7)
        setProperty('camHUD.alpha',1)
        setProperty('dad.alpha',0)
        setProperty('gf.alpha',1)
        setProperty('staticThingy.alpha',0.1)
    elseif curBeat == 128 then
        setVar('camMove',false)
    end
end

function middleCam(enabled)
    setProperty('isCameraOnForcedPos',enabled)
    if enabled then
        callMethod('camFollow.setPosition', {1025,800})
    end
end

function opponentNoteHit(i,d,t,s)
    playAnim('gf',getProperty('singAnimations')[d+1],true)
    setProperty('gf.holdTimer', 0)
end

function onTweenCompleted(t)
    if t=='camFollowY' or t=='camFollowX' then
        setProperty('isCameraOnForcedPos',false)
        startTween('dadFadeIn', 'dad', {alpha = 1}, 0.2, {ease = 'quadInOut', startDelay = 0.25})
        startTween('gfFadeOut', 'gf', {alpha = 0}, 0.2, {ease = 'quadInOut', startDelay = 0.25,onComplete='xd'})
    elseif t=='mamamia' then
        callMethod('iconP2.changeIcon',{'mouse-suffer'})
    elseif t == 'camFollowX1' or t == 'camFollowY1' then
        startTween('lolwtftuewresloco', 'camFollow', {x = 800,y=800}, 0.3, {ease = 'quadInOut', startDelay = 0.5})
        setProperty('isCameraOnForcedPos',false)
