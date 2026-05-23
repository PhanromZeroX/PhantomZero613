local shake = false
local shakenerfed = false
local drain = true

function onCreate()
	setProperty('camZooming', true)
	setPropertyFromClass('ClientPrefs', 'camZooms', true)
    makeLuaSprite('bc', 'week1bg/bc', -600, -300);
    addLuaSprite('bc', true);
    setProperty('bc.alpha', 1);
	scaleObject('bc', 15, 15);

	makeLuaSprite('blu', 'week1bg/blue', -600, -300);
    addLuaSprite('blu', true);
    setProperty('blu.alpha', 1);
	scaleObject('blu', 15, 15);
	setObjectCamera('blu', 'camOther')

    makeLuaSprite('vareltBG', 'week5altbg/vareltBG2', -600, -300);
    addLuaSprite('vareltBG', false);
	setProperty('vareltBG.alpha', 0);

	makeLuaSprite('vareltBGlight2', 'week5altbg/vareltBG2-light2', -600, -300);
    addLuaSprite('vareltBGlight2', false);
	setProperty('vareltBGlight2.alpha', 0);

	makeLuaSprite('vareltBGlight', 'week5altbg/vareltBG2-light', -600, -300);
    addLuaSprite('vareltBGlight', false);
	setProperty('vareltBGlight.alpha', 0);

	makeLuaSprite('vareltBGlight3', 'week5altbg/vareltBG2-fx', -600, -300);
    addLuaSprite('vareltBGlight3', false);
	setProperty('vareltBGlight3.alpha', 0);

	makeLuaSprite('goodBG', 'week5bg/vareltBG', -600, -300);
    addLuaSprite('goodBG', false);
	setProperty('goodBG.alpha', 1);

	makeLuaSprite('goodBGlight', 'week5bg/vareltBGlight', -600, -300);
    addLuaSprite('goodBGlight', false);
	setProperty('goodBGlight.alpha', 1);

	makeLuaSprite('goodBGlight2', 'week5bg/vareltBGlight2', -600, -300);
    addLuaSprite('goodBGlight2', false);
	setProperty('goodBGlight2.alpha', 0.5);

	makeAnimatedLuaSprite('fire', 'week5altbg/fire', -100, 150);
    addLuaSprite('fire', false);
    addAnimationByPrefix('fire', 'idle', 'fire', 24, true);
	objectPlayAnimation('fire', 'idle', true);
	setProperty('fire.alpha', 0);
    
end

function onEvent(eventName, value1, value2)

    if eventName == 'Triggers Cover' then

		--Stage changes

        if value1 == 'stage' then

        	if value2 == 'vareltchange' then
				setProperty('goodBG.alpha', 1);
				setProperty('goodBGlight.alpha', 1);
				setProperty('goodBGlight2.alpha', 0.5);

				setProperty('vareltBG.alpha', 0);
				setProperty('vareltBGlight2.alpha', 0);
				setProperty('vareltBGlight.alpha', 0);
				setProperty('vareltBGlight3.alpha', 0);
				setProperty('fire.alpha', 0);
			end

			if value2 == 'vareltchange2' then
				setProperty('goodBG.alpha', 0);
				setProperty('goodBGlight.alpha', 0);
				setProperty('goodBGlight2.alpha', 0);
				
        		setProperty('vareltBG.alpha', 1);
				setProperty('vareltBGlight2.alpha', 1);
				setProperty('vareltBGlight.alpha', 1);
				setProperty('vareltBGlight3.alpha', 0.1);
				setProperty('fire.alpha', 0);
			end

			if value2 == 'fire' then
				setProperty('vareltBGlight3.alpha', 0.5);
				setProperty('fire.alpha', 1);
			end

			if value2 == 'nobg' then
				setProperty('goodBG.alpha', 0);
				setProperty('goodBGlight.alpha', 0);
				setProperty('goodBGlight2.alpha', 0);
				
        		setProperty('vareltBG.alpha', 0);
				setProperty('vareltBGlight2.alpha', 0);
				setProperty('vareltBGlight.alpha', 0);
				setProperty('vareltBGlight3.alpha', 0.0);
				setProperty('fire.alpha', 0);
			end
		end

		--Other events

		if value1 == 'shake' then
			if value2 == "on" then
				shake = true
			end

			if value2 == "off" then
				shake = false
			end
		end

		if value1 == 'shakenerfed' then
			if value2 == "on" then
				shake = true
			end

			if value2 == "off" then
				shake = false
			end
		end

		if value1 == 'nobarra' then
			doTweenAlpha('sexo1', 'camHUD', 0, 0.3, 'cubeinOut')
		end

		if value1 == 'sibarra' then
			doTweenAlpha('sexo2', 'camHUD', 1, 0.3, 'cubeinOut')
		end

        if value1 == 'start' then
			doTweenAlpha('pene1','bc',0,2,'linear')
		end

		if value1 == 'end' then
			doTweenAlpha('pene2','bc',1,2,'linear')
		end

		if value1 == 'endlong' then
			doTweenAlpha('zuri','bc',1,4,'linear')
		end

		if value1 == 'blackout' then
			setProperty('bc.alpha', 1);	
		end

		if value1 == 'blackoutend' then
			setProperty('bc.alpha', 0);	
		end

		if value1 == 'camslow' then
			setProperty('cameraSpeed',1);	
		end

		if value1 == 'camfast' then
			setProperty('cameraSpeed',5);	
		end

		if value1 == 'vareltvisible' then

			if value2 == 'yes' then
				setProperty('dad.alpha',1);
			end

			if value2 == 'no' then
				setProperty('dad.alpha',0);
			end
		end

		if value1 == 'limufocus' then

			if value2 == 'yes' then
				setCamPos(1460,840,'boyfriend')
			end

			if value2 == 'no' then
				setCamPos(1300,800,'boyfriend')
			end
		end

		if value1 == 'vareltfocus' then

			if value2 == 'yes' then
				setCamPos(450,580,'dad')
			end

			if value2 == 'no' then
				setCamPos(600,580,'dad')
			end
		end
	end
end

function opponentNoteHit(id,data,type,sus)
	health = getProperty('health')

	if shake then
        cameraShake("camGame", 0.005, 0.02)
    end

	if shakenerfed then
        cameraShake("camGame", 0.0001, 0.01)
    end

	if drain then
        if getProperty('health') > 0.20 then
            setProperty('health', health- 0.010);
        end
    end

end

function setCamPos(x,y,target)
    callScript('scripts/cameraMoviment','setCamPos',{x,y,target})
end

function doTweenCamPos(x,y,time,easing)
    callScript('scripts/cameraMoviment','doCamTween',{x,y,time,easing})
end

function setZoom(zoom,target)
    callScript('custom_events/Set Cam Zoom','setZoom',{zoom,target})
end

function setOffs(ofs,target)
    callScript('scripts/cameraMoviment','setOffs',{ofs,target})
end