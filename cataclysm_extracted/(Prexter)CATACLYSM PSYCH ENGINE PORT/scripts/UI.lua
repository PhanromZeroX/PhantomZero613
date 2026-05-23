local opOffset = {0, 0, 0, 0}
local plOffset = {0, 0, 0, 0}
local op = ''
local pl = ''
local img = 'healthbar_orange'
local plAnimated = true
local opAnimated = true

function onCreate()
    setProperty('skipArrowStartTween', (songPath ~= 'cataclysm'))
end
function onCreatePost()
    for i = 0, getProperty('unspawnNotes.length')-1 do
        setPropertyFromGroup('unspawnNotes', i, 'copyAlpha', not (songPath ~= 'cataclysm'))
    end
    if (songPath ~= 'cataclysm') then
        for i = 0,7 do
            setPropertyFromGroup('strumLineNotes', i, 'alpha', 0.65)
        end
    end

    if songPath == 'bigotes' then
        op = 'bigotes'
        pl = 'bf-outside'
        opOffset = {0, 20, 0, 0}
        plOffset = {0, 0, 0, 40}
    elseif songPath == 'cataclysm' then
        img = 'healthbar_gray'
        op = '1_FORM_GODFIELD'
        pl = 'NERMAL_GODFIELD'
        opOffset = {0, -10, 0, -10}
    elseif songPath == 'mondaylovania' or songPath == 'cat-patella' then
        img = 'healthbar_gray'
        opOffset = {0, 0, 0, 0}
        plOffset = {0, 0, 0, 0}
        pl = 'BF_sansfield'
        opAnimated = false
    end

    setProperty('healthBar.visible', false)
    setProperty('timeBar.visible', false)
    setProperty('timeTxt.visible', false)

    setTextSize('scoreTxt', 18)

    loadHealthBar(img)

    loadIcon(false)
    loadIcon(true)

    runHaxeCode([[
        game.updateIconsPosition = () -> {};
        game.updateIconsScale = () -> {};
    ]])
end 

function onCountdownTick(c)
    if c == 1 then
        setObjectCamera('countdownReady', 'camOther')
    elseif c == 2 then
        setObjectCamera('countdownSet', 'camOther')
    elseif c == 3 then
        setObjectCamera('countdownGo', 'camOther')
    end
end

function onEvent(n,v1,v2)
    if n == 'Change Character' then
        runHaxeCode "FlxTween.tween(game, {health: 1}, 0.5, {ease: FlxEase.quadOut});"
        if v2 == 'godfield-alto' then
            op = 'GODFIELD_TRUE_FORM'
            opOffset = {50, 50, 50, 50}
        elseif v2 == 'god-gorefield-phase-0' then
            op = 'godfield_gore'
            opOffset = {10, -15, 10, -15}
        elseif v2 == 'god-lasagnacat' then
            op = 'LB_GOREFIELD_GOD'
            opOffset = {0, 0, 0, 0}
        elseif v2 == 'god-sansfield' then
            opAnimated = false
        elseif v2 == 'god-ultragodfield-fall' then
            opOffset = {50, 50, 50, 50}
            op = 'GODFIELD_TRUE_FORM'
            opAnimated = true
        elseif v2 == 'sadgotes' then
            opAnimated = false
            runHaxeCode([[
                game.updateIconsScale = () -> {
                    game.iconP1.scale.set(0.8, 0.8);
                    game.iconP2.scale.set(0.8, 0.8);
                };
            ]])        
            loadHealthBar('healthbar_pixel_orange')
        elseif v2 == 'bigotes' then
            opAnimated = true
            loadHealthBar('healthbar_orange')
        end

        if v2 == 'god-jon-player' then
            pl = 'godfield_jon'
            plOffset = {0, 0, 0, 5}
        elseif v2 == 'god-lasagnaboy' then
            pl = 'LB_JON_GODFIELD'
            plOffset = {0, 0, 0, 0}
        elseif v2 == 'god-novio-negro' then
            pl = 'BF_sansfield_ingame'
            plOffset = {0, 0, 0, 0}
        elseif v2 == 'god-nermal-fall' then
            pl = 'NERMAL_GODFIELD'
        elseif v2 == 'bf-apoc2' then
            plAnimated = false
        elseif v2 == 'bf-apoc' then
            plAnimated = true
        end

        local tag = (v1 == 'bf' and 'iconP1-A' or 'iconP2-A')
        loadIcon(v1 == 'bf')
    end
