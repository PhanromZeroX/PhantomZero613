glowApplied = false

function onStartCountdown()
    if not shadersEnabled then
        debugPrint('Glow Arrows: shaders not enabled')
        return
    end

    debugPrint('Glow Arrows: Loading glow shader...')

    runHaxeCode([[
        game.initLuaShader('glow');
    ]])

    makeLuaSprite('glowShader')
    setSpriteShader('glowShader', 'glow')

    -- Apply the glow shader to every strum line note (the 8 arrow receptors)
    runHaxeCode([[
        var glowShader = game.getLuaObject('glowShader').shader;
        for (i in 0...game.strumLineNotes.length) {
            var note = game.strumLineNotes.members[i];
            if (note != null) {
                note.shader = glowShader;
            }
        }
    ]])

-- Medium glow strength
    setShaderFloat('glowShader', 'dim', 0.8)
    setShaderFloat('glowShader', 'size', 3.0)

    glowApplied = true
    debugPrint('Glow Arrows: Applied to all strum notes!')
end
