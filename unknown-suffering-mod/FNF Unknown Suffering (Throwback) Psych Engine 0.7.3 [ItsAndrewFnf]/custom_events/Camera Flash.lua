function onEvent(name, value1, value2)
if name == "Camera Flash" then
local params = stringSplit(value1, ",")
local fade = params[1] == "true"
local color = tonumber(params[2]) or -1
local v2 = stringSplit(value2, ",")
local durationBeats = tonumber(v2[1]) or 4
local camera = v2[2] or "camGame"
local durationSecs = (stepCrochet / 1000) * durationBeats
if fade then
cameraFade(camera, color, durationSecs, true, true)
else
cameraFlash(camera, color, durationSecs, true)
end
end
end

