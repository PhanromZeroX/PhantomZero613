--FPS Codename by https://gamebanana.com/mods/535434

startX = 600
startY = 240
moveY = 37.5
function onCreate()
makeLuaText("fps", " ", -1, 9, 5)
setTextSize("fps", 18)
setTextBorder('fps', 0)
setTextFont("fps", 'consola.ttf')
setObjectCamera("fps", 'other'); 
setObjectOrder('fps', 99999)
addLuaText("fps", true)

makeLuaText("codename", "Codename Engine Beta", -1, 10, 42)
setTextSize("codename", 12.4)
setTextBorder('codename', 0)
setProperty('codename.borderSize', 0)
setTextFont("codename", 'consola.ttf')
setObjectCamera("codename", 'other'); 
setObjectOrder('codename', 99999)
addLuaText("codename", true)

makeLuaText("codename2", "Commit 1 (814bd71)", -1, 10, 57)
setTextFont("codename2", 'consola.ttf')
setTextBorder('codename2', 0)
setTextSize("codename2", 12.4)
setObjectCamera("codename2", 'other'); 
setObjectOrder('codename2', 99999)
addLuaText("codename2", true)

makeLuaText("fps2", " ", -1, 31, 11)
setProperty('fps2.borderSize', 0)
setTextBorder('fps2', 0)
setTextSize("fps2", 12.8)
setObjectCamera("fps2", 'other'); 
setObjectOrder('fps2', 99999)
addLuaText("fps2", true)    
setTextFont("fps2", 'consola.ttf')

makeLuaText("memory2", " ", -1, 65, 25)
setTextSize("memory2", 12.7)
setTextBorder('memory2', 0)
setProperty('memory2.borderSize', 0)
setProperty('memory2.alpha',0.5)
setObjectCamera("memory2", 'other'); 
setObjectOrder('memory2', 99999)
addLuaText("memory2", true)
setTextFont("memory2", 'consola.ttf')

makeLuaText("MemoryCounter", "MEM: 0MB", -6, 9, 26)
setTextSize("MemoryCounter", 12.7)
setTextBorder('MemoryCounter', 0)
setProperty('MemoryCounter.borderSize', 0)
setTextFont("MemoryCounter", 'consola.ttf')
setObjectCamera("MemoryCounter", 'other'); 
setObjectOrder('MemoryCounter', 99999)
addLuaText("MemoryCounter", true)

makeLuaText('Pene', 'Port By Prexter', 0, 10, 69)
    setTextSize('Pene', 12.7)
    setTextFont('Pene', 'consola.ttf')
    setTextBorder('Pene', 0)
    setObjectCamera('Pene', 'other')
    addLuaText('Pene')
end

function onCreatePost()

--Score [Credits - uhh nose quien lo hizo :v en verdad no se quien lo hizo]
    makeLuaText('Accuracy', 'Accuracy:-% - [N/A]', -1, 329, ((downscroll == true) and 143 or 587))
    setObjectCamera('Accuracy', 'hud')
    setTextAlignment('Accuracy', 'left')
    setProperty('Accuracy.borderSize', 0.8)
    setTextSize('Accuracy', 17) 
    addLuaText('Accuracy')

    makeLuaText('Rating', '[N/A]', -1, 470, ((downscroll == true) and 143 or 587))
    setObjectCamera('Rating', 'hud')
    setTextAlignment('Rating', 'left')
    setTextColor('Rating', '656565')
    setProperty('Rating.borderSize', 0.8)
    setTextSize('Rating', 17) 
    addLuaText('Rating')

    makeLuaText('Miss', 'Misses: 0', -1, 590, ((downscroll == true) and 143 or 587))
    setObjectCamera('Miss', 'hud')
    setTextAlignment('Miss', 'left')
    setProperty('Miss.borderSize', 0.8)
    setTextSize('Miss', 17) 
    addLuaText('Miss')

    makeLuaText('Score', 'Score:0', -1, 775, ((downscroll == true) and 143 or 587))
    setObjectCamera('Score', 'hud')
    setTextAlignment('Score', 'left')
    setProperty('Score.borderSize', 0.8)
    setTextSize('Score', 17) 
    addLuaText('Score')

    setProperty('scoreTxt.visible', false)
    
addHaxeLibrary('Main');
   runHaxeCode([[
    Main.fpsVar.visible = false;
  ]]);

if downscroll then
setProperty('headsUp.flipY', true)
end
end

function onDestroy()
   runHaxeCode([[
    Main.fpsVar.visible = true;
  ]]);
end

