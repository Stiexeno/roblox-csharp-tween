local EaseMap = {}

local STYLES = {
    "Quad", "Cubic", "Quart", "Quint",
    "Sine", "Exponential", "Circular",
    "Elastic", "Back", "Bounce",
}

local DIRS = {
    Enum.EasingDirection.In,
    Enum.EasingDirection.Out,
    Enum.EasingDirection.InOut,
}

function EaseMap.resolve(ease)
    ease = ease or 0
    if ease == 0 then
        return Enum.EasingStyle.Linear, Enum.EasingDirection.Out
    end
    local idx = ease - 1
    local styleName = STYLES[math.floor(idx / 3) + 1]
    local dir = DIRS[(idx % 3) + 1]
    return Enum.EasingStyle[styleName], dir
end

return EaseMap
