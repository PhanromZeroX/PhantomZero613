local allowCountdown = false
local def = 0
local gameIntensity = 0.001
local HudIntensity = 0.0005

function onStartCountdown()
    if not allowCountdown and isStoryMode and not seenCutscene then
        startVideo('hasshaku1_cutscene')
        allowCountdown = true
        return Function_Stop
    end
    return Function_Continue
end

function onCreate()
    for i = 0, getProperty('unspawnNotes.length') - 1 do
        if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'Hurt Note' then
            setPropertyFromGroup('unspawnNotes', i, 'texture', 'HURTNOTE_assets')

            if not getPropertyFromGroup('unspawnNotes', i, 'mustPress') then
                setPropertyFromGroup('unspawnNotes', i, 'noAnimation', true)
            end
        end
    end

    setPropertyFromClass('substates.GameOverSubstate', 'characterName', 'BF_Hasshaku1_dead')
    setPropertyFromClass('substates.GameOverSubstate', 'deathSoundName', 'fnf_loss_sfx_hasshaku1') --file goes inside sounds/ folder
    setPropertyFromClass('substates.GameOverSubstate', 'loopSoundName', 'gameOver_hasshaku1')      --file goes inside music/ folder
    setPropertyFromClass('substates.GameOverSubstate', 'endSoundName', 'gameOverEnd_hasshaku1')    --file goes inside music/ folder

end

function onGameOver()
    setProperty("defaultCamZoom", 1)
    setProperty("camGame.zoom", 0.8)
end

function onGameOverConfirm(retry)
    if retry then
        cameraFlash("other", 'ffffff', 1.0 / playbackRate, true)
    end
end

function onEndSong()
    if isStoryMode and not seenCutscene then
        setProperty("camGame.alpha", .0)
        setProperty("camHUD.alpha", .0)
        startVideo('hasshaku1_end')
        seenCutscene = true
        return Function_Stop
    end
    return Function_Continue
end