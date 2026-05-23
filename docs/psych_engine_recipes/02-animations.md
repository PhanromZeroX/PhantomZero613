# Psych Engine Recipe: Animations

This recipe shows animated sprite setup and how to play animations.

## What it teaches

- `makeAnimatedLuaSprite`
- `addAnimationByPrefix`
- `objectPlayAnimation`
- `Psych.makeAnimatedSprite`
- `Psych.playAnimation`

## Example

```lua
function onCreate()
    Psych.makeAnimatedSprite('bug', 'enemies/bug', 600, 500, 'fly', 'Bug', 24, true, false, 1, 1, 'game')
end

function onBeatHit()
    Psych.playAnimation('bug', 'fly', true)
end
```

## Notes

- `addAnimationByPrefix` uses the animation prefix in the sprite sheet.
- Many engine mods use animation names like `idle`, `singLEFT`, `singRIGHT`.
- Reuse `Psych.playAnimation` for cleaner code.
