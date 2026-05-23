function onEvent(name, value1, value2)
if name == "Camera Modulo Change" then
local p1 = stringSplit(value1, ",")
camZoomingInterval = tonumber(p1[1])
camZoomingStrength = tonumber(p1[2])
end
end

function onBeatHit()
if curBeat % camZoomingInterval == 0 then
setProperty('camGame.zoom', getProperty('camGame.zoom') + 0.015 * camZoomingStrength)
setProperty('camHUD.zoom', getProperty('camHUD.zoom') + 0.03 * camZoomingStrength)
end
end