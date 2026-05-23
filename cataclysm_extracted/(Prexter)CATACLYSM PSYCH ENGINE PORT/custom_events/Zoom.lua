--event solo renombrado para uso en esta song--
function onEvent(name,value1,value2)
if name == "Zoom" then        
if value2 == '' then
setProperty("defaultCamZoom",value1)
else
doTweenZoom('camz','camGame',tonumber(value1),tonumber(value2),'sineInOut')
end
end
end
function onTweenCompleted(name)
if name == 'camz' then
setProperty("defaultCamZoom",getProperty('camGame.zoom'))       	 
end
end