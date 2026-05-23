vhsApplied = false

function onStartCountdown()
    if not shadersEnabled then
        debugPrint('VHS: shadersEnabled is false, skipping')
        return
    end

    if songPath ~= 'cataclysm' then
        debugPrint('VHS: song is not cataclysm, skipping')
        return
    end

    debugPrint('VHS: Loading shader...')

    -- Try to init shader safely
    local success = pcall(function()
        runHaxeCode([[
            try {
                game.initLuaShader('vhs');
                setVar('vhs_init_ok', true);
            } catch(e) {
                setVar('vhs_init_ok', false);
                trace('VHS init failed: ' + e);
            }
        ]])
    end)

    if not success or not getVar('vhs_init_ok') then
        debugPrint('VHS: Shader init failed! Aborting.')
        return
    end

    -- Create sprite and attach shader
    makeLuaSprite('vhsShader')
    setSpriteShader('vhsShader', 'vhs')

    -- Safely apply to camera with try-catch
    runHaxeCode([[
        try {
            var spr = game.getLuaObject("vhsShader");
            if (spr == null || spr.shader == null) {
                trace('VHS: sprite or shader is null');
                setVar('vhs_filter_ok', false);
            } else {
                var vhsFilter = new ShaderFilter(spr.shader);
                game.camGame.setFilters([vhsFilter]);
                setVar('vhs_filter_ok', true);
                trace('VHS: Filter applied to camGame');
            }
        } catch(e) {
            trace('VHS: Filter apply failed: ' + e);
            setVar('vhs_filter_ok', false);
        }
    ]])

    if not getVar('vhs_filter_ok') then
        debugPrint('VHS: Could not apply filter! Aborting.')
        return
    end

    -- Set uniforms
    setShaderFloat('vhsShader', 'time', 0)
    setShaderFloat('vhsShader', 'noiseIntensity', 0.02)
    setShaderFloat('vhsShader', 'colorOffsetIntensity', 0.5)

    vhsApplied = true
    debugPrint('VHS: Shader applied successfully!')
end

function onUpdatePost(elapsed)
    if vhsApplied then
        setShaderFloat('vhsShader', 'time', getSongPosition() / 1000)
    end
end

