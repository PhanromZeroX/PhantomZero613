local curTarget = nil
local enableSystem = true
local allowCam = true
local cameraPositions = {
    default = {x = nil,y = nil},
    all = {x = nil, y = nil}, -- if not nil, the camFollow will always by this value.
    dad = {x = nil,y = nil},
    boyfriend = {x = nil,y = nil},
    gf = {x = nil, y = nil}

}
local cameraOffsets = {
    default = 50
}

local followX = true
local followY = true

local targetX = 0
local targetY = 0

local cam = 'camGame.scroll'
function onCreatePost()
    if version <= '0.6' then
        cam = 'camFollowPos'
    end
    setProperty(cam..'.x',detectMiddleX('dad','boyfriend') - 300)
    setProperty(cam..'.y',detectMiddleY('dad','boyfriend') - 300)
    if songName == 'No Party' then
        allowCam = false
    end
    if allowCam then
        detectStage(curStage)
        detectOfs(curStage)
    end
end

function detectStage(stage,resetCamPos)
    enableSystem = true
    if resetCamPos then
        setCamPos()
    end
    if stage == 'nesbeat' then
        setCamPos(700,450)
    elseif stage == 'directstream' then
        setCamPos(1050,585)
        setProperty(cam..'.x',420)
        setProperty(cam..'.y',215)
    elseif stage == 'castlestar' then
        setCamPos(400,420,'dad')
        setCamPos(1320,500,'bf')
    elseif stage == 'racing' then
        setCamPos(420,450,'dad')
        setCamPos(720,450,'bf')
        setOffs(30)
    elseif stage == 'realbg' then
        setCamPos(1030,750,'bf')
        setOffs(20)
    else
        setCamPos()
    end
end

function detectOfs(stage)
    setOffs(40)
    if stage == 'nesbeat' then
        setOffs(35)
    elseif stage == 'directstream' then
        setOffs(0)
    elseif stage == 'hatebg' then
        setOffs(50)
    elseif stage == 'warioworld' then
        setOffs(30,'dad')
    end
end

function setOffs(ofs,target)
    if ofs == nil then
        detectOfs(curStage)
    else
        if target == nil then
            for chars, charOfs in pairs(cameraOffsets) do
                cameraOffsets[chars] = ofs
            end
        else
            cameraOffsets[target] = ofs
        end
    end
end

function setCamPos(x,y,target)
    if target == 'bf' then
        target = 'boyfriend'
    end
    if type(x) == "string" then
        x = detectPos(x)
    end
    if type(y) == "string" then
        y = detectPos(y)
    end
    if target == nil then
        for char, positions in pairs(cameraPositions) do
            if char ~= 'all' then
                if x ~= '' then
                    cameraPositions[char].x = x
                end
                if y ~= '' then
                    cameraPositions[char].y = y
                end
            end
        end
    else
        if cameraPositions[target] == nil then
            cameraPositions[target] = {x = nil, y = nil}
        end
        if x ~= '' then
            cameraPositions[target].x = x
        end
        if y ~= '' then
            cameraPositions[target].y = y
        end
    end
end

function onUpdatePost()
    if not inGameOver and not getProperty('isCameraOnForcedPos') then
        local anim = getProperty(curTarget..'.animation.curAnim.name')
        local ofs = 0
        
        if cameraOffsets[curTarget] ~= nil then
            ofs = cameraOffsets[curTarget]
        else
            ofs = cameraOffsets['default']
        end
    
        local ofsX = 0
        local ofsY = 0
        if enableSystem then
            if stringStartsWith(anim,'singLEFT') then
                ofsX = -ofs
            elseif stringStartsWith(anim,'singDOWN') then
                ofsY = ofs
            elseif stringStartsWith(anim,'singUP') then
                ofsY = -ofs
            elseif stringStartsWith(anim,'singRIGHT') then
                ofsX = ofs
            end
        end

        if followX then
            if cameraPositions['all'].x ~= nil then
                targetX = cameraPositions['all'].x + ofsX
            else
                targetX = getCharX(curTarget,curTarget == 'boyfriend') + ofsX
            end
            setProperty('camFollow.x',targetX)
        end
        if followY then
            if cameraPositions['all'].y ~= nil then
                targetY = cameraPositions['all'].y + ofsY
            else
                targetY = getCharY(curTarget) + ofsY
            end
            setProperty('camFollow.y',targetY)
        end
    end
    if luaSpriteExists('camTweenX') then
        followX = false
        setProperty('camFollow.x',getProperty('camTweenX.x'))
        targetX = getProperty('camFollow.x')
    end
    if luaSpriteExists('camTweenY') then
        followY = false
        setProperty('camFollow.y',getProperty('camTweenY.x'))
        targetY = getProperty('camFollow.y')
    end
end


function doCamTween(x,y,time,easing)
    if time == nil then
        time = 1
    end
    if x ~= nil then
        makeLuaSprite('camTweenX',nil,targetX)
        doTweenX('camFollowTweenX','camTweenX',detectPos(x),time,easing)
    end
    if y ~= nil then
        makeLuaSprite('camTweenY',nil,targetY)
        doTweenX('camFollowTweenY','camTweenY',detectPos(y),time,easing)
    end
end

function cancelCamTween(pos)
    if pos == 'x' then
        cancelTween('camFollowTweenX')
        setProperty('camFollow.x',getProperty(cam..'.x'))
        followX = true
    elseif pos == 'y' then
        cancelTween('camFollowTweenY')
        setProperty('camFollow.y',getProperty(cam..'.y'))
        followY = true
    else
        cancelTween('camFollowTweenX')
        cancelTween('camFollowTweenY')
        removeLuaSprite('camTweenX',true)
        removeLuaSprite('camTweenY',true)
        setProperty('camFollow.x',getProperty(cam..'.x'))
        setProperty('camFollow.y',getProperty(cam..'.y'))
        followX = true
        followY = true
    end
