local IN = false
local targetAlpha1 = 0.25
local targetAlpha2 = 1
local lerpCam = false
local controlHealthAlpha = true  
local curHealthAlpha = 1
local curCameraTarget = 1

local camFollowChars = true
local jonTrail = { visible = true, active = true }
local jonFlying = true
local zoomDisabled = false



local lightFlicker = false
local fullTime = 2
local canFloat = true

function lerp(a, b, t)
    return a + (b - a) * t
end
function onSongStart()
startVideo('GODFIELD_INTRO') 	
setProperty('inCutscene', false);
setProperty('white.alpha', 1);
setProperty('AGS1.alpha', 0);
setProperty('AGS2.alpha', 0);
setProperty('AGS4.alpha', 0);
setProperty('AGS3.alpha', 0);
	end
function onEvent(name, value1, value2)
    if name == "Camera Movement" then
        if value1 == "0" then
doTweenAlpha("bfBarBG", "GarfieldHealthBG", targetAlpha2, 0.5, "linear")
    doTweenAlpha("bfBar", "GarfieldHealthLEFT", targetAlpha2, 0.5, "linear")
        doTweenAlpha("bfBr", "GarfieldHealthRIGHT", targetAlpha2, 0.5, "linear")
    doTweenAlpha("bfIconP1", "iconP1-A", targetAlpha2, 0.5, "linear")
    doTweenAlpha("bfIconP2", "iconP2-A", targetAlpha2, 0.5, "linear")
    doTweenAlpha("bfScore", "Score", targetAlpha2, 0.5, "linear")
    doTweenAlpha("bfMisses", "Miss", targetAlpha2, 0.5, "linear")
    doTweenAlpha("bfAccuracy", "Accuracy", targetAlpha2, 0.5, "linear")
    doTweenAlpha("r", "Rating", targetAlpha2, 0.5, "linear")
end
        if value1 == "1" then
doTweenAlpha("dadBarBG", "GarfieldHealthBG", targetAlpha1, 0.5, "linear")
    doTweenAlpha("dadBar", "GarfieldHealthLEFT", targetAlpha1, 0.5, "linear")
    doTweenAlpha("dadBr", "GarfieldHealthRIGHT", targetAlpha2, 0.5, "linear")
    doTweenAlpha("dadIconP1", "iconP1-A", targetAlpha1, 0.5, "linear")
    doTweenAlpha("dadIconP2", "iconP2-A", targetAlpha1, 0.5, "linear")
    doTweenAlpha("dadScore", "Score", targetAlpha1, 0.5, "linear")
    doTweenAlpha("dadMisses", "Miss", targetAlpha1, 0.5, "linear")
    doTweenAlpha("dadAccuracy", "Accuracy", targetAlpha1, 0.5, "linear")
    doTweenAlpha("ra", "Rating", targetAlpha1, 0.5, "linear")
        end
  if value1 == "0" and IN == true then
doTweenAlpha("bfBarBG", "GarfieldHealthBG", targetAlpha2, 0.5, "linear")
    doTweenAlpha("bfBar", "GarfieldHealthLEFT", targetAlpha2, 0.5, "linear")
        doTweenAlpha("bfBr", "GarfieldHealthRIGHT", targetAlpha2, 0.5, "linear")
    doTweenAlpha("bfIconP1", "iconP1-A", targetAlpha2, 0.5, "linear")
    doTweenAlpha("bfIconP2", "iconP2", targetAlpha2, 0.5, "linear")
    doTweenAlpha("bfScore", "Score", targetAlpha2, 0.5, "linear")
    doTweenAlpha("bfMisses", "Miss", targetAlpha2, 0.5, "linear")
    doTweenAlpha("bfAccuracy", "Accuracy", targetAlpha2, 0.5, "linear")
    doTweenAlpha("r", "Rating", targetAlpha2, 0.5, "linear")
end
        if value1 == "1" and IN == true then
doTweenAlpha("dadBarBG", "GarfieldHealthBG", targetAlpha1, 0.5, "linear")
    doTweenAlpha("dadBar", "GarfieldHealthLEFT", targetAlpha1, 0.5, "linear")
    doTweenAlpha("dadBr", "GarfieldHealthRIGHT", targetAlpha2, 0.5, "linear")
    doTweenAlpha("dadIconP1", "iconP1-A", targetAlpha1, 0.5, "linear")
    doTweenAlpha("dadIconP2", "iconP2", targetAlpha1, 0.5, "linear")
    doTweenAlpha("dadScore", "Score", targetAlpha1, 0.5, "linear")
    doTweenAlpha("dadMisses", "Miss", targetAlpha1, 0.5, "linear")
    doTweenAlpha("dadAccuracy", "Accuracy", targetAlpha1, 0.5, "linear")
    doTweenAlpha("ra", "Rating", targetAlpha1, 0.5, "linear")        
    end
