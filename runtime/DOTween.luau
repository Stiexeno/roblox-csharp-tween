local Tween = require(script.Parent.Tween)
local Sequence = require(script.Parent.Sequence)
local Registry = require(script.Parent.Registry)

local DOTween = {}

function DOTween.To(getter, setter, endValue, duration)
    return Tween.new("custom", {
        getter = getter,
        setter = setter,
        endValue = endValue,
        duration = duration,
    })
end

function DOTween.Property(target, property, endValue, duration)
    return Tween.new("property", {
        target = target,
        property = property,
        endValue = endValue,
        duration = duration,
    })
end

function DOTween.Sequence()
    return Sequence.new()
end

function DOTween.KillAll()
    for tween in pairs(Registry.all()) do tween:Kill() end
end

function DOTween.PauseAll()
    for tween in pairs(Registry.all()) do tween:Pause() end
end

function DOTween.ResumeAll()
    for tween in pairs(Registry.all()) do tween:Resume() end
end

return DOTween
