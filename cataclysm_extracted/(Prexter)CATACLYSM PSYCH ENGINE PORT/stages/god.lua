function onCreate()
setProperty('skipCountdown', true) 
   makeLuaSprite('BG', 'stages/god/BG_GOD', -1950, -1600)
    setLuaSpriteScrollFactor('BG', 1, 0.8)  -- Aplicando el scroll factor
    scaleObject('BG', 2.8571428571428, 2.8571428571428)
    addLuaSprite('BG', false)

    makeLuaSprite('BG2', 'stages/god/ANGEL_BG', -970, -1500)
    setLuaSpriteScrollFactor('BG2', 1, 1)  -- Aplicando el scroll factor
    scaleObject('BG2', 2.8571428571428, 2.8571428571428)
    addLuaSprite('BG2', false)

makeLuaSprite('MARCO_BG', 'stages/god/marco_UNDERTALE_GOD', 0, 0)
setLuaSpriteScrollFactor('MARCO_BG', 1, 1)
scaleObject('MARCO_BG', 2.8571428571428, 2.8571428571428)
setProperty('MARCO_BG.alpha', 0.0000001)
addLuaSprite('MARCO_BG', true)

makeLuaSprite('LASAGNA_BG', 'stages/god/BG_LASAGNA_GOD', -1200, -600)
setLuaSpriteScrollFactor('LASAGNA_BG', 1, 1)
scaleObject('LASAGNA_BG', 2.8571428571428, 2.8571428571428)
setProperty('LASAGNA_BG.alpha', 0.0000001)
addLuaSprite('LASAGNA_BG', false)


    -- Ejemplo para sprites animados
    makeAnimatedLuaSprite('viento', 'stages/god/viento', -750, -900)
    addAnimationByPrefix('viento', 'idle', 'vientitoo', 24, true)
    setLuaSpriteScrollFactor('viento', 1, 1)  -- Aplicando el scroll factor
    scaleObject('viento', 5.7142857142857, 5.7142857142857)
    setProperty('viento.alpha', 0.0000001)
    addLuaSprite('viento', false)

    makeAnimatedLuaSprite('BONES_SANS', 'stages/god/BONES_GOD', 30, -950)
    addAnimationByPrefix('BONES_SANS', 'idle', 'bones', 24, true)
    setLuaSpriteScrollFactor('BONES_SANS', 1, 1)  -- Aplicando el scroll factor
    scaleObject('BONES_SANS', 2.8571428571428, 2.8571428571428)
    setProperty('BONES_SANS.alpha', 0.0000001)
    addLuaSprite('BONES_SANS', true)

    makeAnimatedLuaSprite('ALO', 'stages/god/ALO', 1160, -440)
    addAnimationByPrefix('ALO', 'aro', 'aro', 24, true)
    setLuaSpriteScrollFactor('ALO', 1, 1.4)  -- Aplicando el scroll factor
    scaleObject('ALO', 3.4285714285714, 3.4285714285714)
    addLuaSprite('ALO', false)

    makeAnimatedLuaSprite('ALO2', 'stages/god/ALO', -2160, -440)
    addAnimationByPrefix('ALO2', 'aro', 'aro', 24, true)
    setLuaSpriteScrollFactor('ALO2', 1, 1.4)  -- Aplicando el scroll factor
    setProperty('ALO2.flipX', true)
    scaleObject('ALO2', 3.4285714285714, 3.4285714285714)
    addLuaSprite('ALO2', false)

    makeAnimatedLuaSprite('RAYO_DIVISOR', 'stages/god/RAYO_DIVISOR', -1256, -450)
    addAnimationByPrefix('RAYO_DIVISOR', 'idle', 'rayo divisorio', 24, true)
    setLuaSpriteScrollFactor('RAYO_DIVISOR', 1, 1)  -- Aplicando el scroll factor
    scaleObject('RAYO_DIVISOR', 2.4, 2.4)
    setProperty('RAYO_DIVISOR.alpha', 0.0000001)
    addLuaSprite('RAYO_DIVISOR', true)

makeLuaSprite('PUNISH_BG1', 'stages/god/BG_GOD_GOREFIELD', -200, 100)
setLuaSpriteScrollFactor('PUNISH_BG1', 1, 1)
scaleObject('PUNISH_BG1', 2.8571428571428, 2.8571428571428)
addLuaSprite('PUNISH_BG1', false)

makeLuaSprite('PUNISH_TV', 'stages/god/tv_GOD', -100, 570)
setLuaSpriteScrollFactor('PUNISH_TV', 1, 1)
scaleObject('PUNISH_TV', 2.8571428571428, 2.8571428571428)
addLuaSprite('PUNISH_TV', false)

setObjectOrder('PUNISH_TV', getObjectOrder('boyfriendGroup') - 1)  
setObjectOrder('PUNISH_BG1', getObjectOrder('dadGroup') - 1)  
    setProperty('PUNISH_TV.visible', false)
    setProperty('PUNISH_BG1.visible', false)

