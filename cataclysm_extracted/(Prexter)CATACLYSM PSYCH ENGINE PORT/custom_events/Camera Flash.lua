function onEvent(n,v1,v2)


	if n == 'Camera Flash' then

	   makeLuaSprite('flash2', 'white', -300, -300);
	      addLuaSprite('flash2', true);
	      setObjectCamera('flash2','hud')
	      setLuaSpriteScrollFactor('flash2',0,0)
          scaleObject('flash2', 90, 90)
	      setProperty('flash.alpha',0)
		setProperty('flash.alpha',1)
		
		makeLuaSprite('flash', 'white', -300, -300);
	      addLuaSprite('flash', true);
	      setLuaSpriteScrollFactor('flash',0,0)
          scaleObject('flash', 90, 90)
	      setProperty('flash.alpha',0)
		setProperty('flash.alpha',1)
		doTweenAlpha('flTw','flash',0,v1,'linear')
		doTweenAlpha('hhshsh','flash2',0,v1,'linear')
	end



end