end

function getCharX(character,isPlayer)
    if cameraPositions[character] == nil or cameraPositions[character] ~= nil and cameraPositions[character].x == nil then
        local offset = 0
        if isPlayer == nil then
            isPlayer = (character == 'boyfriend')
        end
        if character == 'dad' then
            offset = getProperty('opponentCameraOffset[0]')
        elseif character == 'gf' then
            offset = offset - 150 + getProperty('girlfriendCameraOffset[0]')--- "-150" because gf is not a player, the game adds 150 at position x if the focused character is not a player
        elseif character == 'boyfriend' then
            offset = offset - getProperty('boyfriendCameraOffset[0]')
        end
        if isPlayer then
            offset = offset - 100 - getProperty(character..'.cameraPosition[0]')
        else
            offset = offset + 150  + getProperty(character..'.cameraPosition[0]')
        end
        local x = getMidpointX(character) + offset
        return x
    else
        return cameraPositions[character].x
    end
end

function getCharY(character)
    if cameraPositions[character] == nil or cameraPositions[character] ~= nil and cameraPositions[character].y == nil then
        local offset = 0
    
        if character == 'gf' then
            offset = getProperty('girlfriendCameraOffset[1]')
        else
            offset = -100
            if character == 'dad' then
                offset = offset + getProperty('opponentCameraOffset[1]')
            elseif character == 'boyfriend' then
                offset = offset + getProperty('boyfriendCameraOffset[1]')
            end
        end

        return getMidpointY(character) + getProperty(character..'.cameraPosition[1]') + offset
    else
        return cameraPositions[character].y
    end
end

function detectMiddleX(character1,character2)
    return getCharX(character1) + ((getCharX(character2) - getCharX(character1))/2)
end
function detectMiddleY(character1,character2)
    return getCharY(character1) + ((getCharY(character2) - getCharY(character1))/2)
end

function onTweenCompleted(tag)
    if tag == 'camFollowTweenX' then
        followX = true
        removeLuaSprite('camTweenX',true)
    elseif tag == 'camFollowTweenY' then
        followY = true
        removeLuaSprite('camTweenY',true)
    end
end

function detectSection()
    if gfSection == true then
        return 'gf'
    else
        if not mustHitSection then
            return 'dad'
        end
    end
    return 'boyfriend'
end

function setCamTarget(focus)--Used to change target in another scripts
    curTarget = focus
end
function onMoveCamera(focus)
    curTarget = focus
end

function detectPos(pos)
    if pos ~= nil then
        local _,findSpace = string.find(pos,' ',0,true)
        if findSpace ~= nil then
            pos = string.sub(pos,findSpace+1)
        end
        local curNumber = 0
        for operation, number in string.gmatch('+'..pos,'(%p)(%w+)') do
            local toNumber
            if number == 'dadX' then
                toNumber = getCharX('dad')
            elseif number == 'defaultDadX' then
                toNumber = getMidPointX('dadGroup') + getProperty('dadCameraOffset[0]') + getProperty('dad.cameraPosition[0]') + 150
            elseif number == 'bfX' or pos == 'boyfriendX' then
                toNumber = getCharX('boyfriend')
            
            elseif number == 'middlebfdadX' or number == 'middledadbfX' then
                toNumber = detectMiddleX('boyfriend','dad')
            elseif number == 'middlebfgfX' or number == 'middlegfbfX' then
                toNumber = detectMiddleX('boyfriend','gf')
            elseif number == 'middledadgfX' or number == 'middledadbfX' then
                toNumber = detectMiddleX('dad','gf')
            
            elseif number == 'middlebfdadY' or number == 'middledadbfY' then
                toNumber = detectMiddleY('boyfriend','dad')
            elseif number == 'middlebfgfY' or number == 'middlegfbfY' then
                toNumber = detectMiddleY('boyfriend','gf')
            elseif number == 'middledadgfY' or number == 'middledadbfY' then
                toNumber = detectMiddleY('dad','gf')

            elseif number == 'middledadgfY' or number == 'middledadbfY' then
                toNumber = detectMiddleY('dad','gf')
            
            elseif number == 'defaultDadY' then
                toNumber = getMidPointY('dadGroup') + getProperty('opponentCameraOffset[1]') + getProperty('dad.cameraPosition[1]') - 100
            elseif number == 'gfX' then
                toNumber = getCharX('gf')
            elseif number == 'curX' then
                toNumber = getProperty('camFollow.x')
            elseif number == 'dadY' then
                toNumber = getCharY('dad')
            elseif number == 'bfY' or pos == 'boyfriendY' then
                toNumber = getCharY('boyfriend')
            elseif number == 'defaultBFY' then
                toNumber = getMidPointY('boyfriendGroup') + getProperty('boyfriendCameraOffset[1]') + getProperty('boyfriend.cameraPosition[1]') - 100
            elseif number == 'gfY' then
                toNumber = getCharY('gf')
            elseif number == 'curY' then
                toNumber = getProperty('camFollow.y')

            elseif number ~= 'nil' then
                toNumber = tonumber(number)
            end

            if number ~= 'nil' then
                if operation == '+' then
                    curNumber = curNumber + toNumber
                elseif operation == '-' then
                    curNumber = curNumber - toNumber
                elseif operation == '/' then
                    curNumber = curNumber/toNumber

                elseif operation == '*' then
                    curNumber = curNumber*toNumber

                elseif operation == '^' then
                    curNumber = curNumber^toNumber
                end
            else
                curNumber = -1
            end
        end
        if curNumber == -1 then
            return nil
        end
        pos = curNumber
    end
    
    return pos
end