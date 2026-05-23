function onCreate()
	local enabled = false
end

function onEvent(n,v1,v2)
	if v1 == 'true' then
		enabled = true
	elseif v1 == 'false' then
		enabled = false
	end
end

function opponentNoteHit(id, noteData, noteType, isSustainNote)
	if enabled == true then
		triggerEvent('Screen Shake', '0.2, 0.005', '0, 0');
	elseif enabled == false then
		--debugPrint('no enableado')
	end
end