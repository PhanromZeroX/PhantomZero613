-- psych_engine_example.lua
-- Example Psych Engine mod script using the Psych helper library.

local Psych = require('psych_engine_lib')

function onCreate()
    Psych.makeSprite('bg', 'stage/background', -400, -200, false, 1.1, 1.1, 'game')
    Psych.makeAnimatedSprite('bug', 'enemies/bug', 600, 500, 'fly', 'Bug', 24, true, false, 1, 1, 'game')
    Psych.makeText('scoreText', 'Score: 0', 20, 20, 28, 'FFFFFF')
    Psych.runTimer('startIntro', 1.5)
end

function onTimerCompleted(tag, loops, loopsLeft)
    if tag == 'startIntro' then
        Psych.screenShake(0.3, 0.02)
        Psych.trigger('Flash Camera', '0.4', '0')
    end
end

function onUpdate(elapsed)
    local songPos = getSongPosition()
    local zoomValue = 1 + math.sin(songPos / 500) * 0.01
    Psych.setCameraZoom(zoomValue)
end

function onBeatHit()
    Psych.tweenAlpha('bg', 'bg', 0.8, 0.2, 'linear')
end
