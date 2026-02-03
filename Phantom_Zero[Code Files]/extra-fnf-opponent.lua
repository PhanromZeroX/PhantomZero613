-- This function runs as soon as the mod starts loading
function onCreate()
    -- Create the second character
    -- 'extraOpponent': The nickname for the script
    -- 'mom': The folder name of the character
    -- 100, 100: The X and Y coordinates
    makeCharacter('extraOpponent', 'liruv2', -60, -70); 
    addLuaCharacter('extraOpponent');
end

-- This function runs every time the opponent hits a note
function opponentNoteHit(id, direction, noteType, isSustainNote)
    -- Make the extra character play the correct sing animation
    characterPlayAnim('extraOpponent', getProperty('singAnimations['..direction..']'), true);
    
    -- Reset the timer so they don't get stuck singing
    setProperty('extraOpponent.holdTimer', 0);
end