end
end
function onStepHit()
    if curStep == 32 then
        for i = 0, 3 do
            noteTweenAlpha("noteAlpha" .. i, i, 1, 0.8, "quadInOut")
        end    
doTweenAlpha("ja", "white", 0, 0.5, "quadIn")
        setProperty("black.alpha", 0)    
    
    end 

    if curStep == 800 then
        targetAlpha1 = 0
        targetAlpha2 = 0
        for i = 0, 3 do
            noteTweenAlpha("noteAlpha" .. i, i, 0, 0.8, "quadInOut")
        end   
    end 

    if curStep == 912 then
        for i = 0, 3 do
            noteTweenAlpha("noteAlpha" .. i, i, 1, 0.8, "quadInOut")
        end   
    end 

    if curStep == 935 then
        zoomDisabled = true
        doTweenZoom("zoomIn", "camGame", 0.7, 12, "quadIn")
        doTweenAlpha("BGAlpha", "BG", 0.15, 12, "quadInOut")
        doTweenAlpha("BG2Alpha", "BG2", 0.15, 12, "quadInOut")
        doTweenAlpha("ALOAlpha", "ALO", 0.15, 12, "quadInOut")
        doTweenAlpha("ALO2Alpha", "ALO2", 0.15, 12, "quadInOut")
        for i = 4, 7 do
            noteTweenAlpha("noteAlpha" .. i, i, 0, 0.8, "quadInOut")
        end     
    end 

    if curStep == 1052 then
        zoomDisabled = false
        doTweenAlpha("camHUDAlphaC", "camHUD", 0, 0.4, "quadIn")
    end

    if curStep == 1058 then
        for i = 0, 7 do
            noteTweenAlpha("noteAlpha" .. i, i, 1, 0.1, "quadInOut")
        end   
    end         
    
    if curStep == 1062 then
        doTweenAlpha("BGAlpha", "BG", 1, 2, "quadIn")
        doTweenAlpha("BG2Alpha", "BG2", 1, 2, "quadIn")
        doTweenAlpha("ALOAlpha", "ALO", 1, 2, "quadIn")
        doTweenAlpha("ALO2Alpha", "ALO2", 1, 2, "quadIn")
        doTweenAlpha("camHUDAlpha", "camHUD", 1, 0.96, "quadIn")
    end

    if curStep == 1070 then
        targetAlpha2 = 1
        targetAlpha1 = 0.25
doTweenAlpha("bfBarBG", "GarfieldHealthBG", targetAlpha2, 0.5, "linear")
    doTweenAlpha("bfBar", "GarfieldHealthLEFT", targetAlpha2, 0.5, "linear")
        doTweenAlpha("bfBr", "GarfieldHealthRIGHT", targetAlpha2, 0.5, "linear")
    doTweenAlpha("bfIconP1", "iconP1-A", targetAlpha2, 0.5, "linear")
    doTweenAlpha("bfIconP2", "iconP2-A", targetAlpha2, 0.5, "linear")
    doTweenAlpha("bfScore", "Score", targetAlpha2, 0.5, "linear")
    doTweenAlpha("bfMisses", "Miss", targetAlpha2, 0.5, "linear")
    doTweenAlpha("bfAccuracy", "Accuracy", targetAlpha2, 0.5, "linear")
    doTweenAlpha("r", "Rating", targetAlpha2, 0.5, "linear")
    end

    if curStep == 1584 then


    end

    if curStep == 1585 then
        startVideo("CINEMATIC_LAYER")
        canFloat = false
        setProperty("inCutscene", false)
    end

    if curStep == 1590 then
        setProperty("BG.visible", false)
        setProperty("BG2.visible", false)
        setProperty("ALO.visible", false)
        setProperty("ALO2.visible", false)
        setProperty("PUNISH_TV.visible", true)
        setProperty("PUNISH_BG1.visible", true)
    end

    if curStep == 1632 then
        doTweenZoom("zoon", "camGame", 1.2, 0.15, "quadIn")     
        doTweenAlpha("blackAlpha", "black", 1, 0.15, "quadIn")
    end

    if curStep == 1648 then
        jonTrail.visible = false
        jonTrail.active = false
        jonFlying = false
        strumLineDadZoom = 0.9
        strumLineBfZoom = 1.2
    
        doTweenAlpha("blackFadeOut", "black", 0, 0.64, "quadOut")
        doTweenAlpha("camHUDFadeIn", "camHUD", 1, 0.64, "quadOut")
    end

    if curStep == 2175 then
        targetAlpha2 = 0
        targetAlpha1 = 0
        lerpCam = false
        doTweenZoom("cameraZoom0", "camGame", 1.4, 1.5, "quadIn")
        doTweenAlpha("blackAlpha", "black", 1, 1.5, "quadIn")
        runTimer("cameraZoom0", 1.5)  
    end

    if curStep == 2192 then
        setProperty("PUNISH_BG1.visible", false)
        setProperty("PUNISH_TV.visible", false)
        setProperty("LASAGNA_BG.alpha", 1)
        doTweenAlpha("LASAGNA_BGb", "LASAGNA_BG", 1, 0.0001, "quadInOut")
        targetAlpha1 = 1
        targetAlpha2 = 1
        strumLineBfZoom = -1
        strumLineDadZoom = -1
