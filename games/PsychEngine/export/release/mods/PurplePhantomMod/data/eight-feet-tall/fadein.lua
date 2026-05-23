function onCreate() --Or onCreatePost()
    makeLuaSprite('FadeName', '')

    makeGraphic('FadeName', 1920, 1080, '000000')

    screenCenter("FadeName")

    setScrollFactor("FadeName", .0, .0)

    addLuaSprite('FadeName', true) --Could make this false and hide all the hud stuff until the song starts if you want the countdown to appear.

    setObjectCamera('FadeName', 'game')

    --setProperty('skipCountdown', true) --Remove the two lines at the start if you want to skip the countdown.
end

function onSongStart()
    doTweenAlpha('FadeAlpha', 'FadeName', 0, 17 / playbackRate, 'linear') --Change your_desired_time to the amount of time you want the fade in to go for.
end
