# Psych Engine Recipe: Sprite Setup

This recipe shows how to create stage sprites, place them, scale them, and set camera layers.

## What it teaches

- `makeLuaSprite`
- `addLuaSprite`
- `scaleObject`
- `setObjectCamera`
- `Psych.makeSprite`

## Example

```lua
function onCreate()
    Psych.makeSprite('bg', 'stage/background', -400, -200, false, 1.1, 1.1, 'game')
    Psych.makeSprite('overlay', '', 0, 0, true, 1, 1, 'other')
    Psych.makeOverlay('fade', 1280, 720, '000000', 1, 'other')
end
```

## Notes

- Use `game` camera for stage objects and `other` camera for UI overlays.
- `scaleObject` lets you resize sprites without changing the source image.
- `Psych.makeSprite` wraps repeated setup steps.
