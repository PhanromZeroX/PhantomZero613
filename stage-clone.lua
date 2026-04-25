function onCreate()
	makeLuaSprite('ground', 'jami/images/virtual ground', -395, -150)
	scaleObject('ground', 1.1, 1.1)
	addLuaSprite('ground', false)
	
	makeAnimatedLuaSprite('insect', 'jami/images/bug', 1200, 680)
	addAnimationByPrefix('insect', 'walk', 'Bug', 24, true)
	scaleObject('insect', 1.1, 1.1)
	addLuaSprite('insect', false)
	setPropertyLuaSprite('insect', 'flipX', true)
	
	makeLuaSprite('sides', 'jami/images/light sides', -395, -150)
	scaleObject('sides', 1.1, 1.1)
	addLuaSprite('sides', false)
	
	makeLuaSprite('light', 'jami/images/actual light', -395, -150)
	scaleObject('light', 1.1, 1.1)
	addLuaSprite('light', false)
	
	makeLuaSprite('light2', 'jami/images/blue light', -395, -150)
	scaleObject('light2', 1.1, 1.1)
	addLuaSprite('light2', true)
	
	makeLuaSprite('shadow1', 'jami/images/shadow', 175, 785)
	scaleObject('shadow1', 1.1, 1.1)
	addLuaSprite('shadow1', false)
	
	makeLuaSprite('shadow2', 'jami/images/shadow', 750, 785)
	scaleObject('shadow2', 1.2, 1.2)
	addLuaSprite('shadow2', false)
	
	makeLuaSprite('shadow3', 'jami/images/shadow', 530, 790)
	scaleObject('shadow3', 0.8, 0.8)
	addLuaSprite('shadow3', false)
	
	makeLuaSprite('black left', '', -1130, 0)
	makeGraphic('black left', 1280, 720, '000000')
	setObjectCamera('black left', 'other')
	addLuaSprite('black left', false)
	
	makeLuaSprite('black right', '', 1110, 0)
	makeGraphic('black right', 1280, 720, '000000')
	setObjectCamera('black right', 'other')
	addLuaSprite('black right', false)
end

function onUpdate()
	setPropertyFromGroup('opponentStrums',0,'x','132')
    setPropertyFromGroup('opponentStrums',1,'x','247')
    setPropertyFromGroup('opponentStrums',2,'x','361')
    setPropertyFromGroup('opponentStrums',3,'x','475')
  
    setPropertyFromGroup('playerStrums',0,'x','675')
    setPropertyFromGroup('playerStrums',1,'x','787')
    setPropertyFromGroup('playerStrums',2,'x','900')
    setPropertyFromGroup('playerStrums',3,'x','1013')
end

function onStepHit()
	if curStep == 288 then
		doTweenX('insect', 'insect', 0, 7.5, 'linear')
	end
end