doTweenAlpha("bfBarBG", "GarfieldHealthBG", targetAlpha2, 0.5, "linear")
    doTweenAlpha("bfBar", "GarfieldHealthLEFT", targetAlpha2, 0.5, "linear")
        doTweenAlpha("bfBr", "GarfieldHealthRIGHT", targetAlpha2, 0.5, "linear")
    doTweenAlpha("bfIconP1", "iconP1-A", targetAlpha2, 0.5, "linear")
    doTweenAlpha("bfIconP2", "iconP2-A", targetAlpha2, 0.5, "linear")
    doTweenAlpha("bfScore", "Score", targetAlpha2, 0.5, "linear")
    doTweenAlpha("bfMisses", "Miss", targetAlpha2, 0.5, "linear")
    doTweenAlpha("bfAccuracy", "Accuracy", targetAlpha2, 0.5, "linear")
    doTweenAlpha("r", "Rating", targetAlpha2, 0.5, "linear")
        doTweenAlpha("blackAlpha", "black", 0, 0.16, "quadOut")
    end

    if curStep == 2720 then
        targetAlpha1 = 0
        targetAlpha2 = 0
        lerpCam = false
        doTweenAlpha("blackAlpha", "black", 1, 1.5, "quadOut")
        doTweenAlpha("camHUDAlpha", "camHUD", 0, 1.5, "quadOut")
    end
    if curStep == 2735 then
doTweenZoom("u", "camGame", 1.5, 0.0001, "quadInOut")        
doTweenAlpha("jjjjjjjj", "iconP2", 0, 0.00001, "linear")
   end
    if curStep == 2736 then
doTweenAlpha("jjjjjjjnj", "iconP2", 0, 0.00001, "linear")
        setProperty("LASAGNA_BG.alpha", 0)
        setProperty("MARCO_BG.alpha", 1)
        setProperty("BONES_SANS.alpha", 1)
        doTweenAlpha("blackAlpha", "black", 0, 3, "quadOut")
        zoomDisabled = true
        camFollowChars = false
IN = true
        triggerEvent('Camera Follow Pos', '600', '0')
doTweenZoom("uo", "camGame", 1.5, 0.0001, "quadInOut")        
        doTweenZoom("cameraZoom3", "camGame", 0.35, 14.86, "quadInOut")
        runTimer("cameraZoom3", 14.86)  
    end

    if curStep == 2988 then
        targetAlpha1 = 1
        targetAlpha2 = 1
