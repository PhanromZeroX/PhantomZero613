function onEvent(name, value1, value2)
    if name == "Change Character" then
        -- Verifica si se debe cambiar el personaje del jugador (BF) o del oponente (Dad)
        if value1 == "0" then
            triggerEvent("Change Character", "bf", value2) -- Cambia el personaje de BF al especificado en value2
        elseif value1 == "1" then
            triggerEvent("Change Character", "dad", value2) -- Cambia el personaje de Dad al especificado en value2
        end
    end
end