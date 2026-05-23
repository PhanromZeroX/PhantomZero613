# Psych Engine Recipe: Camera Effects

This recipe shows how to control camera zoom, shake, and HUD visibility.

## What it teaches

- `setProperty('camGame.zoom', value)`
- `setProperty('camHUD.alpha', value)`
- `Psych.setCameraZoom`
- `Psych.screenShake`
- `Psych.setHUDAlpha`

## Example

```lua
function onCreate()
    Psych.setCameraZoom(1)
    Psych.setHUDAlpha(1)
end

function onBeatHit()
    Psych.screenShake(0.2, 0.015)
    Psych.setCameraZoom(1.05)
end
```

## Notes

- Use `camHUD.alpha` to hide UI during special effects.
- `Psych.screenShake` triggers built-in screen shake via events.
- Keep camera zoom small to avoid disorienting players.
