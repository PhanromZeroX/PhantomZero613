function onEvent(name, value1, value2)
if name == "Camera Zoom" then
local params = stringSplit(value1, ",")
local params2 = stringSplit(value2, ",")
local enableTween = params[1] == "true"
local zoomAmount = tonumber(params[2])
local camera = params[3]
local durationBeats = tonumber(params[4])
local easeType = params2[1]
local easeDirection = params2[2]
local useDirect = params2[3] == "direct"
local multiplyCurrentZoom = params2[4] == "true"
local finalZoom = zoomAmount
if multiplyCurrentZoom then
finalZoom = finalZoom * getProperty(camera .. ".zoom")
end

local duration = (stepCrochet / 1000) * durationBeats
if not enableTween then
setProperty(camera .. ".zoom", finalZoom)
setProperty("defaultCamZoom", finalZoom)
else
doTweenZoom("b",camera,finalZoom,duration,easeType .. easeDirection)
end
end
end

function onTweenCompleted(t)
if t=='b' then
setProperty('defaultCamZoom',getProperty('camGame.zoom'))
end
end