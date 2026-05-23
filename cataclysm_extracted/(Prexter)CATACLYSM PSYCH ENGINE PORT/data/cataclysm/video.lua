local allowCountdown = false
stage1 = 'loadingscreens/'
function onCreate()
--stage--
if not lowQuality then     
     makeLuaSprite('bg',  stage1 .. 'pantalla_de_carga_final', -20, -55);
    setProperty('bg.antialiasing', true);
		setObjectCamera('bg', 'Other')
    scaleObject('bg', 1.36, 1.36) 
    addLuaSprite('bg', false)
    
    makeAnimatedLuaSprite('gatito', stage1 .. 'GODFIELD_CARGA', 280, 115);
		addAnimationByPrefix('gatito', 'GODFIELD CARGA0', 'GODFIELD CARGA0', 1, true)
		setObjectCamera('gatito', 'Other')
		addLuaSprite('gatito', true)
scaleObject('gatito', 1.34, 1.34)     
setProperty('gatito.antialiasing', true);

    makeAnimatedLuaSprite('pizza', stage1 .. 'pizza', 10, 570);
				addAnimationByPrefix('pizza', 'ahahaha', 'pizza0', 24, true)
				addAnimationByPrefix('pizza', 'pizza0', 'pizza0', 24, false)
		addAnimationByPrefix('pizza', 'ENTER0', 'ENTER0', 24, false)
		addAnimationByPrefix('pizza', 'PRESS ENTER LOOP0', 'PRESS ENTER LOOP0', 24, false)
		setObjectCamera('pizza', 'Other')
		addLuaSprite('pizza', true)
scaleObject('pizza', 1.225, 1.225)     
setProperty('pizza.antialiasing', true);

    --hitbox--
    makeLuaSprite('wea','',0, 0)
 makeGraphic('wea', 1280, 720, '000000')
   scaleObject('wea', 1, 1)
    setObjectCamera('wea', 'Other')
    addLuaSprite('wea', true)
    setProperty('wea.alpha', 0)    

runTimer('cero', 2)
setProperty('camGame.visible', false);
setProperty('camHUD.visible', false);    
setProperty('pizza.alpha', 0); 
setProperty('bg.alpha', 0); 
setProperty('gatito.alpha', 0); 
end
if lowQuality then     
runTimer('uno', 0.1)
end
end
function onTimerCompleted(tag)
    if tag == 'cero' then
doTweenAlpha('b', 'bg', 1, 1.25, 'linear')
doTweenAlpha('bn', 'gatito', 1, 1.25, 'linear')
doTweenAlpha('bin', 'pizza', 1, 1.25, 'linear')
playSound('godloadingsound', 1.5, 'godloadingsound')
objectPlayAnimation('pizza', 'pizza0', true)
    end
    if tag == 'empezemos' then
doTweenAlpha('b', 'bg', 0, 1.25, 'linear')
doTweenAlpha('bn', 'gatito', 0, 1.25, 'linear')
doTweenAlpha('bin', 'pizza', 0, 1.25, 'linear')
runTimer('uno', 1.35)
    end    
    if tag == 'uno' then
startVideo('cutscene') 	
setProperty('inCutscene', true);
 runTimer('Wait', 11.2)
    end
    if tag == 'Wait' then
setProperty('camGame.visible', true); 
setProperty('camHUD.visible', true);
       startCountdown()
  end
  end
function onStartCountdown()
	if not allowCountdown then
		allowCountdown = true
		return Function_Stop
	end
	return Function_Continue
end
function onUpdate()
    if getProperty('pizza.animation.curAnim.finished') and getProperty('pizza.animation.curAnim.name') == 'pizza0' then
        objectPlayAnimation('pizza', 'ENTER0', true)
     end
    if getProperty('pizza.animation.curAnim.finished') and getProperty('pizza.animation.curAnim.name') == 'ENTER0' then
        objectPlayAnimation('pizza', 'PRESS ENTER LOOP0', true)
 tocar = true
   end    
    if getMouseX('other') >= getProperty('wea.x') and getMouseX('other') <= getProperty('wea.x') + getProperty('wea.width') and getMouseY('other') >= getProperty('wea.y') and getMouseY('other') <= getProperty('wea.y') + getProperty('wea.height') and mousePressed('left') and tocar then
tocar = false
        runTimer('empezemos', 0.00001)
end
end
