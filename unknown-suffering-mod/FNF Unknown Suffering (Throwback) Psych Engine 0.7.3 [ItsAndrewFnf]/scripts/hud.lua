function onCreatePost()
for i=1,2 do
makeLuaSprite('b'..i, 'hud/healthBar'..(i == 1 and '' or 'BG'), 15+(i == 1 and 0 or 135), (downscroll and 45 or 415)+(i == 1 and 0 or 145))
addLuaSprite('b'..i)
setObjectCamera('b'..i, 'camHUD')
z = i == 1 and 0.9 or 0.35
scaleObject('b'..i,z,z)

if shadersEnabled and songName=='unknown suffering' then
setSpriteShader('b'..i,'contrast')
setShaderFloat('b'..i,'brightness',-0.1)
setShaderFloat('b'..i,'contrast',2)
setShaderFloat('b'..i,'saturation',1)
end
end

for _, i in pairs({'iconP1', 'healthBar', 'scoreTxt','timeBar','timeTxt'}) do
setProperty(i..'.visible', false)
end
setObjectCamera('comboGroup')
runHaxeCode("game.updateIconsPosition = () -> {}")
callMethod('iconP2.setPosition', {getProperty('b1.x')+115,getProperty('b1.y')+5})
end

function onUpdatePost()
f=math.max(getHealth()*3,getHealth()>0 and 1 or 0)
loadGraphic('b2','hud/'..(f<=0 and'healthBarBG'or math.floor(f)))
end

function goodNoteHitPre()
setProperty('showComboNum',combo>8)
end

function onCountdownTick(c)
local x={'Ready','Set','Go'}
if c>0 then
if songName=='unknown suffering' then
scaleObject('countdown'..(x)[c],1,1)
else
scaleObject('countdown'..(x)[c], 0.4, 0.4)
end
screenCenter('countdown'..(x)[c])
doTweenY(c,'countdown'..(x)[c],getProperty('countdown'..(x)[c]..'.y')+100,crochet/1000,'cubeInOut')
end
end