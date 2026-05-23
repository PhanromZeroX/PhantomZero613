function onEvent(name, value1, value2)
    if name == "Change Scroll Speed" then
        setProperty("scrollSpeed", tonumber(value2))  -- Cambia la velocidad de desplazamiento
    end
end