end

function loadHealthBar(path)
    local isPixel = false
    if path:find('pixel') then
        isPixel = true
    end
    makeLuaSprite('GarfieldHealthBG', 'healthbar/'..path, 0, getProperty('healthBar.bg.y') - 30  * (isPixel and 2.25 or 1))
    scaleObject('GarfieldHealthBG', 0.995 * (isPixel and 3.2 or 1), 1.05 * (isPixel and 3.2 or 1))
    setObjectCamera('GarfieldHealthBG', 'camHUD')
    screenCenter('GarfieldHealthBG', 'x')
    setObjectOrder('GarfieldHealthBG', 0)
    setProperty('GarfieldHealthBG.antialiasing', not isPixel)

    makeLuaSprite('GarfieldHealthLEFT', 'healthbar/filler_left', 0, getProperty('GarfieldHealthBG.y') + 34 * (isPixel and 2.1 or 1))
    setObjectCamera('GarfieldHealthLEFT', 'camHUD')
    screenCenter('GarfieldHealthLEFT', 'x')
    setObjectOrder('GarfieldHealthLEFT', getObjectOrder('GarfieldHealthBG') + 1)

    makeLuaSprite('GarfieldHealthRIGHT', 'healthbar/filler_right', 0, getProperty('GarfieldHealthBG.y') + 34  * (isPixel and 2.1 or 1))
    setObjectCamera('GarfieldHealthRIGHT', 'camHUD')
    screenCenter('GarfieldHealthRIGHT', 'x')
    setObjectOrder('GarfieldHealthRIGHT', getObjectOrder('GarfieldHealthLEFT') + 1)
end


function loadIcon(player)
    local tag = (player and 'iconP1-A' or 'iconP2-A')
    makeAnimatedLuaSprite(tag, 'icons/'..(player and pl or op))
    addAnimationByPrefix(tag, 'nor', 'idle', 24, true)
    addAnimationByPrefix(tag, 'los', 'losing', 24, true)
    setObjectCamera(tag, 'camHUD')
    addLuaSprite(tag)  
    if player then
        setProperty('iconP1-A.flipX', true)
        setProperty('iconP1-A.offset.y', -10)
        setProperty('iconP1-A.offset.x', -30)
    end
    setProperty('iconP1.visible', not plAnimated)
    setProperty('iconP1-A.visible', plAnimated)

    setProperty('iconP2.visible', not opAnimated)
    setProperty('iconP2-A.visible', opAnimated)
end

function onUpdateScore()
    scaleObject('scoreTxt', 1, 1)
end

function onUpdatePost()
    local barWidth = (1 - (getHealth() / 2)) * getProperty('GarfieldHealthLEFT.width')
    setProperty('GarfieldHealthRIGHT._frame.frame.width', barWidth)

    updateIcons()
end

function updateIcons()
    local curHealth = getHealth() / 2
    local healthf = math.max(0, math.min(getHealth(), 2))
    local barcenter = getProperty('GarfieldHealthRIGHT.x') + (1 - healthf / 2) * getProperty('GarfieldHealthRIGHT.width')
    local iconOffset = 26

    local ip1 = barcenter + (150 * 1 - 150) / 2 - iconOffset
    local ip2 = barcenter - (150 * 1) / 2 - iconOffset * 2
    setProperty('iconP1-A.x', ip1)
    setProperty('iconP1.x', ip1)
    setProperty('iconP2-A.x', ip2)
    setProperty('iconP2.x', ip2)

    setProperty('iconP1-A.y', getProperty('iconP1.y'))
    setProperty('iconP2-A.y', getProperty('iconP2.y'))

    setProperty('iconP2-A.offset.x', (curHealth < 0.8 and opOffset[1] or opOffset[3]))
    setProperty('iconP2-A.offset.y', (curHealth < 0.8 and opOffset[2] or opOffset[4]))

    setProperty('iconP1-A.offset.x', (curHealth > 0.2 and plOffset[1] or plOffset[3]) - 30)
    setProperty('iconP1-A.offset.y', (curHealth > 0.2 and plOffset[2] or plOffset[4]) - 10)

    playAnim('iconP1-A', (curHealth > 0.2 and 'nor' or 'los'))
    playAnim('iconP2-A', (curHealth < 0.8 and 'nor' or 'los'))
end
