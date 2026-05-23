makeLuaSprite('bg', 'stages/mouse/bg')
scaleObject('bg', 2.5, 2.5,true)
addLuaSprite('bg')

makeLuaSprite('shadow', 'stages/mouse/shadow', 235, 205)
scaleObject('shadow', 1.1, 1.1,true)
setProperty('shadow.alpha', 0.8)
addLuaSprite('shadow')

makeAnimatedLuaSprite('staticThingy', 'stages/mouse/static', 440, 280)
addAnimationByPrefix('staticThingy', 'idle', 'idle', 18, true)
scaleObject('staticThingy', 4, 4,false)
setScrollFactor('staticThingy', 0, 0)
setProperty('staticThingy.alpha', 0)
addLuaSprite('staticThingy', true)

setProperty('gf.alpha', 0)

function onMoveCamera(f)
setProperty('defaultCamZoom',f=='dad' and 0.85 or 1)
end