combo = 0
function goodNoteHit(id, direction, noteType, isSustainNote)
 if not isSustainNote then
  if combo == 0 then
   makeCombo(string.lower(getPropertyFromGroup('notes', id, 'rating')))
   combo = combo + 1
  else
   combo = combo + 1
   makeCombo(string.lower(getPropertyFromGroup('notes', id, 'rating')))
  end
 end
end


function noteMiss(membersIndex, noteData, noteType, isSustainNote)
    combo = 0

    local random = math.random (3)
    if random == 1 then
        playSound("missnote1", 0.001, "miss1") -- change the decimal number to change the volume
    elseif random == 2 then
        playSound("missnote2", 0.001, "miss2")
    elseif random == 3 then
        playSound("missnote3", 0.001, "miss3")
    end
end

function onUpdate(elapsed)
setObjectOrder('MemoryCounter', getObjectOrder('MemoryCounter') + 99999)
setObjectOrder('memory2', getObjectOrder('memory2') + 99999)
setObjectOrder('fps2', getObjectOrder('fps2') + 99999)
setObjectOrder('codename2', getObjectOrder('codename2') + 999999)
setObjectOrder('codename', getObjectOrder('codename') + 999999)
setObjectOrder('fps', getObjectOrder('fps') + 999999)

local curFps = ""..getPropertyFromClass("Main", "fpsVar.currentFPS")
    local memory = round(getPropertyFromClass("openfl.system.System", "totalMemory")/ 1000000, 1);
    local memPeak = memory
    local peakLv = 0  

    setTextString("MemoryCounter", memory.. "MB")
    setTextString("fps", curFps)  
    setTextString("fps2", " FPS")
    setTextString("memory2", "/ 495.90MB")
end

function round(x, n) --https://stackoverflow.com/questions/18313171/lua-rounding-numbers-and-then-truncate
  n = math.pow(10, n or 0)
  x = x * n
  if x >= 0 then x = math.floor(x + 0.5) else x = math.ceil(x - 0.5) end
  return x / n
end

function onUpdatePost()
setProperty('healthBar.visible', false)
setProperty('scoreTxt.visible', false)
setProperty('timeBar.visible', false)
setProperty('guitarHeroSustains', false) --Off sustain as one hit
setObjectCamera('comboGroup', 'camGame')
setProperty('showRating', false)
setProperty('showComboNum', false)

curHealth = (getProperty('health')/2)
	curHealth = (getProperty('health')/2)
	setProperty('healthP1._frame.frame.width', 570 + (math.lerp(-470, 150, curHealth)));

if middlescroll then
		setPropertyFromGroup('strumLineNotes',0,'x',-99930)
    setPropertyFromGroup('strumLineNotes',1,'x',-99930)
    setPropertyFromGroup('strumLineNotes',2,'x',-99930)
    setPropertyFromGroup('strumLineNotes',3,'x',-99930)
end
for i = 0, getProperty('grpNoteSplashes.length') - 1 do
            setPropertyFromGroup('grpNoteSplashes', i, 'alpha', 0.9)
end
end

function math.lerp(a, b, t)
	return a + t * (b - a);
end

function onRecalculateRating()
 if rating >= 0 and rating < 0.5 then
  ratingText = 'F'
  colorRating = '941616'
 elseif rating >= 0.5 and rating < 0.7 then
  ratingText = 'E'
  colorRating = 'CF1414'
 elseif rating >= 0.7 and rating < 0.8 then
  ratingText = 'D'
  colorRating = 'FFAA44' 
 elseif rating >= 0.8 and rating < 0.85 then
  ratingText = 'C'
  colorRating = 'FFFF44'
 elseif rating >= 0.85 and rating < 0.9 then
  ratingText = 'B'
  colorRating = 'FE8503'
 elseif rating >= 0.9 and rating < 0.95 then
  ratingText = 'A'
  colorRating = '95FBFF' 
 elseif rating >= 0.95 and rating < 1 then
  ratingText = 'S'
  colorRating = '85FBFF' 
 elseif rating >= 1 then
  ratingText = 'S++'
  colorRating = '0FF7FF' 
 end
 
 if getProperty('cpuControlled') then
  ratingText = '[N/A]'
  colorRating = '656565'
 end
 
 setTextString('Accuracy', 'Accuracy:' .. string.sub(tostring(rating*100), 1, 5) .. '% -')
 setTextString('Rating', ratingText)
 setProperty('Rating.x', getProperty('Accuracy.x') + getProperty('Accuracy.width'))
 setTextColor('Rating', colorRating)
 setTextString('Miss', 'Misses:' .. getProperty('songMisses'))
 setTextString('Score', 'Score:' .. getProperty('songScore'))