makeLuaSprite('black', 'stages/god/black', -1600, -1200)
setLuaSpriteScrollFactor('black', 1, 1)
scaleObject('black', 80, 80)
addLuaSprite('black', true)
setProperty('black.alpha', 0)

          makeLuaSprite('haha', 'stages/god/black_vignette', 0, 0);
	      addLuaSprite('haha', false);	      
          scaleObject('haha', 1, 1)
          setObjectCamera('haha','CamHUD')
	      setProperty('haha.alpha',0.5)
	
          makeLuaSprite('white', 'white', -1600, -1200);
	      addLuaSprite('white', true);
	      setLuaSpriteScrollFactor('white',1,1)
          scaleObject('white', 90, 90)
	      setProperty('white.alpha',0)
end
function onUpdate()
--this is not mine--
 if dadName == 'god-ultragodfield' then
  if getProperty('dad.animation.curAnim.name') == 'idle' then
   if getProperty('dad.animation.curAnim.curFrame') == (0 or 1 or 2 or 3 or 25) then
    setProperty('boyfriend.x', getProperty('dad.x') + 605)
    setProperty('boyfriend.y', getProperty('dad.y') + 651)
   elseif getProperty('dad.animation.curAnim.curFrame') == (4 or 5 or 21 or 22) then
    setProperty('boyfriend.x', getProperty('dad.x') + 605)
    setProperty('boyfriend.y', getProperty('dad.y') + 651 + 4)
   elseif getProperty('dad.animation.curAnim.curFrame') == (6 or 7 or 19 or 20) then
    setProperty('boyfriend.x', getProperty('dad.x') + 605)
    setProperty('boyfriend.y', getProperty('dad.y') + 651 + 7)
   elseif getProperty('dad.animation.curAnim.curFrame') == (8 or 9) then
    setProperty('boyfriend.x', getProperty('dad.x') + 605)
    setProperty('boyfriend.y', getProperty('dad.y') + 651 + 9)
   elseif getProperty('dad.animation.curAnim.curFrame') == (10 or 11 or 13 or 13 or 14 or 15 or 16 or 17 or 18) then
    setProperty('boyfriend.x', getProperty('dad.x') + 605)
    setProperty('boyfriend.y', getProperty('dad.y') + 651 + 10)
   elseif getProperty('dad.animation.curAnim.curFrame') == (23 or 24) then
    setProperty('boyfriend.x', getProperty('dad.x') + 605)
    setProperty('boyfriend.y', getProperty('dad.y') + 651 + 2)
   end
  end
  
  if getProperty('dad.animation.curAnim.name') == 'singLEFT' then
   setProperty('boyfriend.x', getProperty('dad.x') + 605 + 23)
   setProperty('boyfriend.y', getProperty('dad.y') + 651 + 3)
  end
  
  if getProperty('dad.animation.curAnim.name') == 'singDOWN' then
   if getProperty('dad.animation.curAnim.curFrame') == (0 or 1) then
    setProperty('boyfriend.x', getProperty('dad.x') + 605)
    setProperty('boyfriend.y', getProperty('dad.y') + 651 - 23)
   elseif getProperty('dad.animation.curAnim.curFrame') == (2 or 3) then
    setProperty('boyfriend.x', getProperty('dad.x') + 605)
    setProperty('boyfriend.y', getProperty('dad.y') + 651 - 18)
   elseif getProperty('dad.animation.curAnim.curFrame') == (4 or 5 or 6) then
    setProperty('boyfriend.x', getProperty('dad.x') + 605)
    setProperty('boyfriend.y', getProperty('dad.y') + 651 - 17)
   end
  end
  
  if getProperty('dad.animation.curAnim.name') == 'singUP' then
   if getProperty('dad.animation.curAnim.curFrame') == (0 or 1) then
    setProperty('boyfriend.x', getProperty('dad.x') + 605)
    setProperty('boyfriend.y', getProperty('dad.y') + 651 - 25)
   elseif getProperty('dad.animation.curAnim.curFrame') == (2 or 3) then
    setProperty('boyfriend.x', getProperty('dad.x') + 605)
    setProperty('boyfriend.y', getProperty('dad.y') + 651 - 22)
   elseif getProperty('dad.animation.curAnim.curFrame') == (4 or 5 or 6) then
    setProperty('boyfriend.x', getProperty('dad.x') + 605)
    setProperty('boyfriend.y', getProperty('dad.y') + 651 - 21)
   end
  end
  
  if getProperty('dad.animation.curAnim.name') == 'singRIGHT' then
   if getProperty('dad.animation.curAnim.curFrame') == (0 or 1) then
    setProperty('boyfriend.x', getProperty('dad.x') + 605 + 7)
    setProperty('boyfriend.y', getProperty('dad.y') + 651 + 2)
   elseif getProperty('dad.animation.curAnim.curFrame') == (2 or 3) then
    setProperty('boyfriend.x', getProperty('dad.x') + 605 + 6)
    setProperty('boyfriend.y', getProperty('dad.y') + 651 + 2)
   elseif getProperty('dad.animation.curAnim.curFrame') == (4) then
    setProperty('boyfriend.x', getProperty('dad.x') + 605 + 5)
    setProperty('boyfriend.y', getProperty('dad.y') + 651 + 2)
   end
  end
 end
end