doTweenAlpha("jjjjjnj", "iconP2", targetAlpha2, 0.5, "linear")
doTweenAlpha("bfBarBG", "GarfieldHealthBG", targetAlpha2, 0.5, "linear")
    doTweenAlpha("bfBar", "GarfieldHealthLEFT", targetAlpha2, 0.5, "linear")
        doTweenAlpha("bfBr", "GarfieldHealthRIGHT", targetAlpha2, 0.5, "linear")
    doTweenAlpha("bfIconP1", "iconP1-A", targetAlpha2, 0.5, "linear")
    doTweenAlpha("bfIconP2", "iconP2", targetAlpha2, 0.5, "linear")
    doTweenAlpha("bfScore", "Score", targetAlpha2, 0.5, "linear")
    doTweenAlpha("bfMisses", "Miss", targetAlpha2, 0.5, "linear")
    doTweenAlpha("bfAccuracy", "Accuracy", targetAlpha2, 0.5, "linear")
    doTweenAlpha("r", "Rating", targetAlpha2, 0.5, "linear") 
   end

    if curStep == 3120 then
        zoomDisabled = true
        camFollowChars = false
        doTweenZoom("xbda", "camGame", 0.5, 0.0001, "quadIn")            
        triggerEvent('Camera Follow Pos', '600', '0')
        targetAlpha1 = 0.3
        targetAlpha2 = 0.3
    end

    if curStep == 3121 then
        doTweenZoom("camap", "camGame", 0.35, 11.2, "quadInOut")
        runTimer("camap", 11.2)  
    end

    if curStep == 3504 then
        doTweenAlpha("blackAlphalpha", "black", 1, 2.1, "quadIn")
        doTweenAlpha("camHUDAlpha", "camHUD", 0, 2.4, "quadIn")
    end    

    if curStep == 3533 then
IN = false
        startVideo("GODFIELD_CINEMATIC_2")
        setProperty("inCutscene", false)
    end

    if curStep == 3850 then
        camFollowChars = false
        triggerEvent('Camera Follow Pos', '-50', '-320')   
        doTweenAlpha("cho", "camHUD", 1, 0.4, "linear")
doTweenAlpha("fa", "white", 1, 0.1, "quadIn")
    end
    if curStep == 3856 then
        objectPlayAnimation("boyfriend", "idle", true, "DANCE")
        setProperty("MARCO_BG.alpha", 0)
        setProperty("BONES_SANS.alpha", 0)
        setProperty("RAYO_DIVISOR.alpha", 1)
        setProperty("viento.alpha", 1)
       targetAlpha1 = 0.2
        targetAlpha2 = 0.2
doTweenAlpha("fa", "white", 0, 0.45, "quadIn")        
        doTweenAlpha("blackAlpha", "black", 0, 0.4, "quadOut")
    end

    if curStep == 4312 then
        doTweenAlpha("rayoDivisorAlpha", "RAYO_DIVISOR", 0, 0.4, "quadOut")
        doTweenAlpha("vientoAlpha", "viento", 0, 0.4, "quadOut")
        doTweenY("dadMove", "dad", getProperty("dad.y") + 600, 0.7, "quadIn")
        doTweenY("bfMove", "boyfriend", getProperty("boyfriend.y") + 265, 0.7, "linear")
    end

    if curStep == 4322 then
        triggerEvent('Camera Follow Pos','0','-320')
    end

    if curStep == 4369 then
        triggerEvent('Camera Follow Pos','-50','180')
        setProperty("dad.y", -330)
        defaultCamZoom = 0.85

    end

    if curStep == 4868 then
for i=0, 3 do
   noteTweenAlpha('aalp' .. i, i, 0,0.8, 'quadOut')
   noteTweenX('movx' .. i + 4, i + 4, 412 + (112 * i),1.2, 'quadInOut')
  end
    end
    if curStep == 4880 then
        targetAlpha1 = 0
        targetAlpha2 = 0
        triggerEvent('Camera Follow Pos','-50','400')    
        defaultCamZoom = 1.6        
for i=0, 3 do
   noteTweenAlpha('cha' .. i, i, opponentStrumAlpha, 0.8, 'quadOut')
  end
  end
    if curStep == 5008 then
        targetAlpha1 = 0.2
        targetAlpha2 = 0.2
doTweenAlpha("bfBarBG", "GarfieldHealthBG", targetAlpha2, 0.5, "linear")
    doTweenAlpha("bfBar", "GarfieldHealthLEFT", targetAlpha2, 0.5, "linear")
        doTweenAlpha("bfBr", "GarfieldHealthRIGHT", targetAlpha2, 0.5, "linear")
    doTweenAlpha("bfIconP1", "iconP1-A", targetAlpha2, 0.5, "linear")
    doTweenAlpha("bfIconP2", "iconP2-A", targetAlpha2, 0.5, "linear")
    doTweenAlpha("bfScore", "Score", targetAlpha2, 0.5, "linear")
    doTweenAlpha("bfMisses", "Miss", targetAlpha2, 0.5, "linear")
    doTweenAlpha("bfAccuracy", "Accuracy", targetAlpha2, 0.5, "linear")
    doTweenAlpha("r", "Rating", targetAlpha2, 0.5, "linear")
        doTweenAlpha("blackAlpha", "black", 0, 0.16, "quadOut")
    
  noteTweenX('XDDDDD', 4, defaultPlayerStrumX0, 1.2, 'quadInOut')
  noteTweenX('XDDDDD1', 5, defaultPlayerStrumX1, 1.2, 'quadInOut')
  noteTweenX('XDDDDD2', 6, defaultPlayerStrumX2, 1.2, 'quadInOut')
  noteTweenX('XDDDDD3', 7, defaultPlayerStrumX3, 1.2, 'quadInOut')    
  
