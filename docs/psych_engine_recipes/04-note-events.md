# Psych Engine Recipe: Note Events

This recipe shows how to react to note hits and misses in Lua.

## What it teaches

- `opponentNoteHit`
- `goodNoteHit`
- `noteMiss`
- `Psych.setProp`
- `Psych.trigger`

## Example

```lua
function goodNoteHit(id, noteData, noteType, isSustainNote)
    Psych.trigger('Add Camera Zoom', '0.05', '0')
end

function opponentNoteHit(id, noteData, noteType, isSustainNote)
    Psych.screenShake(0.1, 0.01)
end

function noteMiss(id, noteData, noteType, isSustainNote)
    Psych.setProp('health', getProperty('health') - 0.05)
end
```

## Notes

- `noteData` is the note direction (0=left, 1=down, 2=up, 3=right).
- Use `noteType` to handle special notes.
- `isSustainNote` is true for hold notes.
