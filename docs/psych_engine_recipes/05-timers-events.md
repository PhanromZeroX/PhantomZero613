# Psych Engine Recipe: Timers and Events

This recipe shows timer usage and event-based behavior.

## What it teaches

- `runTimer`
- `onTimerCompleted`
- `triggerEvent`
- `Psych.trigger`
- `Psych.runTimer`

## Example

```lua
function onCreate()
    Psych.runTimer('startBeat', 1)
end

function onTimerCompleted(tag, loops, loopsLeft)
    if tag == 'startBeat' then
        Psych.trigger('Flash Camera', '0.5', '0')
    end
end
```

## Notes

- `runTimer` can repeat if you pass a loops count.
- `onTimerCompleted` receives `loops` and `loopsLeft`.
- Custom events can be used to batch effects and trigger code from Haxe.
