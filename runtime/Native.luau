local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local EaseMap = require(script.Parent.EaseMap)

local Native = {}

function Native.start(tween)
    local p = tween._params
    local style, direction = EaseMap.resolve(tween._ease)
    local info = TweenInfo.new(
        p.duration,
        style,
        direction,
        tween._loops > 0 and tween._loops or 0,
        tween._loopType == 1,
        tween._delay or 0
    )
    local native = TweenService:Create(p.target, info, { [p.property] = p.endValue })
    local handle = {}
    local hb

    local conn = native.Completed:Connect(function(state)
        if state == Enum.PlaybackState.Completed then
            tween:_finish("completed")
        end
    end)

    if tween._cb.update then
        hb = RunService.Heartbeat:Connect(function()
            if tween._state == "playing" then tween._cb.update() end
        end)
    end

    function handle.pause() native:Pause() end
    function handle.resume() native:Play() end
    function handle.stop()
        native:Cancel()
        conn:Disconnect()
        if hb then hb:Disconnect() end
    end
    function handle.complete()
        native:Cancel()
        pcall(function() p.target[p.property] = p.endValue end)
    end

    native:Play()
    return handle
end

return Native