end

function onTweenCompleted(tag)
 if string.sub(tag, 1, 10) == 'comboNumIn' then
  doTweenY(string.sub(tag, 1, 8) .. 'Out' .. string.sub(tag, 11), string.sub(tag, 1, 8) .. string.sub(tag, 11), getProperty(string.sub(tag, 1, 8) .. string.sub(tag, 11) .. '.y') + (moveY * 1.8), _G[string.sub(tag, 11) .. 'time'], 'quadIn')
  doTweenAlpha(string.sub(tag, 1, 8) .. 'End' .. string.sub(tag, 11), string.sub(tag, 1, 8) .. string.sub(tag, 11), 0, _G[string.sub(tag, 11) .. 'time'], 'quadIn')
 end
 
 if string.sub(tag, 1, 11) == 'comboNumEnd' then
  removeLuaSprite(string.sub(tag, 1, 8) .. string.sub(tag, 12), true)
 end
 
 if string.sub(tag, 1, 8) == 'ratingIn' then
  doTweenY(string.sub(tag, 1, 6) .. 'Out' .. string.sub(tag, 9), string.sub(tag, 1, 6) .. string.sub(tag, 9), getProperty(string.sub(tag, 1, 6) .. string.sub(tag, 9) .. '.y') + (moveY * 1.8), 0.5, 'quadIn')
  doTweenAlpha(string.sub(tag, 1, 6) .. 'End' .. string.sub(tag, 9), string.sub(tag, 1, 6) .. string.sub(tag, 9), 0, 0.5, 'quadIn')
 end
 
 if string.sub(tag, 1, 9) == 'ratingEnd' then
  removeLuaSprite(string.sub(tag, 1, 6) .. string.sub(tag, 10), true)
 end
 
 if string.sub(tag, 1, 7) == 'comboIn' then
  doTweenY(string.sub(tag, 1, 5) .. 'Out' .. string.sub(tag, 9), string.sub(tag, 1, 5) .. string.sub(tag, 8), getProperty(string.sub(tag, 1, 5) .. string.sub(tag, 8) .. '.y') + (moveY * 1.8), 0.5, 'quadIn')
  doTweenAlpha(string.sub(tag, 1, 5) .. 'End' .. string.sub(tag, 9), string.sub(tag, 1, 5) .. string.sub(tag, 8), 0, 0.5, 'quadIn')
 end
 
 if string.sub(tag, 1, 8) == 'comboEnd' then
  removeLuaSprite(string.sub(tag, 1, 5) .. string.sub(tag, 9), true)
 end
end

function makeCombo(rate)
 if combo >= 10 then
  makeLuaSprite('combo' .. time, 'combo', startX + 41, startY + 60)
  scaleObject('combo' .. time, 1, 1)
  addLuaSprite('combo' .. time, true)
  doTweenY('comboIn' .. time, 'combo' .. time, getProperty('combo' .. time .. '.y') - moveY, 0.5, 'quadOut')
 end
 
 time = getSongPosition()
 makeLuaSprite('rating' .. time, '' .. rate, startX, startY)
 scaleObject('rating' .. time, 1, 1)
 addLuaSprite('rating' .. time, true)
 doTweenY('ratingIn' .. time, 'rating' .. time, getProperty('rating' .. time .. '.y') - moveY, 0.5, 'quadOut')
 
 if combo >= 10 then
  if combo > 999 then
   long = 4
  else
   long = 3
  end
  if combo == 0 then
   comboDisplay = '000'
  elseif combo >= 10 and combo < 100 then
   comboDisplay = '0' .. combo
  elseif combo >= 100 then
   comboDisplay = combo
  end
  for i=1, long do
   _G[i .. time .. 'time'] = getRandomFloat(0.6, 0.8)
   makeLuaSprite('comboNum' .. i .. time, 'num' .. string.sub(comboDisplay, i, i), startX - 49, startY + 139)
   scaleObject('comboNum' .. i .. time, 0.3, 0.3)
   addLuaSprite('comboNum' .. i .. time, true)
   if i > 1 then
    setProperty('comboNum' .. i .. time .. '.x', getProperty('comboNum' .. (i-1) .. time .. '.x') + (getProperty('comboNum' .. (i-1) .. time .. '.width') - 3))
   end
   doTweenY('comboNumIn' .. i .. time, 'comboNum'.. i .. time, getProperty('comboNum'.. i .. time .. '.y') - moveY, _G[i .. time .. 'time'], 'quadOut')
  end
 end
end