doTweenAlpha("bfBarBG", "GarfieldHealthBG", targetAlpha2, 0.5, "linear")
    doTweenAlpha("bfBar", "GarfieldHealthLEFT", targetAlpha2, 0.5, "linear")
        doTweenAlpha("bfBr", "GarfieldHealthRIGHT", targetAlpha2, 0.5, "linear")
    doTweenAlpha("bfIconP1", "iconP1-A", targetAlpha2, 0.5, "linear")
    doTweenAlpha("bfIconP2", "iconP2-A", targetAlpha2, 0.5, "linear")
    doTweenAlpha("bfScore", "Score", targetAlpha2, 0.5, "linear")
    doTweenAlpha("bfMisses", "Miss", targetAlpha2, 0.5, "linear")
    doTweenAlpha("bfAccuracy", "Accuracy", targetAlpha2, 0.5, "linear")
    doTweenAlpha("r", "Rating", targetAlpha2, 0.5, "linear")
        doTweenAlpha("blackAlpha", "black", 0, 0.16, "quadOut")
    
        triggerEvent('Camera Follow Pos','-50','180') 
        defaultCamZoom = 0.85
  for i=0, 3 do
   noteTweenAlpha('fle' .. i, i, 1, 0.8, 'quadOut')
  end
end
 if curStep == 5009 then
doTweenX('AGB', 'AGS1', 495, 2.4, 'quadInOut')
doTweenY('AGB2', 'AGS1', -1520, 2.4, 'quadInOut')
end

if curStep == 5010 then
doTweenX('AGB3', 'AGS2', 516, 2.4, 'quadInOut')
doTweenY('AGB4', 'AGS2', -1378, 2.4, 'quadInOut')
end

if curStep == 5011 then
doTweenX('AGB5', 'AGS3', 1595, 2.4, 'quadInOut')
doTweenY('AGB6', 'AGS3', -1525, 2.4, 'quadInOut')
end

if curStep == 5012 then
doTweenX('AGB7', 'AGS4', 1550, 2.4, 'quadInOut')
doTweenY('AGB8', 'AGS4', -1390, 2.4, 'quadInOut')
end
    if curStep == 5070 then
        doTweenAlpha("camHUDAlphaTween", "camHUD", 0, 1.6, "quadInOut")
    end

    if curStep == 5128 then
        triggerEvent('Camera Follow Pos','-50','430')
        defaultCamZoom = 1.5
    end

    if curStep == 5136 then
        changeCallback = false
        setProperty("dad.animation.callback", nil)
        setProperty("dad.visible", false)
    end

    if curStep == 5137 then
        if getProperty("boyfriend.animation.finished") then
            setProperty("boyfriend.visible", false)
        end
end
end
function onTimerCompleted(tag, loops, loopsLeft)
    if tag == "cameraZoom0" then
        lerpCam = true

   end
    if tag == "camap" then
        zoomDisabled = false
        camFollowChars = true
        triggerEvent('Camera Follow Pos','','')
        runTimer("CFP", 0.1)
        targetAlpha1, targetAlpha2 = 1, 1
        doTweenZoom("pn", "camGame", 0.9, 0.75, "quadInOut")
end
    if tag == "cameraZoom3" then
        zoomDisabled = false
        camFollowChars = true
        triggerEvent('Camera Follow Pos','','')
        runTimer("CFP", 0.00001)
        doTweenAlpha("camHUDAlphaTweenOnZoom3", "camHUD", 1, 0.6, "quadIn")
        strumLineBfZoom = 0.9
        strumLineDadZoom = 0.6
    end
    if tag == "CFP" then
        triggerEvent('Camera Follow Pos','','')
    end
    if tag == "camr" then
        zoomDisabled = false
        camFollowChars = true
        triggerEvent('Camera Follow Pos','','')
        targetAlpha1, targetAlpha2 = 1, 1
        doTweenZoom("pn", "camGame", 0.9, 0.75, "quadInOut")
    end
end