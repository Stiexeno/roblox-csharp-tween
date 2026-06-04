local EaseFn = {}

local PI = math.pi
local TAU = 2 * PI

local function bounceOut(t)
    if t < 1 / 2.75 then
        return 7.5625 * t * t
    elseif t < 2 / 2.75 then
        t = t - 1.5 / 2.75
        return 7.5625 * t * t + 0.75
    elseif t < 2.5 / 2.75 then
        t = t - 2.25 / 2.75
        return 7.5625 * t * t + 0.9375
    else
        t = t - 2.625 / 2.75
        return 7.5625 * t * t + 0.984375
    end
end

local fns = {
    Linear = function(t) return t end,

    InQuad = function(t) return t * t end,
    OutQuad = function(t) return 1 - (1 - t) ^ 2 end,
    InOutQuad = function(t) return t < 0.5 and 2 * t * t or 1 - (-2 * t + 2) ^ 2 / 2 end,

    InCubic = function(t) return t ^ 3 end,
    OutCubic = function(t) return 1 - (1 - t) ^ 3 end,
    InOutCubic = function(t) return t < 0.5 and 4 * t ^ 3 or 1 - (-2 * t + 2) ^ 3 / 2 end,

    InQuart = function(t) return t ^ 4 end,
    OutQuart = function(t) return 1 - (1 - t) ^ 4 end,
    InOutQuart = function(t) return t < 0.5 and 8 * t ^ 4 or 1 - (-2 * t + 2) ^ 4 / 2 end,

    InQuint = function(t) return t ^ 5 end,
    OutQuint = function(t) return 1 - (1 - t) ^ 5 end,
    InOutQuint = function(t) return t < 0.5 and 16 * t ^ 5 or 1 - (-2 * t + 2) ^ 5 / 2 end,

    InSine = function(t) return 1 - math.cos(t * PI / 2) end,
    OutSine = function(t) return math.sin(t * PI / 2) end,
    InOutSine = function(t) return -(math.cos(PI * t) - 1) / 2 end,

    InExpo = function(t) return t == 0 and 0 or 2 ^ (10 * t - 10) end,
    OutExpo = function(t) return t == 1 and 1 or 1 - 2 ^ (-10 * t) end,
    InOutExpo = function(t)
        if t == 0 then return 0 end
        if t == 1 then return 1 end
        if t < 0.5 then return 2 ^ (20 * t - 10) / 2 end
        return (2 - 2 ^ (-20 * t + 10)) / 2
    end,

    InCirc = function(t) return 1 - math.sqrt(1 - t ^ 2) end,
    OutCirc = function(t) return math.sqrt(1 - (t - 1) ^ 2) end,
    InOutCirc = function(t)
        if t < 0.5 then return (1 - math.sqrt(1 - (2 * t) ^ 2)) / 2 end
        return (math.sqrt(1 - (-2 * t + 2) ^ 2) + 1) / 2
    end,

    InElastic = function(t)
        if t == 0 then return 0 end
        if t == 1 then return 1 end
        return -(2 ^ (10 * t - 10)) * math.sin((t * 10 - 10.75) * TAU / 3)
    end,
    OutElastic = function(t)
        if t == 0 then return 0 end
        if t == 1 then return 1 end
        return 2 ^ (-10 * t) * math.sin((t * 10 - 0.75) * TAU / 3) + 1
    end,
    InOutElastic = function(t)
        if t == 0 then return 0 end
        if t == 1 then return 1 end
        if t < 0.5 then return -(2 ^ (20 * t - 10) * math.sin((20 * t - 11.125) * TAU / 4.5)) / 2 end
        return (2 ^ (-20 * t + 10) * math.sin((20 * t - 11.125) * TAU / 4.5)) / 2 + 1
    end,

    InBack = function(t) return 2.70158 * t ^ 3 - 1.70158 * t ^ 2 end,
    OutBack = function(t) return 1 + 2.70158 * (t - 1) ^ 3 + 1.70158 * (t - 1) ^ 2 end,
    InOutBack = function(t)
        local c = 1.70158 * 1.525
        if t < 0.5 then return ((2 * t) ^ 2 * ((c + 1) * 2 * t - c)) / 2 end
        return ((2 * t - 2) ^ 2 * ((c + 1) * (2 * t - 2) + c) + 2) / 2
    end,

    InBounce = function(t) return 1 - bounceOut(1 - t) end,
    OutBounce = bounceOut,
    InOutBounce = function(t)
        if t < 0.5 then return (1 - bounceOut(1 - 2 * t)) / 2 end
        return (1 + bounceOut(2 * t - 1)) / 2
    end,
}

local order = {
    "Linear",
    "InQuad", "OutQuad", "InOutQuad",
    "InCubic", "OutCubic", "InOutCubic",
    "InQuart", "OutQuart", "InOutQuart",
    "InQuint", "OutQuint", "InOutQuint",
    "InSine", "OutSine", "InOutSine",
    "InExpo", "OutExpo", "InOutExpo",
    "InCirc", "OutCirc", "InOutCirc",
    "InElastic", "OutElastic", "InOutElastic",
    "InBack", "OutBack", "InOutBack",
    "InBounce", "OutBounce", "InOutBounce",
}

function EaseFn.resolve(ease)
    return fns[order[(ease or 0) + 1]] or fns.Linear
end

return EaseFn
