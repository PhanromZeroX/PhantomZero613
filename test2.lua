function onStartCountdown()
    if not ShadersEnabled then
        debugPrint('Glow Characters: shaders not enabled')
        return

runHaxeCode([[
    game.initLuaShader('glow');
]])

